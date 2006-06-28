import os.path, sys
import distutils.util

# Append the directory in which the binaries were placed to Python's sys.path,
# then import the D DLL.
libDir = os.path.join('build', 'lib.%s-%s' % (
    distutils.util.get_platform(),
    '.'.join(str(v) for v in sys.version_info[:2])
  ))
sys.path.append(os.path.abspath(libDir))
import testdll

print testdll.bar(12)

print

testdll.foo()

print

print "testdll.baz():"
testdll.baz()
print "testdll.baz(20):"
testdll.baz(20)
print "testdll.baz(30, 'cat'):"
testdll.baz(30, 'cat')

print

a = testdll.Foo()
a.foo()

print

print '--------'
print 'SUCCESS'
print '--------'
