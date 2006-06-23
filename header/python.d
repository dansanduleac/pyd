/* DSR:2005.10.26.16.28:

XXX:

- In a build process controlled by Python distutils, need to detect whether the
  Python interpreter was built in debug build mode, and if so, make the
  appropriate adjustments to the header mixins.

*/

module python;

import std.c.stdio;
import std.c.time;
import std.c.string;
import std.stdio;

/* D long is always 64 bits, but when the Python/C API mentions long, it is of
 * course referring to the C type long, the size of which is 32 bits on both
 * X86 and X86_64 under Windows, but 32 bits on X86 and 64 bits on X86_64 under
 * most other operating systems. */

alias long C_longlong;
alias ulong C_ulonglong;

version(Windows) {
  alias int C_long;
  alias uint C_ulong;
} else {
  version (X86) {
    alias int C_long;
    alias uint C_ulong;
  } else {
    alias long C_long;
    alias ulong C_ulong;
  }
}


extern (C) {
///////////////////////////////////////////////////////////////////////////////
// PYTHON DATA STRUCTURES AND ALIASES
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/Python.h:
  const int Py_single_input = 256;
  const int Py_file_input = 257;
  const int Py_eval_input = 258;

  // Python-header-file: Include/object.h:

  // XXX:Conditionalize in if running debug build of Python interpreter:
  /*
  version (Python_Debug_Build) {
    template _PyObject_HEAD_EXTRA() {
      PyObject *_ob_next;
      PyObject *_ob_prev;
    }
  } else {
  */
    template _PyObject_HEAD_EXTRA() {}
  /*}*/

  template PyObject_HEAD() {
    mixin _PyObject_HEAD_EXTRA;
    int ob_refcnt;
    PyTypeObject *ob_type;
  }

  struct PyObject {
    mixin PyObject_HEAD;
  }

  template PyObject_VAR_HEAD() {
    mixin PyObject_HEAD;
    int ob_size; /* Number of items in variable part */
  }

  struct PyVarObject {
    mixin PyObject_VAR_HEAD;
  }

  alias PyObject * (*unaryfunc)(PyObject *);
  alias PyObject * (*binaryfunc)(PyObject *, PyObject *);
  alias PyObject * (*ternaryfunc)(PyObject *, PyObject *, PyObject *);
  alias int (*inquiry)(PyObject *);
  alias int (*coercion)(PyObject **, PyObject **);
  alias PyObject *(*intargfunc)(PyObject *, int);
  alias PyObject *(*intintargfunc)(PyObject *, int, int);
  alias int(*intobjargproc)(PyObject *, int, PyObject *);
  alias int(*intintobjargproc)(PyObject *, int, int, PyObject *);
  alias int(*objobjargproc)(PyObject *, PyObject *, PyObject *);
  alias int (*getreadbufferproc)(PyObject *, int, void **);
  alias int (*getwritebufferproc)(PyObject *, int, void **);
  alias int (*getsegcountproc)(PyObject *, int *);
  alias int (*getcharbufferproc)(PyObject *, int, char **);
  alias int (*objobjproc)(PyObject *, PyObject *);
  alias int (*visitproc)(PyObject *, void *);
  alias int (*traverseproc)(PyObject *, visitproc, void *);

  // Python-header-file: Include/object.h:
  struct PyNumberMethods {
    binaryfunc nb_add;
    binaryfunc nb_subtract;
    binaryfunc nb_multiply;
    binaryfunc nb_divide;
    binaryfunc nb_remainder;
    binaryfunc nb_divmod;
    ternaryfunc nb_power;
    unaryfunc nb_negative;
    unaryfunc nb_positive;
    unaryfunc nb_absolute;
    inquiry nb_nonzero;
    unaryfunc nb_invert;
    binaryfunc nb_lshift;
    binaryfunc nb_rshift;
    binaryfunc nb_and;
    binaryfunc nb_xor;
    binaryfunc nb_or;
    coercion nb_coerce;
    unaryfunc nb_int;
    unaryfunc nb_long;
    unaryfunc nb_float;
    unaryfunc nb_oct;
    unaryfunc nb_hex;

    binaryfunc nb_inplace_add;
    binaryfunc nb_inplace_subtract;
    binaryfunc nb_inplace_multiply;
    binaryfunc nb_inplace_divide;
    binaryfunc nb_inplace_remainder;
    ternaryfunc nb_inplace_power;
    binaryfunc nb_inplace_lshift;
    binaryfunc nb_inplace_rshift;
    binaryfunc nb_inplace_and;
    binaryfunc nb_inplace_xor;
    binaryfunc nb_inplace_or;


    binaryfunc nb_floor_divide;
    binaryfunc nb_true_divide;
    binaryfunc nb_inplace_floor_divide;
    binaryfunc nb_inplace_true_divide;
  }

  struct PySequenceMethods {
    inquiry sq_length;
    binaryfunc sq_concat;
    intargfunc sq_repeat;
    intargfunc sq_item;
    intintargfunc sq_slice;
    intobjargproc sq_ass_item;
    intintobjargproc sq_ass_slice;
    objobjproc sq_contains;
    binaryfunc sq_inplace_concat;
    intargfunc sq_inplace_repeat;
  }

  struct PyMappingMethods {
    inquiry mp_length;
    binaryfunc mp_subscript;
    objobjargproc mp_ass_subscript;
  }

  struct PyBufferProcs {
    getreadbufferproc bf_getreadbuffer;
    getwritebufferproc bf_getwritebuffer;
    getsegcountproc bf_getsegcount;
    getcharbufferproc bf_getcharbuffer;
  }


  alias void (*freefunc)(void *);
  alias void (*destructor)(PyObject *);
  alias int (*printfunc)(PyObject *, FILE *, int);
  alias PyObject *(*getattrfunc)(PyObject *, char *);
  alias PyObject *(*getattrofunc)(PyObject *, PyObject *);
  alias int (*setattrfunc)(PyObject *, char *, PyObject *);
  alias int (*setattrofunc)(PyObject *, PyObject *, PyObject *);
  alias int (*cmpfunc)(PyObject *, PyObject *);
  alias PyObject *(*reprfunc)(PyObject *);
  alias C_long (*hashfunc)(PyObject *);
  alias PyObject *(*richcmpfunc) (PyObject *, PyObject *, int);
  alias PyObject *(*getiterfunc) (PyObject *);
  alias PyObject *(*iternextfunc) (PyObject *);
  alias PyObject *(*descrgetfunc) (PyObject *, PyObject *, PyObject *);
  alias int (*descrsetfunc) (PyObject *, PyObject *, PyObject *);
  alias int (*initproc)(PyObject *, PyObject *, PyObject *);
  alias PyObject *(*newfunc)(PyTypeObject *, PyObject *, PyObject *);
  alias PyObject *(*allocfunc)(PyTypeObject *, int);

  struct PyTypeObject {
    mixin PyObject_VAR_HEAD;

    char *tp_name;
    int tp_basicsize, tp_itemsize;

    destructor tp_dealloc;
    printfunc tp_print;
    getattrfunc tp_getattr;
    setattrfunc tp_setattr;
    cmpfunc tp_compare;
    reprfunc tp_repr;

    PyNumberMethods *tp_as_number;
    PySequenceMethods *tp_as_sequence;
    PyMappingMethods *tp_as_mapping;

    hashfunc tp_hash;
    ternaryfunc tp_call;
    reprfunc tp_str;
    getattrofunc tp_getattro;
    setattrofunc tp_setattro;

    PyBufferProcs *tp_as_buffer;

    C_long tp_flags;

    char *tp_doc;

    traverseproc tp_traverse;

    inquiry tp_clear;

    richcmpfunc tp_richcompare;

    C_long tp_weaklistoffset;

    getiterfunc tp_iter;
    iternextfunc tp_iternext;

    PyMethodDef *tp_methods;
    PyMemberDef *tp_members;
    PyGetSetDef *tp_getset;
    PyTypeObject *tp_base;
    PyObject *tp_dict;
    descrgetfunc tp_descr_get;
    descrsetfunc tp_descr_set;
    C_long tp_dictoffset;
    initproc tp_init;
    allocfunc tp_alloc;
    newfunc tp_new;
    freefunc tp_free;
    inquiry tp_is_gc;
    PyObject *tp_bases;
    PyObject *tp_mro;
    PyObject *tp_cache;
    PyObject *tp_subclasses;
    PyObject *tp_weaklist;
    destructor tp_del;
  }

  //alias _typeobject PyTypeObject;

  struct _heaptypeobject {
    PyTypeObject type;
    PyNumberMethods as_number;
    PyMappingMethods as_mapping;
    PySequenceMethods as_sequence;
    PyBufferProcs as_buffer;
    PyObject *name;
    PyObject *slots;
  }
  alias _heaptypeobject PyHeapTypeObject;


  // Python-header-file: Include/pymem.h:
  void * PyMem_Malloc(size_t);
  void * PyMem_Realloc(void *, size_t);
  void PyMem_Free(void *);


///////////////////////////////////////////////////////////////////////////////
// GENERIC TYPE CHECKING
///////////////////////////////////////////////////////////////////////////////

  int PyType_IsSubtype(PyTypeObject *, PyTypeObject *);

  // D translation of C macro:
  int PyObject_TypeCheck(PyObject *ob, PyTypeObject *tp) {
    return (ob.ob_type == tp || PyType_IsSubtype(ob.ob_type, tp));
  }

  /* Note that this Python support module makes pointers to PyType_Type and
   * other global variables exposed by the Python API available to D
   * programmers indirectly (see this module's static initializer). */

  // D translation of C macro:
  int PyType_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyType_Type_p);
  }
  // D translation of C macro:
  int PyType_CheckExact(PyObject *op) {
    return op.ob_type == PyType_Type_p;
  }

  int PyType_Ready(PyTypeObject *);
  PyObject * PyType_GenericAlloc(PyTypeObject *, int);
  PyObject * PyType_GenericNew(PyTypeObject *, PyObject *, PyObject *);


  int PyObject_Print(PyObject *, FILE *, int);
  PyObject * PyObject_Repr(PyObject *);
  PyObject * PyObject_Str(PyObject *);

  PyObject * PyObject_Unicode(PyObject *);

  int PyObject_Compare(PyObject *, PyObject *);
  PyObject * PyObject_RichCompare(PyObject *, PyObject *, int);
  int PyObject_RichCompareBool(PyObject *, PyObject *, int);
  PyObject * PyObject_GetAttrString(PyObject *, char *);
  int PyObject_SetAttrString(PyObject *, char *, PyObject *);
  int PyObject_HasAttrString(PyObject *, char *);
  PyObject * PyObject_GetAttr(PyObject *, PyObject *);
  int PyObject_SetAttr(PyObject *, PyObject *, PyObject *);
  int PyObject_HasAttr(PyObject *, PyObject *);
  PyObject * PyObject_SelfIter(PyObject *);
  PyObject * PyObject_GenericGetAttr(PyObject *, PyObject *);
  int PyObject_GenericSetAttr(PyObject *,
                PyObject *, PyObject *);
  C_long PyObject_Hash(PyObject *);
  int PyObject_IsTrue(PyObject *);
  int PyObject_Not(PyObject *);
  //int PyCallable_Check(PyObject *);
  int PyNumber_Coerce(PyObject **, PyObject **);
  int PyNumber_CoerceEx(PyObject **, PyObject **);

  void PyObject_ClearWeakRefs(PyObject *);

  PyObject * PyObject_Dir(PyObject *);

  int Py_ReprEnter(PyObject *);
  void Py_ReprLeave(PyObject *);

  const int Py_PRINT_RAW = 1;


  const int Py_TPFLAGS_HAVE_GETCHARBUFFER       = 1L<<0;
  const int Py_TPFLAGS_HAVE_SEQUENCE_IN         = 1L<<1;
  const int Py_TPFLAGS_GC                       = 0;
  const int Py_TPFLAGS_HAVE_INPLACEOPS          = 1L<<3;
  const int Py_TPFLAGS_CHECKTYPES               = 1L<<4;
  const int Py_TPFLAGS_HAVE_RICHCOMPARE         = 1L<<5;
  const int Py_TPFLAGS_HAVE_WEAKREFS            = 1L<<6;
  const int Py_TPFLAGS_HAVE_ITER                = 1L<<7;
  const int Py_TPFLAGS_HAVE_CLASS               = 1L<<8;
  const int Py_TPFLAGS_HEAPTYPE                 = 1L<<9;
  const int Py_TPFLAGS_BASETYPE                 = 1L<<10;
  const int Py_TPFLAGS_READY                    = 1L<<12;
  const int Py_TPFLAGS_READYING                 = 1L<<13;
  const int Py_TPFLAGS_HAVE_GC                  = 1L<<14;

  // YYY: Should conditionalize for stackless:
  //#ifdef STACKLESS
  //#define Py_TPFLAGS_HAVE_STACKLESS_EXTENSION (3L<<15)
  //#else
  const int Py_TPFLAGS_HAVE_STACKLESS_EXTENSION = 0;
  //#endif

  const int Py_TPFLAGS_DEFAULT =
      Py_TPFLAGS_HAVE_GETCHARBUFFER |
      Py_TPFLAGS_HAVE_SEQUENCE_IN |
      Py_TPFLAGS_HAVE_INPLACEOPS |
      Py_TPFLAGS_HAVE_RICHCOMPARE |
      Py_TPFLAGS_HAVE_WEAKREFS |
      Py_TPFLAGS_HAVE_ITER |
      Py_TPFLAGS_HAVE_CLASS |
      Py_TPFLAGS_HAVE_STACKLESS_EXTENSION |
      0
    ;

  // D translation of C macro:
  int PyType_HasFeature(PyTypeObject *t, int f) {
    return (t.tp_flags & f) != 0;
  }


///////////////////////////////////////////////////////////////////////////////
// REFERENCE COUNTING
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/object.h:

  void Py_INCREF(PyObject *op) {
    ++op.ob_refcnt;
  }

  void Py_XINCREF(PyObject *op) {
    if (op == null) {
      return;
    }
    Py_INCREF(op);
  }

  void Py_DECREF(PyObject *op) {
    --op.ob_refcnt;
    assert (op.ob_refcnt >= 0);
    if (op.ob_refcnt == 0) {
      op.ob_type.tp_dealloc(op);
    }
  }

  void Py_XDECREF(PyObject* op)
  {
    if(op == null) {
      return;
    }

    Py_DECREF(op);
  }

  void Py_IncRef(PyObject *);
  void Py_DecRef(PyObject *);

  /* Rich comparison opcodes */
  const int Py_LT = 0;
  const int Py_LE = 1;
  const int Py_EQ = 2;
  const int Py_NE = 3;
  const int Py_GT = 4;
  const int Py_GE = 5;


