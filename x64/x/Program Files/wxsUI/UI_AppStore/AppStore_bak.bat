cd /d "%~dp0"
::mode con: cols=36 lines=1 
::@echo off
call :GetWinXShell

%WinXShell% -ui -jcfg wxsUI\\UI_Appstore\\main.jcfg
exit
:GetWinXShell
if exist WinXShell.exe set WINXSHELL=WinXShell.exe 
if exist ..\..\WinXShell.exe set WINXSHELL=..\..\WinXShell.exe
exit /b