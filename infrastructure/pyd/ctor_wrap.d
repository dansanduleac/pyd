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

private import meta.Nameof;

private import std.traits;

T call_ctor(T, Tu ...)(Tu t) {
    return new T(t);
}

// The default __init__ method calls the class's zero-argument constructor.
template wrapped_init(T) {
    extern(C)
    int init(PyObject* self, PyObject* args, PyObject* kwds) {
        return exception_catcher({
            WrapPyObject_SetObj(self, new T);
            return 0;
        });
    }
}

// The __init__ slot for wrapped structs. T is of the type of a pointer to the
// struct.
template wrapped_struct_init(T) {
    extern(C)
    int init(PyObject* self, PyObject* args, PyObject* kwds) {
        return exception_catcher({
            static if (is(T S : S*)) {
                pragma(msg, "wrapped_struct_init, S is " ~ prettynameof!(S));
                T t = new S;
                WrapPyObject_SetObj(self, t);
            }
            return 0;
        });
    }
}

// This template accepts a Tuple of (either) function pointer types or other
// Tuples, which each describe a ctor of T, and  uses them to wrap a Python
// tp_init function.
template wrapped_ctors(T, C ...) {
    alias wrapped_class_object!(T) wrap_object;

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
            // find another Ctor
            C c;
            foreach(i, arg; c) {
                alias ParameterTypeTuple!(typeof(arg)) Ctor;
                if (Ctor.length == len) {
                    auto fn = &call_ctor!(T, ParameterTypeTuple!(typeof(arg)));
                    if (fn is null) {
                        PyErr_SetString(PyExc_RuntimeError, "Couldn't get pointer to class ctor redirect.");
                        return -1;
                    }
                    T t = applyPyTupleToDelegate(fn, args);
                    if (t is null) {
                        PyErr_SetString(PyExc_RuntimeError, "Class ctor redirect didn't return a class instance!");
                        return -1;
                    }
                    WrapPyObject_SetObj(self, t);
                    return 0;
                }
            }
            // No ctor found
            PyErr_SetString(PyExc_TypeError, "Unsupported number of constructor arguments.");
            return -1;
        });
    }
}

