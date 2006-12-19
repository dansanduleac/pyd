module inherit;

import pyd.pyd;
import std.stdio;

class Base {
    void foo() {
        writefln("Base.foo");
    }
    void bar() {
        writefln("Base.bar");
    }
}

class Derived : Base {
    void foo() {
        writefln("Derived.foo");
    }
}

class WrapDerive : Derived {
    mixin OverloadShim;
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
    if (b1 is null) b1 = new Base;
    return b1;
}

Base return_poly_derived() {
    if (b2 is null) b2 = new Derived;
    return b2;
}

Base return_poly_wrap() {
    if (b3 is null) b3 = new WrapDerive;
    return b3;
}

extern(C) void PydMain() {
    def!(call_poly);
    def!(return_poly_base);
    def!(return_poly_derived);
    def!(return_poly_wrap);

    module_init();

    wrapped_class!(Base) b;
    b.def!(Base.foo);
    b.def!(Base.bar);
    finalize_class(b);

    wrapped_class!(Derived) d;
    d.def!(Derived.foo);
    finalize_class(d);

    wrapped_class!(WrapDerive) w;
    w.def!(WrapDerive.foo);
    finalize_class(w);
}
