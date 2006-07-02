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
module pyd.ctor_wrap;

private import python;
private import pyd.class_wrap;
private import pyd.exception;
private import pyd.make_object;

/**
 * This template defines the footprint of an individual constructor.
 */
template ctor(T1=void, T2=void, T3=void, T4=void, T5=void, T6=void, T7=void, T8=void, T9=void, T10=void) {
    static if (!is(T10 == void))
        const uint ARGS = 10;
    else static if(!is(T9 == void))
        const uint ARGS = 9;
    else static if(!is(T8 == void))
        const uint ARGS = 8;
    else static if(!is(T7 == void))
        const uint ARGS = 7;
    else static if(!is(T6 == void))
        const uint ARGS = 6;
    else static if(!is(T5 == void))
        const uint ARGS = 5;
    else static if(!is(T4 == void))
        const uint ARGS = 4;
    else static if(!is(T3 == void))
        const uint ARGS = 3;
    else static if(!is(T2 == void))
        const uint ARGS = 2;
    else static if(!is(T1 == void))
        const uint ARGS = 1;
    else
        const uint ARGS = 0;
    alias T1 arg1;
    alias T2 arg2;
    alias T3 arg3;
    alias T4 arg4;
    alias T5 arg5;
    alias T6 arg6;
    alias T7 arg7;
    alias T8 arg8;
    alias T9 arg9;
    alias T10 arg10;
}

struct dummy { }
alias ctor!(dummy) undefined;

// This template wraps an individual call to a constructor
template wrapped_ctor(T, alias Ctor) {
    int wrapped_ctor(PyObject* self, PyObject* args, PyObject* kwds) {
        T t;

        try { /* begin try */

        static if (Ctor.ARGS == 1) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0))
            );
        } else static if (Ctor.ARGS == 2) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1))
            );
        } else static if (Ctor.ARGS == 3) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2))
            );
        } else static if (Ctor.ARGS == 4) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3))
            );
        } else static if (Ctor.ARGS == 5) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4))
            );
        } else static if (Ctor.ARGS == 6) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4)),
                d_type!(Ctor.arg6)(PyTuple_GetItem(args, 5))
            );
        } else static if (Ctor.ARGS == 7) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4)),
                d_type!(Ctor.arg6)(PyTuple_GetItem(args, 5)),
                d_type!(Ctor.arg7)(PyTuple_GetItem(args, 6))
            );
        } else static if (Ctor.ARGS == 8) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4)),
                d_type!(Ctor.arg6)(PyTuple_GetItem(args, 5)),
                d_type!(Ctor.arg7)(PyTuple_GetItem(args, 6)),
                d_type!(Ctor.arg8)(PyTuple_GetItem(args, 7))
            );
        } else static if (Ctor.ARGS == 9) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4)),
                d_type!(Ctor.arg6)(PyTuple_GetItem(args, 5)),
                d_type!(Ctor.arg7)(PyTuple_GetItem(args, 6)),
                d_type!(Ctor.arg8)(PyTuple_GetItem(args, 7)),
                d_type!(Ctor.arg9)(PyTuple_GetItem(args, 8))
            );
        } else static if (Ctor.ARGS == 10) {
            t = new T(
                d_type!(Ctor.arg1)(PyTuple_GetItem(args, 0)),
                d_type!(Ctor.arg2)(PyTuple_GetItem(args, 1)),
                d_type!(Ctor.arg3)(PyTuple_GetItem(args, 2)),
                d_type!(Ctor.arg4)(PyTuple_GetItem(args, 3)),
                d_type!(Ctor.arg5)(PyTuple_GetItem(args, 4)),
                d_type!(Ctor.arg6)(PyTuple_GetItem(args, 5)),
                d_type!(Ctor.arg7)(PyTuple_GetItem(args, 6)),
                d_type!(Ctor.arg8)(PyTuple_GetItem(args, 7)),
                d_type!(Ctor.arg9)(PyTuple_GetItem(args, 8)),
                d_type!(Ctor.arg10)(PyTuple_GetItem(args, 9))
            );
        }

        } /* end try */

        // A Python exception was raised and duly re-thrown as a D exception.
        // It should now be re-raised as a Python exception.
        catch (PythonException e) {
            PyErr_Restore(e.type(), e.value(), e.traceback());
            return -1;
        }
        // A D exception was raised and should be translated into a meaningful
        // Python exception.
        catch (Exception e) {
            PyErr_SetString(PyExc_RuntimeError, "D Exception: " ~ e.classinfo.name ~ ": " ~ e.msg ~ \0);
            return -1;
        }

        (cast(wrapped_class_object!(T)*)self).d_obj = t;
        wrap_class_instances!(T)[t] = 1;

        return 0;
    }
}

