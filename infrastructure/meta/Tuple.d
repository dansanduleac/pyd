module meta.Tuple;


private {
	import std.stdio;
	import meta.Util;
}



/**
	The insides of a tuple
	A - specialization for the current node
	B - void or a RecTuple
*/
template TupleMultiMix(A, B, int depth) {
	A	head;
	
	static if (is(B == void)) {
		const static bool lastNode = true;
	} else {
		const static bool lastNode = false;
	}
	
	static if (!lastNode) {
		mixin meta.Tuple.TupleMultiMix!(B.HeadType, B.TailType, depth + 1)	tail;
	}
	
	static if (lastNode) {
		const static uint length = 1;
	} else {
		const static uint length = tail.length + 1;
	}

	/**
		Get the n-th value from the tuple
	*/
	template val(uint x) {
		static if (x >= length) {
			pragma (msg, "RecTuple index out of bounds: " ~ itoa!(x) ~ " for tuple of length " ~ itoa!(length));
		}
		else static if (0 == x) {
			alias head val;
		}
		else {
			alias tail.val!(x-1) val;
		}
	}
	
	
	// ----------------------------------------------------------------------------------------------------------------------------
	// insertBefore stuff
	// ----------------------------------------------------------------------------------------------------------------------------

	template insertBeforeT(int i, T) {
			static if (0 == i) {
				alias meta.Tuple.RecTuple!(T, meta.Tuple.RecTuple!(A, B, depth+1), depth) insertBeforeT;
			}
			else static if (length == 1) {
				alias meta.Tuple.RecTuple!(A, meta.Tuple.RecTuple!(T, void, depth + 1), depth) insertBeforeT;
			}
			else {
				alias meta.Tuple.RecTuple!(A, meta.Tuple.RecTuple!(B.HeadType, B.TailType, depth + 1).insertBeforeT!(i - 1, T), depth) insertBeforeT;
			}
	}
	
	template partialCopyTo(int i, T) {
		void partialCopyTo(inout T otherTuple) {
			static if (i >= 0) {
				static if (is(typeof(val!(i)) : typeof(otherTuple.val!(i)))) {
					otherTuple.val!(i) = val!(i);
				}
			}
			
			static if (i > 0) partialCopyTo!(i-1, T)(otherTuple);
		}
	}
	
	private template IBA2(int i, T) {
		void IBA2(inout T otherTuple) {
			static if (i < length) {
				otherTuple.val!(i+1) = val!(i);
			}
			
			static if (i+1 < length) IBA2!(i+1, T)(otherTuple);
		}
	}

	// ----------------------------------------------------------------------------------------------------------------------------
	
	template insertBefore(int i, T) {
		static assert (i <= length);
		
		insertBeforeT!(i, T) insertBefore(T x) {
			insertBeforeT!(i, T) res;
			
			partialCopyTo!(i-1, typeof(res))(res);
			res.val!(i) = x;
			IBA2!(i, typeof(res))(res);
			
			return res;
		}
	}
	
	
	template insertAfterT(int i, T) {
		alias insertBeforeT!(i+1, T) insertAfterT;
	}
	
	template insertAfter(int i, T) {
		insertAfterT!(i, T) insertAfter(T x) {
			return insertBefore!(i+1, T)(x);
		}
	}
	
	
	template appendT(T) {
		alias insertBeforeT!(length, T) appendT;
	} 

	template append(T) {
		appendT!(T) append(T x) {
			return insertBefore!(length, T)(x);
		}
	}

	
	template prependT(T) {
		alias insertBeforeT!(0, T) prependT;
	}

	template prepend(T) {
		prependT!(T) prepend(T x) {
			return insertBefore!(0, T)(x);
		}
	}
	
	
	char[] toString() {
		return "[" ~ toStringImpl ~ "]";
	}
	
	private char[] toStringImpl() {
		static if (is(typeof(head.toString))) {
			char[] res = head.toString;
		} else {
			char[] res = std.string.format(head);
		}
		
		static if (!lastNode) {
			return res ~ ":" ~ typeid(typeof(head)).toString ~ ", " ~ tail.toStringImpl();
		} else {
			return res ~ ":" ~ typeid(typeof(head)).toString;
		}
	}
}


struct EmptyTuple {
	char[] toString() { return "[]"; }
	static const int length = 0;
	
	alias void HeadType;
	alias void TailType;


	template Mixer() {
		template insertBeforeT(int i, T) {
			alias Tuple!(T) insertBeforeT;
		}

		template insertBefore(int i, T) {
			insertBeforeT!(i, T) insertBefore(T x) {
				return makeTuple(x);
			}
		}
		
		
		template insertAfterT(int i, T) {
			alias insertBeforeT!(i+1, T) insertAfterT;
		}
		
		template insertAfter(int i, T) {
			insertAfterT!(i, T) insertAfter(T x) {
				return insertBefore!(i+1, T)(x);
			}
		}
		
		
		template appendT(T) {
			alias insertBeforeT!(length, T) appendT;
		} 

		template append(T) {
			appendT!(T) append(T x) {
				return insertBefore!(length, T)(x);
			}
		}

		
		template prependT(T) {
			alias insertBeforeT!(0, T) prependT;
		}

		template prepend(T) {
			prependT!(T) prepend(T x) {
				return insertBefore!(0, T)(x);
			}
		}	
	}

	mixin Mixer mix;
}


struct RecTuple(A, B = void, int depth = 0) {
	alias A HeadType;
	alias B TailType;
	
	mixin TupleMultiMix!(HeadType, TailType, depth) mix;

	static RecTuple opCall() {
		RecTuple res;
		return res;
	}

