# DSR:2005.10.27.23.51

# XXX:
# These two will have to wait until DMD can create shared libraries on Linux,
# because DSR doesn't have (the non-free version of) MSVC 2003, which is
# necessary to create a debug build or a UCS4 build of Python 2.4 on Windows:
# - Handle distutils debug builds responsibly (make sure both -debug and -g are
#   passed through to DMD, even if optimizations are requested).  Also make
#   sure that extensions built with this module work under debug builds of
#   Python.
# - Try out a UCS4 build of Python to make sure that works.

import os, os.path, sys

from distutils import ccompiler as cc
from distutils.ccompiler import gen_lib_options
from distutils.errors import (
    DistutilsExecError, DistutilsFileError, DistutilsPlatformError,
    CompileError, LibError, LinkError, UnknownFileError
)


_isPlatWin = sys.platform.lower().startswith('win')

_infraDir = os.path.join(os.path.dirname(__file__), 'infrastructure')

_pydFiles = [
    'class_wrap.d',
    'ctor_wrap.d',
    'def.d',
    'dg_convert.d',
    'exception.d',
    'func_wrap.d',
    'iteration.d',
    'make_object.d',
    'op_wrap.d',
    'pyd.d',
    'pydobject.d',
    'struct_wrap.d',
]

_stFiles = [
    'coroutine.d',
    'stackcontext.d',
    'stackthread.d',
    'tls.d',
]

_metaFiles = [
    'Default.d',
    'Demangle.d',
    'Nameof.d',
    'Util.d',
]

_pyVerXDotY = '.'.join(str(v) for v in sys.version_info[:2]) # e.g., '2.4'
_pyVerXY = _pyVerXDotY.replace('.', '') # e.g., '24'


