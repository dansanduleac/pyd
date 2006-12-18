__all__ = ('setup', 'Extension')

from celerid import patch_distutils # Cause distutils to be hot-patched.

from distutils.core import setup, Extension as std_Extension
from distutils.errors import DistutilsOptionError

class Extension(std_Extension):
    def __init__(self, *args, **kwargs):
        if 'define_macros' in kwargs or 'undef_macros' in kwargs:
            raise DistutilsOptionError('D does not support macros, so the'
                ' "define_macros" and "undef_macros" arguments are not'
                ' supported.  Instead, consider using the "Version Condition"'
                ' and "Debug Condition" conditional compilation features'
                ' documented at http://www.digitalmars.com/d/version.html'
                '\n  Version flags can be passed to the compiler via the'
                ' "version_flags" keyword argument to DExtension; debug flags'
                ' via the "debug_flags" keyword argument.  For example, when'
                ' used with the DMD compiler,'
                '\n    DExtension(..., version_flags=["a", "b"])'
                '\nwill cause'
                '\n    -version=a -version=b'
                '\nto be passed to the compiler.'
              )

        # If the user has requested any version_flags or debug_flags, we use
        # the distutils 'define_macros' keyword argument to carry them (they're
        # later unpacked in the dcompiler module).
        define_macros = []
        if 'version_flags' in kwargs or 'debug_flags' in kwargs:
            if 'version_flags' in kwargs:
                for flag in kwargs['version_flags']:
                    define_macros.append((flag, 'version'))
                del kwargs['version_flags']

            if 'debug_flags' in kwargs:
                for flag in kwargs['debug_flags']:
                    define_macros.append((flag, 'debug'))
                del kwargs['debug_flags']

        # Similarly, pass in no_pyd, &c, via define_macros.
        if 'raw_only' in kwargs:
            kwargs['with_pyd'] = False
            kwargs['with_st'] = False
            kwargs['with_meta'] = False
            del kwargs['raw_only']
        with_pyd  = kwargs.pop('with_pyd', True)
        with_st   = kwargs.pop('with_st', True)
        with_meta = kwargs.pop('with_meta', True)
        if with_pyd and not with_meta:
            raise DistutilsOptionError(
                'Cannot specify with_meta=False while using Pyd. Specify'
                ' raw_only=True or with_pyd=False if you want to compile a raw Python/C'
                ' extension.'
            )
        define_macros.append(((with_pyd, with_st, with_meta), 'aux'))
        kwargs['define_macros'] = define_macros

        std_Extension.__init__(self, *args, **kwargs)

