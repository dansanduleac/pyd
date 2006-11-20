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
module pyd.func_wrap;

private {
    import python;

    import pyd.class_wrap;
    import pyd.dg_convert;
    import pyd.exception;
    import pyd.make_object;

    import meta.Default;
    import meta.Nameof;

    import std.string;
    import std.traits;
}

// Builds a Python callable object from a delegate or function pointer.
PyObject* DPyFunc_FromDG(T) (T dg) {
    alias wrapped_class_type!(T) type;
    alias wrapped_class_object!(T) obj;
    if (!is_wrapped!(T)) {
        type.ob_type = PyType_Type_p;
        type.tp_new       = &wrapped_methods!(T).wrapped_new;
        type.tp_dealloc   = &wrapped_methods!(T).wrapped_dealloc;
        type.tp_basicsize = obj.sizeof;
        type.tp_name = "DPyFunc";
        type.tp_call = &wrapped_func_call!(T).call;
        PyType_Ready(&type);
        is_wrapped!(T) = true;
        wrapped_classes[typeid(T)] = true;
    }
    obj* func = cast(obj*)type.tp_new(&type, null, null);
    func.d_obj = dg;
    wrap_class_instances!(T)[dg]++;
    return cast(PyObject*)func;
}

void setWrongArgsError(int gotArgs, uint minArgs, uint maxArgs, char[] funcName="") {
    char[] str;
    if (funcName == "") {
        str ~= "function takes ";
    } else {
        str ~= funcName ~ "() takes ";
    }

    char[] argStr(int args) {
        char[] temp = toString(args) ~ " argument";
        if (args > 1) {
            temp ~= "s";
        }
        return temp;
    }

    if (minArgs == maxArgs) {
        if (minArgs == 0) {
            str ~= "no arguments";
        } else {
            str ~= "exactly " ~ argStr(minArgs);
        }
    }
    else if (gotArgs < minArgs) {
        str ~= "at least " ~ argStr(minArgs);
    } else {
        str ~= "at most " ~ argStr(maxArgs);
    }
    str ~= " (" ~ toString(gotArgs) ~ " given)";

    PyErr_SetString(PyExc_TypeError, str ~ \0);
}

// Calls the passed function with the passed Python tuple.
ReturnType!(fn_t) py_call(fn_t, PY)(fn_t fn, PY* args) {
    alias ParameterTypeTuple!(fn_t) T;
    const uint MAX_ARGS = T.length;
    alias ReturnType!(fn_t) RT;

    int ARGS = 0;
    // This can make it more convenient to call this with 0 args.
    if (args !is null) {
        ARGS = PyObject_Length(args);
    }

    // Sanity check!
    if (ARGS != MAX_ARGS) {
        setWrongArgsError(ARGS, MAX_ARGS, MAX_ARGS);
        handle_exception();
    }

    T t;
    foreach(i, arg; t) {
        t[i] = d_type!(typeof(arg))(PyTuple_GetItem(args, i));
    }

    static if (is(RT == void)) {
        fn(t);
        return;
    } else {
        return fn(t);
    }
}

template wrapped_func_call(fn_t) {
    alias ReturnType!(fn_t) RT;
    // The entry for the tp_call slot of the DPyFunc types.
    // (Or: What gets called when you pass a delegate or function pointer to
    // Python.)
    extern(C)
    PyObject* call(PyObject* self, PyObject* args, PyObject* kwds) {
        if (self is null) {
            PyErr_SetString(PyExc_TypeError, "Wrapped method didn't get a function pointer.");
            return null;
        }

        fn_t fn = (cast(wrapped_class_object!(fn_t)*)self).d_obj;

        return exception_catcher({
            static if (is(RT == void)) {
                py_call(fn, args);
                Py_INCREF(Py_None);
                return Py_None;
            } else {
                return _py( py_call(fn, args) );
            }
        });
    }
}