class DCompiler(cc.CCompiler):

    src_extensions = ['.d']
    obj_extension = (_isPlatWin and '.obj') or '.o'
    static_lib_extension = (_isPlatWin and '.lib') or '.a'
    shared_lib_extension = (_isPlatWin and '.pyd') or '.so'
    static_lib_format = (_isPlatWin and '%s%s') or 'lib%s%s'
    shared_lib_format = '%s%s'
    exe_extension = (_isPlatWin and '.exe') or ''

    def __init__(self, *args, **kwargs):
        cc.CCompiler.__init__(self, *args, **kwargs)
        # Get DMD/GDC specific info
        self._initialize()
        # _binpath
        try:
            dBin = os.environ[self._env_var]
            if not os.path.isfile(dBin):
                self.warn("Environment variable %s provided, but file '%s' does not exist." % (self._env_var, dBin))
                raise KeyError
        except KeyError:
            if _isPlatWin:
                # The environment variable wasn't supplied, so search the PATH.
                # Windows requires the full path for reasons that escape me at
                # the moment.
                dBin = _findInPath(self.compiler_type + self.exe_extension)
                if dBin is None:
                    raise DistutilsFileError('You must either set the %s'
                        ' environment variable to the full path of the %s'
                        ' executable, or place the executable on the PATH.' %
                        (self._env_var, self.compiler_type)
                    )
            else:
                # Just run it via the PATH directly in Linux
                dBin = self.compiler_type
        self._binpath = dBin
        # _unicodeOpt
        self._unicodeOpt = self._versionOpt % ('Python_Unicode_UCS' + ((sys.maxunicode == 0xFFFF and '2') or '4'))

    def _initialize(self):
        # It is intended that this method be implemented by subclasses.
        raise NotImplementedError, "Cannot initialize DCompiler, use DMDDCompiler or GDCDCompiler instead."

    def _def_file(self, output_dir, output_filename):
        """A list of options used to tell the linker how to make a dll/so. In
        DMD, it is the .def file. In GDC, it is
        ['-shared', '-Wl,-soname,blah.so'] or similar."""
        raise NotImplementedError, "Cannot initialize DCompiler, use DMDDCompiler or GDCDCompiler instead."

    def _lib_file(self, libraries):
        return ''

    def find_library_file(self, dirs, lib, debug=0):
        shared_f = self.library_filename(lib, lib_type='shared')
        static_f = self.library_filename(lib, lib_type='static')

        for dir in dirs:
            shared = os.path.join(dir, shared_f)
            static = os.path.join(dir, static_f)

            if os.path.exists(shared):
                return shared
            elif os.path.exists(static):
                return static

        return None

    def compile(self, sources,
        output_dir=None, macros=None, include_dirs=None, debug=0,
        extra_preargs=None, extra_postargs=None, depends=None
    ):
        macros = macros or []
        include_dirs = include_dirs or []
        extra_preargs = extra_preargs or []
        extra_postargs = extra_postargs or []

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        binpath = _qp(self._binpath)
        compileOpts = self._compileOpts
        outputOpts = self._outputOpts

        includePathOpts = []
        
        # To sources, add the appropriate D header file python.d, as well as
        # any platform-specific boilerplate.
        pythonHeaderPath = os.path.join(_infraDir, 'python', _pyVerXDotY, 'python.d')
        # Add the python header's directory to the include path
        includePathOpts += self._includeOpts
        includePathOpts[-1] = includePathOpts[-1] % os.path.join(_infraDir, 'python', _pyVerXDotY)
        if not os.path.isfile(pythonHeaderPath):
            raise DistutilsPlatformError('Required D translation of Python'
                ' header files "%s" is missing.' % pythonHeaderPath
            )
        sources.append(pythonHeaderPath)

        # flags = (no_pyd, no_st, no_meta)
        flags = [f for f, category in macros if category == 'aux'][0]
        # And Pyd!
        if not flags[0]:
            # If we're not using StackThreads, don't use iteration.d in Pyd
            if flags[1]:
                _pydFiles.remove('iteration.d');
            for file in _pydFiles:
                filePath = os.path.join(_infraDir, 'pyd', file)
                if not os.path.isfile(filePath):
                    raise DistutilsPlatformError("Required Pyd source file '%s' is"
                        " missing." % filePath
                    )
                sources.append(filePath)
        # And StackThreads
        if not flags[1]:
            for file in _stFiles:
                filePath = os.path.join(_infraDir, 'st', file)
                if not os.path.isfile(filePath):
                    raise DistutilsPlatformError("Required StackThreads source"
                        " file '%s' is missing." % filePath
                    )
                sources.append(filePath)
            # Add the version conditional for st
            macros.append(('Pyd_with_StackThreads', 'version'))
        # And meta
        if not flags[2]:
            for file in _metaFiles:
                filePath = os.path.join(_infraDir, 'meta', file)
                if not os.path.isfile(filePath):
                    raise DistutilsPlatformError("Required meta source file"
                        " '%s' is missing." % filePath
                    )
                sources.append(filePath)
        # Add the infraDir to the include path for pyd, st, and meta.
        if False in flags:
            includePathOpts += self._includeOpts
            includePathOpts[-1] = includePathOpts[-1] % os.path.join(_infraDir)
        
        # Add DLL/SO boilerplate code file.
        if _isPlatWin:
            boilerplatePath = os.path.join(_infraDir, 'd',
                'python_dll_windows_boilerplate.d'
            )
        else:
            boilerplatePath = os.path.join(_infraDir, 'd',
                'python_so_linux_boilerplate.d'
            )
        if not os.path.isfile(boilerplatePath):
            raise DistutilsFileError('Required supporting code file "%s"'
                ' is missing.' % boilerplatePath
            )
        sources.append(boilerplatePath)

        # Extension subclass DExtension will have packed any user-supplied
        # version and debug flags into macros; we extract them and convert them
        # into the appropriate command-line args.
        versionFlags = [name for (name, category) in macros if category == 'version']
        debugFlags = [name for (name, category) in macros if category == 'debug']
        userVersionAndDebugOpts = (
              [self._versionOpt % v for v in versionFlags] +
              [self._debugOpt   % v for v in debugFlags]
        )

        # Python version option allows extension writer to take advantage of
        # Python/C API features available only in recent version of Python with
        # a version statement like:
        #   version(Python_2_4_Or_Later) {
        #     Py_ConvenientCallOnlyAvailableInPython24AndLater();
        #   } else {
        #     // Do it the hard way...
        #   }
        pythonVersionOpt = self._versionOpt % ('Python_%d_%d_Or_Later' % sys.version_info[:2])

        # Optimization opts
        args = [a.lower() for a in sys.argv[1:]]
        optimize = ('-o' in args or '--optimize' in args)
        if debug:
            optimizationOpts = self._debugOptimizeOpts
        elif optimize:
            optimizationOpts = self._releaseOptimizeOpts
        else:
            optimizationOpts = self._defaultOptimizeOpts

        print 'sources: ', [os.path.basename(s) for s in sources]
        # Compiling one-by-one exhibits a strange bug in the D front-end, while
        # compiling all at once works. This flags allows me to test each form
        # easily. Supporting the one-by-one form is synonymous with GDC support.
        ONE_BY_ONE = True
        if ONE_BY_ONE:
            for source in sources:
                outOpts = outputOpts[:]
                objName = self.object_filenames([os.path.split(source)[1]], 0, output_dir)[0]
                outOpts[-1] = outOpts[-1] % _qp(objName)
                cmdElements = (
                    [binpath] + extra_preargs + compileOpts +
                    [pythonVersionOpt, self._unicodeOpt] + optimizationOpts +
                    includePathOpts + outOpts + userVersionAndDebugOpts +
                    [_qp(source)] + extra_postargs
                )
                cmdElements = [el for el in cmdElements if el]
                try:
                    self.spawn(cmdElements)
                except DistutilsExecError, msg:
                    raise CompileError(msg)
        else:
            # gdc/gcc doesn't support the idea of an output directory, so we
            # compile from the destination
            sources = [_qp(os.path.abspath(s)) for s in sources]
            cwd = os.getcwd()
            os.chdir(output_dir)
            cmdElements = (
                [binpath] + extra_preargs + compileOpts +
                [pythonVersionOpt, self._unicodeOpt] + optimizationOpts +
                includePathOpts + userVersionAndDebugOpts +
                sources + extra_postargs
            )
            cmdElements = [el for el in cmdElements if el]
    
            try:
                self.spawn(cmdElements)
            except DistutilsExecError, msg:
                #os.chdir(cwd)
                raise CompileError(msg)
            os.chdir(cwd)

        return [os.path.join(output_dir, fn) for fn in os.listdir(output_dir) if fn.endswith(self.obj_extension)]

    def link (self,
        target_desc, objects, output_filename,
        output_dir=None,
        libraries=None, library_dirs=None, runtime_library_dirs=None,
        export_symbols=None, debug=0,
        extra_preargs=None, extra_postargs=None,
        build_temp=None, target_lang=None
    ):
        # Distutils defaults to None for "unspecified option list"; we want
        # empty lists in that case (this substitution is done here in the body
        # rather than by changing the default parameters in case distutils
        # passes None explicitly).
        libraries = libraries or []
        library_dirs = library_dirs or []
        runtime_library_dirs = runtime_library_dirs or []
        export_symbols = export_symbols or []
        extra_preargs = extra_preargs or []
        extra_postargs = extra_postargs or []

        binpath = self._binpath
        outputOpts = self._outputOpts[:]
        objectOpts = [_qp(fn) for fn in objects]

        (objects, output_dir) = self._fix_object_args (objects, output_dir)
        (libraries, library_dirs, runtime_library_dirs) = \
            self._fix_lib_args (libraries, library_dirs, runtime_library_dirs)
        if runtime_library_dirs:
            self.warn('This CCompiler implementation does nothing with'
                ' "runtime_library_dirs": ' + str(runtime_library_dirs)
            )

        if output_dir and os.path.basename(output_filename) == output_filename:
            output_filename = os.path.join(output_dir, output_filename)
        else:
            if not output_filename:
                raise DistutilsFileError, 'Neither output_dir nor' \
                    ' output_filename was specified.'
            output_dir = os.path.dirname(output_filename)
            if not output_dir:
                raise DistutilsFileError, 'Unable to guess output_dir on the'\
                    ' bases of output_filename "%s" alone.' % output_filename

        # Format the output filename option
        # (-offilename in DMD, -o filename in GDC)
        outputOpts[-1] = outputOpts[-1] % _qp(output_filename)

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        if not self._need_link(objects, output_filename):
            print "All binary output files are up to date."
            return

        # The .def file (on Windows) or -shared and -soname (on Linux)
        sharedOpts = self._def_file(build_temp, output_filename)

        # The python .lib file, if needed
        pythonLibOpt = self._lib_file(libraries)
        if pythonLibOpt:
            pythonLibOpt = _qp(pythonLibOpt)

        if target_desc != cc.CCompiler.SHARED_OBJECT:
            raise LinkError('This CCompiler implementation does not know'
                ' how to link anything except an extension module (that is, a'
                ' shared object file).'
            )

        # Library linkage options
        print "library_dirs:", library_dirs
        print "runtime_library_dirs:", runtime_library_dirs
        print "libraries:", libraries
        libOpts = gen_lib_options(self, library_dirs, runtime_library_dirs, libraries)

        # Optimization opts
        args = [a.lower() for a in sys.argv[1:]]
        optimize = ('-o' in args or '--optimize' in args)
        if debug:
            optimizationOpts = self._debugOptimizeOpts
        elif optimize:
            optimizationOpts = self._releaseOptimizeOpts
        else:
            optimizationOpts = self._defaultOptimizeOpts

        cmdElements = (
            [binpath] + extra_preargs + self._linkOpts + optimizationOpts +
            outputOpts + [pythonLibOpt] + objectOpts + libOpts + sharedOpts +
            extra_postargs
        )
        cmdElements = [el for el in cmdElements if el]

        try:
            self.spawn(cmdElements)
        except DistutilsExecError, msg:
            raise CompileError(msg)

