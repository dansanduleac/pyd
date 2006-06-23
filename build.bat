SET D_ROOT=C:\dmd
SET PY_ROOT=C:\Python24

SET PATH=%D_ROOT%\dm\bin;%D_ROOT%\dmd\bin;%PY_ROOT%;%PATH%

del .\build\lib.win32-2.4\testdll.pyd
python.exe setup.py build
pause

