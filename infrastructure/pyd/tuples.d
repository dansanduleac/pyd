module pyd.tuples;

private import pyd.ftype;

class Void { }

template tuple(T1=Void, T2=Void, T3=Void, T4=Void, T5=Void, T6=Void, T7=Void, T8=Void, T9=Void, T10=Void) {
    struct tuple {
        T10 arg10;
        T9 arg9;
        T8 arg8;
        T7 arg7;
        T6 arg6;
        T5 arg5;
        T4 arg4;
        T3 arg3;
        T2 arg2;
        T1 arg1;

        alias T1 A1;
        alias T2 A2;
        alias T3 A3;
        alias T4 A4;
        alias T5 A5;
        alias T6 A6;
        alias T7 A7;
        alias T8 A8;
        alias T9 A9;
        alias T10 A10;
        
        static if (!is(T10 == Void))
            static const uint length = 10;
        else static if (!is(T9 == Void))
            static const uint length = 9;
        else static if (!is(T8 == Void))
            static const uint length = 8;
        else static if (!is(T7 == Void))
            static const uint length = 7;
        else static if (!is(T6 == Void))
            static const uint length = 6;
        else static if (!is(T5 == Void))
            static const uint length = 5;
        else static if (!is(T4 == Void))
            static const uint length = 4;
        else static if (!is(T3 == Void))
            static const uint length = 3;
        else static if (!is(T2 == Void))
            static const uint length = 2;
        else static if (!is(T1 == Void))
            static const uint length = 1;
        else
            static const uint length = 0;

        template TypeNo(int pos) {
            static if (pos == 0)
                alias T1 TypeNo;
            else static if (pos == 1)
                alias T2 TypeNo;
            else static if (pos == 2)
                alias T3 TypeNo;
            else static if (pos == 3)
                alias T4 TypeNo;
            else static if (pos == 4)
                alias T5 TypeNo;
            else static if (pos == 5)
                alias T6 TypeNo;
            else static if (pos == 6)
                alias T7 TypeNo;
            else static if (pos == 7)
                alias T8 TypeNo;
            else static if (pos == 8)
                alias T9 TypeNo;
            else static if (pos == 9)
                alias T10 TypeNo;
        }

        template get(int i) {
            TypeNo!(i) get() {
                static if (i == 0)
                    return arg1;
                else static if (i == 1)
                    return arg2;
                else static if (i == 2)
                    return arg3;
                else static if (i == 3)
                    return arg4;
                else static if (i == 4)
                    return arg5;
                else static if (i == 5)
                    return arg6;
                else static if (i == 6)
                    return arg7;
                else static if (i == 7)
                    return arg8;
                else static if (i == 8)
                    return arg9;
                else static if (i == 9)
                    return arg10;
            }
        }

        template set(int i) {
            void set(TypeNo!(i) val) {
                static if (i == 0)
                    arg1 = val;
                else static if (i == 1)
                    arg2 = val;
                else static if (i == 2)
                    arg3 = val;
                else static if (i == 3)
                    arg4 = val;
                else static if (i == 4)
                    arg5 = val;
                else static if (i == 5)
                    arg6 = val;
                else static if (i == 6)
                    arg7 = val;
                else static if (i == 7)
                    arg8 = val;
                else static if (i == 8)
                    arg9 = val;
                else static if (i == 9)
                    arg10 = val;
            }
        }
    }
}

template TypeNo(Tu, int pos) {
    static if (pos == 0)
        alias Tu.A1 TypeNo;
    else static if (pos == 1)
        alias Tu.A2 TypeNo;
    else static if (pos == 2)
        alias Tu.A3 TypeNo;
    else static if (pos == 3)
        alias Tu.A4 TypeNo;
    else static if (pos == 4)
        alias Tu.A5 TypeNo;
    else static if (pos == 5)
        alias Tu.A6 TypeNo;
    else static if (pos == 6)
        alias Tu.A7 TypeNo;
    else static if (pos == 7)
        alias Tu.A8 TypeNo;
    else static if (pos == 8)
        alias Tu.A9 TypeNo;
    else static if (pos == 9)
        alias Tu.A10 TypeNo;
}

