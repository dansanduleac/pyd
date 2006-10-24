module meta.VarArg;

private {
	import meta.Tuple;
}


/**
	Declares a function called 'call' with the args specified in the tuple. It gathers its args into a tuple and calls the provided func
*/
template DeclareFunc(RetType, ArgList, alias func) {
	private template AT(int i) {
		alias typeof(ArgList.mix.val!(i)) AT;
	}
	

	static if (0 == ArgList.length) {
		RetType call() {
			EmptyTuple e;
			return func!(EmptyTuple)(e);
		}
	}

	static if (1 == ArgList.length) {
		RetType call(AT!(0) a0) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0));
		}
	}


	static if (2 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1));
		}
	}


	static if (3 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2));
		}
	}


	static if (4 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3));
		}
	}


	static if (5 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4));
		}
	}


	static if (6 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5));
		}
	}


	static if (7 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6));
		}
	}


	static if (8 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7));
		}
	}


	static if (9 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8));
		}
	}


	static if (10 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9));
		}
	}


	static if (11 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10));
		}
	}


	static if (12 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11));
		}
	}


	static if (13 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12));
		}
	}


	static if (14 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13));
		}
	}


	static if (15 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14));
		}
	}


	static if (16 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14, AT!(15) a15) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15));
		}
	}


	static if (17 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14, AT!(15) a15, AT!(16) a16) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16));
		}
	}


	static if (18 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14, AT!(15) a15, AT!(16) a16, AT!(17) a17) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17));
		}
	}


	static if (19 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14, AT!(15) a15, AT!(16) a16, AT!(17) a17, AT!(18) a18) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18));
		}
	}


	static if (20 == ArgList.length) {
		RetType call(AT!(0) a0, AT!(1) a1, AT!(2) a2, AT!(3) a3, AT!(4) a4, AT!(5) a5, AT!(6) a6, AT!(7) a7, AT!(8) a8, AT!(9) a9, AT!(10) a10, AT!(11) a11, AT!(12) a12, AT!(13) a13, AT!(14) a14, AT!(15) a15, AT!(16) a16, AT!(17) a17, AT!(18) a18, AT!(19) a19) {
			return func!(ArgList)(cast(ArgList)makeTuple(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19));
		}
	}
}



/**
	Declare a set of 'call' functions each of which creates a tuple and calls a specialized version of 'func'
*/
template DeclareVarArgFunc1(alias RetType, alias func) {
	template call(Arg0) {
		RetType!(Arg0, EmptyTuple) call(Arg0 a0) {
			EmptyTuple e;
			return func!(Arg0, EmptyTuple)(a0, e);
		}
	}	template call(Arg0, T0) {
		RetType!(Arg0, Tuple!(T0)) call(Arg0 a0, T0 t0) {
			return func!(Arg0, Tuple!(T0))(a0, makeTuple(t0));
		}
	}


	template call(Arg0, T0, T1) {
		RetType!(Arg0, Tuple!(T0, T1)) call(Arg0 a0, T0 t0, T1 t1) {
			return func!(Arg0, Tuple!(T0, T1))(a0, makeTuple(t0, t1));
		}
	}


	template call(Arg0, T0, T1, T2) {
		RetType!(Arg0, Tuple!(T0, T1, T2)) call(Arg0 a0, T0 t0, T1 t1, T2 t2) {
			return func!(Arg0, Tuple!(T0, T1, T2))(a0, makeTuple(t0, t1, t2));
		}
	}


	template call(Arg0, T0, T1, T2, T3) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3))(a0, makeTuple(t0, t1, t2, t3));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4))(a0, makeTuple(t0, t1, t2, t3, t4));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5))(a0, makeTuple(t0, t1, t2, t3, t4, t5));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17, T18 t18) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18));
		}
	}


	template call(Arg0, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) {
		RetType!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19)) call(Arg0 a0, T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17, T18 t18, T19 t19) {
			return func!(Arg0, Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19))(a0, makeTuple(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19));
		}
	}
}


