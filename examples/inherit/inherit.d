module inherit;

import pyd.pyd;
import std.stdio;

class Base {
    this(int i) { writefln("Base.this(): ", i); }
    void foo() {
        writefln("Base.foo");
    }
    void bar() {
        writefln("Base.bar");
    }
}

class Derived : Base {
    this(int i) { super(i); writefln("Derived.this(): ", i); }
    void foo() {
        writefln("Derived.foo");
    }
}

class BaseWrap : Base {
    mixin OverloadShim;
    this(int i) { super(i); }
    void foo() {
        get_overload(&super.foo, "foo");
    }
    void bar() {
        get_overload(&super.bar, "bar");
    }
}

class DeriveWrap : Derived {
    mixin OverloadShim;
    this(int i) { super(i); }
    void foo() {
        get_overload(&super.foo, "foo");
    }
}

void call_poly(Base b) {
    writefln("call_poly:");
    b.foo();
}

Base b1, b2, b3;

Base return_poly_base() {
    if (b1 is null) b1 = new Base(1);
    return b1;
}

Base return_poly_derived() {
    if (b2 is null) b2 = new Derived(2);
    return b2;
}

Base return_poly_wrap() {
    if (b3 is null) b3 = new DeriveWrap(3);
    return b3;
}

extern(C) void PydMain() {
    def!(call_poly);
    def!(return_poly_base);
    def!(return_poly_derived);
    def!(return_poly_wrap);

    module_init();

    wrapped_class!(Base) b;
    b.hide();
    b.def!(Base.foo);
    b.def!(Base.bar);
    finalize_class(b);

    wrapped_class!(Derived) d;
    d.hide();
    d.def!(Derived.foo);
    finalize_class(d);

    wrapped_class!(BaseWrap, "Base") bw;
    bw.init!(void function(int));
    bw.def!(BaseWrap.foo);
    bw.def!(BaseWrap.bar);
    finalize_class(bw);

    wrapped_class!(DeriveWrap, "Derived") dw;
    dw.init!(void function(int));
    dw.parent!(BaseWrap);
    dw.def!(DeriveWrap.foo);
    finalize_class(dw);
}

