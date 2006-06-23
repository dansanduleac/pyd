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
module pyd.type;

private import python;
private import pyd.object;
private import pyd.lazy_load;


// The actual references to the objects.
private {
    object m_DPy_Type_Type;
    object m_DPy_BaseObject_Type;
    object m_DPy_Super_Type;

    object m_DPy_None_Type;

    object m_DPy_Unicode_Type;
    object m_DPy_Int_Type;
    object m_DPy_Bool_Type;
    object m_DPy_Long_Type;
    object m_DPy_Float_Type;
    object m_DPy_Complex_Type;
    object m_DPy_Range_Type;
    object m_DPy_BaseString_Type;
    object m_DPy_String_Type;
    object m_DPy_Buffer_Type;
    object m_DPy_Tuple_Type;
    object m_DPy_List_Type;
    object m_DPy_Dict_Type;
    object m_DPy_Enum_Type;
    object m_DPy_Reversed_Type;
    object m_DPy_CFunction_Type;
    object m_DPy_Module_Type;
    object m_DPy_Function_Type;
    object m_DPy_ClassMethod_Type;
    object m_DPy_StaticMethod_Type;
    object m_DPy_Class_Type;
    object m_DPy_Instance_Type;
    object m_DPy_Method_Type;
    object m_DPy_File_Type;
    object m_DPy_Code_Type;
    object m_DPy_Frame_Type;
    object m_DPy_Gen_Type;
    object m_DPy_Set_Type;
    object m_DPy_FrozenSet_Type;

    object m_DPy_CObject_Type;
    object m_DPy_TraceBack_Type;
    object m_DPy_Slice_Type;
    object m_DPy_Cell_Type;
    object m_DPy_SeqIter_Type;
    object m_DPy_CallIter_Type;
    object m_DPy_Property_Type;

    object m_DPy_Weakref_RefType;
    object m_DPy_Weakref_ProxyType;
    object m_DPy_Weakref_CallableProxyType;
} /* end private */

// Whenever you want an instance of a object, it's best to use one of these
// helper functions. If you want, e.g., DPy_Int_Type, just call DPy_Int_Type(),
// and it will (a) construct the instance if it hasn't been constructed yet,
// and (b) return it.
alias lazy_load!(m_DPy_Type_Type, PyType_Type_p) DPy_Type_Type;
alias lazy_load!(m_DPy_BaseObject_Type, PyBaseObject_Type_p) DPy_BaseObject_Type;
alias lazy_load!(m_DPy_Super_Type, PySuper_Type_p) DPy_Super_Type;

alias lazy_load!(m_DPy_None_Type, PyNone_Type_p) DPy_None_Type;

alias lazy_load!(m_DPy_Unicode_Type, PyUnicode_Type_p) DPy_Unicode_Type;
alias lazy_load!(m_DPy_Int_Type, PyInt_Type_p) DPy_Int_Type;
alias lazy_load!(m_DPy_Bool_Type, PyBool_Type_p) DPy_Bool_Type;
alias lazy_load!(m_DPy_Long_Type, PyLong_Type_p) DPy_Long_Type;
alias lazy_load!(m_DPy_Float_Type, PyFloat_Type_p) DPy_Float_Type;
alias lazy_load!(m_DPy_Complex_Type, PyComplex_Type_p) DPy_Complex_Type;
alias lazy_load!(m_DPy_Range_Type, PyRange_Type_p) DPy_Range_Type;
alias lazy_load!(m_DPy_BaseString_Type, PyBaseString_Type_p) DPy_BaseString_Type;
alias lazy_load!(m_DPy_String_Type, PyString_Type_p) DPy_String_Type;
alias lazy_load!(m_DPy_Buffer_Type, PyBuffer_Type_p) DPy_Buffer_Type;
alias lazy_load!(m_DPy_Tuple_Type, PyTuple_Type_p) DPy_Tuple_Type;
alias lazy_load!(m_DPy_List_Type, PyList_Type_p) DPy_List_Type;
alias lazy_load!(m_DPy_Dict_Type, PyDict_Type_p) DPy_Dict_Type;
alias lazy_load!(m_DPy_Enum_Type, PyEnum_Type_p) DPy_Enum_Type;
alias lazy_load!(m_DPy_Reversed_Type, PyReversed_Type_p) DPy_Reversed_Type;
alias lazy_load!(m_DPy_CFunction_Type, PyCFunction_Type_p) DPy_CFunction_Type;
alias lazy_load!(m_DPy_Module_Type, PyModule_Type_p) DPy_Module_Type;
alias lazy_load!(m_DPy_Function_Type, PyFunction_Type_p) DPy_Function_Type;
alias lazy_load!(m_DPy_ClassMethod_Type, PyClassMethod_Type_p) DPy_ClassMethod_Type;
alias lazy_load!(m_DPy_StaticMethod_Type, PyStaticMethod_Type_p) DPy_StaticMethod_Type;
alias lazy_load!(m_DPy_Class_Type, PyClass_Type_p) DPy_Class_Type;
alias lazy_load!(m_DPy_Instance_Type, PyInstance_Type_p) DPy_Instance_Type;
alias lazy_load!(m_DPy_Method_Type, PyMethod_Type_p) DPy_Method_Type;
alias lazy_load!(m_DPy_File_Type, PyFile_Type_p) DPy_File_Type;
alias lazy_load!(m_DPy_Code_Type, PyCode_Type_p) DPy_Code_Type;
alias lazy_load!(m_DPy_Frame_Type, PyFrame_Type_p) DPy_Frame_Type;
alias lazy_load!(m_DPy_Gen_Type, PyGen_Type_p) DPy_Gen_Type;
alias lazy_load!(m_DPy_Set_Type, PySet_Type_p) DPy_Set_Type;
alias lazy_load!(m_DPy_FrozenSet_Type, PyFrozenSet_Type_p) DPy_FrozenSet_Type;

