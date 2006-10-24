module meta.Instantiate;

private {
	import meta.Tuple;
}

/**
	Given a template T, instantiate it with the types of the elements of the
	tuple type Tu.
*/
template instantiateTemplate(alias T, Tu) {
	alias instantiateTemplateT!(T, Tu).t instantiateTemplate;
}

template instantiateTemplateT(alias T, Tu) {
	template A(uint i) {
		alias typeof(Tu.mix.val!(i)) A;
	}

	static if (Tu.length == 0)
		alias T!() t;
	else static if (Tu.length == 1)
		alias T!(A!(0)) t;
	else static if (Tu.length == 2)
		alias T!(A!(0), A!(1)) t;
	else static if (Tu.length == 3)
		alias T!(A!(0), A!(1), A!(2)) t;
	else static if (Tu.length == 4)
		alias T!(A!(0), A!(1), A!(2), A!(3)) t;
	else static if (Tu.length == 5)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4)) t;
	else static if (Tu.length == 6)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4), A!(5)) t;
	else static if (Tu.length == 7)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4), A!(5), A!(6)) t;
	else static if (Tu.length == 8)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7)) t;
	else static if (Tu.length == 9)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8)) t;
	else static if (Tu.length == 10)
		alias T!(A!(0), A!(1), A!(2), A!(3), A!(4), A!(5), A!(6), A!(7), A!(8), A!(9)) t;
}
