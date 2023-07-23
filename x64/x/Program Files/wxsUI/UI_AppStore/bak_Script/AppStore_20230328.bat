@echo off
if exist "X:\Program Files\wxsUI\UI_AppStore\nbappstore.lua" start "" "X:\Program Files\wxsUI\UI_AppStore\nbappstore.lua"&&exit
cd /d %temp%
mode con: cols=22 lines=2

if exist %temp%\appstore-master rd /s /q %temp%\appstore-master
call :GetWinXShell
if exist %temp%\appstore\wxsUI\UI_AppStore\loading.jcfg start "" %WINXSHELL% -ui -jcfg wxsUI\UI_AppStore\loading.jcfg -wait 8 -text "正在载入数据,稍候..."
appstore\aria2c.exe --check-certificate=false --user-agent=Wget/1.21.1 --allow-overwrite=true https://gitee.com/zwj4031/appstore/repository/archive/master.zip -d %temp% -o appstore.zip
appstore\bin\7zx64.exe x -y %temp%\appstore.zip
start "" /w %WINXSHELL%  -code "QuitWindow(nil,'AppStore')"
if exist %temp%\appstore-master call :checkrobocopy
start "" %WinXShell% -ui -jcfg wxsUI\\UI_Appstore\\main.jcfg
exit
:GetWinXShell
if exist %temp%\AppStore\WinXShell.exe set WINXSHELL=%temp%\AppStore\WinXShell.exe
if exist ..\..\WinXShell.exe set WINXSHELL=..\..\WinXShell.exe
exit /b
:checkrobocopy
if exist %systemdrive%\windows\system32\robocopy.exe (
robocopy %temp%\appstore-master %temp%\appstore
robocopy %temp%\appstore-master\AppStore %temp%\appstore\AppStore /mir
) else (
xcopy /s /e /y %temp%\appstore-master\AppStore %temp%\appstore\AppStore
)
if exist %systemdrive%\windows\system32\robocopy.exe (
robocopy /mir %temp%\appstore-master\wxsUI %temp%\appstore\wxsUI
) else (
xcopy /s /e /y %temp%\appstore-master\wxsUI %temp%\appstore\wxsUI
)

if exist %systemdrive%\windows\system32\robocopy.exe (
robocopy %temp%\appstore-master\bin %temp%\appstore\bin 
) else (
xcopy /s /e /y %temp%\appstore-master\bin %temp%\appstore\bin
)
exit /b