	static if (length >= 1) {
		static RecTuple opCall(typeof(val!(0)) a0) {
			RecTuple res = opCall();
			res.val!(0) = a0;
			return res;
		}
	}

	static if (length >= 2) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1) {
			RecTuple res = opCall(a0);
			res.val!(1) = a1;
			return res;
		}
	}

	static if (length >= 3) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2) {
			RecTuple res = opCall(a0, a1);
			res.val!(2) = a2;
			return res;
		}
	}

	static if (length >= 4) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3) {
			RecTuple res = opCall(a0, a1, a2);
			res.val!(3) = a3;
			return res;
		}
	}

	static if (length >= 5) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4) {
			RecTuple res = opCall(a0, a1, a2, a3);
			res.val!(4) = a4;
			return res;
		}
	}

	static if (length >= 6) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5) {
			RecTuple res = opCall(a0, a1, a2, a3, a4);
			res.val!(5) = a5;
			return res;
		}
	}

	static if (length >= 7) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5);
			res.val!(6) = a6;
			return res;
		}
	}

	static if (length >= 8) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6);
			res.val!(7) = a7;
			return res;
		}
	}

	static if (length >= 9) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7);
			res.val!(8) = a8;
			return res;
		}
	}

	static if (length >= 10) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8);
			res.val!(9) = a9;
			return res;
		}
	}

	static if (length >= 11) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9);
			res.val!(10) = a10;
			return res;
		}
	}

	static if (length >= 12) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
			res.val!(11) = a11;
			return res;
		}
	}

	static if (length >= 13) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11);
			res.val!(12) = a12;
			return res;
		}
	}

	static if (length >= 14) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12);
			res.val!(13) = a13;
			return res;
		}
	}

	static if (length >= 15) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13);
			res.val!(14) = a14;
			return res;
		}
	}

	static if (length >= 16) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14, typeof(val!(15)) a15) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14);
			res.val!(15) = a15;
			return res;
		}
	}

	static if (length >= 17) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14, typeof(val!(15)) a15, typeof(val!(16)) a16) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
			res.val!(16) = a16;
			return res;
		}
	}

	static if (length >= 18) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14, typeof(val!(15)) a15, typeof(val!(16)) a16, typeof(val!(17)) a17) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16);
			res.val!(17) = a17;
			return res;
		}
	}

	static if (length >= 19) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14, typeof(val!(15)) a15, typeof(val!(16)) a16, typeof(val!(17)) a17, typeof(val!(18)) a18) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17);
			res.val!(18) = a18;
			return res;
		}
	}

	static if (length >= 20) {
		static RecTuple opCall(typeof(val!(0)) a0, typeof(val!(1)) a1, typeof(val!(2)) a2, typeof(val!(3)) a3, typeof(val!(4)) a4, typeof(val!(5)) a5, typeof(val!(6)) a6, typeof(val!(7)) a7, typeof(val!(8)) a8, typeof(val!(9)) a9, typeof(val!(10)) a10, typeof(val!(11)) a11, typeof(val!(12)) a12, typeof(val!(13)) a13, typeof(val!(14)) a14, typeof(val!(15)) a15, typeof(val!(16)) a16, typeof(val!(17)) a17, typeof(val!(18)) a18, typeof(val!(19)) a19) {
			RecTuple res = opCall(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18);
			res.val!(19) = a19;
			return res;
		}
	}
}


template Tuple(T0) {
	alias RecTuple!(T0) Tuple;
}

template Tuple(T0, T1) {
	alias RecTuple!(T0, RecTuple!(T1)) Tuple;
}
template Tuple(T0, T1, T2) {
	alias RecTuple!(T0, .Tuple!(T1, T2)) Tuple;
}

template Tuple(T0, T1, T2, T3) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19)) Tuple;
}

template Tuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20) {
	alias RecTuple!(T0, .Tuple!(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20)) Tuple;
}



template makeTuple() {
	EmptyTuple makeTuple() {
		EmptyTuple res;
		return res;
	}
}

template makeTuple(T0) {
	Tuple!(T0) makeTuple(T0 t0) {
		return Tuple!(T0)(t0);
	}
}

template makeTuple(T0, T1) {
	Tuple!(T0, T1) makeTuple(T0 t0, T1 t1) {
		return Tuple!(T0, T1)(t0, t1);
	}
}

template makeTuple(T0, T1, T2) {
	Tuple!(T0, T1, T2) makeTuple(T0 t0, T1 t1, T2 t2) {
		return Tuple!(T0, T1, T2)(t0, t1, t2);
	}
}

template makeTuple(T0, T1, T2, T3) {
	Tuple!(T0, T1, T2, T3) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3) {
		return Tuple!(T0, T1, T2, T3)(t0, t1, t2, t3);
	}
}

template makeTuple(T0, T1, T2, T3, T4) {
	Tuple!(T0, T1, T2, T3, T4) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4) {
		return Tuple!(T0, T1, T2, T3, T4)(t0, t1, t2, t3, t4);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5) {
	Tuple!(T0, T1, T2, T3, T4, T5) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) {
		return Tuple!(T0, T1, T2, T3, T4, T5)(t0, t1, t2, t3, t4, t5);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6)(t0, t1, t2, t3, t4, t5, t6);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7)(t0, t1, t2, t3, t4, t5, t6, t7);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8)(t0, t1, t2, t3, t4, t5, t6, t7, t8);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17, T18 t18) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17, T18 t18, T19 t19) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19);
	}
}

template makeTuple(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20) {
	Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20) makeTuple(T0 t0, T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7, T8 t8, T9 t9, T10 t10, T11 t11, T12 t12, T13 t13, T14 t14, T15 t15, T16 t16, T17 t17, T18 t18, T19 t19, T20 t20) {
		return Tuple!(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20)(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20);
	}
}
