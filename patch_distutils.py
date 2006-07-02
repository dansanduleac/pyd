# The distutils.ccompiler module doesn't allow the runtime addition of compiler
# classes that live outside the distutils package, and of course it doesn't
# recognize the D language and its associated compilers by default.
#
# This module hot-patches distutils.ccompiler to overcome those limitations.
#
# To apply these changes, the setup.py file for extension modules written in D
# should execute the following import statement:
#   from celerid import patch_distutils

from distutils import ccompiler as cc
from distutils.command import build

from celerid import dcompiler

cc.CCompiler.language_map['.d'] = 'd'
cc.CCompiler.language_order.insert(0, 'd')

cc.compiler_class['dmd'] = ('celerid.dcompiler', 'DMDDCompiler', 'Digital Mars D')

_old_new_compiler = cc.new_compiler

def new_compiler(compiler=None, dry_run=0, force=0, **kwargs):
    if compiler is not None:
        compiler = compiler.lower()

    if compiler not in (None, 'dmd'):
        return _old_new_compiler(compiler=compiler,
            dry_run=dry_run, force=force, **kwargs
          )
    else:
        return dcompiler.DMDDCompiler(None, dry_run, force)

cc.new_compiler = new_compiler


# A user's setup.py wouldn't have imported this module unless it intended to
# compile D code, so override the default compiler setting to point to DMD.
# This allows a user to compile a D extension with the command line
#   python setup.py build
# instead of needing
#   python setup.py build --compiler=dmd
def get_default_compiler(*args, **kwargs):
    return 'dmd'

cc.get_default_compiler = get_default_compiler

# Force the distutils build command to recognize the '--optimize' or '-O'
# command-line option.
build.build.user_options.append(
    ('optimize', 'O',
      'Ask the D compiler to optimize the generated code, at the expense of'
      ' safety features such as array bounds checks.'),
  )
build.build.boolean_options.append('optimize')

_old_initialize_options = build.build.initialize_options
def _new_initialize_options(self):
    _old_initialize_options(self)
    self.optimize = 0
build.build.initialize_options = _new_initialize_options
