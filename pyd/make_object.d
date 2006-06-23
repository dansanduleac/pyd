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
 * This module contains some useful type conversion functions. There are two
 * interesting operations involved here:
 *
 * PyObject* -> D type
 *
 * D type -> PyObject*
 *
 * The former is handled by d_type, the latter by __py. The py function is
 * provided as a convenience to directly convert a D type into an instance of
 * DPyObject.
 */
module pyd.make_object;

private import python;
private import std.string;
// Base type
private import pyd.object;

private import pyd.exception;

private template isArray(T) {
    const bool isArray = is(typeof(T.init[0])[] == T);
}

// This relies on the fact that, for a static array type T,
//      typeof(T.init) != T
// But, rather, T.init is the type it is an array of. (For the dynamic array
// template above, this type is extracted with typeof(T.init[0])).
// Because this is only true for static arrays, it would work just as well to
// say "!is(typeof(T.init) == T)"; however, this template has the advantage of
// being easily fixable should this behavior for static arrays change.
private template isStaticArray(T) {
    const bool isStaticArray = is(typeof(T.init)[(T).sizeof / typeof(T.init).sizeof] == T);
}

private template isAA(T) {
    const bool isAA = is(typeof(T.init.values[0])[typeof(T.init.keys[0])] == T);
}

/**
 * Returns a new (owned) reference to a Python object based on the passed
 * argument. If the passed argument is a PyObject*, this "steals" the
 * reference. (In other words, it returns the PyObject* without changing its
 * reference count.) If the passed argument is a DPyObject, this returns a new
 * reference to whatever the DPyObject holds a reference to.
 *
 * If the passed argument can't be converted to a PyObject, a Python
 * RuntimeError will be raised and this function will return null.
 */
PyObject* _py(T) (T t) {
    static if (is(T : bool)) {
        PyObject* temp = (t) ? Py_True : Py_False;
        Py_INCREF(temp);
        return temp;
    } else static if (is(T : C_long)) {
        return PyInt_FromLong(t);
    } else static if (is(T : C_longlong)) {
        return PyLong_FromLongLong(t);
    } else static if (is(T : double)) {
        return PyFloat_FromDouble(t);
    } else static if (is(T : idouble)) {
        return PyComplex_FromDoubles(0.0, t.im);
    } else static if (is(T : cdouble)) {
        return PyComplex_FromDoubles(t.re, t.im);
    } else static if (is(T : char[])) {
        return PyString_FromString(t ~ \0);
    } else static if (is(T : wchar[])) {
        return PyUnicode_FromWideChar(t, t.length);
    // Converts any array (static or dynamic) to a Python list
    } else static if (isArray!(T) || isStaticArray!(T)) {
        PyObject* lst = PyList_New(t.length);
        PyObject* temp;
        if (lst is null) return null;
        for(int i=0; i<t.length; ++i) {
            temp = _py(t[i]);
            if (temp is null) {
                Py_DECREF(lst);
                return null;
            }
            // Steals the reference to temp
            PyList_SET_ITEM(lst, i, temp);
        }
        return lst;
    // Converts any associative array to a Python dict
    } else static if (isAA!(T)) {
        PyObject* dict = PyDict_New();
        PyObject* ktemp, vtemp;
        int result;
        if (dict is null) return null;
        foreach(k, v; t) {
            ktemp = _py(k);
            vtemp = _py(v);
            if (ktemp is null || vtemp is null) {
                if (ktemp !is null) Py_DECREF(ktemp);
                if (vtemp !is null) Py_DECREF(vtemp);
                Py_DECREF(dict);
                return null;
            }
            result = PyDict_SetItem(dict, ktemp, vtemp);
            Py_DECREF(ktemp);
            Py_DECREF(vtemp);
            if (result == -1) {
                Py_DECREF(dict);
                return null;
            }
        }
    } else static if (is(T : DPyObject)) {
        PyObject* temp = t.ptr();
        Py_INCREF(temp);
        return temp;
    // This just passes the argument right back through without changing
    // its reference count.
    } else static if (is(T : PyObject*)) {
        return t;
    } else {
        PyErr_SetString(PyExc_RuntimeError, "D conversion function _py failed with type " ~ typeid(T).toString());
        return null;
    }
}

