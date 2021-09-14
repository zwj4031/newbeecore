@echo off
mode con cols=32 lines=1
:var
set appname=ToDesk被控端
set appfile=ToDesk_Lite.exe
set apppath=%~dp0%appfile%
set appurl=https://dl.todesk.com/windows/ToDesk_Lite.exe
set aria2cargs=
set runargs=
title=正在下载%appname%

:init
cd /d %~dp0
if exist "%apppath%" (
goto runapp
) else (
call :downsetup
)
goto checkfile

:::checksetup
::if exist MicrosoftEdgeSetup.exe start "" MicrosoftEdgeSetup.exe &&goto checkedge
::call :downsetup
::exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "未检测到%appname%，正在下载安装%appname%……"
aria2c --out="%appfile%" %aria2cargs% "%appurl%"
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "下载完成， 安装中……"
if exist "%appfile%" start "" "%appfile%"&&goto checkefile
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 2 -text "下载失败，重新下载……"
pecmd wait 4000
goto downsetup
exit /b


:checkfile
if exist "%apppath%" goto runapp 
pecmd wait 4000
goto checkfile

:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
pecmd kill %appfile%
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "%appname%已安装，正在打开……"
start "" "%apppath%" %runargs%
exit
