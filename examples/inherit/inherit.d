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

extern(C) void PydMain() {
    def!(call_poly);

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
