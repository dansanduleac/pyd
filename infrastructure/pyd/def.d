/*
Copyright (c) 2006 Kirk McDonald

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module pyd.def;

private import python;
private import pyd.make_object;
private import pyd.object;
private import pyd.ftype;
private import pyd.exception;
private import pyd.dg_convert;
private import pyd.class_wrap;
private import std.string;

private
PyMethodDef module_global_methods[] = [
    { null, null, 0, null }
];

private
PyObject* m_module;

PyObject* DPy_Module_p() {
    return m_module;
}

/**
 * Wraps a D function, making it callable from Python.
 *
 * Params:
 *      name = The name of the function as it will appear in Python.
 *      fn   = The function to wrap.
 *      MIN_ARGS = The minimum number of arguments this function can accept.
 *                 For use with functions with default arguments. Defaults to
 *                 the maximum number of arguments this function supports.
 *      fn_t = The function type of the function to wrap. This must be
 *             specified if more than one function shares the same name,
 *             otherwise the first one defined lexically will be used.
 *
 * Examples:
 *$(D_CODE import pyd.pyd;
 *char[] foo(int i) {
 *    if (i > 10) {
 *        return "It's greater than 10!";
 *    } else {
 *        return "It's less than 10!";
 *    }
 *}
 *extern (C)
 *export void inittestdll() {
 *    _def!("foo", foo);
 *    module_init("testdll");
 *})
 * And in Python:
 *$(D_CODE >>> import testdll
 *>>> print testdll.foo(20)
 *It's greater than 10!)
 */
template def(char[] name, alias fn, uint MIN_ARGS = NumberOfArgs!(typeof(&fn)), fn_t=typeof(&fn)) {
    void def() {
        static PyMethodDef empty = { null, null, 0, null };
        module_global_methods[length-1].ml_name = name ~ \0;
        module_global_methods[length-1].ml_meth =
            cast(PyCFunction)&func_wrap!(fn, MIN_ARGS, void, fn_t).func;
        module_global_methods[length-1].ml_flags = METH_VARARGS;
        module_global_methods[length-1].ml_doc = "";
        module_global_methods ~= empty;
    }
}

/**
 * Module initialization function. Should be called after the last call to def.
 */
PyObject* module_init(char[] name) {
    //_loadPythonSupport();
    m_module = Py_InitModule(name ~ \0, module_global_methods);
    return m_module;
}

