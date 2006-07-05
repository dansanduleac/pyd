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

void foo(int i) {
    writefln("You entered %s", i);
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
    Foo opAdd(Foo f) { return new Foo(m_i + f.m_i); }
    int i() { return m_i; }
    void i(int j) { m_i = j; }
}

void iter_test(PyObject* c) {
    Bar b = new Bar(1, 2, 3, 4, 5);
    PyObject* o, res;
    foreach(i; b) {
        o = _py(i);
        res = PyObject_CallFunctionObjArgs(c, o, null);
        Py_DECREF(res);
        Py_DECREF(o);
    }
}

void delegate() func_test() {
    Foo f = new Foo(20);
    return &f.foo;
}

class Bar {
    int[] m_a;
    this() { }
    this(int[] i ...) { m_a = i; }
    int opApply(int delegate(inout int) dg) {
        int result = 0;
        for (int i=0; i<m_a.length; ++i) {
            result = dg(m_a[i]);
            if (result) break;
        }
        return result;
    }
}

Foo spam(Foo f) {
    f.foo();
    Foo g = new Foo(f.i + 10);
    return g;
}

extern (C)
export void inittestdll() {
    module_init("testdll");

    def!("foo", foo);
    // Python does not support function overloading. This allows us to wrap
    // an overloading function under a different name.
    def!("foo2", foo, 1, void function(int));
    def!("bar", bar);
    // Default argument support - Now implicit!
    def!("baz", baz);
    def!("spam", spam);
    def!("iter_test", iter_test);
    def!("func_test", func_test);

    wrapped_class!("Foo", Foo) f;
    // Constructor wrapping
    f.init!(ctor!(int), ctor!(int, int));
    // Member function wrapping
    f.def!("foo", Foo.foo);
    // Property wrapping
    f.prop!("i", Foo.i);
    finalize_class(f);
}

