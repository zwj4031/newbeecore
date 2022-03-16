cd /d "%~dp0..\.."
call :GetWinXShell

start /WAIT %WINXSHELL% -console -ui -jcfg wxsUI\UI_LED\main.jcfg -scroll -wait '3' -text " Show a scrolling message."
%WINXSHELL% -ui -jcfg wxsUI\UI_LED\main.jcfg -wait 5 -text " Get the IP:<u>127.0.0.1</u>"
start  %WINXSHELL% -ui -jcfg wxsUI\UI_LED\main.jcfg -top -scroll -text " This is a looong message, the window will auto increase the width to shis message."
%WINXSHELL% -code app:sleep(5000)
%WINXSHELL% -code QuitWindow('WinXShell-UI_LED-Wnd')

goto :EOF

:GetWinXShell
if exist x64\Debug\WinXShell.exe set WINXSHELL=x64\Debug\WinXShell.exe&&goto :EOF
if exist WinXShell.exe set WINXSHELL=WinXShell.exe&&goto :EOF
if exist WinXShell_%PROCESSOR_ARCHITECTURE%.exe set WINXSHELL=WinXShell_x86.exe&&goto :EOF
set WINXSHELL=WinXShell_x64.exe
goto :EOF