// This template accepts a list of "ctor" templates and uses them to wrap a Python __init__ function.
template wrapped_ctors(T, alias C1, alias C2, alias C3, alias C4, alias C5, alias C6, alias C7, alias C8, alias C9, alias C10) {
    alias wrapped_class_object!(T) wrap_object;
    static if (!is(C10.arg1 == dummy))
        const uint ARGS = 10;
    else static if(!is(C9.arg1 == dummy))
        const uint ARGS = 9;
    else static if(!is(C8.arg1 == dummy))
        const uint ARGS = 8;
    else static if(!is(C7.arg1 == dummy))
        const uint ARGS = 7;
    else static if(!is(C6.arg1 == dummy))
        const uint ARGS = 6;
    else static if(!is(C5.arg1 == dummy))
        const uint ARGS = 5;
    else static if(!is(C4.arg1 == dummy))
        const uint ARGS = 4;
    else static if(!is(C3.arg1 == dummy))
        const uint ARGS = 3;
    else static if(!is(C2.arg1 == dummy))
        const uint ARGS = 2;
    else static if(!is(C1.arg1 == dummy))
        const uint ARGS = 1;
    else
        const uint ARGS = 0;
    extern(C)
    int init_func(PyObject* self, PyObject* args, PyObject* kwds) {
        int len = PyObject_Length(args);
        // Default ctor
        static if (is(typeof(new T))) {
            if (len == 0) {
                T t = new T;
                (cast(wrap_object*)self).d_obj = t;
                wrap_class_instances!(T)[t] = 1;
                return 0;
            }
        }
        // We only match the first supplied ctor with the proper number of
        // arguments. (Eventually, we'll do some more sophisticated matching,
        // but this will do for now.)
        static if (ARGS >= 1) {
            if (len == C1.ARGS)
                return wrapped_ctor!(T, C1)(self, args, kwds);
        }
        static if (ARGS >= 2) {
            if (len == C2.ARGS)
                return wrapped_ctor!(T, C2)(self, args, kwds);
        }
        static if (ARGS >= 3) {
            if (len == C3.ARGS)
                return wrapped_ctor!(T, C3)(self, args, kwds);
        }
        static if (ARGS >= 4) {
            if (len == C4.ARGS)
                return wrapped_ctor!(T, C4)(self, args, kwds);
        }
        static if (ARGS >= 5) {
            if (len == C5.ARGS)
                return wrapped_ctor!(T, C5)(self, args, kwds);
        }
        static if (ARGS >= 6) {
            if (len == C6.ARGS)
                return wrapped_ctor!(T, C6)(self, args, kwds);
        }
        static if (ARGS >= 7) {
            if (len == C7.ARGS)
                return wrapped_ctor!(T, C7)(self, args, kwds);
        }
        static if (ARGS >= 8) {
            if (len == C8.ARGS)
                return wrapped_ctor!(T, C8)(self, args, kwds);
        }
        static if (ARGS >= 9) {
            if (len == C9.ARGS)
                return wrapped_ctor!(T, C9)(self, args, kwds);
        }
        static if (ARGS >= 10) {
            if (len == C10.ARGS)
                return wrapped_ctor!(T, C10)(self, args, kwds);
        }
        PyErr_SetString(PyExc_TypeError, "Unsupported number of constructor arguments.");
        return -1;
    }
}