template tuple_from_fnT(Fn, uint ARGS) {
    static if (ARGS >= 1)
        alias ArgType!(Fn, 1) T1;
    else
        alias Void T1;
    static if (ARGS >= 2)
        alias ArgType!(Fn, 2) T2;
    else
        alias Void T2;
    static if (ARGS >= 3)
        alias ArgType!(Fn, 3) T3;
    else
        alias Void T3;
    static if (ARGS >= 4)
        alias ArgType!(Fn, 4) T4;
    else
        alias Void T4;
    static if (ARGS >= 5)
        alias ArgType!(Fn, 5) T5;
    else
        alias Void T5;
    static if (ARGS >= 6)
        alias ArgType!(Fn, 6) T6;
    else
        alias Void T6;
    static if (ARGS >= 7)
        alias ArgType!(Fn, 7) T7;
    else
        alias Void T7;
    static if (ARGS >= 8)
        alias ArgType!(Fn, 8) T8;
    else
        alias Void T8;
    static if (ARGS >= 9)
        alias ArgType!(Fn, 9) T9;
    else
        alias Void T9;
    static if (ARGS >= 10)
        alias ArgType!(Fn, 10) T10;
    else
        alias Void T10;
    alias tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) t;
}

template tuple_from_fn(Fn, uint ARGS = NumberOfArgs!(Fn)) {
    alias tuple_from_fnT!(Fn, ARGS).t tuple_from_fn;
}

template dg_from_tuple(Ret, Tu) {
    static if (Tu.length == 0)
        alias Ret delegate() dg_from_tuple;
    else static if (Tu.length == 1)
        alias Ret delegate(typeof(Tu.arg1)) dg_from_tuple;
    else static if (Tu.length == 2)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2)) dg_from_tuple;
    else static if (Tu.length == 3)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3)) dg_from_tuple;
    else static if (Tu.length == 4)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4)) dg_from_tuple;
    else static if (Tu.length == 5)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5)) dg_from_tuple;
    else static if (Tu.length == 6)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6)) dg_from_tuple;
    else static if (Tu.length == 7)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7)) dg_from_tuple;
    else static if (Tu.length == 8)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8)) dg_from_tuple;
    else static if (Tu.length == 9)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8), typeof(Tu.arg9)) dg_from_tuple;
    else static if (Tu.length == 10)
        alias Ret delegate(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8), typeof(Tu.arg9), typeof(Tu.arg10)) dg_from_tuple;
    else static assert(false);
}

template fn_from_tuple(Ret, Tu) {
    static if (is(dg_from_tuple!(Ret, Tu) Fn == delegate))
        alias Fn* fn_from_tuple;
    else static assert(false);
}

template instant_from_tuple(alias T, Tu) {
    static if (Tu.length == 0)
        alias T!() instant_from_tuple;
    else static if (Tu.length == 1)
        alias T!(typeof(Tu.arg1)) instant_from_tuple;
    else static if (Tu.length == 2)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2)) instant_from_tuple;
    else static if (Tu.length == 3)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3)) instant_from_tuple;
    else static if (Tu.length == 4)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4)) instant_from_tuple;
    else static if (Tu.length == 5)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5)) instant_from_tuple;
    else static if (Tu.length == 6)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6)) instant_from_tuple;
    else static if (Tu.length == 7)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7)) instant_from_tuple;
    else static if (Tu.length == 8)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8)) instant_from_tuple;
    else static if (Tu.length == 9)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8), typeof(Tu.arg9)) instant_from_tuple;
    else static if (Tu.length == 10)
        alias T!(typeof(Tu.arg1), typeof(Tu.arg2), typeof(Tu.arg3), typeof(Tu.arg4), typeof(Tu.arg5), typeof(Tu.arg6), typeof(Tu.arg7), typeof(Tu.arg8), typeof(Tu.arg9), typeof(Tu.arg10)) instant_from_tuple;
    else static assert(false);
}