alias lazy_load!(m_DPy_CObject_Type, PyCObject_Type_p) DPy_CObject_Type;
alias lazy_load!(m_DPy_TraceBack_Type, PyTraceBack_Type_p) DPy_TraceBack_Type;
alias lazy_load!(m_DPy_Slice_Type, PySlice_Type_p) DPy_Slice_Type;
alias lazy_load!(m_DPy_Cell_Type, PyCell_Type_p) DPy_Cell_Type;
alias lazy_load!(m_DPy_SeqIter_Type, PySeqIter_Type_p) DPy_SeqIter_Type;
alias lazy_load!(m_DPy_CallIter_Type, PyCallIter_Type_p) DPy_CallIter_Type;
alias lazy_load!(m_DPy_Property_Type, PyProperty_Type_p) DPy_Property_Type;

alias lazy_load!(m_DPy_Weakref_RefType, _PyWeakref_RefType_p) DPy_Weakref_RefType;
alias lazy_load!(m_DPy_Weakref_ProxyType, _PyWeakref_ProxyType_p) DPy_Weakref_ProxyType;
alias lazy_load!(m_DPy_Weakref_CallableProxyType, _PyWeakref_CallableProxyType_p) DPy_Weakref_CallableProxyType;

// Safely destructs the singleton objects, which doesn't happen by default for
// global (or static) objects. This typically doesn't matter (memory is
// reclaimed by the OS on program exit), but Python likes to keep its reference
// counts.
static ~this() {
    delete m_DPy_Type_Type;
    delete m_DPy_BaseObject_Type;
    delete m_DPy_Super_Type;

    delete m_DPy_None_Type;

    delete m_DPy_Unicode_Type;
    delete m_DPy_Int_Type;
    delete m_DPy_Bool_Type;
    delete m_DPy_Long_Type;
    delete m_DPy_Float_Type;
    delete m_DPy_Complex_Type;
    delete m_DPy_Range_Type;
    delete m_DPy_BaseString_Type;
    delete m_DPy_String_Type;
    delete m_DPy_Buffer_Type;
    delete m_DPy_Tuple_Type;
    delete m_DPy_List_Type;
    delete m_DPy_Dict_Type;
    delete m_DPy_Enum_Type;
    delete m_DPy_Reversed_Type;
    delete m_DPy_CFunction_Type;
    delete m_DPy_Module_Type;
    delete m_DPy_Function_Type;
    delete m_DPy_ClassMethod_Type;
    delete m_DPy_StaticMethod_Type;
    delete m_DPy_Class_Type;
    delete m_DPy_Instance_Type;
    delete m_DPy_Method_Type;
    delete m_DPy_File_Type;
    delete m_DPy_Code_Type;
    delete m_DPy_Frame_Type;
    delete m_DPy_Gen_Type;
    delete m_DPy_Set_Type;
    delete m_DPy_FrozenSet_Type;

    delete m_DPy_CObject_Type;
    delete m_DPy_TraceBack_Type;
    delete m_DPy_Slice_Type;
    delete m_DPy_Cell_Type;
    delete m_DPy_SeqIter_Type;
    delete m_DPy_CallIter_Type;
    delete m_DPy_Property_Type;

    delete m_DPy_Weakref_RefType;
    delete m_DPy_Weakref_ProxyType;
    delete m_DPy_Weakref_CallableProxyType;
}

