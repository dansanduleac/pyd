/*
Copyright (c) 2006 Kirk McDonald

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module pyd.op_wrap;

private import python;

private import pyd.class_wrap;
private import pyd.func_wrap;
private import pyd.exception;
private import pyd.make_object;

private import meta.FuncMeta;

template wrapped_class_as_number(T) {
    static PyNumberMethods wrapped_class_as_number = {
        opAdd_wrap!(T),       /*nb_add*/
        opSub_wrap!(T),       /*nb_subtract*/
        opMul_wrap!(T),       /*nb_multiply*/
        opDiv_wrap!(T),       /*nb_divide*/
        opMod_wrap!(T),       /*nb_remainder*/
        null,                 /*nb_divmod*/
        null,                 /*nb_power*/
        opNeg_wrap!(T),       /*nb_negative*/
        opPos_wrap!(T),       /*nb_positive*/
        null,                 /*nb_absolute*/
        null,                 /*nb_nonzero*/
        opCom_wrap!(T),       /*nb_invert*/
        opShl_wrap!(T),       /*nb_lshift*/
        opShr_wrap!(T),       /*nb_rshift*/
        opAnd_wrap!(T),       /*nb_and*/
        opXor_wrap!(T),       /*nb_xor*/
        opOr_wrap!(T),        /*nb_or*/
        null,                 /*nb_coerce*/
        null,                 /*nb_int*/
        null,                 /*nb_long*/
        null,                 /*nb_float*/
        null,                 /*nb_oct*/
        null,                 /*nb_hex*/
        opAddAssign_wrap!(T), /*nb_inplace_add*/
        opSubAssign_wrap!(T), /*nb_inplace_subtract*/
        opMulAssign_wrap!(T), /*nb_inplace_multiply*/
        opDivAssign_wrap!(T), /*nb_inplace_divide*/
        opModAssign_wrap!(T), /*nb_inplace_remainder*/
        null,                 /*nb_inplace_power*/
        opShlAssign_wrap!(T), /*nb_inplace_lshift*/
        opShrAssign_wrap!(T), /*nb_inplace_rshift*/
        opAndAssign_wrap!(T), /*nb_inplace_and*/
        opXorAssign_wrap!(T), /*nb_inplace_xor*/
        opOrAssign_wrap!(T),  /*nb_inplace_or*/
        null,                 /* nb_floor_divide */
        null,                 /* nb_true_divide */
        null,                 /* nb_inplace_floor_divide */
        null,                 /* nb_inplace_true_divide */
    };
}

template wrapped_class_as_sequence(T) {
    static PySequenceMethods wrapped_class_as_sequence = {
        null,                 /*sq_length*/
        opCat_wrap!(T),       /*sq_concat*/
        null,                 /*sq_repeat*/
        null,                 /*sq_item*/
        null,                 /*sq_slice*/
        null,                 /*sq_ass_item*/
        null,                 /*sq_ass_slice*/
        null,                 /*sq_contains*/
        opCatAssign_wrap!(T), /*sq_inplace_concat*/
        null,                 /*sq_inplace_repeat*/
    };
}

template wrapped_class_as_mapping(T) {
    static PyMappingMethods wrapped_class_as_mapping = {
        null,                 /*mp_length*/
        null,                 /*mp_subscript*/
        null,                 /*mp_ass_subscript*/
    };
}

template opfunc_binary_wrap(T, alias opfn) {
    alias wrapped_class_object!(T) wrap_object;
    extern(C)
    PyObject* func(PyObject* self, PyObject* o) {
        PyObject* temp_tuple = PyTuple_New(1);
        if (temp_tuple is null) return null;
        Py_INCREF(o);
        PyTuple_SetItem(temp_tuple, 0, o);
        PyObject* res = func_wrap!(opfn, 1, T).func(self, temp_tuple);
        Py_DECREF(temp_tuple);
        return res;
    }
}

template opfunc_unary_wrap(T, alias opfn) {
    alias wrapped_class_object!(T) wrap_object;
    extern(C)
    PyObject* func(PyObject* self) {
        return func_wrap!(opfn, 0, T).func(self, null);
    }
}

template opindex_sequence_pyfunc(T) {
    alias wrapped_class_object!(T) wrap_object;
    
    extern(C)
    PyObject* func(PyObject* self, int i) {
        return exception_catcher(delegate PyObject*() {
            return _py((cast(wrap_object*)self).d_obj.opIndex(i));
        });
    }
}

template opindexassign_sequence_pyfunc(T) {
    alias wrapped_class_object!(T) wrap_object;

    extern(C)
    int func(PyObject* self, int i, PyObject* o) {
        
    }
}

