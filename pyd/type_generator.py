names = [
    'm_DPy_BaseObject_Type;',
    'm_DPy_Super_Type;',

    'm_DPy_None_Type;',

    'm_DPy_Unicode_Type;',
    'm_DPy_Int_Type;',
    'm_DPy_Bool_Type;',
    'm_DPy_Long_Type;',
    'm_DPy_Float_Type;',
    'm_DPy_Complex_Type;',
    'm_DPy_Range_Type;',
    'm_DPy_BaseString_Type;',
    'm_DPy_String_Type;',
    'm_DPy_Buffer_Type;',
    'm_DPy_Tuple_Type;',
    'm_DPy_List_Type;',
    'm_DPy_Dict_Type;',
    'm_DPy_Enum_Type;',
    'm_DPy_Reversed_Type;',
    'm_DPy_CFunction_Type;',
    'm_DPy_Module_Type;',
    'm_DPy_Function_Type;',
    'm_DPy_ClassMethod_Type;',
    'm_DPy_StaticMethod_Type;',
    'm_DPy_Class_Type;',
    'm_DPy_Instance_Type;',
    'm_DPy_Method_Type;',
    'm_DPy_File_Type;',
    'm_DPy_Code_Type;',
    'm_DPy_Frame_Type;',
    'm_DPy_Gen_Type;',
    'm_DPy_Set_Type;',
    'm_DPy_FrozenSet_Type;',

    'm_DPy_CObject_Type;',
    'm_DPy_TraceBack_Type;',
    'm_DPy_Slice_Type;',
    'm_DPy_Cell_Type;',
    'm_DPy_SeqIter_Type;',
    'm_DPy_CallIter_Type;',
    'm_DPy_Property_Type;',

    'm_DPy_Weakref_RefType;',
    'm_DPy_Weakref_ProxyType;',
    'm_DPy_Weakref_CallableProxyType;',
]

def main():
    file = open("type_output.d", 'w')
    
    template = "alias lazy_load!(%s, %s) %s;\n"
    
    for name in names:
        name = name[:-1]
        n = [name, name[3:]+'_p', name[2:]]
        file.write(template % n)

if __name__ == "__main__":
    main()
