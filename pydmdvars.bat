@echo off

Set D_ROOT=C:\dmd
Set PY_ROOT=C:\Python24
Set PATH=%D_ROOT%\dmd\bin;%D_ROOT%\dm\bin;%PY_ROOT%;%PATH%
Set LIB=%D_ROOT%\dmd\lib;%D_ROOT%\dm\lib;%LIB%

echo Environment configured for Python and DMD

