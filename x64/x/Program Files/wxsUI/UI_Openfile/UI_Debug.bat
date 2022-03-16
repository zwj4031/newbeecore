cd /d "%~dp0..\.."

call :GetWinXShell
::%WINXSHELL%  -console -ui -jcfg wxsUI\UI_info\main.jcfg -nwinfo
taskkill /f /im winxshell.exe
start "" %WINXSHELL%  -ui -jcfg wxsUI\UI_Openfile\main.jcfg
pause

%0
:::%0
goto :EOF

:GetWinXShell
if exist x64\Debug\WinXShell.exe set WINXSHELL=x64\Debug\WinXShell.exe&&goto :EOF
if exist WinXShell.exe set WINXSHELL=WinXShell.exe&&goto :EOF
if exist WinXShell_%PROCESSOR_ARCHITECTURE%.exe set WINXSHELL=WinXShell_x86.exe&&goto :EOF
set WINXSHELL=WinXShell_x64.exe
goto :EOF