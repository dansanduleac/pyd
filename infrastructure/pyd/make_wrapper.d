/*
Copyright 2006, 2007 Kirk McDonald

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
module pyd.make_wrapper;

import python;

import pyd.class_wrap;
import pyd.dg_convert;
import pyd.exception;
import pyd.func_wrap;
import pyd.lib_abstract :
    ReturnType,
    ParameterTypeTuple,
    ToString
;

template OverloadShim() {
    template __pyd_get_overload(char[] realname, fn_t) {
        ReturnType!(fn_t) func(T ...) (char[] name, T t) {
            PyObject** _pyobj = cast(void*)this in wrapped_gc_objects;
            PyTypeObject** _pytype = this.classinfo in wrapped_classes;
            if (_pyobj is null || _pytype is null || (*_pyobj).ob_type != *_pytype) {
                // If this object's type is not the wrapped class's type (that is,
                // if this object is actually a Python subclass of the wrapped
                // class), then call the Python object.
                PyObject* method = PyObject_GetAttrString(*_pyobj, (name ~ \0).ptr);
                if (method is null) handle_exception();
                auto pydg = PydCallable_AsDelegate!(fn_to_dg!(fn_t))(method);
                Py_DECREF(method);
                return pydg(t);
            } else {
                mixin("return super."~realname~"(t);");
            }
        }
    }
}

template class_decls(uint i, Params...) {
    static if (i < Params.length) {
        const char[] class_decls = Params[i].shim!(i) ~ class_decls!(i+1, Params);
    } else {
        const char[] class_decls = "";
    }
}

template make_wrapper(T, Params...) {
    const char[] cls = 
    "class wrapper : T {\n"~
    "    mixin OverloadShim;\n"~
    class_decls!(0, Params)~"\n"~
    "}\n";
    pragma(msg, cls);
    mixin(cls);
}

