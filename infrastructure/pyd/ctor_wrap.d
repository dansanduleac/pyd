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
private import pyd.tuples;

template outer(T) {
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

// This template accepts a list of "ctor" templates and uses them to wrap a Python tp_init function.
template wrapped_ctors(T, Tuple) {
    alias wrapped_class_object!(T) wrap_object;
    const uint ARGS = Tuple.length;
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
            // We only match the first supplied ctor with the proper number of
            // arguments. (Eventually, we'll do some more sophisticated matching,
            // but this will do for now.)
            static if (ARGS >= 1) {
                if (len == TypeNo!(Tuple, 0).length) {
                    // This works thusly:
                    // 1) outer!(T).call_ctor is a series of template functions
                    //    that call a constructor with its passed arguments, and
                    //    return the new object.
                    // 2) instant_from_tuple is a template that instantiates a
                    //    template with the types in the passed tuple type. By
                    //    combining call_ctor with the selected tuple representing
                    //    the best match of constructor, we can get something like
                    //    a pointer to a constructor function.
                    // 3) This function pointer is sent off to py_call, which calls
                    //    it with the PyTuple that args points to.
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 0) ) fn1;
                    WrapPyObject_SetObj(self, py_call( &fn1, args ));
                    return 0;
                }
            }
            static if (ARGS >= 2) {
                if (len == TypeNo!(Tuple, 1).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 1) ) fn2;
                    WrapPyObject_SetObj(self, py_call( &fn2, args ));
                    return 0;
                }
            }
            static if (ARGS >= 3) {
                if (len == TypeNo!(Tuple, 2).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 2) ) fn3;
                    WrapPyObject_SetObj(self, py_call( &fn3, args ));
                    return 0;
                }
            }
            static if (ARGS >= 4) {
                if (len == TypeNo!(Tuple, 3).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 3) ) fn4;
                    WrapPyObject_SetObj(self, py_call( &fn4, args ));
                    return 0;
                }
            }
            static if (ARGS >= 5) {
                if (len == TypeNo!(Tuple, 4).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 4) ) fn5;
                    WrapPyObject_SetObj(self, py_call( &fn5, args ));
                    return 0;
                }
            }
            static if (ARGS >= 6) {
                if (len == TypeNo!(Tuple, 5).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 5) ) fn6;
                    WrapPyObject_SetObj(self, py_call( &fn6, args ));
                    return 0;
                }
            }
            static if (ARGS >= 7) {
                if (len == TypeNo!(Tuple, 6).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 6) ) fn7;
                    WrapPyObject_SetObj(self, py_call( &fn7, args ));
                    return 0;
                }
            }
            static if (ARGS >= 8) {
                if (len == TypeNo!(Tuple, 7).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 7) ) fn8;
                    WrapPyObject_SetObj(self, py_call( &fn8, args ));
                    return 0;
                }
            }
            static if (ARGS >= 9) {
                if (len == TypeNo!(Tuple, 8).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 8) ) fn9;
                    WrapPyObject_SetObj(self, py_call( &fn9, args ));
                    return 0;
                }
            }
            static if (ARGS >= 10) {
                if (len == TypeNo!(Tuple, 9).length) {
                    alias instant_from_tuple!( outer!(T).call_ctor, TypeNo!(Tuple, 9) ) fn10;
                    WrapPyObject_SetObj(self, py_call( &fn10, args ));
                    return 0;
                }
            } else {
                PyErr_SetString(PyExc_TypeError, "Unsupported number of constructor arguments.");
                return -1;
            }
        });
    }
}

