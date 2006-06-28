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
private import pyd.def;
private import std.string;

// This is a big, big template with a bunch of stuff in it.
template wrapped_class_object(T) {
    extern(C)
    struct wrapped_class_object {
        mixin PyObject_HEAD;
        T d_obj;
    }
}

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
        null,                         /*tp_repr*/
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
        &wrapped_methods!(T).wrapped_init, /* tp_init */
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
    int wrapped_init(PyObject* self, PyObject* args, PyObject* kwds) {
        // TODO: Provide better constructor support...
        T t = new T;
        (cast(wrap_object*)self).d_obj = t;
        wrap_class_instances!(T)[t] = null;
        return 0;
    }

    extern(C)
    void wrapped_dealloc(PyObject* _self) {
        wrap_object* self = cast(wrap_object*)_self;
        wrap_class_instances!(T).remove(self.d_obj);
        self.ob_type.tp_free(cast(PyObject*)self);
    }
}

template wrap_class_instances(T) {
    void*[T] wrap_class_instances;
}

void wrap_class(char[] name, T) () {
    assert(DPy_Module_p !is null, "Must initialize module before wrapping classes.");
    char[] module_name = .toString(PyModule_GetName(DPy_Module_p));
    wrapped_class_type!(name, T).ob_type = PyType_Type_p;
    wrapped_class_type!(name, T).tp_new = &PyType_GenericNew;
    wrapped_class_type!(name, T).tp_name =
        module_name ~ "." ~ name ~ \0;
    if (PyType_Ready(&wrapped_class_type!(name, T)) < 0)
        return;
    Py_INCREF(cast(PyObject*)&wrapped_class_type!(name, T));
    PyModule_AddObject(DPy_Module_p, name, cast(PyObject*)&wrapped_class_type!(name, T));
}
