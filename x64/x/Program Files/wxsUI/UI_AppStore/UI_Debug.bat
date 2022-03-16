@echo on
cd /d "%~dp0..\.."

call :GetWinXShell
call :GetFolderName "%~p0"


start "" %WINXSHELL% -ui -console -jcfg wxsUI\%p0%\main.jcfg -file
pause
taskkill /f /im winxshell.exe
start "" %WINXSHELL% -ui -console -jcfg wxsUI\%p0%\main.jcfg -file xxoo.rmvb
pause
taskkill /f /im winxshell.exe
start "" %WINXSHELL% -ui -console -jcfg wxsUI\%p0%\main.jcfg -file xxoo.vmx
pause
taskkill /f /im winxshell.exe



goto :EOF

:GetWinXShell
if exist x64\Debug\WinXShell.exe set WINXSHELL=x64\Debug\WinXShell.exe&&goto :EOF
if exist WinXShell.exe set WINXSHELL=WinXShell.exe&&goto :EOF
if exist WinXShell_%PROCESSOR_ARCHITECTURE%.exe set WINXSHELL=WinXShell_x86.exe&&goto :EOF
set WINXSHELL=WinXShell_x64.exe
goto :EOF

:GetFolderName
if "x%~2"=="x1" set "p0=%~n1" && goto :EOF
set "p0=%~1"
set p0=%p0:~0,-1%
call :GetFolderName  "%p0%" 1
goto :EOF
