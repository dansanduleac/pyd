module meta.FuncMeta;


/**
	Meta information about a function / delegate
*/
struct FuncMeta(int NumArgs, Ret, T0=void, T1=void, T2=void, T3=void, T4=void, T5=void, T6=void, T7=void, T8=void, T9=void, T10=void, T11=void, T12=void, T13=void, T14=void, T15=void, T16=void, T17=void, T18=void, T19=void, T20=void) {
	alias FuncMeta Meta;

	//! numer of args of the function
	static const int	numArgs = NumArgs;
	
	//! return type of the function
	alias	Ret			RetType;
	
	//! type of the n-th arg
	template ArgType(int i) {
		static if (0 == i) alias T0 ArgType;
		else static if (1 == i) alias T1 ArgType;
		else static if (2 == i) alias T2 ArgType;
		else static if (3 == i) alias T3 ArgType;
		else static if (4 == i) alias T4 ArgType;
		else static if (5 == i) alias T5 ArgType;
		else static if (6 == i) alias T6 ArgType;
		else static if (7 == i) alias T7 ArgType;
		else static if (8 == i) alias T8 ArgType;
		else static if (9 == i) alias T9 ArgType;
		else static if (10 == i) alias T10 ArgType;
		else static if (11 == i) alias T11 ArgType;
		else static if (12 == i) alias T12 ArgType;
		else static if (13 == i) alias T13 ArgType;
		else static if (14 == i) alias T14 ArgType;
		else static if (15 == i) alias T15 ArgType;
		else static if (16 == i) alias T16 ArgType;
		else static if (17 == i) alias T17 ArgType;
		else static if (18 == i) alias T18 ArgType;
		else static if (19 == i) alias T19 ArgType;
		else static if (20 == i) alias T20 ArgType;
		else alias void ArgType;
	}
}


template funcInfo(Ret) {
	FuncMeta!(0, Ret) funcInfo(Ret function() x) { assert(false); };
}

template funcInfo(Ret, T0) {
	FuncMeta!(1, Ret, T0) funcInfo(Ret function(T0) x) { assert(false); };
}

template funcInfo(Ret, T0, T1) {
	FuncMeta!(2, Ret, T0, T1) funcInfo(Ret function(T0, T1) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2) {
	FuncMeta!(3, Ret, T0, T1, T2) funcInfo(Ret function(T0, T1, T2) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3) {
	FuncMeta!(4, Ret, T0, T1, T2, T3) funcInfo(Ret function(T0, T1, T2, T3) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4) {
	FuncMeta!(5, Ret, T0, T1, T2, T3, T4) funcInfo(Ret function(T0, T1, T2, T3, T4) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5) {
	FuncMeta!(6, Ret, T0, T1, T2, T3, T4, T5) funcInfo(Ret function(T0, T1, T2, T3, T4, T5) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6) {
	FuncMeta!(7, Ret, T0, T1, T2, T3, T4, T5, T6) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7) {
	FuncMeta!(8, Ret, T0, T1, T2, T3, T4, T5, T6, T7) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8) {
	FuncMeta!(9, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
	FuncMeta!(10, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
	FuncMeta!(11, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
	FuncMeta!(12, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
	FuncMeta!(13, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
	FuncMeta!(14, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) {
	FuncMeta!(15, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) {
	FuncMeta!(16, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) {
	FuncMeta!(17, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) {
	FuncMeta!(18, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) {
	FuncMeta!(19, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) x) { assert(false); };
}

template funcInfo(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) {
	FuncMeta!(20, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) funcInfo(Ret function(T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) x) { assert(false); };
}

// inout function argument support
template funcInfoInout(Ret, T0) {
	FuncMeta!(1, Ret, T0)
	funcInfoInout(Ret function(inout T0) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1) {
	FuncMeta!(2, Ret, T0, T1)
	funcInfoInout(Ret function(inout T0, inout T1) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2) {
	FuncMeta!(3, Ret, T0, T1, T2)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3) {
	FuncMeta!(4, Ret, T0, T1, T2, T3)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4) {
	FuncMeta!(5, Ret, T0, T1, T2, T3, T4)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5) {
	FuncMeta!(6, Ret, T0, T1, T2, T3, T4, T5)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6) {
	FuncMeta!(7, Ret, T0, T1, T2, T3, T4, T5, T6)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7) {
	FuncMeta!(8, Ret, T0, T1, T2, T3, T4, T5, T6, T7)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8) {
	FuncMeta!(9, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
	FuncMeta!(10, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
	FuncMeta!(11, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11) {
	FuncMeta!(12, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12) {
	FuncMeta!(13, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13) {
	FuncMeta!(14, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14) {
	FuncMeta!(15, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15) {
	FuncMeta!(16, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14, inout T15) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16) {
	FuncMeta!(17, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14, inout T15, inout T16) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17) {
	FuncMeta!(18, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14, inout T15, inout T16, inout T17) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18) {
	FuncMeta!(19, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14, inout T15, inout T16, inout T17, inout T18) x) { assert(false); };
}

template funcInfoInout(Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19) {
	FuncMeta!(20, Ret, T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19)
	funcInfoInout(Ret function(inout T0, inout T1, inout T2, inout T3, inout T4, inout T5, inout T6, inout T7, inout T8, inout T9, inout T10, inout T11, inout T12, inout T13, inout T14, inout T15, inout T16, inout T17, inout T18, inout T19) x) { assert(false); };
}



/**
	Retrieve meta func info, given a type of the function
*/
template funcInfoT(T) {
	alias typeof(funcInfo(T.init)) funcInfoT;
}


/**
	Converts a delegate type to a function pointer type, a function type to a
	function pointer type, and leaves function pointer types alone.
*/
template funcType(T) {
	static if (is(T FT == delegate)) {
		alias FT* funcType;
	} else static if (is(T == function)) {
		alias T* funcType;
	} else {
		alias T funcType;
	}
}

/**
	Get meta info for a function or a delegate
*/
template funcDelegInfoT(T) {
	alias funcInfoT!(funcType!(T)) funcDelegInfoT;
//	static if (is(T FT == delegate)) {
//		alias funcInfoT!(FT*) funcDelegInfoT;
//	} else {
//		alias funcInfoT!(T) funcDelegInfoT;
//	}
}

template funcDelegInoutInfoT(T) {
	alias typeof(funcInfoInout(funcType!(T).init)) funcDelegInoutInfoT;
}


private template Deref(T) {
	alias typeof(*T) Deref;
}


/**
	Return type of a function / delegate without the massive number of templates
*/
template RetType(T) {
	static if (is(Deref!(funcType!(T)) U == function)) {
		alias U RetType;
	}
//	static if (is(Deref!(T) U == function)) {
//		alias U RetType;
//	} else static if (is(T U == delegate)) {
//		static if (is(U X == function)) {
//			alias X RetType;
//		}
//	}
} 
