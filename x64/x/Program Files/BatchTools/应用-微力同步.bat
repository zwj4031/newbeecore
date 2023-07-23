@echo off
mode con cols=32 lines=1
title=正在下载微力同步
cd /d %~dp0
set appdir=verysync
set appexe=verysync.exe
set dlurl=http://www.verysync.com/download.php?platform=windows-amd64
set outfile=very.zip

:downloadapp
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "正在下载安装微力同步……"
aria2c -c --user-agent="Chrome/94.0.4606.71" %dlurl% -d %temp% -o %outfile%


:setrunapp
if not exist %temp%\%appdir% md %temp%\%appdir%
if exist %temp%\%outfile% (
start "" /w "%ProgramFiles%\7-zip\7z.exe" -y x %temp%\%outfile% -o%temp%\%appdir%
) else (
goto downloadapp
)

for /f %%i in ('dir /b /s %temp%\%appdir%\*%appexe%') do set runapp=%%i

:run
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" /min %runapp%
mklink %desktop%\微力同步 %runapp%
exit