@echo off
mode con cols=32 lines=1
title=正在下载QQ2021
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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text ""正在安装QQ……""
goto checkQQ
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "未检测到QQ，准备下载安装QQ……"
aria2c --check-certificate=false "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe" -c
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "下载完成，正在安装QQ……"
if exist PCQQ2021.exe start "" PCQQ2021.exe /s &&goto checkQQ
exit /b


:checkQQ
if exist "X:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe" goto runapp 
pecmd wait 4000
goto checkQQ


:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "QQ已安装，正在打开……"
pecmd kill QQsetupEx.exe
pecmd wait 8000
del/q /f PCQQ2021.exe
start "" "X:\Program Files (x86)\Tencent\QQ\Bin\QQScLauncher.exe"
exit
