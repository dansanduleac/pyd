module meta.Bind;

private {
	import std.conv;
	import meta.Tuple;
	import meta.Apply;
	import meta.FuncMeta;
	import meta.VarArg;
}



/**
	When passed to the 'bind' function, it will mark a dynamic param - one that isn't statically bound
	In boost, they're called _1, _2, _3, etc.. here Arg0, Arg1, Arg2, ...
*/
struct Arg(int i) {
	static assert (i >= 0);
	alias i argNr;
	
	char[] toString() {
		return "Arg!(" ~ std.conv.toString(i) ~ ")";
	}
}


Arg!(0) Arg0;
Arg!(1) Arg1;
Arg!(2) Arg2;
Arg!(3) Arg3;
Arg!(4) Arg4;
Arg!(5) Arg5;
Arg!(6) Arg6;
Arg!(7) Arg7;
Arg!(8) Arg8;
Arg!(9) Arg9;
Arg!(10) Arg10;
Arg!(11) Arg11;
Arg!(12) Arg12;
Arg!(13) Arg13;
Arg!(14) Arg14;
Arg!(15) Arg15;
Arg!(16) Arg16;
Arg!(17) Arg17;
Arg!(18) Arg18;
Arg!(19) Arg19;



// For some internal workings
private struct NoType {
}


template isDynArg(T) {
	static if (is(typeof(T.argNr))) {
		static if(is(T : Arg!(T.argNr))) {
			static const bool isDynArg = true;
		} else static const bool isDynArg = false;
	} else static const bool isDynArg = false;
}


template isDynArg(T, int i) {
	static const bool isDynArg = is(T : Arg!(i));
}


template isBoundFunc(T) {
	static if (is(T.FuncType)) {
		static if (is(T.BoundArgs)) {
			static if (is(T : BoundFunc!(T.FuncType, T.BoundArgs))) {
				static const bool isBoundFunc = true;
			} else static const bool isBoundFunc = false;
		} else static const bool isBoundFunc = false;
	} else static const bool isBoundFunc = false;
}


template isTuple(T) {
	static if (is(T.HeadType)) {
		static if (is(T.TailType)) {
			static if (is(T : RecTuple!(T.HeadType, T.TailType))) {
				static const bool isTuple = true;
			} else static const bool isTuple = false;
		} else static const bool isTuple = false;
	} else static const bool isTuple = false;
}

static assert(isTuple!(Tuple!(int)));
static assert(isTuple!(Tuple!(float, char)));
static assert(isTuple!(Tuple!(double, float, int, char[])));
static assert(isTuple!(Tuple!(Object, creal, long)));
static assert(!isTuple!(Object));
static assert(!isTuple!(int));



/**
	Prepend New to the List; if the list is an EmptyTuple, create a fresh Tuple
*/
private template prependNoEmpty(New, List) {
	static if (is(List == EmptyTuple)) {
		alias Tuple!(New) prependNoEmpty;
	} else {
		alias List.mix.prependT!(New) prependNoEmpty;
	}
}


/**
	Gather all types that a given dynamic arg uses
	The types will be returned/aliased to a tuple
*/
template dynArgTypes(int i, FuncArgs, BoundArgs) {
	
	// performs slicing on the tuple ... tuple[i .. length]
	template sliceOffTuple(T, int i) {
		static if (i > 0) {
			alias sliceOffTuple!(T.TailType, i-1).res res;
		} else {
			alias T res;
		}
	}
	
	// prepends a T to the resulting tuple
	// SkipType - the type in BoundArgs that we're just processing
	template prependType(T, SkipType) {
		static if (isTuple!(SkipType) && !isTuple!(FuncArgs.HeadType)) {
			// perform tuple decomposition
			// e.g. if a function being bound is accepting (int, int) and the current type is a Tuple!(int, int),
			// then skip just one tuple in the bound args and the length of the tuple in func args
			// - skips two ints and one tuple in the example
			alias prependNoEmpty!(T, dynArgTypes!(i, sliceOffTuple!(FuncArgs, SkipType.length).res, BoundArgs.TailType).res) res;
		} else {
			alias prependNoEmpty!(T, dynArgTypes!(i, sliceOffTuple!(FuncArgs, 1).res, BoundArgs.TailType).res) res;
		}
	}
	
	// iteration end detector
	static if (is(BoundArgs == void)) {
		static if (!is(FuncArgs == void)) {
			// this assert will always be false, we'll only use it to get a nicer error msg
			static assert (is(FuncArgs.HeadType == void), "BoundArgs and FuncArgs must have the same length");
		}
		
		// just so that things don't explode in other places too much
		alias EmptyTuple res;
	}
	else {
		
		// w00t, detected a regular dynamic arg
		static if (isDynArg!(BoundArgs.HeadType, i)) {
			alias prependType!(FuncArgs.HeadType, BoundArgs.HeadType).res res;
		} 
		
		// the arg is a bound function, extract info from its meta
		else static if (isBoundFunc!(BoundArgs.HeadType)) {
			// does that function even have any dynamic args ?
			static if (BoundArgs.HeadType.DynArgs.length > i) {
				alias prependType!(typeof(BoundArgs.HeadType.DynArgs.mix.val!(i)), BoundArgs.HeadType.FuncMeta.RetType).res res;
			}
			// it doesn't
			else {
				alias prependType!(NoType, BoundArgs.HeadType.FuncMeta.RetType).res res;
			}
		}
		
		// a static arg, just skip it
		else alias prependType!(NoType, BoundArgs.HeadType).res res;
	}
}


