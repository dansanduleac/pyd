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
    'ftype.d',
    'func_wrap.d',
    'make_object.d',
    'object.d',
    'op_wrap.d',
    'pyd.d',
    'tuples.d',
]

_pyVerXDotY = '.'.join(str(v) for v in sys.version_info[:2]) # e.g., '2.4'
_pyVerXY = _pyVerXDotY.replace('.', '') # e.g., '24'


class DCompiler(cc.CCompiler):
    # YYY: This class exists because in the long term, a GDCDCompiler class
    # should be created (selectable with 'python setup.py build -cgdc') and
    # common code should be factored into the common superclass DCompiler.
    pass


class DMDDCompiler(DCompiler):
    compiler_type = 'dmd'

    executables = {
        'preprocessor' : None,
        'compiler'     : ['dmd'],
        'compiler_so'  : ['dmd'],
        'linker_so'    : ['dmd', '-shared'], # XXX?
        'linker_exe'   : ['dmd'],
      }

    src_extensions = ['.d']
    obj_extension = (_isPlatWin and '.obj') or '.o'
    static_lib_extension = (_isPlatWin and '.lib') or '.a'
    shared_lib_extension = (_isPlatWin and '.pyd') or '.so'
    static_lib_format = (_isPlatWin and '%s%s') or 'lib%s%s'
    shared_lib_format = '%s%s'
    exe_extension = (_isPlatWin and '.exe') or ''

    def __init__(self, *args, **kwargs):
        DCompiler.__init__(self, *args, **kwargs)
        self._initialized = False


    def _initialize(self, debug):
        # Would like to determine whether optimization was requested in a more
        # proper manner (by checking the 'optimize' attribute of the Command
        # object under which we're operating), but can't figure out how to get
        # a reference to that Command object without burdening client
        # programmers by forcing them to pass a cmd_class argument to setup().
        args = [a.lower() for a in sys.argv[1:]]
        optimize = ('-o' in args or '--optimize' in args)

        dmdExeFilename = (_isPlatWin and 'dmd.exe') or 'dmd'

        # Require environment variable D_ROOT:
        try:
            dRoot = os.environ['D_ROOT']
        except KeyError:
            if _isPlatWin:
                exampleDMDPath = os.path.join(
                    os.path.dirname(os.path.dirname(sys.executable)),
                    'd', 'dmd', 'bin', dmdExeFilename
                  )
            else:
                exampleDMDPath = '/opt/d/dmd/bin/' + dmdExeFilename

            raise DistutilsFileError('You must set the D_ROOT environment'
                ' variable to the great-grandparent directory of the dmd'
                ' executable.'
                '\n(If the dmd executable were at\n  "%s", D_ROOT should be'
                '\n  "%s".)'
                % (exampleDMDPath,
                   os.path.dirname(os.path.dirname(
                       os.path.dirname(exampleDMDPath)
                     ))
                  )
              )

        # Find the DMD executable:
        dmdExePath = _findInPath(dmdExeFilename,
            startIn=os.path.join(dRoot, 'dmd', 'bin')
          )
        if not dmdExePath:
            dmdExeSubPath = os.path.join('dmd', 'bin',
                'dmd' + ((_isPlatWin and '.exe') or '')
              )
            dmdExePath = os.path.join(dRoot, dmdExeSubPath)
            if not os.path.isfile(dmdExePath):
                dmdExePathRepr = os.path.join(
                    ((_isPlatWin and '%D_ROOT%') or '$D_ROOT'),
                    dmdExeSubPath
                  )
                raise DistutilsFileError('Could not find dmd executable.  It'
                    ' should be located at "%s".' % dmdExePathRepr
                  )

        # Store in instance variables the info we'll need later:
        self._dRoot = dRoot
        self._dmdExePath = dmdExePath
        self._unicodeOpt = ('-version=Python_Unicode_UCS'
            + ((sys.maxunicode == 0xFFFF and '2') or '4')
          )

        # Set optimization-versus-safety options (conservatively by default;
        # as aggressively optimized as possible when the user specifies
        # 'python setup.py build -O').
        conservativeOpts = ['-debug', '-unittest']
        if debug:
            # Conservative checking AND symbolic debugging information:
            self._optimizationOpts = conservativeOpts + ['-g']
        elif optimize:
            self._optimizationOpts = ['-version=Optimized',
                '-release', '-O', '-inline',
              ]
        else:
            # The default is conservative in that it generates validation code,
            # but it does not include symbolic debugging information:
            self._optimizationOpts = conservativeOpts


        self._initialized = True


    def compile(self, sources,
        output_dir=None, macros=None, include_dirs=None, debug=0,
        extra_preargs=None, extra_postargs=None, depends=None
      ):
        if not self._initialized: self._initialize(debug)

        # Distutils defaults to None for "unspecified option list"; we want
        # empty lists in that case (this substitution is done here in the body
        # rather than by changing the default parameters in case distutils
        # passes None explicitly).
        macros = macros or []
        include_dirs = include_dirs or []
        extra_preargs = extra_preargs or []
        extra_postargs = extra_postargs or []

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        dmdExeOpt = _qp(self._dmdExePath)
        compileOnlyOpt = '-c' # In this stage, we don't want to link.

        outputDirOpt = '-od' + _qp(output_dir)

        # To sources, add the appropriate D header file python.d, as well as
        # any platform-specific boilerplate.
        pythonHeaderPath = os.path.join(_infraDir, 'python', 'headers', 'python.d')
        if not os.path.isfile(pythonHeaderPath):
            raise DistutilsPlatformError('Required D translation of Python'
                ' header files "%s" is missing.' % pythonHeaderPath
              )
        sources.append(_qp(pythonHeaderPath))

        # And Pyd!
        # XXX: Add support for compiling without Pyd
        for file in _pydFiles:
            filePath = os.path.join(_infraDir, 'pyd', file)
            if not os.path.isfile(filePath):
                raise DistutilsPlatformError("Required Pyd source file '%s' is"
                    " missing." % filePath
                )
            sources.append(_qp(filePath))
        
        if _isPlatWin:
            pdwbPath = os.path.join(_infraDir, 'd',
                'python_dll_windows_boilerplate.d'
              )
            if not os.path.isfile(pdwbPath):
                raise DistutilsFileError('Required supporting code file "%s"'
                    ' is missing.' % pdwbPath
                  )
            sources.append(_qp(pdwbPath))


        quotedSourceFiles = [_qp(sf) for sf in sources]

        # Extension subclass DExtension will have packed any user-supplied
        # version and debug flags into macros; we extract them and convert them
        # into the appropriate DMD command-line args.
        versionFlags = [name for (name, category) in macros if category == 'version']
        debugFlags = [name for (name, category) in macros if category == 'debug']
        userVersionAndDebugOpts = (
              ['-version=%s' % v for v in versionFlags]
            + ['-debug=%s' % v for v in debugFlags]
          )

        # Python version option allows extension writer to take advantage of
        # Python/C API features available only in recent version of Python with
        # a version statement like:
        #   version(Python_2_4_Or_Later) {
        #     Py_ConvenientCallOnlyAvailableInPython24AndLater();
        #   } else {
        #     // Do it the hard way...
        #   }
        pythonVersionOpt = '-version=Python_%d_%d_Or_Later' % sys.version_info[:2]

        # Generate a complete list of all command-line arguments, excluding any
        # that turned out to be blank:
        cmdElements = ([dmdExeOpt] + extra_preargs
            + [compileOnlyOpt, pythonVersionOpt, self._unicodeOpt]
            + self._optimizationOpts + [outputDirOpt]
            + userVersionAndDebugOpts + quotedSourceFiles + extra_postargs
          )
        cmdElements = [el for el in cmdElements if el]

        # Invoke the compiler:
        try:
            self.spawn(cmdElements)
        except DistutilsExecError, msg:
            raise CompileError(msg)

        # Return a list of paths to the object files generated by the
        # compilation process:
        return [os.path.join(output_dir, fn) for fn in os.listdir(output_dir)]


    def link (self,
        target_desc, objects, output_filename,
        output_dir=None,
        libraries=None, library_dirs=None, runtime_library_dirs=None,
        export_symbols=None, debug=0,
        extra_preargs=None, extra_postargs=None,
        build_temp=None, target_lang=None
      ):
        if not self._initialized: self._initialize(debug)

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

        (objects, output_dir) = self._fix_object_args (objects, output_dir)
        (libraries, library_dirs, runtime_library_dirs) = \
            self._fix_lib_args (libraries, library_dirs, runtime_library_dirs)
        if runtime_library_dirs:
            self.warn('This CCompiler implementation does nothing with'
                ' "runtime_library_dirs": ' + str(runtime_library_dirs)
              )

        # Determine output_dir from output_filename or vice versa, depending
        # on which was supplied:
        if output_dir and os.path.basename(output_filename) == output_filename:
            output_filename = os.path.join(output_dir, output_filename)
        else:
            if not output_filename:
                raise DistutilsFileError('Neither output_dir nor'
                    ' output_filename was specified.'
                  )
            output_dir = os.path.dirname(output_filename)
            if not output_dir:
                raise DistutilsFileError('Unable to guess output_dir on the'
                    ' basis of output_filename "%s" alone.' % output_filename
                  )

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        if not self._need_link(objects, output_filename):
            print ('The distutils infrastructure indicated that all binary'
                ' output files are up to date.'
              )
            return

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
            defFilePath = os.path.join(build_temp, 'python_dll_def.def')
            f = file(defFilePath, 'wb')
            try:
                f.write(defFileContents)
            finally:
                f.close()

            objects.append(defFilePath)

        if target_desc != cc.CCompiler.SHARED_OBJECT:
            raise LinkError('This CCompiler implementation does not know'
                ' how to link anything except an extension module (that is, a'
                ' shared object file).'
              )

        dmdExeOpt = _qp(self._dmdExePath)
        outputDirOpt = '-od' + _qp(output_dir)
        outputObjOpt = '-of' + _qp(output_filename)
        inputObjectOpts = [_qp(oFN) for oFN in objects]

        if not _isPlatWin:
            # DMD uses the GNU linker on non-Windows platforms, so there's no
            # need for us to change the distutils defaults.
            pythonLibOpt = ''
        else:
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
            pythonDMDLibPath = _qp(os.path.join(_infraDir, 'python', 'libs',
                _pyVerXDotY, 'python%s_digitalmars.lib' % _pyVerXY
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

        # Find the paths of any requested library files:
        explicitLibOpts = []
        if libraries:
            if not _isPlatWin:
                # Pass through library requests to the GNU linker via DMD's -L
                # option.
                explicitLibOpts.extend('-L-l' + libName for libName in libraries)
            else:
                # On Windows, the linker that DMD uses doesn't seem to have an
                # equivalent of GCC's -LsearchDirectory and -llibraryName
                # arguments, so we try to find the exact paths for the
                # libraries mentioned and pass those paths to DMD.
                # XXX: What about OptLink's /scanlib option and the LIB env var?
                explicitLibFilenames = [
                    libName + DMDDCompiler.static_lib_extension
                    for libName in libraries
                  ]
                if not library_dirs:
                    explicitLibOpts.extend(explicitLibFilenames)
                else:
                    curDir = os.path.abspath(os.curdir)
                    if curDir not in library_dirs:
                        library_dirs.insert(0, curDir)

                    libFound = [False] * len(libraries)
                    for libIndex, libFilename in enumerate(explicitLibFilenames):
                        for libDir in library_dirs:
                            probeLibPath = os.path.join(libDir, libFilename)
                            if os.path.isfile(probeLibPath):
                                explicitLibOpts.append(_qp(probeLibPath))
                                libFound[libIndex] = True
                                break

                    libsNotFound = []
                    for libIndex, found in enumerate(libFound):
                        if not found:
                            libsNotFound.append(
                                (libraries[libIndex], explicitLibFilenames[libIndex])
                              )
                    if libsNotFound:
                        raise LinkError('Unable to find the following libraries'
                            ' in the specified library search directories:\n  '
                            + '\n  '.join(
                                  '%s  (filename "%s")' % (libName, libFilename)
                                  for (libName, libFilename) in libsNotFound
                                )
                            + '\nSearched the following directories:\n  '
                            + '\n  '.join(library_dirs)
                          )

        # Generate a complete list of all command-line arguments, excluding any
        # that turned out to be blank:
        cmdElements = ([dmdExeOpt] + extra_preargs + self._optimizationOpts
            + [outputDirOpt, outputObjOpt, pythonLibOpt, self._unicodeOpt]
            + inputObjectOpts + explicitLibOpts + extra_postargs
          )
        cmdElements = [el for el in cmdElements if el]

        # Invoke the linker indirectly by calling the compiler:
        try:
            self.spawn(cmdElements)
        except DistutilsExecError, msg:
            raise CompileError(msg)


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
