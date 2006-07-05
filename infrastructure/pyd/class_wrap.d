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
private import pyd.func_wrap;
private import pyd.make_object;
private import pyd.op_wrap;

private import std.string;

template DPyObject_HEAD(T) {
    mixin PyObject_HEAD;
    T d_obj;
}

/// The class object, a subtype of PyObject
template wrapped_class_object(T) {
    extern(C)
    struct wrapped_class_object {
        mixin DPyObject_HEAD!(T);
    }
}

///
template wrapped_class_type(T) {
/// The type object, an instance of PyType_Type
    static PyTypeObject wrapped_class_type = {
        1,
        null,
        0,                            /*ob_size*/
        null,                         /*tp_name*/
        0,                            /*tp_basicsize*/
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
        Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /*tp_flags*/
        null,                         /*tp_doc*/
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

/// Various wrapped methods
template wrapped_methods(T) {
    alias wrapped_class_object!(T) wrap_object;
    /// The generic "__new__" method
    extern(C)
    PyObject* wrapped_new(PyTypeObject* type, PyObject* args, PyObject* kwds) {
        wrap_object* self;

        self = cast(wrap_object*)type.tp_alloc(type, 0);
        if (self !is null) {
            self.d_obj = null;
        }

        return cast(PyObject*)self;
    }

    /// The generic dealloc method.
    extern(C)
    void wrapped_dealloc(PyObject* _self) {
        wrap_object* self = cast(wrap_object*)_self;
        if (self.d_obj !is null) {
            wrap_class_instances!(T)[self.d_obj]--;
            if (wrap_class_instances!(T)[self.d_obj] <= 0) {
                wrap_class_instances!(T).remove(self.d_obj);
            }
        }
        self.ob_type.tp_free(self);
    }
}

template wrapped_repr(T) {
    alias wrapped_class_object!(T) wrap_object;
    /// The default repr method calls the class's toString.
    extern(C)
    PyObject* repr(PyObject* _self) {
        wrap_object* self = cast(wrap_object*)_self;
        char[] repr = self.d_obj.toString();
        return _py(repr);
    }
}

///
template wrapped_init(T) {
    alias wrapped_class_object!(T) wrap_object;
    /// The default _init method calls the class's zero-argument constructor.
    extern(C)
    int init(PyObject* self, PyObject* args, PyObject* kwds) {
        T t = new T;
        (cast(wrap_object*)self).d_obj = t;
        wrap_class_instances!(T)[t] = 1;
        return 0;
    }
}

// This template gets an alias to a property and derives the types of the
// getter form and the setter form. It requires that the getter form return the
// same type that the setter form accepts.
template property_parts(alias p) {
    // This may be either the getter or the setter
    alias typeof(&p) p_t;
    // This means it's the getter
    static if (NumberOfArgs!(p_t) == 0) {
        alias p_t getter_type;
        // The setter may return void, or it may return the newly set attribute.
        alias typeof(p(ReturnType!(p_t).init)) function(ReturnType!(p_t)) setter_type;
    // This means it's the setter
    } else {
        alias p_t setter_type;
        alias ArgType!(p_t, 1) function() getter_type;
    }
}

///
template wrapped_get(T, alias Fn) {
    /// A generic wrapper around a "getter" property.
    extern(C)
    PyObject* func(PyObject* self, void* closure) {
        return func_wrap!(Fn, 0, T, property_parts!(Fn).getter_type).func(self, null);
    }
}

///
template wrapped_set(T, alias Fn) {
    /// A generic wrapper around a "setter" property.
    extern(C)
    int func(PyObject* self, PyObject* value, void* closure) {
        PyObject* temp_tuple = PyTuple_New(1);
        if (temp_tuple is null) return -1;
        Py_INCREF(value);
        PyTuple_SetItem(temp_tuple, 0, value);
        PyObject* res = func_wrap!(Fn, 1, T, property_parts!(Fn).setter_type).func(self, temp_tuple);
        // We'll get something back, and need to DECREF it.
        Py_DECREF(res);
        Py_DECREF(temp_tuple);
        return 0;
    }
}

// The set of all instances of this class that are passed into Python. Keeping
// references here in D is needed to keep the GC happy. The integer value is
// used to make this a sort of poor man's multiset.
template wrap_class_instances(T) {
    int[T] wrap_class_instances;
}

/**
 * A useful check for whether a given class has been wrapped. Mainly used by
 * the conversion functions (see make_object.d), but possibly useful elsewhere.
 */
template is_wrapped(T) {
    bool is_wrapped = false;
}

// The list of wrapped methods for this class.
template wrapped_method_list(T) {
    static PyMethodDef[] wrapped_method_list = [
        { null, null, 0, null }
    ];
}

// The list of wrapped properties for this class.
template wrapped_prop_list(T) {
    static PyGetSetDef[] wrapped_prop_list = [
        { null, null, null, null, null }
    ];
}

/**
 * This struct wraps a D class. Its member functions are the primary way of
 * wrapping the specific parts of the class.
 */
template wrapped_class(char[] classname, T) {
    struct wrapped_class {
        static const char[] _name = classname;
        T t = null;
        /**
         * Wraps a member function of the class.
         *
         * Params:
         * name = The name of the function as it will appear in Python.
         * fn = The member function to wrap.
         * MIN_ARGS = The minimum number of arguments this function can accept.
         * fn_t = The type of the function. It is only useful to specify this
         *        if more than one function has the same name as this one.
         */
        template def(char[] name, alias fn, uint MIN_ARGS = MIN_ARGS!(fn), fn_t=typeof(&fn)) {
            static void def() {
                static PyMethodDef empty = { null, null, 0, null };
                alias wrapped_method_list!(T) list;
                list[length-1].ml_name = name ~ \0;
                list[length-1].ml_meth = &func_wrap!(fn, MIN_ARGS, T, fn_t).func;
                list[length-1].ml_flags = METH_VARARGS;
                list[length-1].ml_doc = "";
                list ~= empty;
                // It's possible that appending the empty item invalidated the
                // pointer in the type struct, so we renew it here.
                wrapped_class_type!(T).tp_methods = list;
            }
        }

        /**
         * Wraps a property of the class.
         *
         * Params:
         * name = The name of the property as it will appear in Python.
         * fn = The property to wrap.
         * RO = Whether this is a read-only property.
         */
        template prop(char[] name, alias fn, bool RO=false) {
            static void prop() {
                static PyGetSetDef empty = { null, null, null, null, null };
                wrapped_prop_list!(T)[length-1].name = name ~ \0;
                wrapped_prop_list!(T)[length-1].get =
                    &wrapped_get!(T, fn).func;
                static if (!RO) {
                    wrapped_prop_list!(T)[length-1].set =
                        &wrapped_set!(T, fn).func;
                }
                wrapped_prop_list!(T)[length-1].doc = "";
                wrapped_prop_list!(T)[length-1].closure = null;
                wrapped_prop_list!(T) ~= empty;
                // It's possible that appending the empty item invalidated the
                // pointer in the type struct, so we renew it here.
                wrapped_class_type!(T).tp_getset =
                    wrapped_prop_list!(T);
            }
        }

        /**
         * Wraps the constructors of the class.
         *
         * This template takes a series of specializations of the ctor template
         * (see ctor_wrap.d), each of which describes a different constructor
         * that the class supports. The default constructor need not be
         * specified, and will always be available if the class supports it.
         *
         * Bugs:
         * This currently does not support having multiple constructors with
         * the same number of arguments.
         */
        template init(alias C1=undefined, alias C2=undefined, alias C3=undefined, alias C4=undefined, alias C5=undefined, alias C6=undefined, alias C7=undefined, alias C8=undefined, alias C9=undefined, alias C10=undefined) {
            static void init() {
                wrapped_class_type!(T).tp_init =
                    &wrapped_ctors!(T, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10).init_func;
            }
        }
    }
}

/**
 * Finalize the wrapping of the class. It is neccessary to call this after all
 * calls to the wrapped_class member functions.
 */
void finalize_class(CLS) (CLS cls) {
    alias typeof(cls.t) T;
    alias wrapped_class_type!(T) type;
    const char[] name = CLS._name;
    
    assert(DPy_Module_p !is null, "Must initialize module before wrapping classes.");
    char[] module_name = .toString(PyModule_GetName(DPy_Module_p));
    
    // Fill in missing values
    type.ob_type      = PyType_Type_p;
    type.tp_basicsize = (wrapped_class_object!(T)).sizeof;
    type.tp_doc       = name ~ " objects" ~ \0;
    //type.tp_new       = &PyType_GenericNew;
    type.tp_repr      = &wrapped_repr!(T).repr;
    type.tp_methods   = wrapped_method_list!(T);
    type.tp_name      = module_name ~ "." ~ name ~ \0;
    if (wrapped_class_as_number!(T) != PyNumberMethods.init) {
        type.tp_as_number = &wrapped_class_as_number!(T);
    }
    
    // If a ctor wasn't supplied, try the default.
    if (type.tp_init is null) {
        type.tp_init = &wrapped_init!(T).init;
    }
    if (PyType_Ready(&type) < 0) {
        // XXX: This will probably crash the interpreter, as it isn't normally
        // caught and translated.
        throw new Exception("Couldn't ready wrapped type!");
    }
    Py_INCREF(cast(PyObject*)&type);
    PyModule_AddObject(DPy_Module_p, name, cast(PyObject*)&type);
    is_wrapped!(T) = true;
}
