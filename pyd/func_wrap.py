f = open('func_wrap.txt', 'w')

template = "d_type!(ArgType!(typeof(fn), %s))(PyTuple_GET_ITEM(args, %s))"

for i in range(1, 11):
    f.write(" " * 8 + "} else static if (ARGS == %s) {\n" % i)
    f.write(" " * 12 +    "static if (is(RetType : void)) {\n")
    f.write(" " * 16 +        "fn(\n")
    for j in range(i):
        f.write(" " * 20 + template % (j+1, j))
        if j < i-1:
            f.write(',')
        f.write('\n')
    f.write(" " * 16 +        ");\n")
    f.write(" " * 16 +        "Py_INCREF(Py_None);\n")
    f.write(" " * 16 +        "ret = Py_None;\n")
    f.write(" " * 12 +    "} else {\n")
    f.write(" " * 16 +        "return _py( fn(\n")
    for j in range(i):
        f.write(" " * 20 + template % (j+1, j))
        if j < i-1:
            f.write(',')
        f.write('\n')
    f.write(" " * 16 +        ") );\n")
    f.write(" " * 12 +    "}\n")
f.write (" " * 8 + "}")