template opcmp_wrap(T) {
    alias wrapped_class_object!(T) wrap_object;
    alias funcDelegInfoT!(typeof(&T.opCmp)) Info;
    alias Info.Meta.ArgType!(0) OtherT;
    extern(C)
    int func(PyObject* self, PyObject* other) {
        return exception_catcher(delegate int() {
            int result = (cast(wrap_object*)self).d_obj.opCmp(d_type!(OtherT)(other));
            // The Python API reference specifies that tp_compare must return
            // -1, 0, or 1. The D spec says opCmp may return any integer value,
            // and just compares it with zero.
            if (result < 0) return -1;
            if (result == 0) return 0;
            if (result > 0) return 1;
        });
    }
}

// The rest of the file is composed of these short stubs
template opIndex_sequence_wrap(T) {
    static if (is(typeof(&T.opIndex)) &&
               funcDelegInfoT!(typeof(&T.opIndex)).numArgs == 1 &&
               is(funcDelegInfoT!(typeof(&T.opIndex)).Meta.ArgType!(0) : int)
    ) {
        const intargfunc opIndex_sequence_wrap = &opindex_sequence_pyfunc!(T).func;
    } else {
        const intargfunc opIndex_sequence_wrap = null;
    }
}

template opIndexAssign_sequence_wrap(T) {
    static if (true) {
        const intobjargproc opIndexAssign_sequence_wrap = null;
    } else {
        const intobjargproc opIndexAssign_sequence_wrap = null;
    }
}

template opIndex_mapping_wrap(T) {

}

template opIndexAssign_mapping_wrap(T) {

}

template opSlice_wrap(T) {

}

template opSliceAssign_wrap(T) {

}

template opAdd_wrap(T) {
    static if (is(typeof(&T.opAdd))) {
        const binaryfunc opAdd_wrap = &opfunc_binary_wrap!(T, T.opAdd).func;
    } else {
        const binaryfunc opAdd_wrap = null;
    }
}

template opSub_wrap(T) {
    static if (is(typeof(&T.opSub))) {
        const binaryfunc opSub_wrap = &opfunc_binary_wrap!(T, T.opSub).func;
    } else {
        const binaryfunc opSub_wrap = null;
    }
}


template opMul_wrap(T) {
    static if (is(typeof(&T.opMul))) {
        const binaryfunc opMul_wrap = &opfunc_binary_wrap!(T, T.opMul).func;
    } else {
        const binaryfunc opMul_wrap = null;
    }
}


template opDiv_wrap(T) {
    static if (is(typeof(&T.opDiv))) {
        const binaryfunc opDiv_wrap = &opfunc_binary_wrap!(T, T.opDiv).func;
    } else {
        const binaryfunc opDiv_wrap = null;
    }
}


template opMod_wrap(T) {
    static if (is(typeof(&T.opMod))) {
        const binaryfunc opMod_wrap = &opfunc_binary_wrap!(T, T.opMod).func;
    } else {
        const binaryfunc opMod_wrap = null;
    }
}


template opAnd_wrap(T) {
    static if (is(typeof(&T.opAnd))) {
        const binaryfunc opAnd_wrap = &opfunc_binary_wrap!(T, T.opAnd).func;
    } else {
        const binaryfunc opAnd_wrap = null;
    }
}


template opOr_wrap(T) {
    static if (is(typeof(&T.opOr))) {
        const binaryfunc opOr_wrap = &opfunc_binary_wrap!(T, T.opOr).func;
    } else {
        const binaryfunc opOr_wrap = null;
    }
}


template opXor_wrap(T) {
    static if (is(typeof(&T.opXor))) {
        const binaryfunc opXor_wrap = &opfunc_binary_wrap!(T, T.opXor).func;
    } else {
        const binaryfunc opXor_wrap = null;
    }
}


template opShl_wrap(T) {
    static if (is(typeof(&T.opShl))) {
        const binaryfunc opShl_wrap = &opfunc_binary_wrap!(T, T.opShl).func;
    } else {
        const binaryfunc opShl_wrap = null;
    }
}


template opShr_wrap(T) {
    static if (is(typeof(&T.opShr))) {
        const binaryfunc opShr_wrap = &opfunc_binary_wrap!(T, T.opShr).func;
    } else {
        const binaryfunc opShr_wrap = null;
    }
}


template opUShr_wrap(T) {
    static if (is(typeof(&T.opUShr))) {
        const binaryfunc opUShr_wrap = &opfunc_binary_wrap!(T, T.opUShr).func;
    } else {
        const binaryfunc opUShr_wrap = null;
    }
}


template opCat_wrap(T) {
    static if (is(typeof(&T.opCat))) {
        const binaryfunc opCat_wrap = &opfunc_binary_wrap!(T, T.opCat).func;
    } else {
        const binaryfunc opCat_wrap = null;
    }
}


