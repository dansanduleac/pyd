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

void call_poly(Base b) {
    writef("call_poly: ");
    b.foo();
}

extern(C)
export void initinherit() {
    def!(call_poly);

    module_init("inherit");

    wrapped_class!(Base) b;
    b.def!(Base.foo);
    b.def!(Base.bar);
    finalize_class(b);

    wrapped_class!(Derived) d;
    d.def!(Derived.foo);
    finalize_class(d);
}
