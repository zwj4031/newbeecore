cd /d "%~dp0..\.."
call :GetWinXShell
%WINXSHELL% -code QuitWindow('WinXShell-UI_info')

::%WINXSHELL%  -console -ui -jcfg wxsUI\UI_info\main.jcfg -nwinfo
%WINXSHELL%  -ui -jcfg wxsUI\UI_info\main.jcfg -nwinfo -top

%WINXSHELL% -code QuitWindow('UI_info')
:::%0
goto :EOF

:GetWinXShell
if exist x64\Debug\WinXShell.exe set WINXSHELL=x64\Debug\WinXShell.exe&&goto :EOF
if exist WinXShell.exe set WINXSHELL=WinXShell.exe&&goto :EOF
if exist WinXShell_%PROCESSOR_ARCHITECTURE%.exe set WINXSHELL=WinXShell_x86.exe&&goto :EOF
set WINXSHELL=WinXShell_x64.exe
goto :EOF