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
private import pyd.func_wrap;
private import pyd.make_object;

private import meta.Tuple;
private import meta.Bind;
private import meta.Instantiate;

template ctor_redirect(T) {
    T call_ctor()() {
        return new T();
    }
    
    T call_ctor(T1)(T1 t1) {
        return new T(t1);
    }
    
    T call_ctor(T1, T2)(T1 t1, T2 t2) {
        return new T(t1, t2);
    }
    
    T call_ctor(T1, T2, T3)(T1 t1, T2 t2, T3 t3) {
        return new T(t1, t2, t3);
    }
    
    T call_ctor(T1, T2, T3, T4)(T1 t1, T2 t2, T3 t3, T4 t4) {
        return new T(t1, t2, t3, t4);
    }
    
    T call_ctor(T1, T2, T3, T4, T5)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
        return new T(t1, t2, t3, t4, t5);
    }
    
    T call_ctor(T1, T2, T3, T4, T5, T6)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
        return new T(t1, t2, t3, t4, t5, t6);
    }
    
    T call_ctor(T1, T2, T3, T4, T5, T6, T7)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
        return new T(t1, t2, t3, t4, t5, t6, t7);
    }
    
    T call_ctor(T1, T2, T3, T4, T5, T6, T7, T8)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
        return new T(t1, t2, t3, t4, t5, t6, t7, t8);
    }
    
    T call_ctor(T1, T2, T3, T4, T5, T6, T7, T8, T9)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
        return new T(t1, t2, t3, t4, t5, t6, t7, t8, t9);
    }
    
    T call_ctor(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
        return new T(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10);
    }
}

// This template accepts a Tuple of (either) function pointer types or other
// Tuples, which each describe a ctor of T, and  uses them to wrap a Python
// tp_init function.
template wrapped_ctors(T, Tu) {
    alias wrapped_class_object!(T) wrap_object;

    // The user can provide ctor footprints as either function pointer types
    // or as tuples. This converts either to a tuple.
    template ctorAsTuple(T) {
        static if (isTuple!(T))
            alias T ctorAsTuple;
        else static if (is(typeof(*T) == function))
            alias getFuncTuple!(T) ctorAsTuple;
    }

    // This loops through the passed Tuple type and extracts the actual ctor
    // types.
    template loop(uint current, NewTu = EmptyTuple) {
        static if (current == Tu.length || is(typeof(Tu.mix.val!(current))==int)) {
            alias NewTu type;
        } else {
            alias loop!(current+1, NewTu.mix.appendT!(ctorAsTuple!(typeof(Tu.mix.val!(current))))).type type;
        }
    }
    alias loop!(0).type Ctors;

    // Checks each element of the Ctors tuple against the number of arguments
    // passed in from Python. Then, it calls the ctor with the passed-in
    // arguments.
    int findAndCallCtor(uint current) (PyObject* self, PyObject* args, int argCount) {
        static if (current == Ctors.length) {
            // No match, handle error
            PyErr_SetString(PyExc_TypeError, "Unsupported number of constructor arguments.");
            return -1;
        } else {
            alias typeof(Ctors.mix.val!(current)) Ctor;
            if (Ctor.length == argCount) {
                alias instantiateTemplate!(ctor_redirect!(T).call_ctor, Ctor) fn;
                WrapPyObject_SetObj(self, py_call(&fn, args));
                return 0;
            } else {
                return findAndCallCtor!(current+1)(self, args, argCount);
            }
        }
    }

    extern(C)
    int init_func(PyObject* self, PyObject* args, PyObject* kwds) {
        int len = PyObject_Length(args);

        return exception_catcher({
            // Default ctor
            static if (is(typeof(new T))) {
                if (len == 0) {
                    WrapPyObject_SetObj(self, new T);
                    return 0;
                }
            }
            return findAndCallCtor!(0) (self, args, len);
        });
    }
}

