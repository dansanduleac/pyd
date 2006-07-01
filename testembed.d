import python;
import std.string;

int main() {
    Py_Initialize();
    scope(exit) Py_Finalize();

    PyObject* sys = PyImport_ImportModule("sys");
    scope(exit) Py_DECREF(sys);

    PyObject* path = PyObject_GetAttrString(sys, "path");
    scope(exit) Py_DECREF(path);

    PyObject* dir = PyString_FromString("C:\\Projects\\Pyd\\build\\lib.win32-2.4");
    PyList_Append(path, dir);
    Py_DECREF(dir);

    PyObject* testdll = PyImport_ImportModule("testdll");
    scope(exit) Py_DECREF(testdll);

    PyObject* Foo = PyObject_GetAttrString(testdll, "Foo");
    scope(exit) Py_DECREF(Foo);

    PyObject* t = PyObject_Type(Foo);
    scope(exit) Py_DECREF(t);
    PyObject* s = PyObject_Repr(t);
    scope(exit) Py_DECREF(s);
    char[] str = .toString(PyString_AsString(s));
    writefln("type(Foo) is %s", str);

    PyObject* i = PyInt_FromLong(12);
    scope(exit) Py_DECREF(i);
    PyObject* st = PyString_FromString("moo");
    scope(exit) Py_DECREF(st);

    PyObject* a = PyObject_CallFunctionObjArgs(Foo, i, null);
    scope(exit) Py_DECREF(a);

    PyObject* b = PyObject_CallFunctionObjArgs(Foo, st, null);
    scope(exit) Py_DECREF(b);

    PyObject* foo = PyObject_GetAttrString(a, "foo");
    scope(exit) Py_DECREF(foo);

    PyObject* temp = PyObject_CallObject(foo, null);
    Py_DECREF(temp);

    return 0;
}