class DMDDCompiler(DCompiler):
    compiler_type = 'dmd'

    executables = {
        'preprocessor' : None,
        'compiler'     : ['dmd'],
        'compiler_so'  : ['dmd'],
        'linker_so'    : ['dmd'],
        'linker_exe'   : ['dmd'],
    }

    _env_var = 'DMD_BIN'

    def _initialize(self):
        # _compileOpts
        self._compileOpts = ['-c']
        # _outputOpts
        self._outputOpts = ['-of%s']
        # _linkOpts
        self._linkOpts = []
        # _includeOpts
        self._includeOpts = ['-I%s']
        # _versionOpt
        self._versionOpt = '-version=%s'
        # _debugOpt
        self._debugOpt = '-debug=%s'
        # _defaultOptimizeOpts
        self._defaultOptimizeOpts = ['-debug']
        # _debugOptimizeOpts
        self._debugOptimizeOpts = self._defaultOptimizeOpts + ['-unittest', '-g']
        # _releaseOptimizeOpts
        self._releaseOptimizeOpts = ['-version=Optimized', '-release', '-O', '-inline']

    #def link_opts(self, 

    def _def_file(self, output_dir, output_filename):
        if _isPlatWin:
            # Automatically create a .def file:
            defTemplatePath = os.path.join(_infraDir, 'd',
                'python_dll_def.def_template'
            )
            if not os.path.isfile(defTemplatePath):
                raise DistutilsFileError('Required def template file "%s" is'
                    ' missing.' % defTemplatePath
                )
            f = file(defTemplatePath, 'rb')
            try:
                defTemplate = f.read()
            finally:
                f.close()

            defFileContents = defTemplate % os.path.basename(output_filename)
            defFilePath = os.path.join(output_dir, 'python_dll_def.def')
            f = file(defFilePath, 'wb')
            try:
                f.write(defFileContents)
            finally:
                f.close()

            return [defFilePath]
        else:
            return []

    def _lib_file(self, libraries):
        if _isPlatWin:
            # The DMD-compatible .lib file can be generated with implib.exe
            # (from the Digital Mars "Basic Utilities" package) using a command
            # series similar to the following:
            #   cd C:\Windows\system32
            #   \path\to\dm\bin\implib.exe /system python24_digitalmars.lib python24.dll
            #
            # I chose not to incorporate automatic .lib generation into this
            # code because Python X.Y releases are fairly infrequent, so it's
            # more convenient to distribute a pre-extracted .lib file to the
            # users and spare them the need for the "Basic Utilities" package.
            pythonDMDLibPath = _qp(os.path.join(_infraDir, 'python', _pyVerXDotY,
                'python%s_digitalmars.lib' % _pyVerXY
            ))
            if not os.path.isfile(pythonDMDLibPath):
                raise DistutilsFileError('The DMD-compatible Python .lib file'
                    ' which should be located at "%s" is missing.  Try'
                    ' downloading a more recent version of celeriD that'
                    ' contains a .lib file appropriate for your Python version.'
                    % pythonDMDLibPath
                )
            pythonLibOpt = _qp(pythonDMDLibPath)

            # distutils will normally request that the library 'pythonXY' be
            # linked against.  Since D requires a different .lib file from the
            # one used by the C compiler that built Python, and we've just
            # dealt with that requirement, we take the liberty of removing the
            # distutils-requested pythonXY.lib.
            if 'python' + _pyVerXY in libraries:
                libraries.remove('python' + _pyVerXY)
            return pythonLibOpt
        else:
            return ''

    def library_dir_option(self, dir):
        self.warn("Don't know how to set library search path for DMD.")
        #raise DistutilsPlatformError, "Don't know how to set library search path for DMD."

    def runtime_library_dir_option(self, dir):
        self.warn("Don't know how to set runtime library search path for DMD.")
        #raise DistutilsPlayformError, "Don't know how to set runtime library search path for DMD."

    def library_option(self, lib):
        if _isPlatWin:
            return self.library_filename(lib)
        else:
            return '-L-l' + lib

