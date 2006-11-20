/**
	Various templates for dealing with a function's default arguments.
*/
module meta.Default;

private import std.traits;
private import std.typetuple;

/**
	Derives a function that only calls the first n arguments of fn.
*/
template firstArgs(alias fn, uint n, fn_t = typeof(&fn)) {
	alias firstArgsT!(fn, n, fn_t).func firstArgs;
}

template firstArgsT(alias fn, uint args, fn_t = typeof(&fn)) {
	alias ReturnType!(fn_t) R;
	alias ParameterTypeTuple!(fn_t) T;

	R func(T[0 .. args] t) {
		static if (is(R == void)) {
			fn(t);
			return;
		} else {
			return fn(t);
		}
	}
}

template defaultsTupleT(alias fn, uint MIN_ARGS, fn_t = typeof(&fn), uint current=MIN_ARGS, T ...) {
	alias ParameterTypeTuple!(fn_t) Tu;
	const uint MAX_ARGS = Tu.length;
	static if (current > MAX_ARGS) {
		alias T type;
	} else {
		alias defaultsTupleT!(fn, MIN_ARGS, fn_t, current+1, T, typeof(&firstArgs!(fn, current, fn_t))).type type;
	}
}

/**
	Returns a tuple of function pointers to fn representing all of the valid
	calls to that function, as per its default arguments.
*/
void defaultsTuple(alias fn, uint MIN_ARGS, fn_t = typeof(&fn)) (
	void delegate(defaultsTupleT!(fn, MIN_ARGS, fn_t).type) dg
) {
	alias defaultsTupleT!(fn, MIN_ARGS, fn_t).type T;
	T t;
	foreach(i, arg; t) {
		t[i] = &firstArgs!(fn, ParameterTypeTuple!(typeof(t[i])).length, fn_t);
	}
	dg(t);
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
	alias ParameterTypeTuple!(fn_t) T;

	T[i] I(uint i)() {
		return T[i].init;
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
