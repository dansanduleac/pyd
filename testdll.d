module testdll;

import python;
import pyd.pyd;
import std.stdio;

// d_type testing
void foo() {
    PyObject* s = PyString_FromString("blargh");
    PyObject* i = PyInt_FromLong(20);

    int a = d_type!(int)(i);
    char[] b = d_type!(char[])(s);

    writefln("%s\n%s", a, b);

    Py_DECREF(s);
    Py_DECREF(i);
}

char[] bar(int i) {
    if (i > 10) {
        return "It's greater than 10!";
    } else {
        return "It's less than 10!";
    }
}

void baz(int i=10, char[] s="moo") {
    writefln("i = %s\ns = %s", i, s);
}

class Foo {
    int m_i;
    this() { }
    this(int i) { m_i = i; }
    this(int i, int j) { m_i = i + j; }
    void foo() {
        writefln("Foo.foo(): i = %s", m_i);
    }
}

extern (C)
export void inittestdll() {
    def!("foo", foo);
    def!("bar", bar);
    // Minimum argument count.
    def!("baz", baz, 0);

    module_init("testdll");

    auto Foo_ = wrap_class!("Foo", Foo)();
    Foo_.init!(ctor!(int), ctor!(int, int));
    Foo_.def!("foo", Foo.foo);
    finalize_class!("Foo", Foo);
}