/**
 * Constructs an object based on the type of the argument passed in.
 *
 * For example, calling py(10) would return a DPyObject holding the value 10.
 *
 * Calling this with a DPyObject will return back a reference to the very same
 * DPyObject.
 *
 * Calling this with a PyObject* will "steal" the reference.
 */
DPyObject py(T) (T t) {
    static if(is(T : DPyObject)) {
        return t;
    } else {
        return new DPyObject(_py(t));
    }
}

class DPyConversionException : Exception {
    this(char[] msg) { super(msg); }
}

/**
 * This converts a PyObject* to a D type. The template argument is the type to
 * convert to. The function argument is the PyObject* to convert. For instance:
 *
 *$(D_CODE PyObject* i = PyInt_FromLong(20);
 *int n = _d_type!(int)(i);
 *assert(n == 20);)
 *
 * This throws a DPyConversionException if the PyObject can't be converted to
 * the given D type.
 */
T d_type(T) (PyObject* o) {
    // This ordering is very important. If the check for bool came first,
    // then all integral types would be converted to bools (they would be
    // 0 or 1), because bool can be implicitly converted to any integral
    // type.
    //
    // This also means that:
    //  (1) Conversion to Object will construct an object and return that.
    //  (2) Any integral type smaller than a C_long (which is usually just
    //      an int, meaning short and byte) will use the bool conversion.
    //  (3) Conversion to a float shouldn't work.
    static if (is(PyObject* : T)) {
        return o;
    } else static if (is(DPyObject : T)) {
        return new DPyObject(o);
    /+
    } else static if (is(wchar[] : T)) {
        wchar[] temp;
        temp.length = PyUnicode_GetSize(o);
        PyUnicode_AsWideChar(cast(PyUnicodeObject*)o, temp, temp.length);
        return temp;
    +/
    } else static if (is(char[] : T)) {
        char* result;
        PyObject* repr;
        // If it's a string, convert it
        if (PyString_Check(o) || PyUnicode_Check(o)) {
            result = PyString_AsString(o);
        // If it's something else, convert its repr
        } else {
            repr = PyObject_Repr(o);
            if (repr is null) handle_exception();
            result = PyString_AsString(repr);
            Py_DECREF(repr);
        }
        if (result is null) handle_exception();
        return .toString(result);
    } else static if (is(cdouble : T)) {
        double real_ = PyComplex_RealAsDouble(o);
        handle_exception();
        double imag = PyComplex_ImagAsDouble(o);
        handle_exception();
        return real_ + imag * 1i;
    } else static if (is(double : T)) {
        double res = PyFloat_AsDouble(o);
        handle_exception();
        return res;
    } else static if (is(C_longlong : T)) {
        if (!PyNumber_Check(o)) could_not_convert!(T)(o);
        C_longlong res = PyLong_AsLongLong(o);
        handle_exception();
        return res;
    } else static if (is(C_long : T)) {
        C_long res = PyInt_AsLong(o);
        handle_exception();
        return res;
    } else static if (is(bool : T)) {
        int res = PyObject_IsTrue(o);
        handle_exception();
        return res == 1;
    } else {
        could_not_convert!(T)(o);
    }
}

private
void could_not_convert(T) (PyObject* o) {
    // Pull out the name of the type of this Python object, and the
    // name of the D type.
    char[] py_typename, d_typename;
    PyObject* py_type, py_type_str;
    py_type = PyObject_Type(o);
    if (py_type is null) {
        py_typename = "<unknown>";
    } else {
        py_type_str = PyObject_GetAttrString(py_type, "__name__");
        Py_DECREF(py_type);
        if (py_type_str is null) {
            py_typename = "<unknown>";
        } else {
            py_typename = .toString(PyString_AsString(py_type_str));
            Py_DECREF(py_type_str);
        }
    }
    d_typename = typeid(T).toString();
    throw new DPyConversionException(
        "Couldn't convert Python type '" ~
        py_typename ~
        "' to D type '" ~
        d_typename ~
        "'"
    );
}
