// A minimal "hello world" Pyd module.
module hello;

import pyd.pyd;
import std.stdio;

void hello() {
    writefln("Hello, world!");
}

extern(C)
export void inithello() {
    def!(hello);
    module_init("hello");
}
