@echo off
mode con cols=32 lines=1
:var
set appname=ToDesk���ض�
set appfile=ToDesk_Lite.exe
set apppath=%~dp0%appfile%
set appurl=https://dl.todesk.com/windows/ToDesk_Lite.exe
set aria2cargs=
set runargs=
title=��������%appname%

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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "δ��⵽%appname%���������ذ�װ%appname%����"
aria2c --out="%appfile%" %aria2cargs% "%appurl%"
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "������ɣ� ��װ�С���"
if exist "%appfile%" start "" "%appfile%"&&goto checkefile
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 2 -text "����ʧ�ܣ��������ء���"
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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "%appname%�Ѱ�װ�����ڴ򿪡���"
start "" "%apppath%" %runargs%
exit
