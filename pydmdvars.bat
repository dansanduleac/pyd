@echo off

Set D_ROOT=C:\dmd
Set PY_ROOT=C:\Python25
Set PATH=%D_ROOT%\dmd\bin;%D_ROOT%\dm\bin;%D_ROOT%\gdc\bin;%PY_ROOT%;%PATH%
Set LIB=%D_ROOT%\dmd\lib;%D_ROOT%\dm\lib;%LIB%

echo Environment configured for Python and D

