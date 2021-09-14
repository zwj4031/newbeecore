@echo off
mode con cols=32 lines=1
title=正在下载Edge浏览器下载器
cd /d %~dp0
if exist edge.7z "%ProgramFiles%\7-zip\7z.exe" x edge.7z -o%temp% -y
if exist "X:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" goto runapp


if exist MicrosoftEdgeSetup.exe (
start "" MicrosoftEdgeSetup.exe 
) else (
call :downsetup
)
goto checkedge

:checksetup
if exist MicrosoftEdgeSetup.exe start "" MicrosoftEdgeSetup.exe &&goto checkedge
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "未检测到Edge，正在下载安装Edge……"
aria2c  --check-certificate=false "https://c2rsetup.officeapps.live.com/c2r/downloadEdge.aspx?platform=Default&source=EdgeStablePage&Channel=Stable&language=zh-CN&consent=1"
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "下载完成， 安装中……"
if exist MicrosoftEdgeSetup.exe start "" MicrosoftEdgeSetup.exe&&goto checkedge
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 2 -text "下载失败，重新下载……"
pecmd wait 4000
goto downsetup
exit /b


:checkedge
if exist "X:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" goto runapp 
pecmd wait 4000
goto checkedge

:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
pecmd kill MicrosoftEdgeSetup.exe
pecmd kill MicrosoftEdgeUpdate.exe
if exist "X:\Program Files (x86)\Microsoft\EdgeUpdate" rd /s /q "X:\Program Files (x86)\Microsoft\EdgeUpdate"
if exist "X:\Program Files (x86)\Microsoft\Temp" rd /s /q "X:\Program Files (x86)\Microsoft\Temp"
if exist MicrosoftEdgeSetup.exe del /f /q MicrosoftEdgeSetup.exe
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "Edge已安装，正在打开……"
start "" "X:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
exit
