@echo off
cd /d "%~dp0"
start "" WinXShell.exe -ui -jcfg wxsUI\UI_Text\main.jcfg -text "得到服务器IP为:<u>127.0.0.1</u>"
start "" WinXShell.exe -ui -jcfg wxsUI\UI_Text\main.jcfg -text ""
start "" WinXShell.exe -ui -jcfg wxsUI\UI_Text\main.jcfg -text "然后想做啥:<u>127.0.0.1</u>"
pause
set WINXSHELL=WinXShell.exe
set x8664=x64
if not "x%PROCESSOR_ARCHITECTURE%"=="xAMD64" set x8664=x86
if not exist %WINXSHELL% set WINXSHELL=WinXShell_%x8664%.exe

echo Hints:
echo ----------------------------------------
echo For UI_Logon
echo Username:Administrator
echo Password:admin
echo.
echo For UI_Shutdown
echo Press 'Esc' to cancel(close)
echo ----------------------------------------
echo.
echo.
echo Press any key to test ...
pause >nul

start %WINXSHELL% -ui -jcfg wxsUI\UI_Logon.zip
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Logon.zip -bk bk2.jpg
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Settings.zip
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Shutdown.zip\full.jcfg -blur 5.0
pause
rem start %WINXSHELL% -ui -jcfg wxsUI\UI_Resolution.zip
rem pause
rem start %WINXSHELL% -ui -jcfg wxsUI\UI_Shutdown.zip
rem pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_WIFI.zip\main.jcfg -theme light
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Volume.zip\main.jcfg -theme dark
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Resolution.zip\wallpaper.jcfg
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Calendar.zip\calendar.jcfg -theme light
rem start %WINXSHELL% -ui -jcfg wxsUI\UI_Calendar.zip\calendar.jcfg
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_SystemInfo.zip
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Launcher.zip -theme dark
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Launcher.zip\full.jcfg -custom
echo exit...
pause
exit 0

rem run with parameter
rem change resolution directly
start %WINXSHELL% -ui -jcfg wxsUI\UI_Resolution.zip -direct
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Resolution.zip -lua direct.lua
pause
rem no sound playing when volume changed
start %WINXSHELL% -ui -jcfg wxsUI\UI_Volume.zip -nobeep
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_WIFI.zip -hidewindow
pause
start %WINXSHELL% -ui -jcfg wxsUI\UI_Launcher.zip -theme dark
pause