template func_wrap(alias real_fn, uint MIN_ARGS, C=void, fn_t=typeof(&real_fn)) {
    //typeof(&r_fn) fn = &r_fn;
    //alias typeof(&real_fn) fn_t;
    const uint MAX_ARGS = NumberOfArgs!(fn_t);
    alias ReturnType!(fn_t) RetType;
    extern (C)
    PyObject* func(PyObject* self, PyObject* args) {
        PyObject* ret;

        // If C is specified, then this is a method call. We need to pull out
        // the object in self and turn the member function pointer in real_fn
        // into a delegate. This conversion is done with a dirty hack; see
        // dg_convert.d.
        static if (!is(C == void)) {
            // Didn't pass a "self" parameter! Ack!
            if (self is null) {
                PyErr_SetString(PyExc_TypeError, "Wrapped method didn't get a 'self' parameter.");
                return null;
            }
            C instance = (cast(wrapped_class_object!(C)*)self).d_obj;
            fn_to_dg!(fn_t) fn = dg_wrapper!(C, fn_t)(instance, &real_fn);
        // If C is not specified, then this is just a normal function call.
        } else {
            fn_t fn = &real_fn;
        }

        // Sanity check!
        int ARGS = 0;
        // This can make it more convenient to call this with 0 args.
        if (args !is null)
            ARGS = PyObject_Length(args);
        if (ARGS < MIN_ARGS || ARGS > MAX_ARGS) {
            PyErr_SetString(PyExc_TypeError, "Wrong number of arguments. Got " ~ toString(ARGS) ~ ", expected between " ~ toString(MIN_ARGS) ~ "-" ~ toString(MAX_ARGS) ~ " args.");
            return null;
        }
        
        try { /* begin try */
        
        static if (MIN_ARGS <= 0 && MAX_ARGS >= 0) {
            if (ARGS == 0) {
                // If the return type is void...
                static if (is(RetType : void)) {
                    fn();
                    // Return Py_None
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    // Otherwise, return a conversion of the return value
                    ret = _py( fn() );
                }
            }
        } static if (MIN_ARGS <= 1 && MAX_ARGS >= 1) {
            if (ARGS == 1) {
                // See, this ugly code works like this:
                // (1) _py takes the return type of the wrapped function, and
                // converts it to a PyObject*, which is passed straight back into
                // Python.
                // (2) fn is the wrapped function. Each of its arguments take the
                // form:
                // (3) d_type is a template function. It converts a PyObject* into
                // a reasonable D type. The template argument is the type to
                // convert to. The function argument is the PyObject* to convert.
                // (4) ArgType derives the type of an argument to the function. It
                // (therefore) is used to pass the correct type into d_type's
                // template argument.
                // This pattern is repeated umpteen times, as each number of
                // function arguments requires its own statement TWICE, as void
                // return types must be handled differently.
                static if (is(RetType : void)) {
                    // Call with void return type
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0))
                    );
                    // Return Py_None
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    // Capture return value
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 2 && MAX_ARGS >= 2) {
            if (ARGS == 2) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 3 && MAX_ARGS >= 3) {
            if (ARGS == 3) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 4 && MAX_ARGS >= 4) {
            if (ARGS == 4) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 5 && MAX_ARGS >= 5) {
            if (ARGS == 5) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 6 && MAX_ARGS >= 6) {
            if (ARGS == 6) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 7 && MAX_ARGS >= 7) {
            if (ARGS == 7) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 8 && MAX_ARGS >= 8) {
            if (ARGS == 8) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 9 && MAX_ARGS >= 9) {
            if (ARGS == 9) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7)),
                        d_type!(ArgType!(fn_t, 9))(PyTuple_GetItem(args, 8))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7)),
                        d_type!(ArgType!(fn_t, 9))(PyTuple_GetItem(args, 8))
                    ) );
                }
            }
        } static if (MIN_ARGS <= 10 && MAX_ARGS >= 10) {
            if (ARGS == 10) {
                static if (is(RetType : void)) {
                    fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7)),
                        d_type!(ArgType!(fn_t, 9))(PyTuple_GetItem(args, 8)),
                        d_type!(ArgType!(fn_t, 10))(PyTuple_GetItem(args, 9))
                    );
                    Py_INCREF(Py_None);
                    ret = Py_None;
                } else {
                    ret = _py( fn(
                        d_type!(ArgType!(fn_t, 1))(PyTuple_GetItem(args, 0)),
                        d_type!(ArgType!(fn_t, 2))(PyTuple_GetItem(args, 1)),
                        d_type!(ArgType!(fn_t, 3))(PyTuple_GetItem(args, 2)),
                        d_type!(ArgType!(fn_t, 4))(PyTuple_GetItem(args, 3)),
                        d_type!(ArgType!(fn_t, 5))(PyTuple_GetItem(args, 4)),
                        d_type!(ArgType!(fn_t, 6))(PyTuple_GetItem(args, 5)),
                        d_type!(ArgType!(fn_t, 7))(PyTuple_GetItem(args, 6)),
                        d_type!(ArgType!(fn_t, 8))(PyTuple_GetItem(args, 7)),
                        d_type!(ArgType!(fn_t, 9))(PyTuple_GetItem(args, 8)),
                        d_type!(ArgType!(fn_t, 10))(PyTuple_GetItem(args, 9))
                    ) );
                }
            }
        }
        
        } /* end try */
        // A Python exception was raised and duly re-thrown as a D exception.
        // It should now be re-raised as a Python exception.
        catch (PythonException e) {
            PyErr_Restore(e.type(), e.value(), e.traceback());
            return null;
        }
        // A D exception was raised and should be translated into a meaningful
        // Python exception.
        catch (Exception e) {
            PyErr_SetString(PyExc_RuntimeError, "D Exception: " ~ e.classinfo.name ~ ": " ~ e.msg ~ \0);
            return null;
        }
        return ret;
    }
}

