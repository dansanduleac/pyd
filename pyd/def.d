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
private import std.string, std.stdio;

private
PyMethodDef module_global_methods[] = [
    { null, null, 0, null }
];

/**
 * Wraps a D function, making it callable from Python.
 *
 * For example:
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
 *
 * And in Python:
 *
 *$(D_CODE >>> import testdll
 *>>> print testdll.foo(20)
 *It's greater than 10!)
 */
template def(char[] name, alias fn) {
    void def() {
        static PyMethodDef empty = { null, null, 0, null };
        module_global_methods[length-1].ml_name = name ~ \0;
        module_global_methods[length-1].ml_meth =
            cast(PyCFunction)&func_wrap!(fn).func;
        module_global_methods[length-1].ml_flags = METH_VARARGS;
        module_global_methods[length-1].ml_doc = "";
        module_global_methods ~= empty;
    }
}

/**
 * Module initialization function. Should be called after the last call to def.
 */
void module_init(char[] name) {
    //_loadPythonSupport();
    Py_InitModule(name ~ \0, module_global_methods);
}

template func_wrap(alias fn) {
    //typeof(&r_fn) fn = &r_fn;
    alias typeof(&fn) fn_t;
    const uint ARGS = NumberOfArgs!(fn_t);
    alias ReturnType!(fn_t) RetType;
    extern (C)
    PyObject* func(PyObject* self, PyObject* args) {
        PyObject* ret;

        // Sanity check!
        if (PyObject_Length(args) != ARGS) {
            PyErr_SetString(PyExc_TypeError, "Wrong number of arguments. Got " ~ toString(PyObject_Length(args)) ~ " expected " ~ toString(ARGS) ~ ".");
            return null;
        }
        
        try { /* begin try */
        
        static if (ARGS == 0) {
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
        } else static if (ARGS == 1) {
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
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0))
                );
                // Return Py_None
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                writefln("function type = %s", typeid(typeof(&fn)));
                writefln("ArgType!(fn_t, 1) = %s", typeid(ArgType!(fn_t, 1)));
                // Capture return value
                ret = _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0))
                ) );
            }
        } else static if (ARGS == 2) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1))
                ) );
            }
        } else static if (ARGS == 3) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2))
                ) );
            }
        } else static if (ARGS == 4) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3))
                ) );
            }
        } else static if (ARGS == 5) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4))
                ) );
            }
        } else static if (ARGS == 6) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5))
                ) );
            }
        } else static if (ARGS == 7) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6))
                ) );
            }
        } else static if (ARGS == 8) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7))
                ) );
            }
        } else static if (ARGS == 9) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7)),
                    d_type!(ArgType!(fn_t, 9))(PyTuple_GET_ITEM(args, 8))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7)),
                    d_type!(ArgType!(fn_t, 9))(PyTuple_GET_ITEM(args, 8))
                ) );
            }
        } else static if (ARGS == 10) {
            static if (is(RetType : void)) {
                fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7)),
                    d_type!(ArgType!(fn_t, 9))(PyTuple_GET_ITEM(args, 8)),
                    d_type!(ArgType!(fn_t, 10))(PyTuple_GET_ITEM(args, 9))
                );
                Py_INCREF(Py_None);
                ret = Py_None;
            } else {
                return _py( fn(
                    d_type!(ArgType!(fn_t, 1))(PyTuple_GET_ITEM(args, 0)),
                    d_type!(ArgType!(fn_t, 2))(PyTuple_GET_ITEM(args, 1)),
                    d_type!(ArgType!(fn_t, 3))(PyTuple_GET_ITEM(args, 2)),
                    d_type!(ArgType!(fn_t, 4))(PyTuple_GET_ITEM(args, 3)),
                    d_type!(ArgType!(fn_t, 5))(PyTuple_GET_ITEM(args, 4)),
                    d_type!(ArgType!(fn_t, 6))(PyTuple_GET_ITEM(args, 5)),
                    d_type!(ArgType!(fn_t, 7))(PyTuple_GET_ITEM(args, 6)),
                    d_type!(ArgType!(fn_t, 8))(PyTuple_GET_ITEM(args, 7)),
                    d_type!(ArgType!(fn_t, 9))(PyTuple_GET_ITEM(args, 8)),
                    d_type!(ArgType!(fn_t, 10))(PyTuple_GET_ITEM(args, 9))
                ) );
            }
        } /* end ARGS static ifs */
        
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

