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
module pyd.exception;

private import python;
private import std.string;

/**
 * This function first checks if a Python exception is set, and then (if one
 * is) pulls it out, stuffs it in a PythonException, and throws that exception.
 *
 * If this exception is never caught, it will be handled by exception_catcher
 * (below) and passed right back into Python as though nothing happened.
 */
void handle_exception() {
    PyObject* type, value, traceback;
    if (PyErr_Occurred() !is null) {
        PyErr_Fetch(&type, &value, &traceback);
        throw new PythonException(type, value, traceback);
    }
}

/**
 * It is intended that any functions that interface directly with Python which
 * have the possibility of a D exception being raised wrap their contents in a
 * call to this function, e.g.:
 *
 *$(D_CODE extern (C)
 *PyObject* some_func(PyObject* self) {
 *    return _exception_catcher({
 *        // ...
 *    });
 *})
 */
PyObject* exception_catcher(PyObject* delegate() dg) {
    try {
        return dg();
    }
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
    // Some other D object was thrown. Deal with it.
    catch (Object o) {
        PyErr_SetString(PyExc_RuntimeError, "thrown D Object: " ~ o.classinfo.name ~ ": " ~ o.toString() ~ \0);
        return null;
    }
}

// XXX: Some way to combine this with the above?
int exception_catcher(int delegate() dg) {
    try {
        return dg();
    }
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
    // Some other D object was thrown. Deal with it.
    catch (Object o) {
        PyErr_SetString(PyExc_RuntimeError, "thrown D Object: " ~ o.classinfo.name ~ ": " ~ o.toString() ~ \0);
        return -1;
    }
}

/**
 * This simple exception class holds a Python exception.
 */
class PythonException : Exception {
protected:
    PyObject* m_type, m_value, m_trace;
public:
    this(PyObject* type, PyObject* value, PyObject* traceback) {
        super(.toString(PyString_AsString(value)));
        m_type = type;
        m_value = value;
        m_trace = traceback;
    }

    ~this() {
        Py_DECREF(m_type);
        Py_DECREF(m_value);
        Py_DECREF(m_trace);
    }

    PyObject* type() {
        Py_INCREF(m_type);
        return m_type;
    }
    PyObject* value() {
        Py_INCREF(m_value);
        return m_value;
    }
    PyObject* traceback() {
        Py_INCREF(m_trace);
        return m_trace;
    }
}