ReturnType!(Fn) apply_tuple_to_fnT(uint ARGS, Tu, Fn)(Tu t, Fn fn) {
    //const uint ARGS = Tu.length;
    static if (ARGS == 0)
        return fn();
    else static if (ARGS == 1)
        return fn(t.get!(0));
    else static if (ARGS == 2)
        return fn(t.get!(0), t.get!(1));
    else static if (ARGS == 3)
        return fn(t.get!(0), t.get!(1), t.get!(2));
    else static if (ARGS == 4)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3));
    else static if (ARGS == 5)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4));
    else static if (ARGS == 6)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4), t.get!(5));
    else static if (ARGS == 7)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4), t.get!(5), t.get!(6));
    else static if (ARGS == 8)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4), t.get!(5), t.get!(6), t.get!(7));
    else static if (ARGS == 9)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4), t.get!(5), t.get!(6), t.get!(7), t.get!(8));
    else static if (ARGS == 10)
        return fn(t.get!(0), t.get!(1), t.get!(2), t.get!(3), t.get!(4), t.get!(5), t.get!(6), t.get!(7), t.get!(8), t.get!(9));
}

ReturnType!(Fn) apply_tuple_to_fn(Tu, Fn)(Tu t, Fn fn) {
    return apply_tuple_to_fnT!(NumberOfArgs!(Fn), Tu, Fn)(t, fn);
}

template fn_partT(alias fn, uint args) {
    alias typeof(&fn) Fn;
    alias ReturnType!(Fn) R;

    // Shortcut for ArgType
    template A(uint a) {
        alias ArgType!(Fn, a) A;
    }

    static if (args == 0)
        alias R function() f;
    else static if (args == 1)
        alias R function(A!(1)) f;
    else static if (args == 2)
        alias R function(A!(1), A!(2)) f;
    else static if (args == 3)
        alias R function(A!(1), A!(2), A!(3)) f;
    else static if (args == 4)
        alias R function(A!(1), A!(2), A!(3), A!(4)) f;
    else static if (args == 5)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5)) f;
    else static if (args == 6)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5), A!(6)) f;
    else static if (args == 7)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7)) f;
    else static if (args == 8)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8)) f;
    else static if (args == 9)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8), A!(9)) f;
    else static if (args == 10)
        alias R function(A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8), A!(9), A!(10)) f;
}

/**
 * This template derives a function type that is based on the first 'n'
 * arguments of the passed function alias.
 *
 * (Written by Kirk McDonald.)
 */
template fn_part(alias fn, uint n) {
    alias fn_partT!(fn, n).f fn_part;
}

template partialT(alias fn, uint args) {
    alias typeof(&fn) Fn;
    alias ReturnType!(Fn) R;

    // Shortcut for ArgType
    template A(uint a) {
        alias ArgType!(Fn, a) A;
    }

    static if (args == 0) {
        R func() {
            return fn();
        }
    } else static if (args == 1) {
        R func(A!(1) a1) {
            return fn(a1);
        }
    } else static if (args == 2) {
        R func(A!(1) a1, A!(2) a2) {
            return fn(a1, a2);
        }
    } else static if (args == 3) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3) {
            return fn(a1, a2, a3);
        }
    } else static if (args == 4) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4) {
            return fn(a1, a2, a3, a4);
        }
    } else static if (args == 5) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5) {
            return fn(a1, a2, a3, a4, a5);
        }
    } else static if (args == 6) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5, A!(6) a6) {
            return fn(a1, a2, a3, a4, a5, a6);
        }
    } else static if (args == 7) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5, A!(6) a6, A!(7) a7) {
            return fn(a1, a2, a3, a4, a5, a6, a7);
        }
    } else static if (args == 8) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5, A!(6) a6, A!(7) a7, A!(8) a8) {
            return fn(a1, a2, a3, a4, a5, a6, a7, a8);
        }
    } else static if (args == 9) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5, A!(6) a6, A!(7) a7, A!(8) a8, A!(9) a9) {
            return fn(a1, a2, a3, a4, a5, a6, a7, a8, a9);
        }
    } else static if (args == 10) {
        R func(A!(1) a1, A!(2) a2, A!(3) a3, A!(4) a4, A!(5) a5, A!(6) a6, A!(7) a7, A!(8) a8, A!(9) a9, A!(10) a10) {
            return fn(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
        }
    }
}

/**
 * Calls a function alias with only the first 'n' arguments.
 */
template partial(alias fn, uint n) {
    alias partialT!(fn, n).func partial;
}

