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

    import meta.Tuple;
    import meta.Bind;
    import meta.FuncMeta;
    import meta.Apply;
    import meta.Default;
    import meta.Nameof;

    import std.string;
}

// Builds a Python callable object from a delegate or function pointer.
template DPyFunc_FromDG(T) {
    PyObject* DPyFunc_FromDG(T dg) {
        alias wrapped_class_type!(T) type;
        alias wrapped_class_object!(T) obj;
        if (!is_wrapped!(T)) {
            type.ob_type = PyType_Type_p;
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
}

// Populates the tuple t with converted arguments from the PyTuple args
private void loop(T, uint i = 0) (T* t, PyObject* args) {
    static if (i < T.length) {
        t.val!(i) = d_type!(typeof(t.val!(i)))(PyTuple_GetItem(args, i));
        loop!(T, i+1)(t, args);
    }
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
RetType!(fn_t) py_call(fn_t, PY)(fn_t fn, PY* args) {
    alias funcDelegInfoT!(fn_t) Meta;
    const uint MAX_ARGS = Meta.numArgs;
    alias RetType!(fn_t) RT;

    int ARGS = 0;
    // This can make it more convenient to call this with 0 args.
    if (args !is null) {
        ARGS = PyObject_Length(args);
        //assert(ARGS == MAX_ARGS, "Function called with wrong number of arguments");
    }

    // Sanity check!
    if (ARGS != MAX_ARGS) {
        setWrongArgsError(ARGS, MAX_ARGS, MAX_ARGS);
        handle_exception();
    }

    alias getFuncTuple!(fn_t) T; // tuple type
    T t;

    loop!(T)(&t, args);

    static if (is(RT : void)) {
        apply(fn, t);
        return;
    } else {
        return apply(fn, t);
    }
}

template wrapped_func_call(fn_t) {
    alias funcDelegInfoT!(fn_t) Meta;
    const uint MAX_ARGS = Meta.numArgs;
    alias RetType!(fn_t) RT;
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
        //PyObject* ret;

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
    alias funcDelegInfoT!(fn_t) Meta;
    const uint MAX_ARGS = Meta.numArgs;
    alias RetType!(fn_t) RT;

    // Wraps py_call to return a PyObject*
    PyObject* py_py_call(fn_t, PY)(fn_t fn, PY* args) {
        static if (is(RetType!(fn_t) == void)) {
            py_call(fn, args);
            Py_INCREF(Py_None);
            return Py_None;
        } else {
            return _py( py_call(fn, args) );
        }
    }

    // Loops through the tuple of function pointers until the number of
    // elements in the PyTuple equals the number of arguments accepted by the
    // function pointer. Then, it applies the PyTuple to the function pointer.
    PyObject* loop(T, uint i = 0) (T* t, PyObject* args, int argCount) {
        static if (i == T.length) {
            // This is tripped if the number of args in the passed PyTuple is
            // not matched to a function pointer in the defaultsTuple.
            setWrongArgsError(argCount, MIN_ARGS, MAX_ARGS);
            return null;
        } else {
            alias funcDelegInfoT!(typeof(t.val!(i))) current;
            if (current.numArgs == argCount) {
                return py_py_call(t.val!(i), args);
            }
            return loop!(T, i+1) (t, args, argCount);
        }
    }

    // Calls py_py_call with the proper function contained in a tuple
    // returned from tuples.func_range.
    PyObject* tuple_py_call(Tu, PY)(Tu t, PY* args) {
        int argCount = 0;
        if (args !is null)
            argCount = PyObject_Length(args);
        
        static if (MIN_ARGS == 0) {
            if (argCount == 0)
                return py_py_call(&firstArgs!(real_fn, 0, fn_t), args);
        }
        return loop!(Tu)(&t, args, argCount);
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
                static if (is(RetType!(typeof(fn)) == void)) {
                    py_call(fn, args);
                    Py_INCREF(Py_None);
                    return Py_None;
                } else {
                    return _py( py_call(fn, args) );
                }
            // If C is not specified, then this is just a normal function call.
            } else {
                return tuple_py_call(defaultsTuple!(real_fn, MIN_ARGS, fn_t)(), args);
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
    alias funcDelegInfoT!(Dg) Info;
    const uint ARGS = Info.numArgs;
    alias RetType!(Dg) Tr;

    template A(uint i) {
        alias Info.Meta.ArgType!(i-1) A;
    }

    Dg func(PyObject* c) {
        auto f = new DPyWrappedFunc(c);

        static if (ARGS == 0)
            return &f.fn!(Tr);
        else static if (ARGS == 1)
            return &f.fn!(Tr, A!(1));
        else static if (ARGS == 2)
            return &f.fn!(Tr, A!(1), A!(2));
        else static if (ARGS == 3)
            return &f.fn!(Tr, A!(1), A!(2), A!(3));
        else static if (ARGS == 4)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4));
        else static if (ARGS == 5)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5));
        else static if (ARGS == 6)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5), A!(6));
        else static if (ARGS == 7)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7));
        else static if (ARGS == 8)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8));
        else static if (ARGS == 9)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8), A!(9));
        else static if (ARGS == 10)
            return &f.fn!(Tr, A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8), A!(9), A!(10));
        else static assert(false, "Unsupported number of args in delegate type.");
    }
}

private
class DPyWrappedFunc {
    PyObject* callable;

    this(PyObject* c) { callable = c; Py_INCREF(c); }
    ~this() { Py_DECREF(callable); }
    
    Tr boilerplate(Tr)(PyObject* ret) {
        if (ret is null) handle_exception();
        scope(exit) Py_DECREF(ret);
        return d_type!(Tr)(ret);
    }
    
    Tr fn(Tr)() {
        return boilerplate!(Tr)(call(makeTuple()));
    }
    
    Tr fn(Tr, T1)(T1 t1) {
        return boilerplate!(Tr)(call(makeTuple(t1)));
    }

    Tr fn(Tr, T1, T2)(T1 t1, T2 t2) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2)));
    }

    Tr fn(Tr, T1, T2, T3)(T1 t1, T2 t2, T3 t3) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3)));
    }

    Tr fn(Tr, T1, T2, T3, T4)(T1 t1, T2 t2, T3 t3, T4 t4) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5, t6)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5, t6, t7)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5, t6, t7, t8)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8, T9)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5, t6, t7, t8, t9)));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
        return boilerplate!(Tr)(call(makeTuple(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)));
    }

    void loop(T, uint current)(T* dt, PyObject* pyt) {
        static if (current < T.length) {
            PyTuple_SetItem(pyt, current, _py(dt.val!(current)));
            loop!(T, current+1)(dt, pyt);
        }
    }

    PyObject* call(T) (T dt) {
        const uint ARGS = T.length;

        PyObject* pyt = PyTuple_New(ARGS);
        if (pyt is null) return null;
        scope(exit) Py_DECREF(pyt);

        loop!(T, 0)(&dt, pyt);
        return PyObject_CallObject(callable, pyt);
    }
}