///////////////////////////////////////////////////////////////////////////////////////////////
// UNICODE
///////////////////////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/unicodeobject.h:
  /* The Python header explains:
   *   Unicode API names are mangled to assure that UCS-2 and UCS-4 builds
   *   produce different external names and thus cause import errors in
   *   case Python interpreters and extensions with mixed compiled in
   *   Unicode width assumptions are combined. */

  version (Python_Unicode_UCS2) {
    version (Windows) {
      alias wchar Py_UNICODE;
    } else {
      alias ushort Py_UNICODE;
    }
  } else {
    alias uint Py_UNICODE;
  }

  struct PyUnicodeObject {
    mixin PyObject_HEAD;

    int length;
    Py_UNICODE *str;
    C_long hash;
    PyObject *defenc;
  }

  // &PyUnicode_Type is accessible via PyUnicode_Type_p.
  // D translations of C macros:
  int PyUnicode_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyUnicode_Type_p);
  }
  int PyUnicode_CheckExact(PyObject *op) {
    return op.ob_type == PyUnicode_Type_p;
  }

  int PyUnicode_GET_SIZE(PyUnicodeObject *op) {
    return op.length;
  }
  int PyUnicode_GET_DATA_SIZE(PyUnicodeObject *op) {
    return op.length * Py_UNICODE.sizeof;
  }
  Py_UNICODE *PyUnicode_AS_UNICODE(PyUnicodeObject *op) {
    return op.str;
  }
  char *PyUnicode_AS_DATA(PyUnicodeObject *op) {
    return cast(char *) op.str;
  }

  Py_UNICODE Py_UNICODE_REPLACEMENT_CHARACTER = 0xFFFD;

  // YYY: Unfortunately, we have to do it the tedious way since there's no
  // preprocessor in D:
  version (Python_Unicode_UCS2) {
    PyObject *PyUnicodeUCS2_FromUnicode(Py_UNICODE *u, int size);
    Py_UNICODE *PyUnicodeUCS2_AsUnicode(PyObject *unicode);
    int PyUnicodeUCS2_GetSize(PyObject *unicode);
    Py_UNICODE PyUnicodeUCS2_GetMax();

    int PyUnicodeUCS2_Resize(PyObject **unicode, int length);
    PyObject *PyUnicodeUCS2_FromEncodedObject(PyObject *obj, char *encoding, char *errors);
    PyObject *PyUnicodeUCS2_FromObject(PyObject *obj);

    PyObject *PyUnicodeUCS2_FromWideChar(wchar *w, int size);
    int PyUnicodeUCS2_AsWideChar(PyUnicodeObject *unicode, wchar *w, int size);

    PyObject *PyUnicodeUCS2_FromOrdinal(int ordinal);

    PyObject *_PyUnicodeUCS2_AsDefaultEncodedString(PyObject *, char *);

    char *PyUnicodeUCS2_GetDefaultEncoding();
    int PyUnicodeUCS2_SetDefaultEncoding(char *encoding);

    PyObject *PyUnicodeUCS2_Decode(char *s, int size, char *encoding, char *errors);
    PyObject *PyUnicodeUCS2_Encode(Py_UNICODE *s, int size, char *encoding, char *errors);
    PyObject *PyUnicodeUCS2_AsEncodedObject(PyObject *unicode, char *encoding, char *errors);
    PyObject *PyUnicodeUCS2_AsEncodedString(PyObject *unicode, char *encoding, char *errors);

    PyObject *PyUnicodeUCS2_DecodeUTF7(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_EncodeUTF7(Py_UNICODE *data, int length,
        int encodeSetO, int encodeWhiteSpace, char *errors
      );

    PyObject *PyUnicodeUCS2_DecodeUTF8(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_DecodeUTF8Stateful(char *string, int length,
        char *errors, int *consumed
      );
    PyObject *PyUnicodeUCS2_AsUTF8String(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeUTF8(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS2_DecodeUTF16(char *string, int length, char *errors, int *byteorder);
    PyObject *PyUnicodeUCS2_DecodeUTF16Stateful(char *string, int length,
        char *errors, int *byteorder, int *consumed
      );
    PyObject *PyUnicodeUCS2_AsUTF16String(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeUTF16(Py_UNICODE *data, int length,
        char *errors, int byteorder
      );

    PyObject *PyUnicodeUCS2_DecodeUnicodeEscape(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_AsUnicodeEscapeString(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeUnicodeEscape(Py_UNICODE *data, int length);
    PyObject *PyUnicodeUCS2_DecodeRawUnicodeEscape(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_AsRawUnicodeEscapeString(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeRawUnicodeEscape(Py_UNICODE *data, int length);

    PyObject *_PyUnicodeUCS2_DecodeUnicodeInternal(char *string, int length, char *errors);

    PyObject *PyUnicodeUCS2_DecodeLatin1(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_AsLatin1String(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeLatin1(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS2_DecodeASCII(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS2_AsASCIIString(PyObject *unicode);
    PyObject *PyUnicodeUCS2_EncodeASCII(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS2_DecodeCharmap(char *string, int length,
        PyObject *mapping, char *errors
      );
    PyObject *PyUnicodeUCS2_AsCharmapString(PyObject *unicode, PyObject *mapping);
    PyObject *PyUnicodeUCS2_EncodeCharmap(Py_UNICODE *data, int length,
        PyObject *mapping, char *errors
      );
    PyObject *PyUnicodeUCS2_TranslateCharmap(Py_UNICODE *data, int length,
        PyObject *table, char *errors
      );

    version (Windows) {
      PyObject *PyUnicodeUCS2_DecodeMBCS(char *string, int length, char *errors);
      PyObject *PyUnicodeUCS2_AsMBCSString(PyObject *unicode);
      PyObject *PyUnicodeUCS2_EncodeMBCS(Py_UNICODE *data, int length, char *errors);
    }

    int PyUnicodeUCS2_EncodeDecimal(Py_UNICODE *s, int length, char *output, char *errors);

    PyObject *PyUnicodeUCS2_Concat(PyObject *left, PyObject *right);
    PyObject *PyUnicodeUCS2_Split(PyObject *s, PyObject *sep, int maxsplit);
    PyObject *PyUnicodeUCS2_Splitlines(PyObject *s, int keepends);
    PyObject *PyUnicodeUCS2_RSplit(PyObject *s, PyObject *sep, int maxsplit);
    PyObject *PyUnicodeUCS2_Translate(PyObject *str, PyObject *table, char *errors);
    PyObject *PyUnicodeUCS2_Join(PyObject *separator, PyObject *seq);
    int PyUnicodeUCS2_Tailmatch(PyObject *str, PyObject *substr,
        int start, int end, int direction
      );
    int PyUnicodeUCS2_Find(PyObject *str, PyObject *substr,
        int start, int end, int direction
      );
    int PyUnicodeUCS2_Count(PyObject *str, PyObject *substr, int start, int end);
    PyObject *PyUnicodeUCS2_Replace(PyObject *str, PyObject *substr,
        PyObject *replstr, int maxcount
      );
    int PyUnicodeUCS2_Compare(PyObject *left, PyObject *right);
    PyObject *PyUnicodeUCS2_Format(PyObject *format, PyObject *args);
    int PyUnicodeUCS2_Contains(PyObject *container, PyObject *element);
    PyObject *_PyUnicodeUCS2_XStrip(PyUnicodeObject *self, int striptype,
        PyObject *sepobj
      );

    int _PyUnicodeUCS2_IsLowercase(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsUppercase(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsTitlecase(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsWhitespace(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsLinebreak(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS2_ToLowercase(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS2_ToUppercase(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS2_ToTitlecase(Py_UNICODE ch);
    int _PyUnicodeUCS2_ToDecimalDigit(Py_UNICODE ch);
    int _PyUnicodeUCS2_ToDigit(Py_UNICODE ch);
    double _PyUnicodeUCS2_ToNumeric(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsDecimalDigit(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsDigit(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsNumeric(Py_UNICODE ch);
    int _PyUnicodeUCS2_IsAlpha(Py_UNICODE ch);
  } else { /* not Python_Unicode_UCS2: */
    PyObject *PyUnicodeUCS4_FromUnicode(Py_UNICODE *u, int size);
    Py_UNICODE *PyUnicodeUCS4_AsUnicode(PyObject *unicode);
    int PyUnicodeUCS4_GetSize(PyObject *unicode);
    Py_UNICODE PyUnicodeUCS4_GetMax();

    int PyUnicodeUCS4_Resize(PyObject **unicode, int length);
    PyObject *PyUnicodeUCS4_FromEncodedObject(PyObject *obj, char *encoding, char *errors);
    PyObject *PyUnicodeUCS4_FromObject(PyObject *obj);

    PyObject *PyUnicodeUCS4_FromWideChar(wchar *w, int size);
    int PyUnicodeUCS4_AsWideChar(PyUnicodeObject *unicode, wchar *w, int size);

    PyObject *PyUnicodeUCS4_FromOrdinal(int ordinal);

    PyObject *_PyUnicodeUCS4_AsDefaultEncodedString(PyObject *, char *);

    char *PyUnicodeUCS4_GetDefaultEncoding();
    int PyUnicodeUCS4_SetDefaultEncoding(char *encoding);

    PyObject *PyUnicodeUCS4_Decode(char *s, int size, char *encoding, char *errors);
    PyObject *PyUnicodeUCS4_Encode(Py_UNICODE *s, int size, char *encoding, char *errors);
    PyObject *PyUnicodeUCS4_AsEncodedObject(PyObject *unicode, char *encoding, char *errors);
    PyObject *PyUnicodeUCS4_AsEncodedString(PyObject *unicode, char *encoding, char *errors);

    PyObject *PyUnicodeUCS4_DecodeUTF7(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_EncodeUTF7(Py_UNICODE *data, int length,
        int encodeSetO, int encodeWhiteSpace, char *errors
      );

    PyObject *PyUnicodeUCS4_DecodeUTF8(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_DecodeUTF8Stateful(char *string, int length,
        char *errors, int *consumed
      );
    PyObject *PyUnicodeUCS4_AsUTF8String(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeUTF8(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS4_DecodeUTF16(char *string, int length, char *errors, int *byteorder);
    PyObject *PyUnicodeUCS4_DecodeUTF16Stateful(char *string, int length,
        char *errors, int *byteorder, int *consumed
      );
    PyObject *PyUnicodeUCS4_AsUTF16String(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeUTF16(Py_UNICODE *data, int length,
        char *errors, int byteorder
      );

    PyObject *PyUnicodeUCS4_DecodeUnicodeEscape(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_AsUnicodeEscapeString(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeUnicodeEscape(Py_UNICODE *data, int length);
    PyObject *PyUnicodeUCS4_DecodeRawUnicodeEscape(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_AsRawUnicodeEscapeString(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeRawUnicodeEscape(Py_UNICODE *data, int length);

    PyObject *_PyUnicodeUCS4_DecodeUnicodeInternal(char *string, int length, char *errors);

    PyObject *PyUnicodeUCS4_DecodeLatin1(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_AsLatin1String(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeLatin1(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS4_DecodeASCII(char *string, int length, char *errors);
    PyObject *PyUnicodeUCS4_AsASCIIString(PyObject *unicode);
    PyObject *PyUnicodeUCS4_EncodeASCII(Py_UNICODE *data, int length, char *errors);

    PyObject *PyUnicodeUCS4_DecodeCharmap(char *string, int length,
        PyObject *mapping, char *errors
      );
    PyObject *PyUnicodeUCS4_AsCharmapString(PyObject *unicode, PyObject *mapping);
    PyObject *PyUnicodeUCS4_EncodeCharmap(Py_UNICODE *data, int length,
        PyObject *mapping, char *errors
      );
    PyObject *PyUnicodeUCS4_TranslateCharmap(Py_UNICODE *data, int length,
        PyObject *table, char *errors
      );

    version (Windows) {
      PyObject *PyUnicodeUCS4_DecodeMBCS(char *string, int length, char *errors);
      PyObject *PyUnicodeUCS4_AsMBCSString(PyObject *unicode);
      PyObject *PyUnicodeUCS4_EncodeMBCS(Py_UNICODE *data, int length, char *errors);
    }

    int PyUnicodeUCS4_EncodeDecimal(Py_UNICODE *s, int length, char *output, char *errors);

    PyObject *PyUnicodeUCS4_Concat(PyObject *left, PyObject *right);
    PyObject *PyUnicodeUCS4_Split(PyObject *s, PyObject *sep, int maxsplit);
    PyObject *PyUnicodeUCS4_Splitlines(PyObject *s, int keepends);
    PyObject *PyUnicodeUCS4_RSplit(PyObject *s, PyObject *sep, int maxsplit);
    PyObject *PyUnicodeUCS4_Translate(PyObject *str, PyObject *table, char *errors);
    PyObject *PyUnicodeUCS4_Join(PyObject *separator, PyObject *seq);
    int PyUnicodeUCS4_Tailmatch(PyObject *str, PyObject *substr,
        int start, int end, int direction
      );
    int PyUnicodeUCS4_Find(PyObject *str, PyObject *substr,
        int start, int end, int direction
      );
    int PyUnicodeUCS4_Count(PyObject *str, PyObject *substr, int start, int end);
    PyObject *PyUnicodeUCS4_Replace(PyObject *str, PyObject *substr,
        PyObject *replstr, int maxcount
      );
    int PyUnicodeUCS4_Compare(PyObject *left, PyObject *right);
    PyObject *PyUnicodeUCS4_Format(PyObject *format, PyObject *args);
    int PyUnicodeUCS4_Contains(PyObject *container, PyObject *element);
    PyObject *_PyUnicodeUCS4_XStrip(PyUnicodeObject *self, int striptype,
        PyObject *sepobj
      );

    int _PyUnicodeUCS4_IsLowercase(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsUppercase(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsTitlecase(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsWhitespace(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsLinebreak(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS4_ToLowercase(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS4_ToUppercase(Py_UNICODE ch);
    Py_UNICODE _PyUnicodeUCS4_ToTitlecase(Py_UNICODE ch);
    int _PyUnicodeUCS4_ToDecimalDigit(Py_UNICODE ch);
    int _PyUnicodeUCS4_ToDigit(Py_UNICODE ch);
    double _PyUnicodeUCS4_ToNumeric(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsDecimalDigit(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsDigit(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsNumeric(Py_UNICODE ch);
    int _PyUnicodeUCS4_IsAlpha(Py_UNICODE ch);
  }


  /* The client programmer should call PyUnicode_XYZ, but linkage should be
   * done via either PyUnicodeUCS2_XYZ or PyUnicodeUCS4_XYZ. */
  version (Python_Unicode_UCS2) {
    alias PyUnicodeUCS2_AsASCIIString PyUnicode_AsASCIIString;
    alias PyUnicodeUCS2_AsCharmapString PyUnicode_AsCharmapString;
    alias PyUnicodeUCS2_AsEncodedObject PyUnicode_AsEncodedObject;
    alias PyUnicodeUCS2_AsEncodedString PyUnicode_AsEncodedString;
    alias PyUnicodeUCS2_AsLatin1String PyUnicode_AsLatin1String;
    alias PyUnicodeUCS2_AsRawUnicodeEscapeString PyUnicode_AsRawUnicodeEscapeString;
    alias PyUnicodeUCS2_AsUTF16String PyUnicode_AsUTF16String;
    alias PyUnicodeUCS2_AsUTF8String PyUnicode_AsUTF8String;
    alias PyUnicodeUCS2_AsUnicode PyUnicode_AsUnicode;
    alias PyUnicodeUCS2_AsUnicodeEscapeString PyUnicode_AsUnicodeEscapeString;
    alias PyUnicodeUCS2_AsWideChar PyUnicode_AsWideChar;
    alias PyUnicodeUCS2_Compare PyUnicode_Compare;
    alias PyUnicodeUCS2_Concat PyUnicode_Concat;
    alias PyUnicodeUCS2_Contains PyUnicode_Contains;
    alias PyUnicodeUCS2_Count PyUnicode_Count;
    alias PyUnicodeUCS2_Decode PyUnicode_Decode;
    alias PyUnicodeUCS2_DecodeASCII PyUnicode_DecodeASCII;
    alias PyUnicodeUCS2_DecodeCharmap PyUnicode_DecodeCharmap;
    alias PyUnicodeUCS2_DecodeLatin1 PyUnicode_DecodeLatin1;
    alias PyUnicodeUCS2_DecodeRawUnicodeEscape PyUnicode_DecodeRawUnicodeEscape;
    alias PyUnicodeUCS2_DecodeUTF16 PyUnicode_DecodeUTF16;
    alias PyUnicodeUCS2_DecodeUTF16Stateful PyUnicode_DecodeUTF16Stateful;
    alias PyUnicodeUCS2_DecodeUTF8 PyUnicode_DecodeUTF8;
    alias PyUnicodeUCS2_DecodeUTF8Stateful PyUnicode_DecodeUTF8Stateful;
    alias PyUnicodeUCS2_DecodeUnicodeEscape PyUnicode_DecodeUnicodeEscape;
    alias PyUnicodeUCS2_Encode PyUnicode_Encode;
    alias PyUnicodeUCS2_EncodeASCII PyUnicode_EncodeASCII;
    alias PyUnicodeUCS2_EncodeCharmap PyUnicode_EncodeCharmap;
    alias PyUnicodeUCS2_EncodeDecimal PyUnicode_EncodeDecimal;
    alias PyUnicodeUCS2_EncodeLatin1 PyUnicode_EncodeLatin1;
    alias PyUnicodeUCS2_EncodeRawUnicodeEscape PyUnicode_EncodeRawUnicodeEscape;
    alias PyUnicodeUCS2_EncodeUTF16 PyUnicode_EncodeUTF16;
    alias PyUnicodeUCS2_EncodeUTF8 PyUnicode_EncodeUTF8;
    alias PyUnicodeUCS2_EncodeUnicodeEscape PyUnicode_EncodeUnicodeEscape;
    alias PyUnicodeUCS2_Find PyUnicode_Find;
    alias PyUnicodeUCS2_Format PyUnicode_Format;
    alias PyUnicodeUCS2_FromEncodedObject PyUnicode_FromEncodedObject;
    alias PyUnicodeUCS2_FromObject PyUnicode_FromObject;
    alias PyUnicodeUCS2_FromOrdinal PyUnicode_FromOrdinal;
    alias PyUnicodeUCS2_FromUnicode PyUnicode_FromUnicode;
    alias PyUnicodeUCS2_FromWideChar PyUnicode_FromWideChar;
    alias PyUnicodeUCS2_GetDefaultEncoding PyUnicode_GetDefaultEncoding;
    alias PyUnicodeUCS2_GetMax PyUnicode_GetMax;
    alias PyUnicodeUCS2_GetSize PyUnicode_GetSize;
    alias PyUnicodeUCS2_Join PyUnicode_Join;
    alias PyUnicodeUCS2_Replace PyUnicode_Replace;
    alias PyUnicodeUCS2_Resize PyUnicode_Resize;
    alias PyUnicodeUCS2_SetDefaultEncoding PyUnicode_SetDefaultEncoding;
    alias PyUnicodeUCS2_Split PyUnicode_Split;
    alias PyUnicodeUCS2_RSplit PyUnicode_RSplit;
    alias PyUnicodeUCS2_Splitlines PyUnicode_Splitlines;
    alias PyUnicodeUCS2_Tailmatch PyUnicode_Tailmatch;
    alias PyUnicodeUCS2_Translate PyUnicode_Translate;
    alias PyUnicodeUCS2_TranslateCharmap PyUnicode_TranslateCharmap;
    alias _PyUnicodeUCS2_AsDefaultEncodedString _PyUnicode_AsDefaultEncodedString;
    // omitted _PyUnicode_Fini
    // omitted _PyUnicode_Init
    alias _PyUnicodeUCS2_IsAlpha _PyUnicode_IsAlpha;
    alias _PyUnicodeUCS2_IsDecimalDigit _PyUnicode_IsDecimalDigit;
    alias _PyUnicodeUCS2_IsDigit _PyUnicode_IsDigit;
    alias _PyUnicodeUCS2_IsLinebreak _PyUnicode_IsLinebreak;
    alias _PyUnicodeUCS2_IsLowercase _PyUnicode_IsLowercase;
    alias _PyUnicodeUCS2_IsNumeric _PyUnicode_IsNumeric;
    alias _PyUnicodeUCS2_IsTitlecase _PyUnicode_IsTitlecase;
    alias _PyUnicodeUCS2_IsUppercase _PyUnicode_IsUppercase;
    alias _PyUnicodeUCS2_IsWhitespace _PyUnicode_IsWhitespace;
    alias _PyUnicodeUCS2_ToDecimalDigit _PyUnicode_ToDecimalDigit;
    alias _PyUnicodeUCS2_ToDigit _PyUnicode_ToDigit;
    alias _PyUnicodeUCS2_ToLowercase _PyUnicode_ToLowercase;
    alias _PyUnicodeUCS2_ToNumeric _PyUnicode_ToNumeric;
    alias _PyUnicodeUCS2_ToTitlecase _PyUnicode_ToTitlecase;
    alias _PyUnicodeUCS2_ToUppercase _PyUnicode_ToUppercase;
  } else {
    alias PyUnicodeUCS4_AsASCIIString PyUnicode_AsASCIIString;
    alias PyUnicodeUCS4_AsCharmapString PyUnicode_AsCharmapString;
    alias PyUnicodeUCS4_AsEncodedObject PyUnicode_AsEncodedObject;
    alias PyUnicodeUCS4_AsEncodedString PyUnicode_AsEncodedString;
    alias PyUnicodeUCS4_AsLatin1String PyUnicode_AsLatin1String;
    alias PyUnicodeUCS4_AsRawUnicodeEscapeString PyUnicode_AsRawUnicodeEscapeString;
    alias PyUnicodeUCS4_AsUTF16String PyUnicode_AsUTF16String;
    alias PyUnicodeUCS4_AsUTF8String PyUnicode_AsUTF8String;
    alias PyUnicodeUCS4_AsUnicode PyUnicode_AsUnicode;
    alias PyUnicodeUCS4_AsUnicodeEscapeString PyUnicode_AsUnicodeEscapeString;
    alias PyUnicodeUCS4_AsWideChar PyUnicode_AsWideChar;
    alias PyUnicodeUCS4_Compare PyUnicode_Compare;
    alias PyUnicodeUCS4_Concat PyUnicode_Concat;
    alias PyUnicodeUCS4_Contains PyUnicode_Contains;
    alias PyUnicodeUCS4_Count PyUnicode_Count;
    alias PyUnicodeUCS4_Decode PyUnicode_Decode;
    alias PyUnicodeUCS4_DecodeASCII PyUnicode_DecodeASCII;
    alias PyUnicodeUCS4_DecodeCharmap PyUnicode_DecodeCharmap;
    alias PyUnicodeUCS4_DecodeLatin1 PyUnicode_DecodeLatin1;
    alias PyUnicodeUCS4_DecodeRawUnicodeEscape PyUnicode_DecodeRawUnicodeEscape;
    alias PyUnicodeUCS4_DecodeUTF16 PyUnicode_DecodeUTF16;
    alias PyUnicodeUCS4_DecodeUTF16Stateful PyUnicode_DecodeUTF16Stateful;
    alias PyUnicodeUCS4_DecodeUTF8 PyUnicode_DecodeUTF8;
    alias PyUnicodeUCS4_DecodeUTF8Stateful PyUnicode_DecodeUTF8Stateful;
    alias PyUnicodeUCS4_DecodeUnicodeEscape PyUnicode_DecodeUnicodeEscape;
    alias PyUnicodeUCS4_Encode PyUnicode_Encode;
    alias PyUnicodeUCS4_EncodeASCII PyUnicode_EncodeASCII;
    alias PyUnicodeUCS4_EncodeCharmap PyUnicode_EncodeCharmap;
    alias PyUnicodeUCS4_EncodeDecimal PyUnicode_EncodeDecimal;
    alias PyUnicodeUCS4_EncodeLatin1 PyUnicode_EncodeLatin1;
    alias PyUnicodeUCS4_EncodeRawUnicodeEscape PyUnicode_EncodeRawUnicodeEscape;
    alias PyUnicodeUCS4_EncodeUTF16 PyUnicode_EncodeUTF16;
    alias PyUnicodeUCS4_EncodeUTF8 PyUnicode_EncodeUTF8;
    alias PyUnicodeUCS4_EncodeUnicodeEscape PyUnicode_EncodeUnicodeEscape;
    alias PyUnicodeUCS4_Find PyUnicode_Find;
    alias PyUnicodeUCS4_Format PyUnicode_Format;
    alias PyUnicodeUCS4_FromEncodedObject PyUnicode_FromEncodedObject;
    alias PyUnicodeUCS4_FromObject PyUnicode_FromObject;
    alias PyUnicodeUCS4_FromOrdinal PyUnicode_FromOrdinal;
    alias PyUnicodeUCS4_FromUnicode PyUnicode_FromUnicode;
    alias PyUnicodeUCS4_FromWideChar PyUnicode_FromWideChar;
    alias PyUnicodeUCS4_GetDefaultEncoding PyUnicode_GetDefaultEncoding;
    alias PyUnicodeUCS4_GetMax PyUnicode_GetMax;
    alias PyUnicodeUCS4_GetSize PyUnicode_GetSize;
    alias PyUnicodeUCS4_Join PyUnicode_Join;
    alias PyUnicodeUCS4_Replace PyUnicode_Replace;
    alias PyUnicodeUCS4_Resize PyUnicode_Resize;
    alias PyUnicodeUCS4_SetDefaultEncoding PyUnicode_SetDefaultEncoding;
    alias PyUnicodeUCS4_Split PyUnicode_Split;
    alias PyUnicodeUCS4_Splitlines PyUnicode_Splitlines;
    alias PyUnicodeUCS4_Tailmatch PyUnicode_Tailmatch;
    alias PyUnicodeUCS4_Translate PyUnicode_Translate;
    alias PyUnicodeUCS4_TranslateCharmap PyUnicode_TranslateCharmap;
    alias _PyUnicodeUCS4_AsDefaultEncodedString _PyUnicode_AsDefaultEncodedString;
    // omitted _PyUnicode_Fini
    // omitted _PyUnicode_Init
    alias _PyUnicodeUCS4_IsAlpha _PyUnicode_IsAlpha;
    alias _PyUnicodeUCS4_IsDecimalDigit _PyUnicode_IsDecimalDigit;
    alias _PyUnicodeUCS4_IsDigit _PyUnicode_IsDigit;
    alias _PyUnicodeUCS4_IsLinebreak _PyUnicode_IsLinebreak;
    alias _PyUnicodeUCS4_IsLowercase _PyUnicode_IsLowercase;
    alias _PyUnicodeUCS4_IsNumeric _PyUnicode_IsNumeric;
    alias _PyUnicodeUCS4_IsTitlecase _PyUnicode_IsTitlecase;
    alias _PyUnicodeUCS4_IsUppercase _PyUnicode_IsUppercase;
    alias _PyUnicodeUCS4_IsWhitespace _PyUnicode_IsWhitespace;
    alias _PyUnicodeUCS4_ToDecimalDigit _PyUnicode_ToDecimalDigit;
    alias _PyUnicodeUCS4_ToDigit _PyUnicode_ToDigit;
    alias _PyUnicodeUCS4_ToLowercase _PyUnicode_ToLowercase;
    alias _PyUnicodeUCS4_ToNumeric _PyUnicode_ToNumeric;
    alias _PyUnicodeUCS4_ToTitlecase _PyUnicode_ToTitlecase;
    alias _PyUnicodeUCS4_ToUppercase _PyUnicode_ToUppercase;
  }

  alias _PyUnicode_IsWhitespace Py_UNICODE_ISSPACE;
  alias _PyUnicode_IsLowercase Py_UNICODE_ISLOWER;
  alias _PyUnicode_IsUppercase Py_UNICODE_ISUPPER;
  alias _PyUnicode_IsTitlecase Py_UNICODE_ISTITLE;
  alias _PyUnicode_IsLinebreak Py_UNICODE_ISLINEBREAK;
  alias _PyUnicode_ToLowercase Py_UNICODE_TOLOWER;
  alias _PyUnicode_ToUppercase Py_UNICODE_TOUPPER;
  alias _PyUnicode_ToTitlecase Py_UNICODE_TOTITLE;
  alias _PyUnicode_IsDecimalDigit Py_UNICODE_ISDECIMAL;
  alias _PyUnicode_IsDigit Py_UNICODE_ISDIGIT;
  alias _PyUnicode_IsNumeric Py_UNICODE_ISNUMERIC;
  alias _PyUnicode_ToDecimalDigit Py_UNICODE_TODECIMAL;
  alias _PyUnicode_ToDigit Py_UNICODE_TODIGIT;
  alias _PyUnicode_ToNumeric Py_UNICODE_TONUMERIC;
  alias _PyUnicode_IsAlpha Py_UNICODE_ISALPHA;

  int Py_UNICODE_ISALNUM(Py_UNICODE ch) {
    return (
           Py_UNICODE_ISALPHA(ch)
        || Py_UNICODE_ISDECIMAL(ch)
        || Py_UNICODE_ISDIGIT(ch)
        || Py_UNICODE_ISNUMERIC(ch)
      );
  }

  void Py_UNICODE_COPY(void *target, void *source, int length) {
    std.c.string.memcpy(target, source, cast(uint)(length * Py_UNICODE.sizeof));
  }

  void Py_UNICODE_FILL(Py_UNICODE *target, Py_UNICODE value, int length) {
    for (int i = 0; i < length; i++) {
      target[i] = value;
    }
  }

  int Py_UNICODE_MATCH(PyUnicodeObject *string, int offset,
      PyUnicodeObject *substring
    )
  {
    return (
         (*(string.str + offset) == *(substring.str))
      && !memcmp(string.str + offset, substring.str,
             substring.length * Py_UNICODE.sizeof
          )
      );
  }


///////////////////////////////////////////////////////////////////////////////
// INT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/intobject.h:

  struct PyIntObject {
    mixin PyObject_HEAD;

    C_long ob_ival;
  }

  // &PyInt_Type is accessible via PyInt_Type_p.

  // D translation of C macro:
  int PyInt_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyInt_Type_p);
  }
  // D translation of C macro:
  int PyInt_CheckExact(PyObject *op) {
    return op.ob_type == PyInt_Type_p;
  }

  PyObject *PyInt_FromString(char *, char **, int);
  PyObject *PyInt_FromUnicode(Py_UNICODE *, int, int);
  PyObject *PyInt_FromLong(C_long);

  C_long PyInt_AsLong(PyObject *);
  C_ulong PyInt_AsUnsignedLongMask(PyObject *);
  C_ulonglong PyInt_AsUnsignedLongLongMask(PyObject *);

  C_long PyInt_GetMax(); /* Accessible at the Python level as sys.maxint */

  C_ulong PyOS_strtoul(char *, char **, int);
  C_long PyOS_strtol(char *, char **, int);


///////////////////////////////////////////////////////////////////////////////
// BOOL INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/boolobject.h:

  alias PyIntObject PyBoolObject;

  // &PyBool_Type is accessible via PyBool_Type_p.

  // D translation of C macro:
  int PyBool_Check(PyObject *x) {
    return x.ob_type == PyBool_Type_p;
  }

  // Py_False and Py_True are actually macros in the Python/C API, so they're
  // loaded as PyObject pointers in this module static initializer.

  PyObject * PyBool_FromLong(C_long);


///////////////////////////////////////////////////////////////////////////////
// LONG INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/longobject.h:

  // &PyLong_Type is accessible via PyLong_Type_p.

  // D translation of C macro:
  int PyLong_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyLong_Type_p);
  }
  // D translation of C macro:
  int PyLong_CheckExact(PyObject *op) {
    return op.ob_type == PyLong_Type_p;
  }

  PyObject * PyLong_FromLong(C_long);
  PyObject * PyLong_FromUnsignedLong(C_ulong);

  PyObject * PyLong_FromLongLong(C_longlong);
  PyObject * PyLong_FromUnsignedLongLong(C_ulonglong);

  PyObject * PyLong_FromDouble(double);
  PyObject * PyLong_FromVoidPtr(void *);

  C_long PyLong_AsLong(PyObject *);
  C_ulong PyLong_AsUnsignedLong(PyObject *);
  C_ulong PyLong_AsUnsignedLongMask(PyObject *);

  C_longlong PyLong_AsLongLong(PyObject *);
  C_ulonglong PyLong_AsUnsignedLongLong(PyObject *);
  C_ulonglong PyLong_AsUnsignedLongLongMask(PyObject *);

  double PyLong_AsDouble(PyObject *);
  void * PyLong_AsVoidPtr(PyObject *);

  PyObject * PyLong_FromString(char *, char **, int);
  PyObject * PyLong_FromUnicode(Py_UNICODE *, int, int);


///////////////////////////////////////////////////////////////////////////////
// FLOAT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/floatobject.h:

  struct PyFloatObject {
    mixin PyObject_HEAD;

    double ob_fval;
  }

  // &PyFloat_Type is accessible via PyFloat_Type_p.

  // D translation of C macro:
  int PyFloat_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyFloat_Type_p);
  }
  // D translation of C macro:
  int PyFloat_CheckExact(PyObject *op) {
    return op.ob_type == PyFloat_Type_p;
  }

  PyObject * PyFloat_FromString(PyObject *, char** junk);
  PyObject * PyFloat_FromDouble(double);

  double PyFloat_AsDouble(PyObject *);
  void PyFloat_AsReprString(char *, PyFloatObject *v);
  void PyFloat_AsString(char *, PyFloatObject *v);


///////////////////////////////////////////////////////////////////////////////
// COMPLEX INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/complexobject.h:

  struct Py_complex {
    double real_; // real is the name of a D type, so must rename
    double imag;
  }

  struct PyComplexObject {
    mixin PyObject_HEAD;

    Py_complex cval;
  }

  Py_complex c_sum(Py_complex, Py_complex);
  Py_complex c_diff(Py_complex, Py_complex);
  Py_complex c_neg(Py_complex);
  Py_complex c_prod(Py_complex, Py_complex);
  Py_complex c_quot(Py_complex, Py_complex);
  Py_complex c_pow(Py_complex, Py_complex);

  // &PyComplex_Type is accessible via PyComplex_Type_p.

  // D translation of C macro:
  int PyComplex_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyComplex_Type_p);
  }
  // D translation of C macro:
  int PyComplex_CheckExact(PyObject *op) {
    return op.ob_type == PyComplex_Type_p;
  }

  PyObject * PyComplex_FromCComplex(Py_complex);
  PyObject * PyComplex_FromDoubles(double real_, double imag);

  double PyComplex_RealAsDouble(PyObject *op);
  double PyComplex_ImagAsDouble(PyObject *op);
  Py_complex PyComplex_AsCComplex(PyObject *op);


///////////////////////////////////////////////////////////////////////////////
// RANGE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/rangeobject.h:

  // &PyRange_Type is accessible via PyRange_Type_p.

  // D translation of C macro:
  int PyRange_Check(PyObject *op) {
    return op.ob_type == PyRange_Type_p;
  }

  PyObject * PyRange_New(C_long, C_long, C_long, int);


///////////////////////////////////////////////////////////////////////////////
// STRING INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/stringobject.h:

  struct PyStringObject {
    mixin PyObject_VAR_HEAD;

    C_long ob_shash;
    int ob_sstate;
    // DSR:XXX:LAYOUT:
    // Will the D layout for a 1-char array be the same as the C layout?  I
    // think the D array will be larger.
    char ob_sval[1];
  }

  // &PyBaseString_Type is accessible via PyBaseString_Type_p.
  // &PyString_Type is accessible via PyString_Type_p.

  // D translation of C macro:
  int PyString_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyString_Type_p);
  }
  // D translation of C macro:
  int PyString_CheckExact(PyObject *op) {
    return op.ob_type == PyString_Type_p;
  }

  PyObject * PyString_FromStringAndSize(char *, int);
  PyObject * PyString_FromString(char *);
  // PyString_FromFormatV omitted
  PyObject * PyString_FromFormat(char*, ...);
  int PyString_Size(PyObject *);
  char * PyString_AsString(PyObject *);
  PyObject * PyString_Repr(PyObject *, int);
  void PyString_Concat(PyObject **, PyObject *);
  void PyString_ConcatAndDel(PyObject **, PyObject *);
  PyObject * PyString_Format(PyObject *, PyObject *);
  PyObject * PyString_DecodeEscape(char *, int, char *, int, char *);

  void PyString_InternInPlace(PyObject **);
  void PyString_InternImmortal(PyObject **);
  PyObject * PyString_InternFromString(char *);

  PyObject * _PyString_Join(PyObject *sep, PyObject *x);


  PyObject* PyString_Decode(char *s, int size, char *encoding, char *errors);
  PyObject* PyString_Encode(char *s, int size, char *encoding, char *errors);

  PyObject* PyString_AsEncodedObject(PyObject *str, char *encoding, char *errors);
  PyObject* PyString_AsDecodedObject(PyObject *str, char *encoding, char *errors);

  // Since no one has legacy Python extensions written in D, the deprecated
  // functions PyString_AsDecodedString and PyString_AsEncodedString were
  // omitted.

  int PyString_AsStringAndSize(PyObject *obj, char **s, int *len);


///////////////////////////////////////////////////////////////////////////////
// BUFFER INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/bufferobject.h:

  // &PyBuffer_Type is accessible via PyBuffer_Type_p.

  // D translation of C macro:
  int PyBuffer_Check(PyObject *op) {
    return op.ob_type == PyBuffer_Type_p;
  }

  const int Py_END_OF_BUFFER = -1;

  PyObject * PyBuffer_FromObject(PyObject *base, int offset, int size);
  PyObject * PyBuffer_FromReadWriteObject(PyObject *base, int offset, int size);

  PyObject * PyBuffer_FromMemory(void *ptr, int size);
  PyObject * PyBuffer_FromReadWriteMemory(void *ptr, int size);

  PyObject * PyBuffer_New(int size);


///////////////////////////////////////////////////////////////////////////////
// TUPLE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/tupleobject.h:

  struct PyTupleObject {
    mixin PyObject_VAR_HEAD;

    // DSR:XXX:LAYOUT:
    // Will the D layout for a 1-PyObject* array be the same as the C layout?
    // I think the D array will be larger.
    PyObject *ob_item[1];
  }

  // &PyTuple_Type is accessible via PyTuple_Type_p.

  // D translation of C macro:
  int PyTuple_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyTuple_Type_p);
  }
  // D translation of C macro:
  int PyTuple_CheckExact(PyObject *op) {
    return op.ob_type == PyTuple_Type_p;
  }

  PyObject * PyTuple_New(int size);
  int PyTuple_Size(PyObject *);
  PyObject * PyTuple_GetItem(PyObject *, int);
  int PyTuple_SetItem(PyObject *, int, PyObject *);
  PyObject * PyTuple_GetSlice(PyObject *, int, int);
  int _PyTuple_Resize(PyObject **, int);
  PyObject * PyTuple_Pack(int, ...);

  // D translations of C macros:
  PyObject *PyTuple_GET_ITEM(PyObject *op, int i) {
    return (cast(PyTupleObject *) op).ob_item[i];
  }
  int PyTuple_GET_SIZE(PyObject *op) {
    return (cast(PyTupleObject *) op).ob_size;
  }
  PyObject *PyTuple_SET_ITEM(PyObject *op, int i, PyObject *v) {
    PyTupleObject *opAsTuple = cast(PyTupleObject *) op;
    opAsTuple.ob_item[i] = v;
    return v;
  }


///////////////////////////////////////////////////////////////////////////////
// LIST INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/listobject.h:

  struct PyListObject {
    mixin PyObject_VAR_HEAD;

    PyObject **ob_item;
    int allocated;
  }

  // &PyList_Type is accessible via PyList_Type_p.

  // D translation of C macro:
  int PyList_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyList_Type_p);
  }
  // D translation of C macro:
  int PyList_CheckExact(PyObject *op) {
    return op.ob_type == PyList_Type_p;
  }

  PyObject * PyList_New(int size);
  int PyList_Size(PyObject *);

  PyObject * PyList_GetItem(PyObject *, int);
  int PyList_SetItem(PyObject *, int, PyObject *);
  int PyList_Insert(PyObject *, int, PyObject *);
  int PyList_Append(PyObject *, PyObject *);
  PyObject * PyList_GetSlice(PyObject *, int, int);
  int PyList_SetSlice(PyObject *, int, int, PyObject *);
  int PyList_Sort(PyObject *);
  int PyList_Reverse(PyObject *);
  PyObject * PyList_AsTuple(PyObject *);

  // D translations of C macros:
  PyObject *PyList_GET_ITEM(PyObject *op, int i) {
    return (cast(PyListObject *) op).ob_item[i];
  }
  PyObject *PyList_SET_ITEM(PyObject *op, int i, PyObject *v) {
    PyListObject *opAsList = cast(PyListObject *) op;
    opAsList.ob_item[i] = v;
    return v;
  }
  int PyList_GET_SIZE(PyObject *op) {
    return (cast(PyListObject *) op).ob_size;
  }


///////////////////////////////////////////////////////////////////////////////
// DICTIONARY OBJECT TYPE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/dictobject.h:

  const int PyDict_MINSIZE = 8;

  struct PyDictEntry {
    C_long me_hash;
    PyObject *me_key;
    PyObject *me_value;
  }

  struct _dictobject {
    mixin PyObject_HEAD;

    int ma_fill;
    int ma_used;
    int ma_mask;
    PyDictEntry *ma_table;
    PyDictEntry *(*ma_lookup)(PyDictObject *mp, PyObject *key, C_long hash);
    PyDictEntry ma_smalltable[PyDict_MINSIZE];
  }
  alias _dictobject PyDictObject;

  // &PyDict_Type is accessible via PyDict_Type_p.

  // D translation of C macro:
  int PyDict_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyDict_Type_p);
  }
  // D translation of C macro:
  int PyDict_CheckExact(PyObject *op) {
    return op.ob_type == PyDict_Type_p;
  }

  PyObject * PyDict_New();
  PyObject * PyDict_GetItem(PyObject *mp, PyObject *key);
  int PyDict_SetItem(PyObject *mp, PyObject *key, PyObject *item);
  int PyDict_DelItem(PyObject *mp, PyObject *key);
  void PyDict_Clear(PyObject *mp);
  int PyDict_Next(PyObject *mp, int *pos, PyObject **key, PyObject **value);
  PyObject * PyDict_Keys(PyObject *mp);
  PyObject * PyDict_Values(PyObject *mp);
  PyObject * PyDict_Items(PyObject *mp);
  int PyDict_Size(PyObject *mp);
  PyObject * PyDict_Copy(PyObject *mp);
  int PyDict_Contains(PyObject *mp, PyObject *key);

  int PyDict_Update(PyObject *mp, PyObject *other);
  int PyDict_Merge(PyObject *mp, PyObject *other, int override_);
  int PyDict_MergeFromSeq2(PyObject *d, PyObject *seq2, int override_);

  PyObject * PyDict_GetItemString(PyObject *dp, char *key);
  int PyDict_SetItemString(PyObject *dp, char *key, PyObject *item);
  int PyDict_DelItemString(PyObject *dp, char *key);


///////////////////////////////////////////////////////////////////////////////
// PYTHON EXTENSION FUNCTION INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/methodobject.h:

  // &PyCFunction_Type is accessible via PyCFunction_Type_p.

  // D translation of C macro:
  int PyCFunction_Check(PyObject *op) {
    return op.ob_type == PyCFunction_Type_p;
  }

  alias PyObject *(*PyCFunction)(PyObject *, PyObject *);
  alias PyObject *(*PyCFunctionWithKeywords)(PyObject *, PyObject *,PyObject *);
  alias PyObject *(*PyNoArgsFunction)(PyObject *);

  PyCFunction PyCFunction_GetFunction(PyObject *);
  PyObject * PyCFunction_GetSelf(PyObject *);
  int PyCFunction_GetFlags(PyObject *);

  PyObject * PyCFunction_Call(PyObject *, PyObject *, PyObject *);

  struct PyMethodDef {
    char	*ml_name;
    PyCFunction  ml_meth;
    int		 ml_flags;
    char	*ml_doc;
  }

  PyObject * Py_FindMethod(PyMethodDef[], PyObject *, char *);
  PyObject * PyCFunction_NewEx(PyMethodDef *, PyObject *,PyObject *);

  const int METH_OLDARGS = 0x0000;
  const int METH_VARARGS = 0x0001;
  const int METH_KEYWORDS= 0x0002;
  const int METH_NOARGS  = 0x0004;
  const int METH_O       = 0x0008;
  const int METH_CLASS   = 0x0010;
  const int METH_STATIC  = 0x0020;
  const int METH_COEXIST = 0x0040;

  struct PyMethodChain {
    PyMethodDef *methods;
    PyMethodChain *link;
  }

  PyObject * Py_FindMethodInChain(PyMethodChain *, PyObject *, char *);

  struct PyCFunctionObject {
    mixin PyObject_HEAD;

    PyMethodDef *m_ml;
    PyObject    *m_self;
    PyObject    *m_module;
  }


///////////////////////////////////////////////////////////////////////////////
// MODULE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/moduleobject.h:

  // &PyModule_Type is accessible via PyModule_Type_p.

  // D translation of C macro:
  int PyModule_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyModule_Type_p);
  }
  // D translation of C macro:
  int PyModule_CheckExact(PyObject *op) {
    return op.ob_type == PyModule_Type_p;
  }

  PyObject * PyModule_New(char *);
  PyObject * PyModule_GetDict(PyObject *);
  char * PyModule_GetName(PyObject *);
  char * PyModule_GetFilename(PyObject *);

  // Python-header-file: Include/modsupport.h:

  const int PYTHON_API_VERSION = 1012;
  const char[] PYTHON_API_STRING = "1012";

  int PyArg_Parse(PyObject *, char *, ...);
  int PyArg_ParseTuple(PyObject *, char *, ...);
  int PyArg_ParseTupleAndKeywords(PyObject *, PyObject *,
                            char *, char **, ...);
  int PyArg_UnpackTuple(PyObject *, char *, int, int, ...);
  PyObject * Py_BuildValue(char *, ...);

  int PyModule_AddObject(PyObject *, char *, PyObject *);
  int PyModule_AddIntConstant(PyObject *, char *, C_long);
  int PyModule_AddStringConstant(PyObject *, char *, char *);

  PyObject * Py_InitModule4(char *name, PyMethodDef *methods, char *doc,
                            PyObject *self, int apiver);

  PyObject * Py_InitModule(char *name, PyMethodDef *methods)
  {
    return Py_InitModule4(name, methods, cast(char *)(null),
      cast(PyObject *)(null), PYTHON_API_VERSION);
  }

  PyObject *Py_InitModule3(char *name, PyMethodDef *methods, char *doc) {
    return Py_InitModule4(name, methods, doc, cast(PyObject *)null,
      PYTHON_API_VERSION);
  }


///////////////////////////////////////////////////////////////////////////////
// PYTHON FUNCTION INTERFACE (to functions created by the 'def' statement)
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/funcobject.h:

  struct PyFunctionObject {
    mixin PyObject_HEAD;

    PyObject *func_code;
    PyObject *func_globals;
    PyObject *func_defaults;
    PyObject *func_closure;
    PyObject *func_doc;
    PyObject *func_name;
    PyObject *func_dict;
    PyObject *func_weakreflist;
    PyObject *func_module;
  }

  // &PyFunction_Type is accessible via PyFunction_Type_p.

  // D translation of C macro:
  int PyFunction_Check(PyObject *op) {
    return op.ob_type == PyFunction_Type_p;
  }

  PyObject * PyFunction_New(PyObject *, PyObject *);
  PyObject * PyFunction_GetCode(PyObject *);
  PyObject * PyFunction_GetGlobals(PyObject *);
  PyObject * PyFunction_GetModule(PyObject *);
  PyObject * PyFunction_GetDefaults(PyObject *);
  int PyFunction_SetDefaults(PyObject *, PyObject *);
  PyObject * PyFunction_GetClosure(PyObject *);
  int PyFunction_SetClosure(PyObject *, PyObject *);

  // &PyClassMethod_Type is accessible via PyClassMethod_Type_p.
  // &PyStaticMethod_Type is accessible via PyStaticMethod_Type_p.

  PyObject * PyClassMethod_New(PyObject *);
  PyObject * PyStaticMethod_New(PyObject *);


///////////////////////////////////////////////////////////////////////////////
// PYTHON CLASS INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/classobject.h:

  struct PyClassObject {
    mixin PyObject_HEAD;

    PyObject	*cl_bases;	/* A tuple of class objects */
    PyObject	*cl_dict;	/* A dictionary */
    PyObject	*cl_name;	/* A string */
    /* The following three are functions or null */
    PyObject	*cl_getattr;
    PyObject	*cl_setattr;
    PyObject	*cl_delattr;
  }

  struct PyInstanceObject {
    mixin PyObject_HEAD;

    PyClassObject *in_class;
    PyObject	  *in_dict;
    PyObject	  *in_weakreflist;
  }

  struct PyMethodObject {
    mixin PyObject_HEAD;

    PyObject *im_func;
    PyObject *im_self;
    PyObject *im_class;
    PyObject *im_weakreflist;
  }

  // &PyClass_Type is accessible via PyClass_Type_p.
  // D translation of C macro:
  int PyClass_Check(PyObject *op) {
    return op.ob_type == PyClass_Type_p;
  }

  // &PyInstance_Type is accessible via PyInstance_Type_p.
  // D translation of C macro:
  int PyInstance_Check(PyObject *op) {
    return op.ob_type == PyInstance_Type_p;
  }

  // &PyMethod_Type is accessible via PyMethod_Type_p.
  // D translation of C macro:
  int PyMethod_Check(PyObject *op) {
    return op.ob_type == PyMethod_Type_p;
  }

  PyObject * PyClass_New(PyObject *, PyObject *, PyObject *);
  PyObject * PyInstance_New(PyObject *, PyObject *,
                        PyObject *);
  PyObject * PyInstance_NewRaw(PyObject *, PyObject *);
  PyObject * PyMethod_New(PyObject *, PyObject *, PyObject *);

  PyObject * PyMethod_Function(PyObject *);
  PyObject * PyMethod_Self(PyObject *);
  PyObject * PyMethod_Class(PyObject *);

  PyObject * _PyInstance_Lookup(PyObject *pinst, PyObject *name);

  int PyClass_IsSubclass(PyObject *, PyObject *);


///////////////////////////////////////////////////////////////////////////////
// FILE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/fileobject.h:

  struct PyFileObject {
    mixin PyObject_HEAD;

    FILE *f_fp;
    PyObject *f_name;
    PyObject *f_mode;
    int (*f_close)(FILE *);
    int f_softspace;
    int f_binary;
    char* f_buf;
    char* f_bufend;
    char* f_bufptr;
    char *f_setbuf;
    int f_univ_newline;
    int f_newlinetypes;
    int f_skipnextlf;
    PyObject *f_encoding;
    PyObject *weakreflist;
  }

  // &PyFile_Type is accessible via PyFile_Type_p.
  // D translation of C macro:
  int PyFile_Check(PyObject *op) {
    return PyObject_TypeCheck(op, PyFile_Type_p);
  }
  // D translation of C macro:
  int PyFile_CheckExact(PyObject *op) {
    return op.ob_type == PyFile_Type_p;
  }

  PyObject * PyFile_FromString(char *, char *);
  void PyFile_SetBufSize(PyObject *, int);
  int PyFile_SetEncoding(PyObject *,  char *);
  PyObject * PyFile_FromFile(FILE *, char *, char *,
                         int (*)(FILE *));
  FILE * PyFile_AsFile(PyObject *);
  PyObject * PyFile_Name(PyObject *);
  PyObject * PyFile_GetLine(PyObject *, int);
  int PyFile_WriteObject(PyObject *, PyObject *, int);
  int PyFile_SoftSpace(PyObject *, int);
  int PyFile_WriteString(char *, PyObject *);
  int PyObject_AsFileDescriptor(PyObject *);

  // We deal with char *Py_FileSystemDefaultEncoding in the global variables
  // section toward the bottom of this file.

  const char[] PY_STDIOTEXTMODE = "b";

  char *Py_UniversalNewlineFgets(char *, int, FILE*, PyObject *);
  size_t Py_UniversalNewlineFread(char *, size_t, FILE *, PyObject *);


///////////////////////////////////////////////////////////////////////////////
// COBJECT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/cobject.h:

  // PyCObject_Type is a Python type for transporting an arbitrary C pointer
  // from the C level to Python and back (in essence, an opaque handle).

  // &PyCObject_Type is accessible via PyCObject_Type_p.
  // D translation of C macro:
  int PyCObject_Check(PyObject *op) {
    return op.ob_type == PyCObject_Type_p;
  }

  PyObject * PyCObject_FromVoidPtr(void *cobj, void (*destruct)(void*));
  PyObject * PyCObject_FromVoidPtrAndDesc(void *cobj, void *desc,
    void (*destruct)(void*,void*));
  void * PyCObject_AsVoidPtr(PyObject *);
  void * PyCObject_GetDesc(PyObject *);
  void * PyCObject_Import(char *module_name, char *cobject_name);
  int PyCObject_SetVoidPtr(PyObject *self, void *cobj);


///////////////////////////////////////////////////////////////////////////////////////////////
// TRACEBACK INTERFACE
///////////////////////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/traceback.h:

  struct PyTracebackObject {
    mixin PyObject_HEAD;

    PyTracebackObject *tb_next;
    PyFrameObject *tb_frame;
    int tb_lasti;
    int tb_lineno;
  }

  int PyTraceBack_Here(PyFrameObject *);
  int PyTraceBack_Print(PyObject *, PyObject *);

  // &PyTraceBack_Type is accessible via PyTraceBack_Type_p.
  // D translation of C macro:
  int PyTraceBack_Check(PyObject *v) {
    return v.ob_type == PyTraceBack_Type_p;
  }


///////////////////////////////////////////////////////////////////////////////
// SLICE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/sliceobject.h:

  // We deal with Py_Ellipsis in the global variables section toward the bottom
  // of this file.

  struct PySliceObject {
    mixin PyObject_HEAD;

    PyObject *start;
    PyObject *stop;
    PyObject *step;
  }

  // &PySlice_Type is accessible via PySlice_Type_p.
  // D translation of C macro:
  int PySlice_Check(PyObject *op) {
    return op.ob_type == PySlice_Type_p;
  }

  PyObject * PySlice_New(PyObject *start, PyObject *stop, PyObject *step);
  int PySlice_GetIndices(PySliceObject *r, int length, int *start, int *stop, int *step);
  int PySlice_GetIndicesEx(PySliceObject *r, int length, int *start, int *stop, int *step, int *slicelength);


///////////////////////////////////////////////////////////////////////////////
// CELL INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/cellobject.h:

  struct PyCellObject {
    mixin PyObject_HEAD;

    PyObject *ob_ref;
  }

  // &PyCell_Type is accessible via PyCell_Type_p.
  // D translation of C macro:
  int PyCell_Check(PyObject *op) {
    return op.ob_type == PyCell_Type_p;
  }

  PyObject * PyCell_New(PyObject *);
  PyObject * PyCell_Get(PyObject *);
  int PyCell_Set(PyObject *, PyObject *);


///////////////////////////////////////////////////////////////////////////////
// ITERATOR INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/iterobject.h:

  // &PySeqIter_Type is accessible via PySeqIter_Type_p.
  // D translation of C macro:
  int PySeqIter_Check(PyObject *op) {
    return op.ob_type == PySeqIter_Type_p;
  }

  PyObject * PySeqIter_New(PyObject *);

  // &PyCallIter_Type is accessible via PyCallIter_Type_p.
  // D translation of C macro:
  int PyCallIter_Check(PyObject *op) {
    return op.ob_type == PyCallIter_Type_p;
  }

  PyObject * PyCallIter_New(PyObject *, PyObject *);


///////////////////////////////////////////////////////////////////////////////
// DESCRIPTOR INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/descrobject.h:

  alias PyObject *(*getter)(PyObject *, void *);
  alias int (*setter)(PyObject *, PyObject *, void *);

  struct PyGetSetDef {
    char *name;
    getter get;
    setter set;
    char *doc;
    void *closure;
  }

  alias PyObject *(*wrapperfunc)(PyObject *, PyObject *, void *);
  alias PyObject *(*wrapperfunc_kwds)(PyObject *, PyObject *, void *, PyObject *);

  struct wrapperbase {
    char *name;
    int offset;
    void *function_;
    wrapperfunc wrapper;
    char *doc;
    int flags;
    PyObject *name_strobj;
  }

  const int PyWrapperFlag_KEYWORDS = 1;

  template PyDescr_COMMON() {
    mixin PyObject_HEAD;
    PyTypeObject *d_type;
    PyObject *d_name;
  }

  struct PyDescrObject {
    mixin PyDescr_COMMON;
  }

  struct PyMethodDescrObject {
    mixin PyDescr_COMMON;
    PyMethodDef *d_method;
  }

  struct PyMemberDescrObject {
    mixin PyDescr_COMMON;
    PyMemberDef *d_member;
  }

  struct PyGetSetDescrObject {
    mixin PyDescr_COMMON;
    PyGetSetDef *d_getset;
  }

  struct PyWrapperDescrObject {
    mixin PyDescr_COMMON;
    wrapperbase *d_base;
    void *d_wrapped;
  }

  // PyWrapperDescr_Type is currently not accessible from D.

  PyObject * PyDescr_NewMethod(PyTypeObject *, PyMethodDef *);
  PyObject * PyDescr_NewClassMethod(PyTypeObject *, PyMethodDef *);
  PyObject * PyDescr_NewMember(PyTypeObject *, PyMemberDef *);
  PyObject * PyDescr_NewGetSet(PyTypeObject *, PyGetSetDef *);
  PyObject * PyDescr_NewWrapper(PyTypeObject *, wrapperbase *, void *);
  PyObject * PyDictProxy_New(PyObject *);
  PyObject * PyWrapper_New(PyObject *, PyObject *);

  // &PyProperty_Type is accessible via PyProperty_Type_p.


///////////////////////////////////////////////////////////////////////////////
// WEAK REFERENCE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/weakrefobject.h:

  struct PyWeakReference {
    mixin PyObject_HEAD;

    PyObject *wr_object;
    PyObject *wr_callback;
    C_long hash;
    PyWeakReference *wr_prev;
    PyWeakReference *wr_next;
  }

  // &_PyWeakref_RefType is accessible via _PyWeakref_RefType_p.
  // &_PyWeakref_ProxyType is accessible via _PyWeakref_ProxyType_p.
  // &_PyWeakref_CallableProxyType is accessible via _PyWeakref_CallableProxyType_p.

  // D translations of C macros:
  int PyWeakref_CheckRef(PyObject *op) {
    return PyObject_TypeCheck(op, _PyWeakref_RefType_p);
  }
  int PyWeakref_CheckRefExact(PyObject *op) {
    return op.ob_type == _PyWeakref_RefType_p;
  }
  int PyWeakref_CheckProxy(PyObject *op) {
    return op.ob_type == _PyWeakref_ProxyType_p
        || op.ob_type == _PyWeakref_CallableProxyType_p;
  }
  int PyWeakref_Check(PyObject *op) {
    return PyWeakref_CheckRef(op) || PyWeakref_CheckProxy(op);
  }

  PyObject * PyWeakref_NewRef(PyObject *ob, PyObject *callback);
  PyObject * PyWeakref_NewProxy(PyObject *ob, PyObject *callback);
  PyObject * PyWeakref_GetObject(PyObject *ref);

  C_long _PyWeakref_GetWeakrefCount(PyWeakReference *head);
  void _PyWeakref_ClearRef(PyWeakReference *self);

  PyObject *PyWeakref_GET_OBJECT(PyObject *ref) {
    return (cast(PyWeakReference *) ref).wr_object;
  }


///////////////////////////////////////////////////////////////////////////////
// CODEC REGISTRY AND SUPPORT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/codecs.h:

  int PyCodec_Register(PyObject *search_function);
  PyObject * _PyCodec_Lookup(char *encoding);
  PyObject * PyCodec_Encode(PyObject *object, char *encoding, char *errors);
  PyObject * PyCodec_Decode(PyObject *object, char *encoding, char *errors);
  PyObject * PyCodec_Encoder(char *encoding);
  PyObject * PyCodec_Decoder(char *encoding);
  PyObject * PyCodec_StreamReader(char *encoding, PyObject *stream, char *errors);
  PyObject * PyCodec_StreamWriter(char *encoding, PyObject *stream, char *errors);

  /////////////////////////////////////////////////////////////////////////////
  // UNICODE ENCODING INTERFACE
  /////////////////////////////////////////////////////////////////////////////

  int PyCodec_RegisterError(char *name, PyObject *error);
  PyObject * PyCodec_LookupError(char *name);
  PyObject * PyCodec_StrictErrors(PyObject *exc);
  PyObject * PyCodec_IgnoreErrors(PyObject *exc);
  PyObject * PyCodec_ReplaceErrors(PyObject *exc);
  PyObject * PyCodec_XMLCharRefReplaceErrors(PyObject *exc);
  PyObject * PyCodec_BackslashReplaceErrors(PyObject *exc);


///////////////////////////////////////////////////////////////////////////////
// ERROR HANDLING INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/pyerrors.h:

  void PyErr_SetNone(PyObject *);
  void PyErr_SetObject(PyObject *, PyObject *);
  void PyErr_SetString(PyObject *, char *);
  PyObject * PyErr_Occurred();
  void PyErr_Clear();
  void PyErr_Fetch(PyObject **, PyObject **, PyObject **);
  void PyErr_Restore(PyObject *, PyObject *, PyObject *);

  int PyErr_GivenExceptionMatches(PyObject *, PyObject *);
  int PyErr_ExceptionMatches(PyObject *);
  void PyErr_NormalizeException(PyObject **, PyObject **, PyObject **);

  // All predefined Python exception types are dealt with in the global
  // variables section toward the end of this file.

  int PyErr_BadArgument();
  PyObject * PyErr_NoMemory();
  PyObject * PyErr_SetFromErrno(PyObject *);
  PyObject * PyErr_SetFromErrnoWithFilenameObject(PyObject *, PyObject *);
  PyObject * PyErr_SetFromErrnoWithFilename(PyObject *, char *);
  PyObject * PyErr_SetFromErrnoWithUnicodeFilename(PyObject *, Py_UNICODE *);

  PyObject * PyErr_Format(PyObject *, char *, ...);

  version (Windows) {
    PyObject * PyErr_SetFromWindowsErrWithFilenameObject(int,  char *);
    PyObject * PyErr_SetFromWindowsErrWithFilename(int, char *);
    PyObject * PyErr_SetFromWindowsErrWithUnicodeFilename(int, Py_UNICODE *);
    PyObject * PyErr_SetFromWindowsErr(int);
    PyObject * PyErr_SetExcFromWindowsErrWithFilenameObject(PyObject *, int, PyObject *);
    PyObject * PyErr_SetExcFromWindowsErrWithFilename(PyObject *, int,  char *);
    PyObject * PyErr_SetExcFromWindowsErrWithUnicodeFilename(PyObject *, int, Py_UNICODE *);
    PyObject * PyErr_SetExcFromWindowsErr(PyObject *, int);
  }

  // PyErr_BadInternalCall and friends purposely omitted.

  PyObject * PyErr_NewException(char *name, PyObject *base, PyObject *dict);
  void PyErr_WriteUnraisable(PyObject *);

  int PyErr_Warn(PyObject *, char *);
  int PyErr_WarnExplicit(PyObject *, char *, char *, int, char *, PyObject *);

  int PyErr_CheckSignals();
  void PyErr_SetInterrupt();

  void PyErr_SyntaxLocation(char *, int);
  PyObject * PyErr_ProgramText(char *, int);

  /////////////////////////////////////////////////////////////////////////////
  // UNICODE ENCODING ERROR HANDLING INTERFACE
  /////////////////////////////////////////////////////////////////////////////
  PyObject *PyUnicodeDecodeError_Create(char *, char *, int, int, int, char *);

  PyObject *PyUnicodeEncodeError_Create(char *, Py_UNICODE *, int, int, int, char *);

  PyObject *PyUnicodeTranslateError_Create(Py_UNICODE *, int, int, int, char *);

  PyObject *PyUnicodeEncodeError_GetEncoding(PyObject *);
  PyObject *PyUnicodeDecodeError_GetEncoding(PyObject *);

  PyObject *PyUnicodeEncodeError_GetObject(PyObject *);
  PyObject *PyUnicodeDecodeError_GetObject(PyObject *);
  PyObject *PyUnicodeTranslateError_GetObject(PyObject *);

  int PyUnicodeEncodeError_GetStart(PyObject *, int *);
  int PyUnicodeDecodeError_GetStart(PyObject *, int *);
  int PyUnicodeTranslateError_GetStart(PyObject *, int *);

  int PyUnicodeEncodeError_SetStart(PyObject *, int);
  int PyUnicodeDecodeError_SetStart(PyObject *, int);
  int PyUnicodeTranslateError_SetStart(PyObject *, int);

  int PyUnicodeEncodeError_GetEnd(PyObject *, int *);
  int PyUnicodeDecodeError_GetEnd(PyObject *, int *);
  int PyUnicodeTranslateError_GetEnd(PyObject *, int *);

  int PyUnicodeEncodeError_SetEnd(PyObject *, int);
  int PyUnicodeDecodeError_SetEnd(PyObject *, int);
  int PyUnicodeTranslateError_SetEnd(PyObject *, int);

  PyObject *PyUnicodeEncodeError_GetReason(PyObject *);
  PyObject *PyUnicodeDecodeError_GetReason(PyObject *);
  PyObject *PyUnicodeTranslateError_GetReason(PyObject *);

  int PyUnicodeEncodeError_SetReason(PyObject *, char *);
  int PyUnicodeDecodeError_SetReason(PyObject *, char *);
  int PyUnicodeTranslateError_SetReason(PyObject *, char *);

  int PyOS_snprintf(char *str, size_t size, char *format, ...);


///////////////////////////////////////////////////////////////////////////////
// COMPILATION INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/compile.h:

  struct PyCodeObject { /* Bytecode object */
    mixin PyObject_HEAD;

    int co_argcount;
    int co_nlocals;
    int co_stacksize;
    int co_flags;
    PyObject *co_code;
    PyObject *co_consts;
    PyObject *co_names;
    PyObject *co_varnames;
    PyObject *co_freevars;
    PyObject *co_cellvars;

    PyObject *co_filename;
    PyObject *co_name;
    int co_firstlineno;
    PyObject *co_lnotab;
  }

  /* Masks for co_flags above */
  const int CO_OPTIMIZED   = 0x0001;
  const int CO_NEWLOCALS   = 0x0002;
  const int CO_VARARGS     = 0x0004;
  const int CO_VARKEYWORDS = 0x0008;
  const int CO_NESTED      = 0x0010;
  const int CO_GENERATOR   = 0x0020;
  const int CO_NOFREE      = 0x0040;

  const int CO_GENERATOR_ALLOWED = 0x1000;
  const int CO_FUTURE_DIVISION   = 0x2000;

  // &PyCode_Type is accessible via PyCode_Type_p.
  // D translations of C macros:
  int PyCode_Check(PyObject *op) {
    return op.ob_type == PyCode_Type_p;
  }
  int PyCode_GetNumFree(PyObject *op) {
    return PyObject_Length((cast(PyCodeObject *) op).co_freevars);
  }

  const int CO_MAXBLOCKS = 20;

  struct node {
    short	n_type;
    char	*n_str;
    int		n_lineno;
    int		n_nchildren;
    node	*n_child;
  }

  PyCodeObject *PyNode_Compile(node *, char *);
  PyCodeObject *PyCode_New(
    int, int, int, int, PyObject *, PyObject *, PyObject *, PyObject *,
    PyObject *, PyObject *, PyObject *, PyObject *, int, PyObject *);
  int PyCode_Addr2Line(PyCodeObject *, int);

  struct PyFutureFeatures {
    int ff_found_docstring;
    int ff_last_lineno;
    int ff_features;
  }

  PyFutureFeatures *PyNode_Future(node *, char *);
  PyCodeObject *PyNode_CompileFlags(node *, char *, PyCompilerFlags *);

  const char[] FUTURE_NESTED_SCOPES = "nested_scopes";
  const char[] FUTURE_GENERATORS = "generators";
  const char[] FUTURE_DIVISION = "division";


///////////////////////////////////////////////////////////////////////////////
// CODE EXECUTION INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/pythonrun.h:

  struct PyCompilerFlags {
    int cf_flags;
  }

  void Py_SetProgramName(char *);
  char *Py_GetProgramName();

  void Py_SetPythonHome(char *);
  char *Py_GetPythonHome();

  void Py_Initialize();
  void Py_InitializeEx(int);
  void Py_Finalize();
  int Py_IsInitialized();
  PyThreadState *Py_NewInterpreter();
  void Py_EndInterpreter(PyThreadState *);

  int PyRun_AnyFile(FILE *, char *);
  int PyRun_AnyFileEx(FILE *, char *, int);

  int PyRun_AnyFileFlags(FILE *, char *, PyCompilerFlags *);
  int PyRun_AnyFileExFlags(FILE *, char *, int, PyCompilerFlags *);

  int PyRun_SimpleString(char *);
  int PyRun_SimpleStringFlags(char *, PyCompilerFlags *);
  int PyRun_SimpleFile(FILE *, char *);
  int PyRun_SimpleFileEx(FILE *, char *, int);
  int PyRun_SimpleFileExFlags(FILE *,  char *, int, PyCompilerFlags *);
  int PyRun_InteractiveOne(FILE *, char *);
  int PyRun_InteractiveOneFlags(FILE *, char *, PyCompilerFlags *);
  int PyRun_InteractiveLoop(FILE *, char *);
  int PyRun_InteractiveLoopFlags(FILE *, char *, PyCompilerFlags *);

  node *PyParser_SimpleParseString(char *, int);
  node *PyParser_SimpleParseFile(FILE *, char *, int);
  node *PyParser_SimpleParseStringFlags(char *, int, int);
  node *PyParser_SimpleParseStringFlagsFilename(char *, char *, int, int);
  node *PyParser_SimpleParseFileFlags(FILE *, char *,int, int);

  PyObject *PyRun_String(char *, int, PyObject *, PyObject *);
  PyObject *PyRun_File(FILE *, char *, int, PyObject *, PyObject *);
  PyObject *PyRun_FileEx(FILE *, char *, int, PyObject *, PyObject *, int);
  PyObject *PyRun_StringFlags( char *, int, PyObject *, PyObject *, PyCompilerFlags *);
  PyObject *PyRun_FileFlags(FILE *, char *, int, PyObject *, PyObject *, PyCompilerFlags *);
  PyObject *PyRun_FileExFlags(FILE *, char *, int, PyObject *, PyObject *, int, PyCompilerFlags *);

  PyObject *Py_CompileString(char *, char *, int);
  PyObject *Py_CompileStringFlags(char *, char *, int, PyCompilerFlags *);
  // Py_SymtableString is undocumented, so it's omitted here.

  void PyErr_Print();
  void PyErr_PrintEx(int);
  void PyErr_Display(PyObject *, PyObject *, PyObject *);

  int Py_AtExit(void (*func)());

  void Py_Exit(int);

  int Py_FdIsInteractive(FILE *, char *);


///////////////////////////////////////////////////////////////////////////////
// BOOTSTRAPPING INTERFACE (for embedding Python in D)
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/pythonrun.h:

  int Py_Main(int argc, char **argv);

  char *Py_GetProgramFullPath();
  char *Py_GetPrefix();
  char *Py_GetExecPrefix();
  char *Py_GetPath();

  char *Py_GetVersion();
  char *Py_GetPlatform();
  char *Py_GetCopyright();
  char *Py_GetCompiler();
  char *Py_GetBuildInfo();

  /////////////////////////////////////////////////////////////////////////////
  // ONE-TIME INITIALIZERS
  /////////////////////////////////////////////////////////////////////////////

  PyObject *_PyBuiltin_Init();
  PyObject *_PySys_Init();
  void _PyImport_Init();
  void _PyExc_Init();
  void _PyImportHooks_Init();
  int _PyFrame_Init();
  int _PyInt_Init();

  /////////////////////////////////////////////////////////////////////////////
  // FINALIZERS
  /////////////////////////////////////////////////////////////////////////////

  void _PyExc_Fini();
  void _PyImport_Fini();
  void PyMethod_Fini();
  void PyFrame_Fini();
  void PyCFunction_Fini();
  void PyTuple_Fini();
  void PyString_Fini();
  void PyInt_Fini();
  void PyFloat_Fini();
  void PyOS_FiniInterrupts();

  /////////////////////////////////////////////////////////////////////////////
  // VARIOUS (API members documented as having "no proper home")
  /////////////////////////////////////////////////////////////////////////////
  char *PyOS_Readline(FILE *, FILE *, char *);
  int (*PyOS_InputHook)();
  char *(*PyOS_ReadlineFunctionPointer)(FILE *, FILE *, char *);
  // _PyOS_ReadlineTState omitted.
  const int PYOS_STACK_MARGIN = 2048;
  // PyOS_CheckStack omitted.

  /////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  /////////////////////////////////////////////////////////////////////////////

  alias void (*PyOS_sighandler_t)(int);
  PyOS_sighandler_t PyOS_getsig(int);
  PyOS_sighandler_t PyOS_setsig(int, PyOS_sighandler_t);


///////////////////////////////////////////////////////////////////////////////
// EVAL CALLS (documented as "Interface to random parts in ceval.c")
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/ceval.h:
  PyObject *PyEval_CallObjectWithKeywords(PyObject *, PyObject *, PyObject *);
  PyObject *PyEval_CallObject(PyObject *, PyObject *);
  PyObject *PyEval_CallFunction(PyObject *obj, char *format, ...);
  PyObject *PyEval_CallMethod(PyObject *obj, char *methodname, char *format, ...);

  void PyEval_SetProfile(Py_tracefunc, PyObject *);
  void PyEval_SetTrace(Py_tracefunc, PyObject *);

  PyObject *PyEval_GetBuiltins();
  PyObject *PyEval_GetGlobals();
  PyObject *PyEval_GetLocals();
  PyFrameObject *PyEval_GetFrame();
  int PyEval_GetRestricted();

  int PyEval_MergeCompilerFlags(PyCompilerFlags *cf);
  int Py_FlushLine();
  int Py_AddPendingCall(int (*func)(void *), void *arg);
  int Py_MakePendingCalls();

  void Py_SetRecursionLimit(int);
  int Py_GetRecursionLimit();

  // The following API members are undocumented, so they're omitted here:
    // Py_EnterRecursiveCall
    // Py_LeaveRecursiveCall
    // _Py_CheckRecursiveCall
    // _Py_CheckRecursionLimit
    // _Py_MakeRecCheck

  char *PyEval_GetFuncName(PyObject *);
  char *PyEval_GetFuncDesc(PyObject *);

  PyObject *PyEval_GetCallStats(PyObject *);
  PyObject *PyEval_EvalFrame(PyFrameObject *);


///////////////////////////////////////////////////////////////////////////////
// SYSTEM MODULE INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/sysmodule.h:

  PyObject *PySys_GetObject(char *);
  int PySys_SetObject(char *, PyObject *);
  FILE *PySys_GetFile(char *, FILE *);
  void PySys_SetArgv(int, char **);
  void PySys_SetPath(char *);

  void PySys_WriteStdout(char *format, ...);
  void PySys_WriteStderr(char *format, ...);

  void PySys_ResetWarnOptions();
  void PySys_AddWarnOption(char *);


///////////////////////////////////////////////////////////////////////////////
// INTERRUPT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/intrcheck.h:

  int PyOS_InterruptOccurred();
  void PyOS_InitInterrupts();
  void PyOS_AfterFork();


///////////////////////////////////////////////////////////////////////////////
// FRAME INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/frameobject.h:

  struct PyTryBlock {
    int b_type;
    int b_handler;
    int b_level;
  }

  struct PyFrameObject {
    mixin PyObject_VAR_HEAD;

    PyFrameObject *f_back;
    PyCodeObject *f_code;
    PyObject *f_builtins;
    PyObject *f_globals;
    PyObject *f_locals;
    PyObject **f_valuestack;
    PyObject **f_stacktop;
    PyObject *f_trace;
    PyObject *f_exc_type;
    PyObject *f_exc_value;
    PyObject *f_exc_traceback;
    PyThreadState *f_tstate;
    int f_lasti;
    int f_lineno;
    int f_restricted;
    int f_iblock;
    PyTryBlock f_blockstack[CO_MAXBLOCKS];
    int f_nlocals;
    int f_ncells;
    int f_nfreevars;
    int f_stacksize;
    PyObject *f_localsplus[1];
  }

  // &PyFrame_Type is accessible via PyFrame_Type_p.
  // D translation of C macro:
  int PyFrame_Check(PyObject *op) {
    return op.ob_type == PyFrame_Type_p;
  }

  PyFrameObject *PyFrame_New(PyThreadState *, PyCodeObject *,
                             PyObject *, PyObject *);

  void PyFrame_BlockSetup(PyFrameObject *, int, int, int);
  PyTryBlock *PyFrame_BlockPop(PyFrameObject *);
  PyObject **PyFrame_ExtendStack(PyFrameObject *, int, int);

  void PyFrame_LocalsToFast(PyFrameObject *, int);
  void PyFrame_FastToLocals(PyFrameObject *);


///////////////////////////////////////////////////////////////////////////////
// INTERPRETER STATE AND THREAD STATE INTERFACES
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/pystate.h:

  struct PyInterpreterState {
    PyInterpreterState *next;
    PyThreadState *tstate_head;

    PyObject *modules;
    PyObject *sysdict;
    PyObject *builtins;

    PyObject *codec_search_path;
    PyObject *codec_search_cache;
    PyObject *codec_error_registry;

    int dlopenflags;

    // XXX: Not sure what WITH_TSC refers to, or how to conditionalize it in D:
    //#ifdef WITH_TSC
    //  int tscdump;
    //#endif
  }

  alias int (*Py_tracefunc)(PyObject *, PyFrameObject *, int, PyObject *);

  const int PyTrace_CALL   	= 0;
  const int PyTrace_EXCEPTION = 1;
  const int PyTrace_LINE 		= 2;
  const int PyTrace_RETURN 	= 3;
  const int PyTrace_C_CALL = 4;
  const int PyTrace_C_EXCEPTION = 5;
  const int PyTrace_C_RETURN = 6;

  struct PyThreadState {
    PyThreadState *next;
    PyInterpreterState *interp;

    PyFrameObject *frame;
    int recursion_depth;
    int tracing;
    int use_tracing;

    Py_tracefunc c_profilefunc;
    Py_tracefunc c_tracefunc;
    PyObject *c_profileobj;
    PyObject *c_traceobj;

    PyObject *curexc_type;
    PyObject *curexc_value;
    PyObject *curexc_traceback;

    PyObject *exc_type;
    PyObject *exc_value;
    PyObject *exc_traceback;

    PyObject *dict;

    int tick_counter;
    int gilstate_counter;

    PyObject *async_exc;
    C_long thread_id;
  }

  PyInterpreterState *PyInterpreterState_New();
  void PyInterpreterState_Clear(PyInterpreterState *);
  void PyInterpreterState_Delete(PyInterpreterState *);

  PyThreadState *PyThreadState_New(PyInterpreterState *);
  void PyThreadState_Clear(PyThreadState *);
  void PyThreadState_Delete(PyThreadState *);
  void PyThreadState_DeleteCurrent();

  PyThreadState *PyThreadState_Get();
  PyThreadState *PyThreadState_Swap(PyThreadState *);
  PyObject *PyThreadState_GetDict();
  int PyThreadState_SetAsyncExc(C_long, PyObject *);

  enum PyGILState_STATE {PyGILState_LOCKED, PyGILState_UNLOCKED};

  PyGILState_STATE PyGILState_Ensure();
  void PyGILState_Release(PyGILState_STATE);
  PyThreadState *PyGILState_GetThisThreadState();
  PyInterpreterState *PyInterpreterState_Head();
  PyInterpreterState *PyInterpreterState_Next(PyInterpreterState *);
  PyThreadState *PyInterpreterState_ThreadHead(PyInterpreterState *);
  PyThreadState *PyThreadState_Next(PyThreadState *);

  alias PyFrameObject *(*PyThreadFrameGetter)(PyThreadState *self_);

  // Python-header-file: Include/ceval.h:
  PyThreadState *PyEval_SaveThread();
  void PyEval_RestoreThread(PyThreadState *);

  int PyEval_ThreadsInitialized();
  void PyEval_InitThreads();
  void PyEval_AcquireLock();
  void PyEval_ReleaseLock();
  void PyEval_AcquireThread(PyThreadState *tstate);
  void PyEval_ReleaseThread(PyThreadState *tstate);
  void PyEval_ReInitThreads();

  // YYY: The following macros need to be implemented somehow, but DSR doesn't
  // think D's mixin feature is up to the job.
  // Py_BEGIN_ALLOW_THREADS
  // Py_BLOCK_THREADS
  // Py_UNBLOCK_THREADS
  // Py_END_ALLOW_THREADS


///////////////////////////////////////////////////////////////////////////////
// MODULE IMPORT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/import.h:

  C_long PyImport_GetMagicNumber();
  PyObject *PyImport_ExecCodeModule(char *name, PyObject *co);
  PyObject *PyImport_ExecCodeModuleEx(char *name, PyObject *co, char *pathname);
  PyObject *PyImport_GetModuleDict();
  PyObject *PyImport_AddModule(char *name);
  PyObject *PyImport_ImportModule(char *name);
  PyObject *PyImport_ImportModuleEx(char *name, PyObject *globals, PyObject *locals, PyObject *fromlist);
  PyObject *PyImport_Import(PyObject *name);
  PyObject *PyImport_ReloadModule(PyObject *m);
  void PyImport_Cleanup();
  int PyImport_ImportFrozenModule(char *);

  // The following API members are undocumented, so they're omitted here:
    // _PyImport_FindModule
    // _PyImport_IsScript
    // _PyImport_ReInitLock

  PyObject *_PyImport_FindExtension(char *, char *);
  PyObject *_PyImport_FixupExtension(char *, char *);

  struct _inittab {
    char *name;
    void (*initfunc)();
  }

  int PyImport_AppendInittab(char *name, void (*initfunc)());
  int PyImport_ExtendInittab(_inittab *newtab);

  struct _frozen {
    char *name;
    ubyte *code;
    int size;
  }

  // Omitted:
    // PyImport_FrozenModules


///////////////////////////////////////////////////////////////////////////////
// ABSTRACT OBJECT INTERFACE
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/abstract.h:

  // D translations of C macros:
  int PyObject_DelAttrString(PyObject *o, char *a) {
    return PyObject_SetAttrString(o, a, null);
  }
  int PyObject_DelAttr(PyObject *o, PyObject *a) {
    return PyObject_SetAttr(o, a, null);
  }

  int PyObject_Cmp(PyObject *o1, PyObject *o2, int *result);

  /////////////////////////////////////////////////////////////////////////////
  // CALLABLES
  /////////////////////////////////////////////////////////////////////////////
  int PyCallable_Check(PyObject *o);

  PyObject *PyObject_Call(PyObject *callable_object, PyObject *args, PyObject *kw);
  PyObject *PyObject_CallObject(PyObject *callable_object, PyObject *args);
  PyObject *PyObject_CallFunction(PyObject *callable_object, char *format, ...);
  PyObject *PyObject_CallMethod(PyObject *o, char *m, char *format, ...);
  PyObject *PyObject_CallFunctionObjArgs(PyObject *callable, ...);
  PyObject *PyObject_CallMethodObjArgs(PyObject *o,PyObject *m, ...);

  /////////////////////////////////////////////////////////////////////////////
  // GENERIC
  /////////////////////////////////////////////////////////////////////////////
  PyObject *PyObject_Type(PyObject *o);

  /////////////////////////////////////////////////////////////////////////////
  // CONTAINERS
  /////////////////////////////////////////////////////////////////////////////

  int PyObject_Size(PyObject *o);
  int PyObject_Length(PyObject *o);

  PyObject *PyObject_GetItem(PyObject *o, PyObject *key);
  int PyObject_SetItem(PyObject *o, PyObject *key, PyObject *v);
  int PyObject_DelItemString(PyObject *o, char *key);
  int PyObject_DelItem(PyObject *o, PyObject *key);

  int PyObject_AsCharBuffer(PyObject *obj, char **buffer, int *buffer_len);
  int PyObject_CheckReadBuffer(PyObject *obj);
  int PyObject_AsReadBuffer(PyObject *obj, void **buffer, int *buffer_len);
  int PyObject_AsWriteBuffer(PyObject *obj, void **buffer, int *buffer_len);

  /////////////////////////////////////////////////////////////////////////////
  // ITERATORS
  /////////////////////////////////////////////////////////////////////////////
  PyObject *PyObject_GetIter(PyObject *);

  // D translation of C macro:
  int PyIter_Check(PyObject *obj) {
    return PyType_HasFeature(obj.ob_type, Py_TPFLAGS_HAVE_ITER)
        && obj.ob_type.tp_iternext != null;
  }

  PyObject *PyIter_Next(PyObject *);

  /////////////////////////////////////////////////////////////////////////////
  // NUMBERS
  /////////////////////////////////////////////////////////////////////////////

  int PyNumber_Check(PyObject *o);

  PyObject *PyNumber_Add(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Subtract(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Multiply(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Divide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_FloorDivide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_TrueDivide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Remainder(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Divmod(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Power(PyObject *o1, PyObject *o2, PyObject *o3);
  PyObject *PyNumber_Negative(PyObject *o);
  PyObject *PyNumber_Positive(PyObject *o);
  PyObject *PyNumber_Absolute(PyObject *o);
  PyObject *PyNumber_Invert(PyObject *o);
  PyObject *PyNumber_Lshift(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Rshift(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_And(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Xor(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_Or(PyObject *o1, PyObject *o2);

  PyObject *PyNumber_Int(PyObject *o);
  PyObject *PyNumber_Long(PyObject *o);
  PyObject *PyNumber_Float(PyObject *o);

  PyObject *PyNumber_InPlaceAdd(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceSubtract(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceMultiply(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceDivide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceFloorDivide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceTrueDivide(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceRemainder(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlacePower(PyObject *o1, PyObject *o2, PyObject *o3);
  PyObject *PyNumber_InPlaceLshift(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceRshift(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceAnd(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceXor(PyObject *o1, PyObject *o2);
  PyObject *PyNumber_InPlaceOr(PyObject *o1, PyObject *o2);

  /////////////////////////////////////////////////////////////////////////////
  // SEQUENCES
  /////////////////////////////////////////////////////////////////////////////

  int PySequence_Check(PyObject *o);
  int PySequence_Size(PyObject *o);
  int PySequence_Length(PyObject *o);

  PyObject *PySequence_Concat(PyObject *o1, PyObject *o2);
  PyObject *PySequence_Repeat(PyObject *o, int count);
  PyObject *PySequence_GetItem(PyObject *o, int i);
  PyObject *PySequence_GetSlice(PyObject *o, int i1, int i2);

  int PySequence_SetItem(PyObject *o, int i, PyObject *v);
  int PySequence_DelItem(PyObject *o, int i);
  int PySequence_SetSlice(PyObject *o, int i1, int i2, PyObject *v);
  int PySequence_DelSlice(PyObject *o, int i1, int i2);

  PyObject *PySequence_Tuple(PyObject *o);
  PyObject *PySequence_List(PyObject *o);

  PyObject *PySequence_Fast(PyObject *o,  char* m);
  // D translations of C macros:
  int PySequence_Fast_GET_SIZE(PyObject *o) {
    return PyList_Check(o) ? PyList_GET_SIZE(o) : PyTuple_GET_SIZE(o);
  }
  PyObject *PySequence_Fast_GET_ITEM(PyObject *o, int i) {
    return PyList_Check(o) ? PyList_GET_ITEM(o, i) : PyTuple_GET_ITEM(o, i);
  }
  PyObject *PySequence_ITEM(PyObject *o, int i) {
    return o.ob_type.tp_as_sequence.sq_item(o, i);
  }
  PyObject **PySequence_Fast_ITEMS(PyObject *sf) {
    return
        PyList_Check(sf) ?
            (cast(PyListObject *)sf).ob_item
          : (cast(PyTupleObject *)sf).ob_item
      ;
  }

  int PySequence_Count(PyObject *o, PyObject *value);
  int PySequence_Contains(PyObject *seq, PyObject *ob);

  int PY_ITERSEARCH_COUNT    = 1;
  int PY_ITERSEARCH_INDEX    = 2;
  int PY_ITERSEARCH_CONTAINS = 3;

  int _PySequence_IterSearch(PyObject *seq, PyObject *obj, int operation);
  int PySequence_In(PyObject *o, PyObject *value);
  int PySequence_Index(PyObject *o, PyObject *value);

  PyObject * PySequence_InPlaceConcat(PyObject *o1, PyObject *o2);
  PyObject * PySequence_InPlaceRepeat(PyObject *o, int count);

  /////////////////////////////////////////////////////////////////////////////
  // MAPPINGS
  /////////////////////////////////////////////////////////////////////////////
  int PyMapping_Check(PyObject *o);
  int PyMapping_Size(PyObject *o);
  int PyMapping_Length(PyObject *o);
  //alias PyMapping_Size PyMapping_Length;

  // D translations of C macros:
  int PyMapping_DelItemString(PyObject *o, char *k) {
    return PyObject_DelItemString(o, k);
  }
  int PyMapping_DelItem(PyObject *o, PyObject *k) {
    return PyObject_DelItem(o, k);
  }

  int PyMapping_HasKeyString(PyObject *o, char *key);
  int PyMapping_HasKey(PyObject *o, PyObject *key);

  // D translations of C macros:
  PyObject *PyMapping_Keys(PyObject *o) {
    return PyObject_CallMethod(o, "keys", null);
  }
  PyObject *PyMapping_Values(PyObject *o) {
    return PyObject_CallMethod(o, "values", null);
  }
  PyObject *PyMapping_Items(PyObject *o) {
    return PyObject_CallMethod(o, "items", null);
  }

  PyObject *PyMapping_GetItemString(PyObject *o, char *key);
  int PyMapping_SetItemString(PyObject *o, char *key, PyObject *value);

  /////////////////////////////////////////////////////////////////////////////
  // GENERIC
  /////////////////////////////////////////////////////////////////////////////
  int PyObject_IsInstance(PyObject *object, PyObject *typeorclass);
  int PyObject_IsSubclass(PyObject *object, PyObject *typeorclass);


///////////////////////////////////////////////////////////////////////////////
// OBJECT CREATION AND GARBAGE COLLECTION
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/objimpl.h:

  void * PyObject_Malloc(size_t);
  void * PyObject_Realloc(void *, size_t);
  void PyObject_Free(void *);

  PyObject * PyObject_Init(PyObject *, PyTypeObject *);
  PyVarObject * PyObject_InitVar(PyVarObject *,
                           PyTypeObject *, int);
  /* Without macros, DSR knows of no way to translate PyObject_New and
   * PyObject_NewVar to D; the lower-level _PyObject_New and _PyObject_NewVar
   * will have to suffice.
   * YYY: Perhaps D's mixins could be used? */
  PyObject * _PyObject_New(PyTypeObject *);
  PyVarObject * _PyObject_NewVar(PyTypeObject *, int);


  C_long PyGC_Collect();

  // D translations of C macros:
  int PyType_IS_GC(PyTypeObject *t) {
    return PyType_HasFeature(t, Py_TPFLAGS_HAVE_GC);
  }
  int PyObject_IS_GC(PyObject *o) {
    return PyType_IS_GC(o.ob_type)
        && (o.ob_type.tp_is_gc == null || o.ob_type.tp_is_gc(o));
  }
  PyVarObject *_PyObject_GC_Resize(PyVarObject *, int);
  // XXX: Can D mixins allows trans of PyObject_GC_Resize?

  union PyGC_Head {
    struct gc {
      PyGC_Head *gc_next;
      PyGC_Head *gc_prev;
      int gc_refs;
    }
    real dummy; // XXX: C type was long double; is this equiv?
  }

  // Numerous macro definitions that appear in objimpl.h at this point are not
  // document.  They appear to be for internal use, so they're omitted here.

  PyObject *_PyObject_GC_Malloc(size_t);
  PyObject *_PyObject_GC_New(PyTypeObject *);
  PyVarObject *_PyObject_GC_NewVar(PyTypeObject *, int);
  void PyObject_GC_Track(void *);
  void PyObject_GC_UnTrack(void *);
  void PyObject_GC_Del(void *);

  // XXX: DSR currently knows of no way to translate the PyObject_GC_New and
  // PyObject_GC_NewVar macros to D.

  /////////////////////////////////////////////////////////////////////////////
  // MISCELANEOUS
  /////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/pydebug.h:
  void Py_FatalError(char *message);


///////////////////////////////////////////////////////////////////////////////
// cStringIO (Must be explicitly imported with PycString_IMPORT().)
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/cStringIO.h:

PycStringIO_CAPI *PycStringIO = null;

PycStringIO_CAPI *PycString_IMPORT() {
  if (PycStringIO == null) {
    PycStringIO = cast(PycStringIO_CAPI *)
      PyCObject_Import("cStringIO", "cStringIO_CAPI");
  }
  return PycStringIO;
}

struct PycStringIO_CAPI {
  int(*cread)(PyObject *, char **, int);
  int(*creadline)(PyObject *, char **);
  int(*cwrite)(PyObject *, char *, int);
  PyObject *(*cgetvalue)(PyObject *);
  PyObject *(*NewOutput)(int);
  PyObject *(*NewInput)(PyObject *);
  PyTypeObject *InputType;
  PyTypeObject *OutputType;
}

// D translations of C macros:
int PycStringIO_InputCheck(PyObject *o) {
  return o.ob_type == PycStringIO.InputType;
}
int PycStringIO_OutputCheck(PyObject *o) {
  return o.ob_type == PycStringIO.OutputType;
}


///////////////////////////////////////////////////////////////////////////////
// datetime (Must be explicitly imported with PycString_IMPORT().)
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/datetime.h:

const int _PyDateTime_DATE_DATASIZE = 4;
const int _PyDateTime_TIME_DATASIZE = 6;
const int _PyDateTime_DATETIME_DATASIZE = 10;

struct PyDateTime_Delta {
  mixin PyObject_HEAD;

  C_long hashcode;
  int days;
  int seconds;
  int microseconds;
}

struct PyDateTime_TZInfo {
  mixin PyObject_HEAD;
}

template _PyTZINFO_HEAD() {
  mixin PyObject_HEAD;
  C_long hashcode;
  ubyte hastzinfo;
}

struct _PyDateTime_BaseTZInfo {
  mixin _PyTZINFO_HEAD;
}

template _PyDateTime_TIMEHEAD() {
  mixin _PyTZINFO_HEAD;
  ubyte data[_PyDateTime_TIME_DATASIZE];
}

struct _PyDateTime_BaseTime {
  mixin _PyDateTime_TIMEHEAD;
}

struct PyDateTime_Time {
  mixin _PyDateTime_TIMEHEAD;
  PyObject *tzinfo;
}

struct PyDateTime_Date {
  mixin _PyTZINFO_HEAD;
  ubyte data[_PyDateTime_DATE_DATASIZE];
}

template _PyDateTime_DATETIMEHEAD() {
  mixin _PyTZINFO_HEAD;
  ubyte data[_PyDateTime_DATETIME_DATASIZE];
}

struct _PyDateTime_BaseDateTime {
  mixin _PyDateTime_DATETIMEHEAD;
}

struct PyDateTime_DateTime {
  mixin _PyDateTime_DATETIMEHEAD;
  PyObject *tzinfo;
}

// D translations of C macros:
int PyDateTime_GET_YEAR(PyObject *o) {
  PyDateTime_Date *ot = cast(PyDateTime_Date *) o;
  return (ot.data[0] << 8) | ot.data[1];
}
int PyDateTime_GET_MONTH(PyObject *o) {
  PyDateTime_Date *ot = cast(PyDateTime_Date *) o;
  return ot.data[2];
}
int PyDateTime_GET_DAY(PyObject *o) {
  PyDateTime_Date *ot = cast(PyDateTime_Date *) o;
  return ot.data[3];
}

int PyDateTime_DATE_GET_HOUR(PyObject *o) {
  PyDateTime_DateTime *ot = cast(PyDateTime_DateTime *) o;
  return ot.data[4];
}
int PyDateTime_DATE_GET_MINUTE(PyObject *o) {
  PyDateTime_DateTime *ot = cast(PyDateTime_DateTime *) o;
  return ot.data[5];
}
int PyDateTime_DATE_GET_SECOND(PyObject *o) {
  PyDateTime_DateTime *ot = cast(PyDateTime_DateTime *) o;
  return ot.data[6];
}
int PyDateTime_DATE_GET_MICROSECOND(PyObject *o) {
  PyDateTime_DateTime *ot = cast(PyDateTime_DateTime *) o;
  return (ot.data[7] << 16) | (ot.data[8] << 8) | ot.data[9];
}

int PyDateTime_TIME_GET_HOUR(PyObject *o) {
  PyDateTime_Time *ot = cast(PyDateTime_Time *) o;
  return ot.data[0];
}
int PyDateTime_TIME_GET_MINUTE(PyObject *o) {
  PyDateTime_Time *ot = cast(PyDateTime_Time *) o;
  return ot.data[1];
}
int PyDateTime_TIME_GET_SECOND(PyObject *o) {
  PyDateTime_Time *ot = cast(PyDateTime_Time *) o;
  return ot.data[2];
}
int PyDateTime_TIME_GET_MICROSECOND(PyObject *o) {
  PyDateTime_Time *ot = cast(PyDateTime_Time *) o;
  return (ot.data[3] << 16) | (ot.data[4] << 8) | ot.data[5];
}

struct PyDateTime_CAPI {
  PyTypeObject *DateType;
  PyTypeObject *DateTimeType;
  PyTypeObject *TimeType;
  PyTypeObject *DeltaType;
  PyTypeObject *TZInfoType;

  PyObject *(*Date_FromDate)(int, int, int, PyTypeObject*);
  PyObject *(*DateTime_FromDateAndTime)(int, int, int, int, int, int, int,
          PyObject*, PyTypeObject*);
  PyObject *(*Time_FromTime)(int, int, int, int, PyObject*, PyTypeObject*);
  PyObject *(*Delta_FromDelta)(int, int, int, int, PyTypeObject*);

  PyObject *(*DateTime_FromTimestamp)(PyObject*, PyObject*, PyObject*);
  PyObject *(*Date_FromTimestamp)(PyObject*, PyObject*);
}

const int DATETIME_API_MAGIC = 0x414548d5;
PyDateTime_CAPI *PyDateTimeAPI;

PyDateTime_CAPI *PyDateTime_IMPORT() {
  if (PyDateTimeAPI == null) {
    PyDateTimeAPI = cast(PyDateTime_CAPI *)
      PyCObject_Import("datetime", "datetime_CAPI");
  }
  return PyDateTimeAPI;
}

// D translations of C macros:
int PyDate_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyDateTimeAPI.DateType);
}
int PyDate_CheckExact(PyObject *op) {
  return op.ob_type == PyDateTimeAPI.DateType;
}
int PyDateTime_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyDateTimeAPI.DateTimeType);
}
int PyDateTime_CheckExact(PyObject *op) {
  return op.ob_type == PyDateTimeAPI.DateTimeType;
}
int PyTime_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyDateTimeAPI.TimeType);
}
int PyTime_CheckExact(PyObject *op) {
  return op.ob_type == PyDateTimeAPI.TimeType;
}
int PyDelta_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyDateTimeAPI.DeltaType);
}
int PyDelta_CheckExact(PyObject *op) {
  return op.ob_type == PyDateTimeAPI.DeltaType;
}
int PyTZInfo_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyDateTimeAPI.TZInfoType);
}
int PyTZInfo_CheckExact(PyObject *op) {
  return op.ob_type == PyDateTimeAPI.TZInfoType;
}

PyObject *PyDate_FromDate(int year, int month, int day) {
  return PyDateTimeAPI.Date_FromDate(year, month, day, PyDateTimeAPI.DateType);
}
PyObject *PyDateTime_FromDateAndTime(int year, int month, int day, int hour, int min, int sec, int usec) {
  return PyDateTimeAPI.DateTime_FromDateAndTime(year, month, day, hour,
    min, sec, usec, Py_None, PyDateTimeAPI.DateTimeType);
}
PyObject *PyTime_FromTime(int hour, int minute, int second, int usecond) {
  return PyDateTimeAPI.Time_FromTime(hour, minute, second, usecond,
    Py_None, PyDateTimeAPI.TimeType);
}
PyObject *PyDelta_FromDSU(int days, int seconds, int useconds) {
  return PyDateTimeAPI.Delta_FromDelta(days, seconds, useconds, 1,
    PyDateTimeAPI.DeltaType);
}
PyObject *PyDateTime_FromTimestamp(PyObject *args) {
  return PyDateTimeAPI.DateTime_FromTimestamp(
    cast(PyObject*) (PyDateTimeAPI.DateTimeType), args, null);
}
PyObject *PyDate_FromTimestamp(PyObject *args) {
  return PyDateTimeAPI.Date_FromTimestamp(
    cast(PyObject*) (PyDateTimeAPI.DateType), args);
}


///////////////////////////////////////////////////////////////////////////////
// Interface to execute compiled code
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/eval.h:
PyObject *PyEval_EvalCode(PyCodeObject *, PyObject *, PyObject *);
PyObject *PyEval_EvalCodeEx(
    PyCodeObject *co,
    PyObject *globals,
    PyObject *locals,
    PyObject **args, int argc,
    PyObject **kwds, int kwdc,
    PyObject **defs, int defc,
    PyObject *closure
  );
PyObject *_PyEval_CallTracing(PyObject *func, PyObject *args);


///////////////////////////////////////////////////////////////////////////////
// Generator object interface
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/genobject.h:
struct PyGenObject {
  mixin PyObject_HEAD;
  PyFrameObject *gi_frame;
  int gi_running;
  PyObject *gi_weakreflist;
}

// &PyGen_Type is accessible via PyGen_Type_p.
// D translations of C macros:
int PyGen_Check(PyObject *op) {
  return PyObject_TypeCheck(op, PyGen_Type_p);
}
int PyGen_CheckExact(PyObject *op) {
  return op.ob_type == PyGen_Type_p;
}

PyObject *PyGen_New(PyFrameObject *);


///////////////////////////////////////////////////////////////////////////////
// Interface for marshal.c
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/marshal.h:

const int Py_MARSHAL_VERSION = 1;

void PyMarshal_WriteLongToFile(C_long, FILE *, int);
void PyMarshal_WriteObjectToFile(PyObject *, FILE *, int);
PyObject * PyMarshal_WriteObjectToString(PyObject *, int);

C_long PyMarshal_ReadLongFromFile(FILE *);
int PyMarshal_ReadShortFromFile(FILE *);
PyObject *PyMarshal_ReadObjectFromFile(FILE *);
PyObject *PyMarshal_ReadLastObjectFromFile(FILE *);
PyObject *PyMarshal_ReadObjectFromString(char *, int);


///////////////////////////////////////////////////////////////////////////////
// Platform-independent wrappers around strod, etc (probably not needed in D)
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/pystrtod.h:

double PyOS_ascii_strtod(char *str, char **ptr);
double PyOS_ascii_atof(char *str);
char *PyOS_ascii_formatd(char *buffer, int buf_len, char *format, double d);


///////////////////////////////////////////////////////////////////////////////
// INTERFACE TO THE STDLIB 'THREAD' MODULE
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/pythread.h:

alias void * PyThread_type_lock;
alias void * PyThread_type_sema;

void PyThread_init_thread();
C_long PyThread_start_new_thread(void (*)(void *), void *);
void PyThread_exit_thread();
void PyThread__PyThread_exit_thread();
C_long PyThread_get_thread_ident();

PyThread_type_lock PyThread_allocate_lock();
void PyThread_free_lock(PyThread_type_lock);
int PyThread_acquire_lock(PyThread_type_lock, int);
const int WAIT_LOCK = 1;
const int NOWAIT_LOCK = 0;
void PyThread_release_lock(PyThread_type_lock);

void PyThread_exit_prog(int);
void PyThread__PyThread_exit_prog(int);

int PyThread_create_key();
void PyThread_delete_key(int);
int PyThread_set_key_value(int, void *);
void *PyThread_get_key_value(int);
void PyThread_delete_key_value(int key);


///////////////////////////////////////////////////////////////////////////////
// SET INTERFACE (built-in types set and frozenset)
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/setobject.h:

struct PySetObject {
  mixin PyObject_HEAD;

  PyObject *data;
  C_long hash;
  PyObject *weakreflist;
}

// &PySet_Type is accessible via PySet_Type_p.
// &PyFrozenSet_Type is accessible via PyFrozenSet_Type_p.
// D translations of C macros:
int PyFrozenSet_CheckExact(PyObject *ob) {
  return ob.ob_type == PyFrozenSet_Type_p;
}
int PyAnySet_Check(PyObject *ob) {
  return (
         ob.ob_type == PySet_Type_p
      || ob.ob_type == PyFrozenSet_Type_p
      || PyType_IsSubtype(ob.ob_type, PySet_Type_p)
      || PyType_IsSubtype(ob.ob_type, PyFrozenSet_Type_p)
    );
}


///////////////////////////////////////////////////////////////////////////////
// Interface to map C struct members to Python object attributes
///////////////////////////////////////////////////////////////////////////////
// Python-header-file: Include/structmember.h:

struct PyMemberDef {
  char *name;
  int type;
  int offset;
  int flags;
  char *doc;
}

const int T_SHORT = 0;
const int T_INT = 1;
const int T_LONG = 2;
const int T_FLOAT = 3;
const int T_DOUBLE = 4;
const int T_STRING = 5;
const int T_OBJECT = 6;
const int T_CHAR = 7;
const int T_BYTE = 8;
const int T_UBYTE = 9;
const int T_USHORT = 10;
const int T_UINT = 11;
const int T_ULONG = 12;
const int T_STRING_INPLACE = 13;
const int T_OBJECT_EX = 16;

const int READONLY = 1;
alias READONLY RO;
const int READ_RESTRICTED = 2;
const int WRITE_RESTRICTED = 4;
const int RESTRICTED = (READ_RESTRICTED | WRITE_RESTRICTED);

PyObject *PyMember_GetOne(char *, PyMemberDef *);
int PyMember_SetOne(char *, PyMemberDef *, PyObject *);


///////////////////////////////////////////////////////////////////////////////
// INTERFACE FOR TUPLE-LIKE "STRUCTURED SEQUENCES"
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/structseq.h:

struct PyStructSequence_Field {
  char *name;
  char *doc;
}

struct PyStructSequence_Desc {
  char *name;
  char *doc;
  PyStructSequence_Field *fields;
  int n_in_sequence;
}

// XXX: What about global var PyStructSequence_UnnamedField?

void PyStructSequence_InitType(PyTypeObject *type, PyStructSequence_Desc *desc);
PyObject *PyStructSequence_New(PyTypeObject* type);

struct PyStructSequence {
  mixin PyObject_VAR_HEAD;
  // DSR:XXX:LAYOUT:
  // Will the D layout for a 1-obj array be the same as the C layout?  I
  // think the D array will be larger.
  PyObject *ob_item[1];
}

// D translation of C macro:
PyObject *PyStructSequence_SET_ITEM(PyObject *op, int i, PyObject *v) {
  PyStructSequence *ot = cast(PyStructSequence *) op;
  ot.ob_item[i] = v;
  return v;
}


///////////////////////////////////////////////////////////////////////////////
// UTILITY FUNCTION RELATED TO TIMEMODULE.C
///////////////////////////////////////////////////////////////////////////////
  // Python-header-file: Include/timefuncs.h:

  time_t _PyTime_DoubleToTimet(double x);



} /* extern (C) */


/* The following global variables will contain pointers to certain immutable
 * Python objects that Python/C API programmers expect.
 *
 * In order to make these global variables from the Python library available
 * to D, I tried the extern workaround documented at:
 *   http://www.digitalmars.com/d/archives/digitalmars/D/15427.html
 * but it didn't work (Python crashed when attempting to manipulate the
 * pointers).
 * Besides, in some cases, canonical use of the Python/C API *requires* macros.
 * I ultimately resorted to traversing the Python module structure and loading
 * pointers to the required objects manually (see
 * python_support.d/_loadPythonSupport). */

/* Singletons: */
PyObject* m_Py_None;
PyObject* m_Py_NotImplemented;
PyObject* m_Py_Ellipsis;
PyObject* m_Py_True;
PyObject* m_Py_False;

/* Types: */
PyTypeObject* m_PyType_Type_p;
PyTypeObject* m_PyBaseObject_Type_p;
PyTypeObject* m_PySuper_Type_p;

PyTypeObject* m_PyNone_Type_p;

PyTypeObject* m_PyUnicode_Type_p;
PyTypeObject* m_PyInt_Type_p;
PyTypeObject* m_PyBool_Type_p;
PyTypeObject* m_PyLong_Type_p;
PyTypeObject* m_PyFloat_Type_p;
PyTypeObject* m_PyComplex_Type_p;
PyTypeObject* m_PyRange_Type_p;
PyTypeObject* m_PyBaseString_Type_p;
PyTypeObject* m_PyString_Type_p;
PyTypeObject* m_PyBuffer_Type_p;
PyTypeObject* m_PyTuple_Type_p;
PyTypeObject* m_PyList_Type_p;
PyTypeObject* m_PyDict_Type_p;
PyTypeObject* m_PyEnum_Type_p;
PyTypeObject* m_PyReversed_Type_p;
PyTypeObject* m_PyCFunction_Type_p;
PyTypeObject* m_PyModule_Type_p;
PyTypeObject* m_PyFunction_Type_p;
PyTypeObject* m_PyClassMethod_Type_p;
PyTypeObject* m_PyStaticMethod_Type_p;
PyTypeObject* m_PyClass_Type_p;
PyTypeObject* m_PyInstance_Type_p;
PyTypeObject* m_PyMethod_Type_p;
PyTypeObject* m_PyFile_Type_p;
PyTypeObject* m_PyCode_Type_p;
PyTypeObject* m_PyFrame_Type_p;
PyTypeObject* m_PyGen_Type_p;
PyTypeObject* m_PySet_Type_p;
PyTypeObject* m_PyFrozenSet_Type_p;

/* YYY: Python's default encoding can actually be changed during program
 * with sys.setdefaultencoding, so perhaps it would be better not to expose
 * this at all: */
char* m_Py_FileSystemDefaultEncoding;

PyTypeObject* m_PyCObject_Type_p;
PyTypeObject* m_PyTraceBack_Type_p;
PyTypeObject* m_PySlice_Type_p;
PyTypeObject* m_PyCell_Type_p;
PyTypeObject* m_PySeqIter_Type_p;
PyTypeObject* m_PyCallIter_Type_p;
/* PyWrapperDescr_Type_p omitted. */
PyTypeObject* m_PyProperty_Type_p;

PyTypeObject* m__PyWeakref_RefType_p;
PyTypeObject* m__PyWeakref_ProxyType_p;
PyTypeObject* m__PyWeakref_CallableProxyType_p;

/* Exceptions: */
PyObject* m_PyExc_Exception;
PyObject* m_PyExc_StopIteration;
PyObject* m_PyExc_StandardError;
PyObject* m_PyExc_ArithmeticError;
PyObject* m_PyExc_LookupError;

PyObject* m_PyExc_AssertionError;
PyObject* m_PyExc_AttributeError;
PyObject* m_PyExc_EOFError;
PyObject* m_PyExc_FloatingPointError;
PyObject* m_PyExc_EnvironmentError;
PyObject* m_PyExc_IOError;
PyObject* m_PyExc_OSError;
PyObject* m_PyExc_ImportError;
PyObject* m_PyExc_IndexError;
PyObject* m_PyExc_KeyError;
PyObject* m_PyExc_KeyboardInterrupt;
PyObject* m_PyExc_MemoryError;
PyObject* m_PyExc_NameError;
PyObject* m_PyExc_OverflowError;
PyObject* m_PyExc_RuntimeError;
PyObject* m_PyExc_NotImplementedError;
PyObject* m_PyExc_SyntaxError;
PyObject* m_PyExc_IndentationError;
PyObject* m_PyExc_TabError;
PyObject* m_PyExc_ReferenceError;
PyObject* m_PyExc_SystemError;
PyObject* m_PyExc_SystemExit;
PyObject* m_PyExc_TypeError;
PyObject* m_PyExc_UnboundLocalError;
PyObject* m_PyExc_UnicodeError;
PyObject* m_PyExc_UnicodeEncodeError;
PyObject* m_PyExc_UnicodeDecodeError;
PyObject* m_PyExc_UnicodeTranslateError;
PyObject* m_PyExc_ValueError;
PyObject* m_PyExc_ZeroDivisionError;
version (Windows) {
  PyObject* m_PyExc_WindowsError;
}
/* PyExc_MemoryErrorInst omitted. */

PyObject* m_PyExc_Warning;
PyObject* m_PyExc_UserWarning;
PyObject* m_PyExc_DeprecationWarning;
PyObject* m_PyExc_PendingDeprecationWarning;
PyObject* m_PyExc_SyntaxWarning;
/* PyExc_OverflowWarning omitted, because it'll go away in Python 2.5. */
PyObject* m_PyExc_RuntimeWarning;
PyObject* m_PyExc_FutureWarning;

private {

PyObject *eval(char[] code) {
    PyObject *pyGlobals = PyEval_GetGlobals(); /* borrowed ref */
    PyObject *res = PyRun_String(code ~ \0, Py_eval_input,
        pyGlobals, pyGlobals
    ); /* New ref, or NULL on error. */
    if (res == null) {
        throw new Exception("XXX: write error message; make PythonException D class");
    }
    return res;
}

PyObject* m_builtins, m_types, m_weakref;

// These template functions will lazily-load the various singleton objects,
// removing the need for a "load" function that does it all at once.
typeof(Ptr) lazy_sys(alias Ptr, char[] name) () {
    if (Ptr is null) {
        PyObject* sys_modules = PyImport_GetModuleDict();
        Ptr = PyDict_GetItemString(sys_modules, name ~ \0);
    }
    assert (Ptr !is null, "python.d couldn't load " ~ name ~ " attribute!");
    return Ptr;
}

alias lazy_sys!(m_builtins, "__builtin__") builtins;
alias lazy_sys!(m_types, "types") types;
alias lazy_sys!(m_weakref, "weakref") weakref;

typeof(Ptr) lazy_load(alias from, alias Ptr, char[] name) () {
    if (Ptr is null) {
        Ptr = cast(typeof(Ptr)) PyObject_GetAttrString(from(), name ~ \0);
    }
    assert (Ptr !is null, "python.d couldn't load " ~ name ~ " attribute!");
    return Ptr;
}

typeof(Ptr) lazy_eval(alias Ptr, char[] code) () {
    if (Ptr is null) {
        Ptr = cast(typeof(Ptr)) eval(code);
    }
    assert (Ptr !is null, "python.d couldn't lazily eval something...");
    return Ptr;
}

} /* end private */

//void _loadPythonSupport() {
//static this() {
//printf("[_loadPythonSupport started (Py_None is null: %d)]\n", Py_None is null);

/+
  PyObject *sys_modules = PyImport_GetModuleDict();

  PyObject *builtins = PyDict_GetItemString(sys_modules, "__builtin__");
  assert (builtins != null);
  PyObject *types = PyDict_GetItemString(sys_modules, "types");
  assert (types != null);

  PyObject *weakref = PyImport_ImportModule("weakref");
  assert (weakref != null);
+/

  /* Since Python never unloads an extension module once it has been loaded,
   * we make no attempt to release these references. */

  /* Singletons: */
alias lazy_load!(builtins, m_Py_None, "None") Py_None;
alias lazy_load!(builtins, m_Py_NotImplemented, "NotImplemented") Py_NotImplemented;
alias lazy_load!(builtins, m_Py_Ellipsis, "Ellipsis") Py_Ellipsis;
alias lazy_load!(builtins, m_Py_True, "True") Py_True;
alias lazy_load!(builtins, m_Py_False, "False") Py_False;

  /* Types: */
alias lazy_load!(builtins, m_PyType_Type_p, "type") PyType_Type_p;
alias lazy_load!(builtins, m_PyBaseObject_Type_p, "object") PyBaseObject_Type_p;
alias lazy_load!(builtins, m_PySuper_Type_p, "super") PySuper_Type_p;

alias lazy_load!(types, m_PyNone_Type_p, "NoneType") PyNone_Type_p;

alias lazy_load!(builtins, m_PyUnicode_Type_p, "unicode") PyUnicode_Type_p;
alias lazy_load!(builtins, m_PyInt_Type_p, "int") PyInt_Type_p;
alias lazy_load!(builtins, m_PyBool_Type_p, "bool") PyBool_Type_p;
alias lazy_load!(builtins, m_PyLong_Type_p, "long") PyLong_Type_p;
alias lazy_load!(builtins, m_PyFloat_Type_p, "float") PyFloat_Type_p;
alias lazy_load!(builtins, m_PyComplex_Type_p, "complex") PyComplex_Type_p;
alias lazy_load!(builtins, m_PyRange_Type_p, "xrange") PyRange_Type_p;
alias lazy_load!(builtins, m_PyBaseString_Type_p, "basestring") PyBaseString_Type_p;
alias lazy_load!(builtins, m_PyString_Type_p, "str") PyString_Type_p;
alias lazy_load!(builtins, m_PyBuffer_Type_p, "buffer") PyBuffer_Type_p;
alias lazy_load!(builtins, m_PyTuple_Type_p, "tuple") PyTuple_Type_p;
alias lazy_load!(builtins, m_PyList_Type_p, "list") PyList_Type_p;
alias lazy_load!(builtins, m_PyDict_Type_p, "dict") PyDict_Type_p;
alias lazy_load!(builtins, m_PyEnum_Type_p, "enumerate") PyEnum_Type_p;
alias lazy_load!(builtins, m_PyReversed_Type_p, "reversed") PyReversed_Type_p;

alias lazy_load!(types, m_PyCFunction_Type_p, "BuiltinFunctionType") PyCFunction_Type_p;
alias lazy_load!(types, m_PyModule_Type_p, "ModuleType") PyModule_Type_p;
alias lazy_load!(types, m_PyFunction_Type_p, "FunctionType") PyFunction_Type_p;

alias lazy_load!(builtins, m_PyClassMethod_Type_p, "classmethod") PyClassMethod_Type_p;
alias lazy_load!(builtins, m_PyStaticMethod_Type_p, "staticmethod") PyStaticMethod_Type_p;

alias lazy_load!(types, m_PyClass_Type_p, "ClassType") PyClass_Type_p;
alias lazy_load!(types, m_PyInstance_Type_p, "InstanceType") PyInstance_Type_p;
alias lazy_load!(types, m_PyMethod_Type_p, "MethodType") PyMethod_Type_p;

alias lazy_load!(builtins, m_PyFile_Type_p, "file") PyFile_Type_p;

char* Py_FileSystemDefaultEncoding() {
    if (m_Py_FileSystemDefaultEncoding is null) {
        m_Py_FileSystemDefaultEncoding = PyUnicode_GetDefaultEncoding();
        assert (m_Py_FileSystemDefaultEncoding !is null,
            "python.d couldn't load PyUnicode_DefaultEncoding attribute!");
    }
    return m_Py_FileSystemDefaultEncoding;
}

  /* Python's "CObject" type is intended to serve as an opaque handle for
   * passing a C void pointer from C code to Python code and back. */
PyTypeObject* PyCObject_Type_p() {
    if (m_PyCObject_Type_p is null) {
        PyObject *aCObject = PyCObject_FromVoidPtr(null, null);
        m_PyCObject_Type_p = cast(PyTypeObject *) PyObject_Type(aCObject);
        Py_DECREF(aCObject);
    }
    return m_PyCObject_Type_p;
}

alias lazy_load!(types, m_PyTraceBack_Type_p, "TracebackType") PyTraceBack_Type_p;
alias lazy_load!(types, m_PySlice_Type_p, "SliceType") PySlice_Type_p;

PyTypeObject* PyCell_Type_p() {
    if (m_PyCell_Type_p is null) {
        PyObject *cell = PyCell_New(null);
        assert (cell != null);
        m_PyCell_Type_p = cast(PyTypeObject *) PyObject_Type(cell);
        assert (PyCell_Type_p != null);
        Py_DECREF(cell);
    }
    return m_PyCell_Type_p;
}

alias lazy_eval!(m_PySeqIter_Type_p, "type(iter(''))") PySeqIter_Type_p;
alias lazy_eval!(m_PyCallIter_Type_p, "type(iter(lambda: None, None))") PyCallIter_Type_p;

  /* PyWrapperDescr_Type_p omitted. */
alias lazy_load!(builtins, m_PyProperty_Type_p, "property") PyProperty_Type_p;

alias lazy_load!(weakref, m__PyWeakref_RefType_p, "ReferenceType") _PyWeakref_RefType_p;
alias lazy_load!(weakref, m__PyWeakref_ProxyType_p, "ProxyType") _PyWeakref_ProxyType_p;
alias lazy_load!(weakref, m__PyWeakref_CallableProxyType_p, "CallableProxyType") _PyWeakref_CallableProxyType_p;

alias lazy_load!(types, m_PyCode_Type_p, "CodeType") PyCode_Type_p;
alias lazy_load!(types, m_PyFrame_Type_p, "FrameType") PyFrame_Type_p;
alias lazy_load!(types, m_PyGen_Type_p, "GeneratorType") PyGen_Type_p;

alias lazy_load!(builtins, m_PySet_Type_p, "set") PySet_Type_p;
alias lazy_load!(builtins, m_PyFrozenSet_Type_p, "frozenset") PyFrozenSet_Type_p;

  /* Exceptions: */
alias lazy_load!(builtins, m_PyExc_ArithmeticError, "ArithmeticError") PyExc_ArithmeticError;
alias lazy_load!(builtins, m_PyExc_AssertionError, "AssertionError") PyExc_AssertionError;
alias lazy_load!(builtins, m_PyExc_AttributeError, "AttributeError") PyExc_AttributeError;
alias lazy_load!(builtins, m_PyExc_DeprecationWarning, "DeprecationWarning") PyExc_DeprecationWarning;
alias lazy_load!(builtins, m_PyExc_EOFError, "EOFError") PyExc_EOFError;
alias lazy_load!(builtins, m_PyExc_EnvironmentError, "EnvironmentError") PyExc_EnvironmentError;
alias lazy_load!(builtins, m_PyExc_Exception, "Exception") PyExc_Exception;
alias lazy_load!(builtins, m_PyExc_FloatingPointError, "FloatingPointError") PyExc_FloatingPointError;
alias lazy_load!(builtins, m_PyExc_FutureWarning, "FutureWarning") PyExc_FutureWarning;
alias lazy_load!(builtins, m_PyExc_IOError, "IOError") PyExc_IOError;
alias lazy_load!(builtins, m_PyExc_ImportError, "ImportError") PyExc_ImportError;
alias lazy_load!(builtins, m_PyExc_IndentationError, "IndentationError") PyExc_IndentationError;
alias lazy_load!(builtins, m_PyExc_IndexError, "IndexError") PyExc_IndexError;
alias lazy_load!(builtins, m_PyExc_KeyError, "KeyError") PyExc_KeyError;
alias lazy_load!(builtins, m_PyExc_KeyboardInterrupt, "KeyboardInterrupt") PyExc_KeyboardInterrupt;
alias lazy_load!(builtins, m_PyExc_LookupError, "LookupError") PyExc_LookupError;
alias lazy_load!(builtins, m_PyExc_MemoryError, "MemoryError") PyExc_MemoryError;
  /* PyExc_MemoryErrorInst omitted. */
alias lazy_load!(builtins, m_PyExc_NameError, "NameError") PyExc_NameError;
alias lazy_load!(builtins, m_PyExc_NotImplementedError, "NotImplementedError") PyExc_NotImplementedError;
alias lazy_load!(builtins, m_PyExc_OSError, "OSError") PyExc_OSError;
alias lazy_load!(builtins, m_PyExc_OverflowError, "OverflowError") PyExc_OverflowError;
alias lazy_load!(builtins, m_PyExc_PendingDeprecationWarning, "PendingDeprecationWarning") PyExc_PendingDeprecationWarning;
alias lazy_load!(builtins, m_PyExc_ReferenceError, "ReferenceError") PyExc_ReferenceError;
alias lazy_load!(builtins, m_PyExc_RuntimeError, "RuntimeError") PyExc_RuntimeError;
alias lazy_load!(builtins, m_PyExc_RuntimeWarning, "RuntimeWarning") PyExc_RuntimeWarning;
alias lazy_load!(builtins, m_PyExc_StandardError, "StandardError") PyExc_StandardError;
alias lazy_load!(builtins, m_PyExc_StopIteration, "StopIteration") PyExc_StopIteration;
alias lazy_load!(builtins, m_PyExc_SyntaxError, "SyntaxError") PyExc_SyntaxError;
alias lazy_load!(builtins, m_PyExc_SyntaxWarning, "SyntaxWarning") PyExc_SyntaxWarning;
alias lazy_load!(builtins, m_PyExc_SystemError, "SystemError") PyExc_SystemError;
alias lazy_load!(builtins, m_PyExc_SystemExit, "SystemExit") PyExc_SystemExit;
alias lazy_load!(builtins, m_PyExc_TabError, "TabError") PyExc_TabError;
alias lazy_load!(builtins, m_PyExc_TypeError, "TypeError") PyExc_TypeError;
alias lazy_load!(builtins, m_PyExc_UnboundLocalError, "UnboundLocalError") PyExc_UnboundLocalError;
alias lazy_load!(builtins, m_PyExc_UnicodeDecodeError, "UnicodeDecodeError") PyExc_UnicodeDecodeError;
alias lazy_load!(builtins, m_PyExc_UnicodeEncodeError, "UnicodeEncodeError") PyExc_UnicodeEncodeError;
alias lazy_load!(builtins, m_PyExc_UnicodeError, "UnicodeError") PyExc_UnicodeError;
alias lazy_load!(builtins, m_PyExc_UnicodeTranslateError, "UnicodeTranslateError") PyExc_UnicodeTranslateError;
alias lazy_load!(builtins, m_PyExc_UserWarning, "UserWarning") PyExc_UserWarning;
alias lazy_load!(builtins, m_PyExc_ValueError, "ValueError") PyExc_ValueError;
alias lazy_load!(builtins, m_PyExc_Warning, "Warning") PyExc_Warning;

version (Windows) {
    alias lazy_load!(builtins, m_PyExc_WindowsError, "WindowsError") PyExc_WindowsError;
}

alias lazy_load!(builtins, m_PyExc_ZeroDivisionError, "ZeroDivisionError") PyExc_ZeroDivisionError;