class GDCDCompiler(DCompiler):
    compiler_type = 'gdc'

    executables = {
        'preprocessor' : None,
        'compiler'     : ['gdc'],
        'compiler_so'  : ['gdc'],
        'linker_so'    : ['gdc'],
        'linker_exe'   : ['gdc'],
    }

    _env_var = 'GDC_BIN'

    def _initialize(self):
        # _compileOpts
        self._compileOpts = ['-fPIC', '-c']
        # _outputOpts
        self._outputOpts = ['-o', '%s']
        # _linkOpts
        self._linkOpts = ['-fPIC', '-nostartfiles', '-shared']
        # _includeOpts
        self._includeOpts = ['-I', '%s']
        # _versionOpt
        self._versionOpt = '-fversion=%s'
        # _debugOpt
        self._debugOpt = '-fdebug=%s'
        # _defaultOptimizeOpts
        self._defaultOptimizeOpts = ['-fdebug']
        # _debugOptimizeOpts
        self._debugOptimizeOpts = self._defaultOptimizeOpts + ['-g', '-funittest']
        # _releaseOptimizeOpts
        self._releaseOptimizeOpts = ['-fversion=Optimized', '-frelease', '-O3', '-finline-functions']

    def _def_file(self, output_dir, output_filename):
        return ['-Wl,-soname,' + os.path.basename(output_filename)]

    def library_dir_option(self, dir):
        return '-L' + dir

    def runtime_library_dir_option(self, dir):
        return '-Wl,-R' + dir

    def library_option(self, lib):
        return '-l' + lib

# Utility functions:
def _findInPath(fileName, startIn=None):
    # Find a file named fileName in the PATH, starting in startIn.
    try:
        path = os.environ['PATH']
    except KeyError:
        pass
    else:
        pathDirs = path.split(os.pathsep)
        if startIn:
            if startIn in pathDirs:
                pathDirs.remove(startIn)
            pathDirs.insert(0, startIn)

        for pd in pathDirs:
            tentativePath = os.path.join(pd, fileName)
            if os.path.isfile(tentativePath):
                return tentativePath

    return None


def _qp(path): # If path contains any whitespace, quote it.
    if len(path.split()) == 1:
        return path
    else:
        return '"%s"' % path