/**
	Checks whether the type from TypeList[index] is castable to the rest of the types in the list
*/
template canCastType(TypeList, int index, int iter=0) {
	static if (iter < TypeList.length) {
		// check the castability :D
		const static bool canCastType =
			(	is(typeof(TypeList.mix.val!(index)) : typeof(TypeList.mix.val!(iter)))
				||
				is(typeof(TypeList.mix.val!(iter)) : NoType)		// skip bogus items
			)
			&& canCastType!(TypeList, index, iter+1);
	}
	else {
		// to end the iteration...
		const static bool canCastType = true;
	}
}


/**
	Finds the first type in the list that can be casted to all the rest in the same list
*/
template bestTypeFromList(TypeList) {
	template loop(int i) {
		static if (i < TypeList.length) {
			alias typeof(TypeList.mix.val!(i)) CurType;
			
			static if (!is(CurType : NoType) && canCastType!(TypeList, i)) {
				alias CurType res;
			} else {
				alias loop!(i+1).res res;
			}
		}
		else {
			alias NoType res;
		}
	}
	
	alias loop!(0).res res;
}


// just a simple util
private template maxInt(int a, int b) {
	static if (a > b) static const int maxInt = a;
	else static const int maxInt = b;
}


/**
	Given a list of BoundArgs, it returns the nuber of args that should be specified dynamically
*/
template numDynArgs(BoundArgs) {
	static if (is(BoundArgs == void)) {
		// end the itration
		static const int res = 0;
	}
	else static if (BoundArgs.length == 0) {
		// received an EmptyTuple
		static const int res = 0;
	} else {
		// ordinary dynamic arg
		static if (isDynArg!(BoundArgs.HeadType)) {
			static const int res = maxInt!(BoundArgs.HeadType.argNr+1, numDynArgs!(BoundArgs.TailType).res);
		}
		
		// count the args in nested / composed functions
		else static if (isBoundFunc!(BoundArgs.HeadType)) {
			static const int res = maxInt!(BoundArgs.HeadType.DynArgs.length, numDynArgs!(BoundArgs.TailType).res);
		}
		
		// statically bound arg, skip it
		else {
 			static const int res = numDynArgs!(BoundArgs.TailType).res;
		}
	}
}


/**
	Given a function's meta info, retrieve its arg types in a tidy Tuple
*/
private template getFuncArgsTypes(Meta) {
	template loop(int i) {
		static if (i < Meta.numArgs) {
			alias prependNoEmpty!(Meta.Meta.ArgType!(i), loop!(i+1).res) res;
		} else {
			alias EmptyTuple res;
		}
	}
	
	alias loop!(0).res res;
}


// Added 2006-10-17 by KGM
/**
	Given a function pointer or delegate type, derive a Tuple type based on its
	argument types.
*/
template getFuncTuple(Fn) {
	alias getFuncArgsTypes!(funcDelegInfoT!(Fn)).res getFuncTuple;
}

/**
	Get a tuple of all dynamic args a function binding will need
	take nested/composed functions as well as tuple decomposition into account
*/
template getDynArgTypes(FuncArgs, BoundArgs) {
	template loop(int i) {
		static if (i < numDynArgs!(BoundArgs).res) {
			alias dynArgTypes!(i, FuncArgs, BoundArgs).res argTypeList;
			
			// make sure the arg is used
			static if(!is(argTypeList == EmptyTuple)) {
				alias bestTypeFromList!(argTypeList).res argType;
			} else {
				alias NoType argType;		// should be harmless
			}

			alias prependNoEmpty!(argType, loop!(i+1).res) res;
		} else {
			alias EmptyTuple res;
		}
	}
	
	alias loop!(0).res res;
}