template func_rangeT(alias fn, uint MIN_ARGS) {
    alias typeof(&fn) Fn;
    const uint N = NumberOfArgs!(Fn);

    // Shortcut for fn_part
    template P(uint a) {
        static if (MIN_ARGS <= a && N >= a)
            alias fn_part!(fn, a) P;
        else
            alias Void P;
    }
    alias tuple!(P!(1), P!(2), P!(3), P!(4), P!(5), P!(6), P!(7), P!(8), P!(9), P!(10)) t;
}

/**
 * Derives a tuple type based on the valid function types the passed function alias
 * may be called with.
 */
func_rangeT!(fn, MIN_ARGS).t func_range(alias fn, uint MIN_ARGS)() {
    alias func_rangeT!(fn, MIN_ARGS).t func_t;
    func_t t;

    static if (!is(TypeNo!(func_t, 0) == Void))
        t.set!(0)(&partial!(fn, 1));
    static if (!is(TypeNo!(func_t, 1) == Void))
        t.set!(1)(&partial!(fn, 2));
    static if (!is(TypeNo!(func_t, 2) == Void))
        t.set!(2)(&partial!(fn, 3));
    static if (!is(TypeNo!(func_t, 3) == Void))
        t.set!(3)(&partial!(fn, 4));
    static if (!is(TypeNo!(func_t, 4) == Void))
        t.set!(4)(&partial!(fn, 5));
    static if (!is(TypeNo!(func_t, 5) == Void))
        t.set!(5)(&partial!(fn, 6));
    static if (!is(TypeNo!(func_t, 6) == Void))
        t.set!(6)(&partial!(fn, 7));
    static if (!is(TypeNo!(func_t, 7) == Void))
        t.set!(7)(&partial!(fn, 8));
    static if (!is(TypeNo!(func_t, 8) == Void))
        t.set!(8)(&partial!(fn, 9));
    static if (!is(TypeNo!(func_t, 9) == Void))
        t.set!(9)(&partial!(fn, 10));
    return t;
}

tuple!()
make_tuple()() {
    tuple!() t;
    return t;
}

tuple!(T1)
make_tuple(T1)(T1 t1) {
    tuple!(T1) t;
    t.arg1 = t1;
    return t;
}

tuple!(T1, T2)
make_tuple(T1, T2)(T1 t1, T2 t2) {
    tuple!(T1, T2) t;
    t.arg1 = t1;
    t.arg2 = t2;
    return t;
}

tuple!(T1, T2, T3)
make_tuple(T1, T2, T3)(T1 t1, T2 t2, T3 t3) {
    tuple!(T1, T2, T3) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    return t;
}

tuple!(T1, T2, T3, T4)
make_tuple(T1, T2, T3, T4)(T1 t1, T2 t2, T3 t3, T4 t4) {
    tuple!(T1, T2, T3, T4) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    return t;
}

tuple!(T1, T2, T3, T4, T5)
make_tuple(T1, T2, T3, T4, T5)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
    tuple!(T1, T2, T3, T4, T5) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    return t;
}

tuple!(T1, T2, T3, T4, T5, T6)
make_tuple(T1, T2, T3, T4, T5, T6)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
    tuple!(T1, T2, T3, T4, T5, T6) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    t.arg6 = t6;
    return t;
}

tuple!(T1, T2, T3, T4, T5, T6, T7)
make_tuple(T1, T2, T3, T4, T5, T6, T7)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
    tuple!(T1, T2, T3, T4, T5, T6, T7) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    t.arg6 = t6;
    t.arg7 = t7;
    return t;
}

tuple!(T1, T2, T3, T4, T5, T6, T7, T8)
make_tuple(T1, T2, T3, T4, T5, T6, T7, T8)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
    tuple!(T1, T2, T3, T4, T5, T6, T7, T8) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    t.arg6 = t6;
    t.arg7 = t7;
    t.arg8 = t8;
    return t;
}

tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9)
make_tuple(T1, T2, T3, T4, T5, T6, T7, T8, T9)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
    tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    t.arg6 = t6;
    t.arg7 = t7;
    t.arg8 = t8;
    t.arg9 = t9;
    return t;
}

tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)
make_tuple(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
    tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) t;
    t.arg1 = t1;
    t.arg2 = t2;
    t.arg3 = t3;
    t.arg4 = t4;
    t.arg5 = t5;
    t.arg6 = t6;
    t.arg7 = t7;
    t.arg8 = t8;
    t.arg9 = t9;
    t.arg10 = t10;
    return t;
}

