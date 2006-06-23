Pyd is intended to be built with David Rushby's Celerid project:

Link to project:
    http://kinterbasdb.sourceforge.net/other/d/celerid-2006_03_19.zip

Posting about project:
    http://www.digitalmars.com/drn-bin/wwwnews?digitalmars.D/38425

It should be noted that David Rushby has stated this project is unfinished and
not really ready for release. However, it is still the easiest way to compile a
D extension for Python.

Celerid is an extension to Python's distutils module to allow building D
extensions with DMD. Unfortunately, DMD does not yet support building dynamic
libraries (.so) on Linux, and thus cannot be used to build Python extensions on
Linux. This is a severe limitation on the utility of using D to write Python
extensions, and it is hoped it will be fixed in not too much longer.

However, one can still *embed* Python in programs on either Windows or Linux.

Celerid also provides a version of a Python/C API header file for D. Pyd,
however, uses a newer version than the one Celerid currently provides. This
header can be found in Pyd's "header" directory; it is easiest to simply replace
Celerid's header, although this may break existing code that uses the old
Celerid header. (The new header does away with the _loadPythonSupport function.
Removing the call to this function in old code should allow it to Just Work with
the new header.)

