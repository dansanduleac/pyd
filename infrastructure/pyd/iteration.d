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

/**
 * This module provides the support for wrapping opApply with Python's
 * iteration interface using Mikola Lysenko's StackThreads package.
 */
module pyd.iteration;

private import python;
private import pyd.class_wrap;
private import pyd.exception;
private import pyd.ftype;
private import pyd.make_object;
private import st.stackcontext;

// This exception is for yielding a PyObject* from within a StackContext.
class DPyYield : Exception {
    PyObject* m_py;
    this(PyObject* py) {
        super("");
        m_py = py;
    }
    PyObject* item() { return m_py; }
}

// Makes a PyTuple and "steals" all of the passed references
PyObject* _make_pytuple(PyObject*[] pyobjs ...) {
    PyObject* temp = PyTuple_New(pyobjs.length);
    if (temp is null) {
        foreach (PyObject* o; pyobjs) {
            Py_DECREF(o);
        }
        return null;
    }
    foreach (uint i, PyObject* o; pyobjs) {
        PyTuple_SetItem(temp, i, o);
    }
    return temp;
}

// Creates an iterator object from an object.
PyObject* DPySC_FromWrapped(T) (T obj) {
    // Get the number of args the opApply's delegate argument takes
    const uint ARGS = NumberOfArgsInout!(ArgType!(typeof(&T.opApply), 1));
    auto sc = new StackContext(delegate void() {
        T t = obj;
        PyObject* temp;
        // I seriously doubt I need to support up to ten (10!) arguments to the
        // opApply delegate, but everything else in Pyd does, so here we go.
        static if (ARGS == 1) {
            foreach (i; t) {
                StackContext.throwYield(new DPyYield(_py(i)));
            }
        } else static if (ARGS == 2) {
            foreach (a0, a1; t) {
                temp = _make_pytuple(_py(a0), _py(a1));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 3) {
            foreach (a0, a1, a2; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 4) {
            foreach (a0, a1, a2, a3; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 5) {
            foreach (a0, a1, a2, a3, a4; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 6) {
            foreach (a0, a1, a2, a3, a4, a5; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4), _py(a5));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 7) {
            foreach (a0, a1, a2, a3, a4, a5, a6; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4), _py(a5), _py(a6));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 8) {
            foreach (a0, a1, a2, a3, a4, a5, a6, a7; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4), _py(a5), _py(a6), _py(a7));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 9) {
            foreach (a0, a1, a2, a3, a4, a5, a6, a7, a8; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4), _py(a5), _py(a6), _py(a7), _py(a8));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        } else static if (ARGS == 10) {
            foreach (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9; t) {
                temp = _make_pytuple(_py(a0), _py(a1), _py(a2), _py(a3), _py(a4), _py(a5), _py(a6), _py(a7), _py(a8), _py(a9));
                if (temp is null) StackContext.throwYield(new DPyYield(null));
                StackContext.throwYield(new DPyYield(temp));
            }
        }
    });
    return WrapPyObject_FromObject(sc);
}

template wrapped_iter(T) {
    alias wrapped_class_object!(T) wrap_object;

    // Returns an iterator object for this class
    extern (C)
    PyObject* iter (PyObject* _self) {
        return exception_catcher({
            wrap_object* self = cast(wrap_object*)_self;

            return DPySC_FromWrapped(self.d_obj);
        });
    }
}

// Advances an iterator object
extern (C)
PyObject* sc_iternext(PyObject* _self) {
    return exception_catcher(delegate PyObject*() {
        alias wrapped_class_object!(StackContext) DPySC_object;
        DPySC_object* self = cast(DPySC_object*)_self;

        try {
            // If the StackContext is done, cease iteration.
            if (!self.d_obj.ready()) {
                return null;
            }
            self.d_obj.run();
        }
        // The StackContext class yields values by throwing an exception.
        // We catch it and pass the converted value into Python.
        catch (DPyYield y) {
            return y.item();
        }
        return null;
    });
}

/// Readies the iterator class if it hasn't been already.
void DPySC_Ready() {
    alias wrapped_class_type!(StackContext) type;
    alias wrapped_class_object!(StackContext) DPySC_object;
    
    if (!is_wrapped!(StackContext)) {
        type.ob_type = PyType_Type_p;
        type.tp_basicsize = DPySC_object.sizeof;
        //type.tp_doc = "";
        type.tp_name = "DPyOpApplyWrapper";

        type.tp_iter = &PyObject_SelfIter;
        type.tp_iternext = &sc_iternext;

        PyType_Ready(&type);

        // Mark the class as ready
        is_wrapped!(StackContext) = true;
        wrapped_classes[typeid(StackContext)] = true;
    }
}
