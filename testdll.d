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

class Foo {
    void foo() {
        writefln("Foo.foo()");
    }
}

extern (C)
export void inittestdll() {
    def!("bar", bar);
    def!("foo", foo);
    // Minimum argument count.
    def!("baz", baz, 0);

    module_init("testdll");

    auto Foo_ = wrap_class!("Foo", Foo)();
    Foo_.def!("foo", Foo.foo);
    finalize_class!("Foo", Foo);
}

