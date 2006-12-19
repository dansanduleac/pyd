module testdll;

import python;
import pyd.pyd;
import std.stdio, std.string;

void foo() {
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

void delegate() func_test() {
    return { writefln("Delegate works!"); };
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

void throws() {
    throw new Exception("Yay! An exception!");
}

extern(C) void PydMain() {
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
    def!(func_test);
    def!(dg_test);
    def!(throws);

    module_init();

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

