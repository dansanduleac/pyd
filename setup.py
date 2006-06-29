from celerid.support import setup, Extension

projName = 'testdll'
dpy_files = [
    'class_wrap.d',
    'ctor_wrap.d',
    'def.d',
    'dg_convert.d',
    'exception.d',
    'ftype.d',
    'lazy_load.d',
    'make_object.d',
    'pyd.d',
    'object.d',
]

for i in range(len(dpy_files)):
    dpy_files[i] = 'pyd/' + dpy_files[i]

setup(
    name=projName,
    version='0.1',
    ext_modules=[
        Extension(projName, [projName + '.d'] + dpy_files)
    ],
  )