/**
	Retrieve a tuple instance of all args a bound function needs to be called
	Evaluate nested functions, decompose tuples, etc
*/
template getArgValues(FuncArgs, BoundArgs, DynArgs) {
	
	/**
		Number of args in the bound function that this Src arg will cover
	*/
	template getArgLen(Dst, Src) {
		// if the arg is a tuple and the target isn't one, it will be expanded/decomposed to the tuple's length
		static if (isTuple!(Src) && !isTuple!(Dst)) {
			static const int getArgLen = Src.length;
		}
		// plain arg
		else {
			static const int getArgLen = 1;
		}
	}
	
	/**
		Fill the funcArgs tuple, given the info from the Src entity
	*/
	template copyArg(int i, int j, int n, Dst, Src) {
		void copyArg(inout FuncArgs funcArgs, inout Src s) {
			// if it's a tuple, copy stuff over from it
			static if (isTuple!(Src) && !isTuple!(Dst)) {
				funcArgs.val!(i) = s.val!(j);
				static if (j+1 < n) {
					copyArg!(i+1, j+1, n, Dst, Src)(funcArgs, s);
				}
			}
			// plain arg, just assign it
			else {
				funcArgs.val!(i) = s;
			}
		}
	}
	
	// loop thru all args and copy all the needed data
	template loop(int i, int j) {
		void loop(inout FuncArgs funcArgs, inout BoundArgs boundArgs, inout DynArgs dynArgs) {
			alias typeof(funcArgs.mix.val!(i)) DstType;
			
			// a dynamically-specified arg
			static if (isDynArg!(typeof(boundArgs.mix.val!(j)))) {
				alias typeof(dynArgs.mix.val!(boundArgs.mix.val!(j).argNr)) SrcType;
				
				// the arg may have a length > 1 in case of a tuple that's to be expanded
				const int argLen = getArgLen!(DstType, SrcType);
				
				copyArg!(i, 0, argLen, DstType, SrcType)(funcArgs, dynArgs.mix.val!(boundArgs.mix.val!(j).argNr));
			}
			
			// a composed/nested function
			else static if (isBoundFunc!(typeof(boundArgs.mix.val!(j)))) {
				
				// return type of the function
				alias typeof(boundArgs.mix.val!(j).theFunc!(DynArgs)(dynArgs)) SrcType;

				// the arg may have a length > 1 in case of a tuple that's to be expanded
				const int argLen = getArgLen!(DstType, SrcType);
				
				// call the func and get its result
				SrcType src = boundArgs.val!(j).theFunc!(DynArgs)(dynArgs);
				
				copyArg!(i, 0, argLen, DstType, SrcType)(funcArgs, src);
			}
			
			// a statically - bound arg
			else {
				alias typeof(boundArgs.mix.val!(j)) SrcType;
				
				// the arg may have a length > 1 in case of a tuple that's to be expanded
				const int argLen = getArgLen!(DstType, SrcType);
				
				copyArg!(i, 0, argLen, DstType, SrcType)(funcArgs, boundArgs.val!(j));
			}
			

			// process the rest of data
			static if (i+argLen < funcArgs.length) {
				loop!(i+argLen, j+1)(funcArgs, boundArgs, dynArgs);
			}
		}
	}
	
	void getArgValues(inout FuncArgs funcArgs, inout BoundArgs boundArgs, inout DynArgs dynArgs) {
		static if (funcArgs.length > 0) {
			loop!(0, 0)(funcArgs, boundArgs, dynArgs);
		}
	}
}


/**
	A class that identifies a bound function, along with its nested funcs and statically bound params
	Created by the 'bind' function
*/
class BoundFunc(FT, BoundArgsT)
{
	// meta
	alias FT										FuncType;
	alias funcDelegInfoT!(FT)						FuncMeta;
	alias getFuncArgsTypes!(FuncMeta).res			FuncArgs;
	alias FuncMeta.RetType							RetType;
	alias BoundArgsT								BoundArgs;
	alias getDynArgTypes!(FuncArgs, BoundArgs).res	DynArgs;
	
	// data
	FT				fp;
	BoundArgs		boundArgs;
	
	
	/**
		This is the function called by 'call' <- a mixin-generated function
	*/
	private template theFunc(ArgList) {
		RetType theFunc(ArgList dynArgs) {
			FuncArgs funcArgs;
			getArgValues!(FuncArgs, BoundArgs, ArgList).getArgValues(funcArgs, boundArgs, dynArgs);
			return apply(fp, funcArgs);
		}
	}
	
	
	/**
		Create the 'call' function with the specified return type and number and types of args
	*/
	mixin DeclareFunc!(RetType, DynArgs, theFunc);
	alias call opCall;

	/**
		The type of the delegate that may be returned from this object
	*/
	template PtrType() {
		alias typeof(&(new BoundFunc).call) PtrType;
	}
	
	/**
		Get a delegate. Equivalent to getting it thru &foo.call
	*/
	PtrType!() ptr() {
		return &this.opCall;
	}
}


/**
	This function is the one called by a mixin-generated set of 'bind' functions
*/
template bindImpl(FT, ArgList) {
	BoundFunc!(FT, ArgList) bindImpl(FT fp, ArgList args) {
		auto res = new BoundFunc!(FT, ArgList);
		res.fp = fp;
		res.boundArgs = args;
		return res;
	}
}

/*
	Needed for the bind func generator
*/
template BindRetType(FT, ArgList) {
	alias BoundFunc!(FT, ArgList) BindRetType;
}


/*
	Generate the bind function set
*/
mixin DeclareVarArgFunc1!(BindRetType, bindImpl) bindVarArg;
alias bindVarArg.call bind;
