@echo off
mode con cols=32 lines=1
title=正在下载Chrome浏览器下载器
cd /d %~dp0
cd /d %temp%
if exist chrome.7z "%ProgramFiles%\7-zip\7z.exe" x chrome.7z -o%temp% -y
if exist "X:\Program Files\Google\Chrome\Application\chrome.exe" goto runapp


if exist %temp%\google\chromeSetup.exe (
start "" %temp%\google\chromeSetup.exe
) else (
call :downsetup
)
goto checkchrome

:checksetup
if exist chromeSetup.exe start "" chromeSetup.exe &&goto checkchrome
call :downsetup
exit /b

:downsetup
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "未检测到Chrome，正在下载安装chrome……"

git clone https://gitee.com/zwj4031/google.git
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "下载完成， 安装中……"
if exist %temp%\google\chromeSetup.exe start "" %temp%\google\chromeSetup.exe&&goto checkchrome
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 2 -text "下载失败，重新下载……"
pecmd wait 4000
goto downsetup
exit /b


:checkchrome
if exist "X:\Program Files\Google\Chrome\Application\chrome.exe" goto runapp 
pecmd wait 4000
goto checkchrome

:runapp
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
pecmd kill GoogleUpdate.exe
pecmd kill GoogleCrashHandler64.exe
pecmd kill GoogleCrashHandler.exe
if exist "X:\Program Files (x86)\Google" rd /s /q "X:\Program Files (x86)\Google"
if exist X:\Windows\temp\google\ChromeSetup.exe del /f /q X:\Windows\temp\google\ChromeSetup.exe
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "Chrome已安装，正在打开……"
start "" "X:\Program Files\BatchTools\设置默认浏览器.bat"

start "" "X:\Program Files\Google\Chrome\Application\chrome.exe"
copy "X:\Users\Default\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Google Chrome.lnk" "X:\Users\Default\DeskTop" /y
exit
