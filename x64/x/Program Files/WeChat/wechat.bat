@echo off
mode con cols=32 lines=1
title=正在下载wechat
cd /d %~dp0
if exist "X:\Program Files (x86)\Tencent\WeChat\WeChat.exe" goto runapp
if exist WeChatSetup.exe (
goto checksetup
) else (
call :downsetup
)
goto checkwechat

:checksetup
if exist WeChatSetup.exe start "" WeChatSetup.exe /S
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 15 -text ""正在安装微信……""
goto checkwechat
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "未检测到微信，准备下载安装微信……"
aria2c --check-certificate=false "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe" -c
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 15 -text "下载完成，正在安装微信……"
if exist WeChatSetup.exe start "" /w WeChatSetup.exe &&goto checkwechat
exit /b


:checkwechat
if exist "X:\Program Files (x86)\Tencent\wechat\Bin\wechatScLauncher.exe" goto runapp 
pecmd wait 4000
goto checkwechat


:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "微信已安装，正在打开……"
pecmd kill wechatsetupEx.exe
pecmd wait 4000
del/q /f WeChatSetup.exe
start "" "%programfiles%\WinXShell.exe" -winpe
start "" "X:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
exit
