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

testdll.foo()

print

print testdll.bar(12)

print

print "testdll.baz():"
testdll.baz()
print "testdll.baz(20):"
testdll.baz(20)
print "testdll.baz(30, 'cat'):"
testdll.baz(30, 'cat')

print

a = testdll.Foo(10)
a.foo()

print "Testing opApply wrapping:"
try:
    for i in a:
        print i
except TypeError, e:
    print "opApply not supported on this platform"

print

S = testdll.S
s = S()
print "s.s = 'hello'"
s.s = 'hello'
print "s.s"
print s.s
print "s.write_s()"
s.write_s()

print

print '--------'
print 'SUCCESS'
print '--------'
