@echo off
mode con cols=32 lines=1
title=��������wechat
start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_DL\main.jcfg -nbapp wechat&&exit
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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 15 -text ""���ڰ�װ΢�š���""
goto checkwechat
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "δ��⵽΢�ţ�׼�����ذ�װ΢�š���"
aria2c --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36" --check-certificate=false "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe" -c
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 15 -text "������ɣ����ڰ�װ΢�š���"
if exist WeChatSetup.exe start "" /w WeChatSetup.exe &&goto checkwechat
exit /b


:checkwechat
if exist "X:\Program Files (x86)\Tencent\wechat\Bin\wechatScLauncher.exe" goto runapp 
pecmd wait 4000
goto checkwechat


:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "΢���Ѱ�װ�����ڴ򿪡���"
pecmd kill wechatsetupEx.exe
pecmd wait 4000
del/q /f WeChatSetup.exe
start "" "%programfiles%\WinXShell.exe" -winpe
start "" "X:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
exit
