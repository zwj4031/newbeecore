@echo off
mode con cols=32 lines=1
start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_DL\main.jcfg -nbapp qq&&exit
title=��������QQ2021
cd /d %~dp0
if exist "X:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe" goto runapp
if exist PCQQ2021.exe (
goto checksetup
) else (
call :downsetup
)
goto checkQQ

:checksetup
if exist PCQQ2021.exe start "" PCQQ2021.exe /S
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text ""���ڰ�װQQ����""
goto checkQQ
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "δ��⵽QQ��׼�����ذ�װQQ����"
aria2c --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36" --check-certificate=false "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe" -c
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "������ɣ����ڰ�װQQ����"
if exist PCQQ2021.exe start "" PCQQ2021.exe /s &&goto checkQQ
exit /b


:checkQQ
if exist "X:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe" goto runapp 
pecmd wait 4000
goto checkQQ


:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "QQ�Ѱ�װ�����ڴ򿪡���"
pecmd kill QQsetupEx.exe
pecmd wait 8000
del/q /f PCQQ2021.exe
start "" "X:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe"
exit
