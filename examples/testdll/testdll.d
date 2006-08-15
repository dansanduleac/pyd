module testdll;

import python;
import pyd.pyd;
//import pyd.ftype;
import std.stdio;

void apply_test(int i, char[] s) {
    writefln("%s %s", i, s);
}

void foo() {
    alias tuple!(int, char[]) Tuple;
//    alias dg_from_tuple!(void, Tuple) dg;
    Tuple t;
//    Tuple.TypeNo!(0) i = 20;
//    typeof(Tuple.arg1) j = 30;
    t.arg1 = 20;
    t.arg2 = "Monkey";
//    t.arg3 = 5.8;
    apply_tuple_to_fn(t, &apply_test);
    
//    writefln(typeid(ArgType!(dg, 1)));
//    writefln(typeid(TypeNo!(Tuple, 0)));
//    writefln(typeid(Tuple.A1));
//    writefln(typeid(dg));
//    writefln(i, " ", j);
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
    int opApply(int delegate(inout int) dg) {
        int result = 0;
        for (int i=0; i<10; ++i) {
            result = dg(i);
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

Foo spam(Foo f) {
    f.foo();
    Foo g = new Foo(f.i + 10);
    return g;
}

extern (C)
export void inittestdll() {
    def!(foo, "foo");
    // Python does not support function overloading. This allows us to wrap
    // an overloading function under a different name. Note that if the
    // overload accepts a different number of minimum arguments, that number
    // must be specified.
    def!(foo, "foo2", void function(int), 1);
    def!(bar, "bar");
    // Default argument support - Now implicit!
    def!(baz, "baz");
    def!(spam, "spam");
    def!(iter_test, "iter_test");
    def!(func_test, "func_test");
    def!(dg_test, "dg_test");

    module_init("testdll");

    auto t = func_range!(foo, 0)();
    alias typeof(t) Tu;
    writefln(typeid(TypeNo!(Tu, 1)));
    writefln(MIN_ARGS!(bar));

    wrapped_class!(Foo, "Foo") f;
    // Constructor wrapping
    f.init!(tuple!(int), tuple!(int, int));
    // Member function wrapping
    f.def!(Foo.foo, "foo");
    // Property wrapping
    f.prop!(Foo.i, "i");
    finalize_class(f);
}

