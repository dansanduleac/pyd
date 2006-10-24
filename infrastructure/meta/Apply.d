module meta.Apply;

private {
	import meta.FuncMeta;
}


/**
	Call a function, given a tuple of args and a func pointer
*/
template apply(F, T) {
	RetType!(F) apply(F fp, inout T tuple) {
		static if (0 == tuple.length) {
			return fp();
		}
		static if (1 == tuple.length) {
			return fp(tuple.val!(0));
		}
		static if (2 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1));
		}
		static if (3 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2));
		}
		static if (4 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3));
		}
		static if (5 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4));
		}
		static if (6 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5));
		}
		static if (7 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6));
		}
		static if (8 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7));
		}
		static if (9 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8));
		}
		static if (10 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9));
		}
		static if (11 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10));
		}
		static if (12 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11));
		}
		static if (13 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12));
		}
		static if (14 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13));
		}
		static if (15 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14));
		}
		static if (16 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14), tuple.val!(15));
		}
		static if (17 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14), tuple.val!(15), tuple.val!(16));
		}
		static if (18 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14), tuple.val!(15), tuple.val!(16), tuple.val!(17));
		}
		static if (19 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14), tuple.val!(15), tuple.val!(16), tuple.val!(17), tuple.val!(18));
		}
		static if (20 == tuple.length) {
			return fp(tuple.val!(0), tuple.val!(1), tuple.val!(2), tuple.val!(3), tuple.val!(4), tuple.val!(5), tuple.val!(6), tuple.val!(7), tuple.val!(8), tuple.val!(9), tuple.val!(10), tuple.val!(11), tuple.val!(12), tuple.val!(13), tuple.val!(14), tuple.val!(15), tuple.val!(16), tuple.val!(17), tuple.val!(18), tuple.val!(19));
		}
	}
}
