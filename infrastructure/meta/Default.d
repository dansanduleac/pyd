/**
	Various templates for dealing with a function's default arguments.
*/
module meta.Default;

private import meta.FuncMeta;
private import meta.Tuple;
private import meta.Nameof;
private import meta.Util;

/**
	Derives a function that only calls the first n arguments of fn.
*/
template firstArgs(alias fn, uint n, fn_t = typeof(&fn)) {
	alias firstArgsT!(fn, n, fn_t).func firstArgs;
}

template firstArgsT(alias fn, uint args, fn_t = typeof(&fn)) {
	alias RetType!(fn_t) R;
	alias funcDelegInfoT!(fn_t) Info;

	// Shortcut for ArgType
	template A(uint a) {
		// The -1 is pointless; it dates from a time the function
		// metaprogramming module was 1-indexed for function arguments.
		alias Info.Meta.ArgType!(a-1) A;
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

template defaultsTupleT(alias fn, uint MIN_ARGS, fn_t = typeof(&fn), uint current=MIN_ARGS, T = EmptyTuple) {
	alias funcDelegInfoT!(fn_t) Meta;
	const uint MAX_ARGS = Meta.numArgs;
	static if (current > MAX_ARGS) {
		alias T type;
	} else {
		alias defaultsTupleT!(fn, MIN_ARGS, fn_t, current+1, T.mix.appendT!(typeof(&firstArgs!(fn, current, fn_t)))).type type;
	}
}

void loop(alias fn, fn_t, uint i, T)(T* t) {
	static if (i < T.length) {
		const uint args = funcDelegInfoT!(typeof(t.val!(i))).numArgs;
		t.val!(i) = &firstArgs!(fn, args, fn_t);
		loop!(fn, fn_t, i+1, T)(t);
	}
}

/**
	Returns a tuple of function pointers to fn representing all of the valid
	calls to that function, as per its default arguments.
*/
defaultsTupleT!(fn, MIN_ARGS, fn_t).type defaultsTuple(alias fn, uint MIN_ARGS, fn_t = typeof(&fn)) () {
	alias defaultsTupleT!(fn, MIN_ARGS, fn_t).type T;
	T t;
	loop!(fn, fn_t, 0, T)(&t);
	return t;
}

/**
	Derives the minimum number of arguments the given function may be called with.

	This has some cases in which it can fail, or at least not behave exactly as
	expected. For instance, it cannot distinguish between the following:

	void foo(int i);
	void foo(int i, real j);

	and

	void foo(int i, real j=2.0);

	In the first case, calling minArgs!(foo, void function(int, real)) will
	result in 1, which is arguably incorrect. However, minArgs should be "good
	enough" in most cases.
*/
template minArgs(alias fn, fn_t = typeof(&fn)) {
	const uint minArgs = minArgsT!(fn, fn_t).minArgs;
}

template minArgsT(alias fn, fn_t = typeof(&fn)) {
	alias funcDelegInfoT!(fn_t) Info;

	template A(uint i) {
		alias Info.Meta.ArgType!(i) A;
	}

	A!(i) I(uint i)() {
		return A!(i).init;
	}

	static if (is(typeof(fn())))
		const uint minArgs = 0;
	else static if (is(typeof(fn(I!(0)()))))
		const uint minArgs = 1;
	else static if (is(typeof(fn(I!(0)(), I!(1)()))))
		const uint minArgs = 2;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)()))))
		const uint minArgs = 3;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)()))))
		const uint minArgs = 4;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)()))))
		const uint minArgs = 5;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)()))))
		const uint minArgs = 6;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)()))))
		const uint minArgs = 7;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)()))))
		const uint minArgs = 8;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)()))))
		const uint minArgs = 9;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)()))))
		const uint minArgs = 10;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)()))))
		const uint minArgs = 11;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)()))))
		const uint minArgs = 12;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)()))))
		const uint minArgs = 13;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)()))))
		const uint minArgs = 14;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)()))))
		const uint minArgs = 15;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)(), I!(15)()))))
		const uint minArgs = 16;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)(), I!(15)(), I!(16)()))))
		const uint minArgs = 17;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)(), I!(15)(), I!(16)(), I!(17)()))))
		const uint minArgs = 18;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)(), I!(15)(), I!(16)(), I!(17)(), I!(18)()))))
		const uint minArgs = 19;
	else static if (is(typeof(fn(I!(0)(), I!(1)(), I!(2)(), I!(3)(), I!(4)(), I!(5)(), I!(6)(), I!(7)(), I!(8)(), I!(9)(), I!(10)(), I!(11)(), I!(12)(), I!(13)(), I!(14)(), I!(15)(), I!(16)(), I!(17)(), I!(18)(), I!(19)()))))
		const uint minArgs = 20;
}
