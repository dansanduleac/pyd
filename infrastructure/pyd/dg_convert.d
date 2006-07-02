/*
Copyright (c) 2006 Kirk McDonald

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module pyd.dg_convert;

private import pyd.ftype;

template fn_to_dgT(Fn) {
    const uint ARGS = NumberOfArgs!(Fn);
    alias ReturnType!(Fn) RetType;

    static if (ARGS == 0) {
        alias RetType delegate() type;
    } else static if (ARGS == 1) {
        alias RetType delegate(ArgType!(Fn, 1)) type;
    } else static if (ARGS == 2) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2)) type;
    } else static if (ARGS == 3) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3)) type;
    } else static if (ARGS == 4) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4)) type;
    } else static if (ARGS == 5) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5)) type;
    } else static if (ARGS == 6) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5), ArgType!(Fn, 6)) type;
    } else static if (ARGS == 7) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5), ArgType!(Fn, 6), ArgType!(Fn, 7)) type;
    } else static if (ARGS == 8) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5), ArgType!(Fn, 6), ArgType!(Fn, 7), ArgType!(Fn, 8)) type;
    } else static if (ARGS == 9) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5), ArgType!(Fn, 6), ArgType!(Fn, 7), ArgType!(Fn, 8), ArgType!(Fn, 9)) type;
    } else static if (ARGS == 10) {
        alias RetType delegate(ArgType!(Fn, 1), ArgType!(Fn, 2), ArgType!(Fn, 3), ArgType!(Fn, 4), ArgType!(Fn, 5), ArgType!(Fn, 6), ArgType!(Fn, 7), ArgType!(Fn, 8), ArgType!(Fn, 9), ArgType!(Fn, 10)) type;
    }
}

/**
 * This template converts a function type into an equivalent delegate type.
 */
template fn_to_dg(Fn) {
    alias fn_to_dgT!(Fn).type fn_to_dg;
}

struct FakeDG {
    Object instance;
    void* fn;
}

template dg_union(Fn) {
    union dg_union {
        FakeDG fake_dg;
        fn_to_dg!(Fn) real_dg;
    }
}

/**
 * This dirty hack of a template function converts a pointer to a member
 * function into a delegate.
 */
fn_to_dg!(Fn) dg_wrapper(T, Fn) (T t, Fn fn) {
    dg_union!(Fn) u;
    u.fake_dg.instance = t;
    u.fake_dg.fn = cast(void*)fn;

    return u.real_dg;
}
