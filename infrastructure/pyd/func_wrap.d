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

private import python;

private import pyd.class_wrap;
private import pyd.dg_convert;
private import pyd.exception;
private import pyd.ftype;
private import pyd.make_object;
private import pyd.tuples;

private import std.string;

// Builds a Python callable object from a delegate or function pointer.
template DPyFunc_FromDG(T, uint MIN_ARGS=NumberOfArgs!(T)) {
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

// Calls the passed function with the passed Python tuple.
ReturnType!(fn_t) py_call(fn_t, PY)(fn_t fn, PY* args) {
    const uint MAX_ARGS = NumberOfArgs!(fn_t);
    alias ReturnType!(fn_t) RetType;

    int ARGS = 0;
    // This can make it more convenient to call this with 0 args.
    if (args !is null) {
        ARGS = PyObject_Length(args);
        assert(ARGS == MAX_ARGS, "Function called with wrong number of arguments");
    }

    // Sanity check!
    if (ARGS != MAX_ARGS) {
        PyErr_SetString(PyExc_TypeError,
            "Wrong number of arguments. Got " ~
            toString(ARGS) ~
            ", expected " ~
            toString(MAX_ARGS) ~
            " args.");
        handle_exception();
    }

    // I've refactored this to use a tuple rather than the old cascade of
    // variable function calls. There are now 10 calls to d_type where there
    // once were 110.
    alias tuple_from_fn!(fn_t) t_t; // tuple type
    t_t t;

    static if (MAX_ARGS >= 1)
        t.set!(0)(d_type!(t_t.TypeNo!(0))(PyTuple_GetItem(args, 0)));
    static if (MAX_ARGS >= 2)
        t.set!(1)(d_type!(t_t.TypeNo!(1))(PyTuple_GetItem(args, 1)));
    static if (MAX_ARGS >= 3)
        t.set!(2)(d_type!(t_t.TypeNo!(2))(PyTuple_GetItem(args, 2)));
    static if (MAX_ARGS >= 4)
        t.set!(3)(d_type!(t_t.TypeNo!(3))(PyTuple_GetItem(args, 3)));
    static if (MAX_ARGS >= 5)
        t.set!(4)(d_type!(t_t.TypeNo!(4))(PyTuple_GetItem(args, 4)));
    static if (MAX_ARGS >= 6)
        t.set!(5)(d_type!(t_t.TypeNo!(5))(PyTuple_GetItem(args, 5)));
    static if (MAX_ARGS >= 7)
        t.set!(6)(d_type!(t_t.TypeNo!(6))(PyTuple_GetItem(args, 6)));
    static if (MAX_ARGS >= 8)
        t.set!(7)(d_type!(t_t.TypeNo!(7))(PyTuple_GetItem(args, 7)));
    static if (MAX_ARGS >= 9)
        t.set!(8)(d_type!(t_t.TypeNo!(8))(PyTuple_GetItem(args, 8)));
    static if (MAX_ARGS >= 10)
        t.set!(9)(d_type!(t_t.TypeNo!(9))(PyTuple_GetItem(args, 9)));

    static if (is(RetType : void)) {
        apply_tuple_to_fn(t, fn);
        return;
    } else {
        return apply_tuple_to_fn(t, fn);
    }
}

template wrapped_func_call(fn_t) {
    const uint MAX_ARGS = NumberOfArgs!(fn_t);
    alias ReturnType!(fn_t) RetType;
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
            static if (is(RetType == void)) {
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
    const uint MAX_ARGS = NumberOfArgs!(fn_t);
    alias ReturnType!(fn_t) RetType;

    // Wraps py_call to return a PyObject*
    PyObject* py_py_call(fn_t, PY)(fn_t fn, PY* args) {
        static if (is(ReturnType!(fn_t) == void)) {
            py_call(fn, args);
            Py_INCREF(Py_None);
            return Py_None;
        } else {
            return _py( py_call(fn, args) );
        }
    }

    // Calls py_py_call with the proper function contained in a tuple
    // returned from tuples.func_range.
    PyObject* tuple_py_call(Tu, PY)(Tu t, PY* args) {
        int ARGS = 0;
        if (args !is null)
            ARGS = PyObject_Length(args);
        static if (MIN_ARGS == 0) {
            if (ARGS == 0)
                return py_py_call(&partial!(real_fn, 0), args);
        } static if (!is(TypeNo!(Tu, 0) == Void)) {
            if (ARGS == 1)
                return py_py_call(t.get!(0), args);
        } static if (!is(TypeNo!(Tu, 1) == Void)) {
            if (ARGS == 2)
                return py_py_call(t.get!(1), args);
        } static if (!is(TypeNo!(Tu, 2) == Void)) {
            if (ARGS == 3)
                return py_py_call(t.get!(2), args);
        } static if (!is(TypeNo!(Tu, 3) == Void)) {
            if (ARGS == 4)
                return py_py_call(t.get!(3), args);
        } static if (!is(TypeNo!(Tu, 4) == Void)) {
            if (ARGS == 5)
                return py_py_call(t.get!(4), args);
        } static if (!is(TypeNo!(Tu, 5) == Void)) {
            if (ARGS == 6)
                return py_py_call(t.get!(5), args);
        } static if (!is(TypeNo!(Tu, 6) == Void)) {
            if (ARGS == 7)
                return py_py_call(t.get!(6), args);
        } static if (!is(TypeNo!(Tu, 7) == Void)) {
            if (ARGS == 8)
                return py_py_call(t.get!(7), args);
        } static if (!is(TypeNo!(Tu, 8) == Void)) {
            if (ARGS == 9)
                return py_py_call(t.get!(8), args);
        } static if (!is(TypeNo!(Tu, 9) == Void)) {
            if (ARGS == 10)
                return py_py_call(t.get!(9), args);
        }
        PyErr_SetString(PyExc_RuntimeError, "Something happened...");
        return null;
    }

    extern (C)
    PyObject* func(PyObject* self, PyObject* args) {
        // For some reason, D can't infer the return type of this function
        // literal...
        return exception_catcher(delegate PyObject*() {
            // If C is specified, then this is a method call. We need to pull out
            // the object in self and turn the member function pointer in real_fn
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
                return tuple_py_call(func_range!(real_fn, MIN_ARGS)(), args);
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
    auto f = new DPyWrappedFunc(c);

    const uint ARGS = NumberOfArgs!(Dg);
    alias ReturnType!(Dg) Tr;
    static if (ARGS == 0)
        return &f.fn!(Tr);
    else static if (ARGS == 1)
        return &f.fn!(Tr, ArgType!(Dg, 1));
    else static if (ARGS == 2)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2));
    else static if (ARGS == 3)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3));
    else static if (ARGS == 4)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4));
    else static if (ARGS == 5)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5));
    else static if (ARGS == 6)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5), ArgType!(Dg, 6));
    else static if (ARGS == 7)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5), ArgType!(Dg, 6), ArgType!(Dg, 7));
    else static if (ARGS == 8)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5), ArgType!(Dg, 6), ArgType!(Dg, 7), ArgType!(Dg, 8));
    else static if (ARGS == 9)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5), ArgType!(Dg, 6), ArgType!(Dg, 7), ArgType!(Dg, 8), ArgType!(Dg, 9));
    else static if (ARGS == 10)
        return &f.fn!(Tr, ArgType!(Dg, 1), ArgType!(Dg, 2), ArgType!(Dg, 3), ArgType!(Dg, 4), ArgType!(Dg, 5), ArgType!(Dg, 6), ArgType!(Dg, 7), ArgType!(Dg, 8), ArgType!(Dg, 9), ArgType!(Dg, 10));
    else static assert(false, "Unsupported number of args in delegate type.");
}

