// A module written to the raw Python/C API.
module rawexample;

import python;
import std.stdio;

extern(C)
PyObject* hello(PyObject* self, PyObject* args) {
    writefln("Hello, world!");
    Py_INCREF(Py_None);
    return Py_None;
}

PyMethodDef[] rawexample_methods = [
    {"hello", &hello, METH_VARARGS, ""},
    {null, null, 0, null}
];

extern(C)
export void initrawexample() {
    Py_InitModule("rawexample", rawexample_methods);
}

