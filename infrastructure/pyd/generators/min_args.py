import sys
old_stdout = sys.stdout
sys.stdout = open('min_args.txt', 'w')

arg_template = """ArgType!(fn_t, %s).init"""

template = """\
    else static if (is(typeof(fn(%s))))
        const uint MIN_ARGS = %s;"""

for i in range(1, 11):
    args = []
    for j in range(i):
        args.append(arg_template % (j+1,))
    print template % (", ".join(args), i)
