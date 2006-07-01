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
module pyd.class_wrap;

private import python;
private import pyd.ctor_wrap;
private import pyd.def;
private import pyd.ftype;
private import pyd.make_object;
private import std.string;

// The class object, a subtype of PyObject
template wrapped_class_object(T) {
    extern(C)
    struct wrapped_class_object {
        mixin PyObject_HEAD;
        T d_obj;
    }
}

// The type object, an instance of PyType_Type
template wrapped_class_type(char[] name, T) {
    static PyTypeObject wrapped_class_type = {
        1,
        null,
        0,                            /*ob_size*/
        null,                         /*tp_name*/
        (wrapped_class_object!(T)).sizeof, /*tp_basicsize*/
        0,                            /*tp_itemsize*/
        &wrapped_methods!(T).wrapped_dealloc, /*tp_dealloc*/
        null,                         /*tp_print*/
        null,                         /*tp_getattr*/
        null,                         /*tp_setattr*/
        null,                         /*tp_compare*/
        &wrapped_methods!(T).wrapped_repr, /*tp_repr*/
        null,                         /*tp_as_number*/
        null,                         /*tp_as_sequence*/
        null,                         /*tp_as_mapping*/
        null,                         /*tp_hash */
        null,                         /*tp_call*/
        null,                         /*tp_str*/
        null,                         /*tp_getattro*/
        null,                         /*tp_setattro*/
        null,                         /*tp_as_buffer*/
        Py_TPFLAGS_DEFAULT,           /*tp_flags*/
        name ~ " objects" ~ \0,       /*tp_doc*/
        null,		              /* tp_traverse */
        null,		              /* tp_clear */
        null,		              /* tp_richcompare */
        0,		              /* tp_weaklistoffset */
        null,		              /* tp_iter */
        null,		              /* tp_iternext */
        null,                         /* tp_methods */
        null,                         /* tp_members */
        null,                         /* tp_getset */
        null,                         /* tp_base */
        null,                         /* tp_dict */
        null,                         /* tp_descr_get */
        null,                         /* tp_descr_set */
        0,                            /* tp_dictoffset */
        null,                         /* tp_init */
        null,                         /* tp_alloc */
        &wrapped_methods!(T).wrapped_new, /* tp_new */
        null,                         /* tp_free */
        null,                         /* tp_is_gc */
        null,                         /* tp_bases */
        null,                         /* tp_mro */
        null,                         /* tp_cache */
        null,                         /* tp_subclasses */
        null,                         /* tp_weaklist */
        null,                         /* tp_del */
    };
}

// Various wrapped methods
template wrapped_methods(T) {
    alias wrapped_class_object!(T) wrap_object;
    extern(C)
    PyObject* wrapped_new(PyTypeObject* type, PyObject* args, PyObject* kwds) {
        wrap_object* self;

        self = cast(wrap_object*)type.tp_alloc(type, 0);
        if (self !is null) {
            self.d_obj = null;
        }

        return cast(PyObject*)self;
    }

    extern(C)
    void wrapped_dealloc(PyObject* _self) {
        wrap_object* self = cast(wrap_object*)_self;
        wrap_class_instances!(T).remove(self.d_obj);
        self.ob_type.tp_free(self);
    }

    extern(C)
    PyObject* wrapped_repr(PyObject* _self) {
        wrap_object* self = cast(wrap_object*)_self;
        char[] repr = self.d_obj.toString();
        return _py(repr);
    }
}

template wrapped_init(T) {
    alias wrapped_class_object!(T) wrap_object;
    extern(C)
    int init(PyObject* self, PyObject* args, PyObject* kwds) {
        // TODO: Provide better constructor support...
        T t = new T;
        (cast(wrap_object*)self).d_obj = t;
        wrap_class_instances!(T)[t] = null;
        return 0;
    }
}

// The set of all instances of this class that are passed into Python. Keeping
// references here in D is needed to keep the GC happy.
// XXX: This currently fails if the same reference is held by multiple Python
// objects.
template wrap_class_instances(T) {
    void*[T] wrap_class_instances;
}

// A useful check for whether a given class has been wrapped. Mainly used by
// the conversion functions (see make_object.d), but possibly useful elsewhere.
template is_wrapped(T) {
    bool is_wrapped = false;
}

// The list of wrapped methods for this class.
template wrapped_method_list(T) {
    static PyMethodDef[] wrapped_method_list = [
        { null, null, 0, null }
    ];
}

// This struct is returned by wrap_class. Its member functions are the primary
// way of wrapping the specific parts of the class. Note that the struct has no
// members. The only information it carries are its template arguments.
template wrapped_class(char[] classname, T) {
    struct wrapped_class {
        template def(char[] name, alias fn, uint MIN_ARGS = NumberOfArgs!(typeof(&fn))) {
            void def() {
                static PyMethodDef empty = { null, null, 0, null };
                wrapped_method_list!(T)[length-1].ml_name = name ~ \0;
                wrapped_method_list!(T)[length-1].ml_meth =
                    cast(PyCFunction)&func_wrap!(fn, MIN_ARGS, T).func;
                wrapped_method_list!(T)[length-1].ml_flags = METH_VARARGS;
                wrapped_method_list!(T)[length-1].ml_doc = "";
                wrapped_method_list!(T) ~= empty;
                // It's possible that appending the empty item invalidated the
                // pointer in the type struct, so we renew it here.
                wrapped_class_type!(classname, T).tp_methods =
                    wrapped_method_list!(T);
            }
        }

        template init(alias C1=undefined, alias C2=undefined, alias C3=undefined, alias C4=undefined, alias C5=undefined, alias C6=undefined, alias C7=undefined, alias C8=undefined, alias C9=undefined, alias C10=undefined) {
            void init() {
                wrapped_class_type!(classname, T).tp_init =
                    &wrapped_ctors!(T, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10).init;
            }
        }
    }
}

// This template function wraps a D class and exposes it to Python.
wrapped_class!(name, T) wrap_class(char[] name, T) () {
    assert(DPy_Module_p !is null, "Must initialize module before wrapping classes.");
    char[] module_name = .toString(PyModule_GetName(DPy_Module_p));
    wrapped_class_type!(name, T).ob_type = PyType_Type_p;
    wrapped_class_type!(name, T).tp_new = &PyType_GenericNew;
    wrapped_class_type!(name, T).tp_methods = wrapped_method_list!(T);
    wrapped_class_type!(name, T).tp_name =
        module_name ~ "." ~ name ~ \0;
    
    wrapped_class!(name, T) temp;
    return temp;
}

void finalize_class(char[] name, T) () {
    // If a ctor wasn't supplied, try the default.
    if (wrapped_class_type!(name, T).tp_init is null) {
        wrapped_class_type!(name, T).tp_init =
            &wrapped_init!(T).init;
    }
    if (PyType_Ready(&wrapped_class_type!(name, T)) < 0) {
        // XXX: This will probably crash the interpreter, as it isn't normally
        // caught and translated.
        throw new Exception("Couldn't ready wrapped type!");
    }
    Py_INCREF(cast(PyObject*)&wrapped_class_type!(name, T));
    PyModule_AddObject(DPy_Module_p, name, cast(PyObject*)&wrapped_class_type!(name, T));
    is_wrapped!(T) = true;
}