class Dummy { }

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
        return boilerplate!(Tr)(call());
    }
    
    Tr fn(Tr, T1)(T1 t1) {
        return boilerplate!(Tr)(call(t1));
    }

    Tr fn(Tr, T1, T2)(T1 t1, T2 t2) {
        return boilerplate!(Tr)(call(t1, t2));
    }

    Tr fn(Tr, T1, T2, T3)(T1 t1, T2 t2, T3 t3) {
        return boilerplate!(Tr)(call(t1, t2, t3));
    }

    Tr fn(Tr, T1, T2, T3, T4)(T1 t1, T2 t2, T3 t3, T4 t4) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5, t6));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5, t6, t7));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5, t6, t7, t8));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8, T9)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5, t6, t7, t8, t9));
    }

    Tr fn(Tr, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
        return boilerplate!(Tr)(call(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10));
    }
    
    template call(T1=Dummy, T2=Dummy, T3=Dummy, T4=Dummy, T5=Dummy, T6=Dummy, T7=Dummy, T8=Dummy, T9=Dummy, T10=Dummy) {
        PyObject* call (T1 t1=null, T2 t2=null, T3 t3=null, T4 t4=null, T5 t5=null, T6 t6=null, T7 t7=null, T8 t8=null, T9 t9=null, T10 t10=null) {
            static if (!is(T10 == Dummy))
                const uint ARGS = 10;
            else static if (!is(T9 == Dummy))
                const uint ARGS = 9;
            else static if (!is(T8 == Dummy))
                const uint ARGS = 8;
            else static if (!is(T7 == Dummy))
                const uint ARGS = 7;
            else static if (!is(T6 == Dummy))
                const uint ARGS = 6;
            else static if (!is(T5 == Dummy))
                const uint ARGS = 5;
            else static if (!is(T4 == Dummy))
                const uint ARGS = 4;
            else static if (!is(T3 == Dummy))
                const uint ARGS = 3;
            else static if (!is(T2 == Dummy))
                const uint ARGS = 2;
            else static if (!is(T1 == Dummy))
                const uint ARGS = 1;
            else
                const uint ARGS = 0;
            PyObject* t = PyTuple_New(ARGS);
            if (t is null) return null;
            scope(exit) Py_DECREF(t);
            static if (!is(T10 == Dummy))
                PyTuple_SetItem(t, 9, _py(t10));
            static if (!is(T9 == Dummy))
                PyTuple_SetItem(t, 8, _py(t9));
            static if (!is(T8 == Dummy))
                PyTuple_SetItem(t, 7, _py(t8));
            static if (!is(T7 == Dummy))
                PyTuple_SetItem(t, 6, _py(t7));
            static if (!is(T6 == Dummy))
                PyTuple_SetItem(t, 5, _py(t6));
            static if (!is(T5 == Dummy))
                PyTuple_SetItem(t, 4, _py(t5));
            static if (!is(T4 == Dummy))
                PyTuple_SetItem(t, 3, _py(t4));
            static if (!is(T3 == Dummy))
                PyTuple_SetItem(t, 2, _py(t3));
            static if (!is(T2 == Dummy))
                PyTuple_SetItem(t, 1, _py(t2));
            static if (!is(T1 == Dummy))
                PyTuple_SetItem(t, 0, _py(t1));
            return PyObject_CallObject(callable, t);
        }
    }
}