template opAddAssign_wrap(T) {
    static if (is(typeof(&T.opAddAssign))) {
        const binaryfunc opAddAssign_wrap = &opfunc_binary_wrap!(T, T.opAddAssign).func;
    } else {
        const binaryfunc opAddAssign_wrap = null;
    }
}


template opSubAssign_wrap(T) {
    static if (is(typeof(&T.opSubAssign))) {
        const binaryfunc opSubAssign_wrap = &opfunc_binary_wrap!(T, T.opSubAssign).func;
    } else {
        const binaryfunc opSubAssign_wrap = null;
    }
}


template opMulAssign_wrap(T) {
    static if (is(typeof(&T.opMulAssign))) {
        const binaryfunc opMulAssign_wrap = &opfunc_binary_wrap!(T, T.opMulAssign).func;
    } else {
        const binaryfunc opMulAssign_wrap = null;
    }
}


template opDivAssign_wrap(T) {
    static if (is(typeof(&T.opDivAssign))) {
        const binaryfunc opDivAssign_wrap = &opfunc_binary_wrap!(T, T.opDivAssign).func;
    } else {
        const binaryfunc opDivAssign_wrap = null;
    }
}


template opModAssign_wrap(T) {
    static if (is(typeof(&T.opModAssign))) {
        const binaryfunc opModAssign_wrap = &opfunc_binary_wrap!(T, T.opModAssign).func;
    } else {
        const binaryfunc opModAssign_wrap = null;
    }
}


template opAndAssign_wrap(T) {
    static if (is(typeof(&T.opAndAssign))) {
        const binaryfunc opAndAssign_wrap = &opfunc_binary_wrap!(T, T.opAndAssign).func;
    } else {
        const binaryfunc opAndAssign_wrap = null;
    }
}


template opOrAssign_wrap(T) {
    static if (is(typeof(&T.opOrAssign))) {
        const binaryfunc opOrAssign_wrap = &opfunc_binary_wrap!(T, T.opOrAssign).func;
    } else {
        const binaryfunc opOrAssign_wrap = null;
    }
}


template opXorAssign_wrap(T) {
    static if (is(typeof(&T.opXorAssign))) {
        const binaryfunc opXorAssign_wrap = &opfunc_binary_wrap!(T, T.opXorAssign).func;
    } else {
        const binaryfunc opXorAssign_wrap = null;
    }
}


template opShlAssign_wrap(T) {
    static if (is(typeof(&T.opShlAssign))) {
        const binaryfunc opShlAssign_wrap = &opfunc_binary_wrap!(T, T.opShlAssign).func;
    } else {
        const binaryfunc opShlAssign_wrap = null;
    }
}


template opShrAssign_wrap(T) {
    static if (is(typeof(&T.opShrAssign))) {
        const binaryfunc opShrAssign_wrap = &opfunc_binary_wrap!(T, T.opShrAssign).func;
    } else {
        const binaryfunc opShrAssign_wrap = null;
    }
}


template opUShrAssign_wrap(T) {
    static if (is(typeof(&T.opUShrAssign))) {
        const binaryfunc opUShrAssign_wrap = &opfunc_binary_wrap!(T, T.opUShrAssign).func;
    } else {
        const binaryfunc opUShrAssign_wrap = null;
    }
}


template opCatAssign_wrap(T) {
    static if (is(typeof(&T.opCatAssign))) {
        const binaryfunc opCatAssign_wrap = &opfunc_binary_wrap!(T, T.opCatAssign).func;
    } else {
        const binaryfunc opCatAssign_wrap = null;
    }
}


template opIn_wrap(T) {
    static if (is(typeof(&T.opIn_r))) {
        const binaryfunc opIn_wrap = &opfunc_binary_wrap!(T, T.opIn_r).func;
    } else {
        const binaryfunc opIn_wrap = null;
    }
}

template opNeg_wrap(T) {
    static if (is(typeof(&T.opNeg))) {
        const unaryfunc opNeg_wrap = &opfunc_unary_wrap!(T, T.opNeg).func;
    } else {
        const unaryfunc opNeg_wrap = null;
    }
}

template opPos_wrap(T) {
    static if (is(typeof(&T.opPos))) {
        const unaryfunc opPos_wrap = &opfunc_unary_wrap!(T, T.opPos).func;
    } else {
        const unaryfunc opPos_wrap = null;
    }
}

template opCom_wrap(T) {
    static if (is(typeof(&T.opCom))) {
        const unaryfunc opCom_wrap = &opfunc_unary_wrap!(T, T.opCom).func;
    } else {
        const unaryfunc opCom_wrap = null;
    }
}