// This is a handy shortcut that allows us to wrap a function alias directly
// with a PyCFunction.
template func_wrap(alias real_fn, uint MIN_ARGS, C=void, fn_t=typeof(&real_fn)) {
    alias ParameterTypeTuple!(fn_t) Info;
    const uint MAX_ARGS = Info.length;
    alias ReturnType!(fn_t) RT;

    // Wraps py_call to return a PyObject*
    PyObject* py_py_call(fn_t, PY)(fn_t fn, PY* args) {
        static if (is(RT == void)) {
            py_call(fn, args);
            Py_INCREF(Py_None);
            return Py_None;
        } else {
            return _py( py_call(fn, args) );
        }
    }

    // Calls py_py_call with the proper function contained in a tuple
    // returned from tuples.func_range.
    PyObject* tuple_py_call(PY, T ...)(PY* args, T t) {
        int argCount = 0;
        if (args !is null)
            argCount = PyObject_Length(args);
        
        static if (MIN_ARGS == 0) {
            if (argCount == 0)
                return py_py_call(&firstArgs!(real_fn, 0, fn_t), args);
        }
        foreach (i, arg; t) {
            if (ParameterTypeTuple!(typeof(arg)).length == argCount) {
                return py_py_call(arg, args);
            }
        }
    }

    extern (C)
    PyObject* func(PyObject* self, PyObject* args) {
        // For some reason, D can't infer the return type of this function
        // literal...
        return exception_catcher(delegate PyObject*() {
            // If C is specified, then this is a method call. We need to pull out
            // the object in self and turn the member function alias real_fn
            // into a delegate. This conversion is done with a dirty hack; see
            // dg_convert.d.
            static if (!is(C == void)) {
                static assert (MIN_ARGS == MAX_ARGS, "Default arguments with member functions are not supported.");
                // Didn't pass a "self" parameter! Ack!
                if (self is null) {
                    PyErr_SetString(PyExc_TypeError, "Wrapped method didn't get a 'self' parameter.");
                    return null;
                }
                C instance = (cast(wrapped_class_object!(C)*)self).d_obj;
                fn_to_dg!(fn_t) fn = dg_wrapper!(C, fn_t)(instance, &real_fn);
                static if (is(ReturnType!(typeof(fn)) == void)) {
                    py_call(fn, args);
                    Py_INCREF(Py_None);
                    return Py_None;
                } else {
                    return _py( py_call(fn, args) );
                }
            // If C is not specified, then this is just a normal function call.
            } else {
                alias defaultsTupleT!(real_fn, MIN_ARGS, fn_t).type T;
                T t;
                defaultsTuple!(real_fn, MIN_ARGS, fn_t)(delegate void(T tu) {
                    foreach(i, arg; tu) {
                        t[i] = arg;
                    }
                });
                return tuple_py_call(args, t);
            }
        });
    }
}

//-----------------------------------------------------------------------------
// And now the reverse operation: wrapping a Python callable with a delegate.
// These rely on a whole collection of nasty templates, but the result is both
// flexible and pretty fast.
// (Sadly, wrapping a Python callable with a regular function is not quite
// possible.)
//-----------------------------------------------------------------------------
// The steps involved when calling this function are as follows:
// 1) An instance of DPyWrappedFunc is made, and the callable placed within.
// 2) The delegate type Dg is broken into its constituent parts.
// 3) These parts are used to get the proper overload of DPyWrappedFunc.fn
// 4) A delegate to DPyWrappedFunc.fn is returned.
// 5) When fn is called, it attempts to cram the arguments into the callable.
//    If Python objects to this, an exception is raised. Note that this means
//    any error in converting the callable to a given delegate can only be
//    detected at runtime.

Dg DPyCallable_AsDelegate(Dg) (PyObject* c) {
    return _pycallable_asdgT!(Dg).func(c);
}

private template _pycallable_asdgT(Dg) {
    alias ParameterTypeTuple!(Dg) Info;
    alias ReturnType!(Dg) Tr;

    Dg func(PyObject* c) {
        auto f = new DPyWrappedFunc(c);

        return &f.fn!(Tr, Info);
    }
}

private
class DPyWrappedFunc {
    PyObject* callable;

    this(PyObject* c) { callable = c; Py_INCREF(c); }
    ~this() { Py_DECREF(callable); }

    Tr fn(Tr, T ...) (T t) {
        PyObject* ret = call(t);
        if (ret is null) handle_exception();
        scope(exit) Py_DECREF(ret);
        return d_type!(Tr)(ret);
    }

    PyObject* call(T ...) (T t) {
        const uint ARGS = T.length;

        PyObject* pyt = PyTuple_New(ARGS);
        if (pyt is null) return null;
        scope(exit) Py_DECREF(pyt);

        foreach(i, arg; t) {
            PyTuple_SetItem(pyt, i, _py(arg));
        }
        return PyObject_CallObject(callable, pyt);
    }
}
