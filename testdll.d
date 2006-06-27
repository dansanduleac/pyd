module testdll;

import python;
import pyd.pyd;
import std.stdio;

char[] bar(int i) {
    if (i > 10) {
        return "It's greater than 10!";
    } else {
        return "It's less than 10!";
    }
}

void foo() {
    writefln("typeof(Py_None)   == %s", typeid(typeof(Py_None)));
    writefln("typeof(Py_None()) == %s", typeid(typeof(Py_None())));
    DPyObject o = new DPyObject();
    writefln("Py_None.repr() == %s", o);
}

void baz(int i=10, char[] s="moo") {
    writefln("i = %s\ns = %s", i, s);
}

class Foo { }

// New type test...
extern(C)
struct testdll_MyClassObject {
    mixin PyObject_HEAD;
    Foo foo;
}

static PyTypeObject testdll_MyClassType = {
    1, // Initial reference count
    null,
    0,                         /*ob_size*/
    "testdll.MyClass",          /*tp_name*/
    testdll_MyClassObject.sizeof, /*tp_basicsize*/
    0,                         /*tp_itemsize*/
    null,                         /*tp_dealloc*/
    null,                         /*tp_print*/
    null,                         /*tp_getattr*/
    null,                         /*tp_setattr*/
    null,                         /*tp_compare*/
    null,                         /*tp_repr*/
    null,                         /*tp_as_number*/
    null,                         /*tp_as_sequence*/
    null,                         /*tp_as_mapping*/
    null,                         /*tp_hash */
    null,                         /*tp_call*/
    null,                         /*tp_str*/
    null,                         /*tp_getattro*/
    null,                         /*tp_setattro*/
    null,                         /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT,        /*tp_flags*/
    "MyClass objects",           /* tp_doc */
};

extern (C)
export void inittestdll() {
    def!("bar", bar);
    def!("foo", foo);
    // Minimum argument count.
    def!("baz", baz, 0);

    testdll_MyClassType.ob_type = PyType_Type_p;
    testdll_MyClassType.tp_new = &PyType_GenericNew;
    if (PyType_Ready(&testdll_MyClassType) < 0)
        return;

    PyObject* m = module_init("testdll");

    Py_INCREF(cast(PyObject*)&testdll_MyClassType);
    PyModule_AddObject(m, "MyClass", cast(PyObject*)&testdll_MyClassType);
}

