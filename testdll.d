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

extern (C)
export void inittestdll() {
    def!("bar", bar);
    def!("foo", foo);

    module_init("testdll");
}

