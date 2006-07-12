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
module pyd.def;

private import python;

private import pyd.class_wrap;
private import pyd.dg_convert;
private import pyd.exception;
private import pyd.ftype;
private import pyd.func_wrap;
private import pyd.make_object;

private import std.string;

private
PyMethodDef module_global_methods[] = [
    { null, null, 0, null }
];

private
PyObject* m_module;

PyObject* DPy_Module_p() {
    return m_module;
}

/**
 * Wraps a D function, making it callable from Python.
 *
 * Params:
 *      name = The name of the function as it will appear in Python.
 *      fn   = The function to wrap.
 *      MIN_ARGS = The minimum number of arguments this function can accept.
 *                 For use with functions with default arguments. Defaults to
 *                 the maximum number of arguments this function supports.
 *      fn_t = The function type of the function to wrap. This must be
 *             specified if more than one function shares the same name,
 *             otherwise the first one defined lexically will be used.
 *
 * Examples:
 *$(D_CODE import pyd.pyd;
 *char[] foo(int i) {
 *    if (i > 10) {
 *        return "It's greater than 10!";
 *    } else {
 *        return "It's less than 10!";
 *    }
 *}
 *extern (C)
 *export void inittestdll() {
 *    _def!("foo", foo);
 *    module_init("testdll");
 *})
 * And in Python:
 *$(D_CODE >>> import testdll
 *>>> print testdll.foo(20)
 *It's greater than 10!)
 */
template def(alias fn, char[] name, fn_t=typeof(&fn), uint MIN_ARGS = MIN_ARGS!(fn)) {
    pragma(msg, "def: " ~ name);
    void def() {
        PyMethodDef empty;
        alias module_global_methods list;

        list[length-1].ml_name = name ~ \0;
        list[length-1].ml_meth = &func_wrap!(fn, MIN_ARGS, void, fn_t).func;
        list[length-1].ml_flags = METH_VARARGS;
        list[length-1].ml_doc = "";
        list ~= empty;
    }
}

/**
 * Module initialization function. Should be called after the last call to def.
 */
PyObject* module_init(char[] name) {
    //_loadPythonSupport();
    m_module = Py_InitModule(name ~ \0, module_global_methods);
    return m_module;
}

