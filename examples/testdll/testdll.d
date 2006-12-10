module testdll;

import python;
import pyd.pyd;
//import pyd.ftype;
import std.stdio, std.string;

//import meta.Tuple;
//import meta.Apply;

void apply_test(int i, char[] s) {
    writefln("%s %s", i, s);
}

void foo() {
    /+
    alias Tuple!(int, char[]) T;
    T t;
    t.val!(0) = 20;
    t.val!(1) = "Monkey";
    apply(&apply_test, t);
    +/
    writefln("20 Monkey");
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
    this(int i) {
        m_i = i;
    }
    this(int i, int j) {
        m_i = i + j;
    }
    void foo() {
        writefln("Foo.foo(): i = %s", m_i);
    }
    int length() { return 10; }
    int opSlice(int i1, int i2) {
        writefln(i1, " ", i2);
        return 12;
    }
    int opIndex(int x, int y) {
        writefln(x, " ", y);
        return x+y;
    }
    Foo opAdd(Foo f) { return new Foo(m_i + f.m_i); }
    int opApply(int delegate(inout int, inout int) dg) {
        int result = 0;
        int j;
        for (int i=0; i<10; ++i) {
            j = i+1;
            result = dg(i, j);
            if (result) break;
        }
        return result;
    }
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

void dg_test(void delegate() dg) {
    dg();
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

struct S {
    int i;
    char[] s;
    void write_s() {
        writefln(s);
    }
}

Foo spam(Foo f) {
    f.foo();
    Foo g = new Foo(f.i + 10);
    return g;
}

extern (C)
export void inittestdll() {
    def!(foo);
    // Python does not support function overloading. This allows us to wrap
    // an overloading function under a different name. Note that if the
    // overload accepts a different number of minimum arguments, that number
    // must be specified.
    def!(foo, "foo2", void function(int), 1);
    def!(bar);
    // Default argument support - Now implicit!
    def!(baz);
    def!(spam);
    def!(iter_test);
    def!(func_test);
    def!(dg_test);

    module_init("testdll");

    wrapped_class!(Foo) f;
    // Constructor wrapping
    f.init!(void function(int), void function(int, int));
    // Member function wrapping
    f.def!(Foo.foo);
    // Property wrapping
    f.prop!(Foo.i);
    finalize_class(f);

    wrapped_struct!(S) s;
    s.def!(S.write_s);
    const size_t i = S.i.offsetof;
    const size_t t = S.s.offsetof;
    s.member!(int, i, "i");
    s.member!(char[], t, "s");
    finalize_struct(s);
}

