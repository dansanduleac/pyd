Welcome to Pyd!

This package is composed of two separate parts:

* Celerid - An extension to Python's Distutils that is aware of the DMD
            compiler.
* Pyd - A library for D that wraps the Python API.

It is important to note that DMD does not yet support building dynamic
libraries on Linux, and so this package is largely only useful to Windows-
users.

Celerid is primarily written by David Rushby, and Pyd is primarily written by
Kirk McDonald. Pyd uses a number of additional libraries; see credits.txt for
details. These libraries are contained in the "infrastructure" directory.

INSTALLATION

In the easiest case, you just need to say:

    python setup.py install

while in the root directory of the project. This will place both Celerid and
Pyd in Python's site-packages directory.

You may find it helpful to place both DMD and Python on your system's path. A
batch file and a Windows shortcut are helpfully provided, though you will
probably have to edit them to point to the correct path on your system:

* In pydmdvars.bat, simply edit the D_ROOT and PY_ROOT variables.
* In the "Python-DMD Command Line" shortcut's "Properties" window, edit the
"Start in:" field to point to where the batch file is located.

Additionally, Celerid requires D_ROOT to be set to the grandparent of the DMD
compiler executable.

An example of using Celerid/Pyd may be found in the "examples" directory.

