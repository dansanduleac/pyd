module meta.Use;

private {
	import meta.FuncMeta;
}



private struct UseInStruct(T) {
	private {
		alias funcDelegInfoT!(typeof(&T.useInHandler)) info;
		static assert (1 == info.numArgs);
		info.RetType delegate(info.Meta.ArgType!(0)) handler;
	}
	
	public {
		info.RetType opIn(info.Meta.ArgType!(0) dg) {
			return handler(dg);
		}
	}
}


/**
	Provides controlled execution of code blocks.

	Usage:
		use (someObject) in [(args)] {
		};
	
	Result:
		calls someObject.useInHandler, giving it the provided delegate as an argument.
		
	Example:
		class SomeClass {
			void useInHandler(int delegate(int x, float y) dg) {
				writefln("pre");
				writefln("result: ", dg(3, 1.33));
				writefln("post");
			}
		}

		auto sc = new SomeClass;
		use (sc) in (int x, float y) {
			writefln("x inside: %s  y inside: %s", x, y);
			return x * x;
		};
*/
UseInStruct!(T) use(T)(T x) {
	static if (is(T : Object)) {
		assert (x !is null);
	}
	
	UseInStruct!(T) s;
	s.handler = &x.useInHandler;
	return s;
}
