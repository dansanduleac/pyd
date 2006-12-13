import os.path, sys
import distutils.util

# Append the directory in which the binaries were placed to Python's sys.path,
# then import the D DLL.
libDir = os.path.join('build', 'lib.%s-%s' % (
    distutils.util.get_platform(),
    '.'.join(str(v) for v in sys.version_info[:2])
))
sys.path.append(os.path.abspath(libDir))

import inherit

b = inherit.Base()
d = inherit.Derived()

b.foo()
b.bar()
d.foo()
d.bar()

print "issubclass(inherit.Derived, inherit.Base)"
print issubclass(inherit.Derived, inherit.Base)

inherit.call_poly(b)
inherit.call_poly(d)

w = inherit.WrapDerive()
inherit.call_poly(w)

class PyClass(inherit.WrapDerive):
    def foo(self):
        print 'PyClass.foo'

p = PyClass()
#print "The basic inheritance support breaks down here:"
inherit.call_poly(p)
