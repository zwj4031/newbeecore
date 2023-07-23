@ech@echo on
set root=%~dp0
cd /d "%~dp0..\.."
call :GetWinXShell
call :GetFolderName "%~p0"
if exist %temp%\AppStore rd /s /q %temp%\AppStore
mkdir %temp%\AppStore

cd /d %temp%\AppStore
git clone https://gitee.com/zwj4031/appstore.git
if errorlevel 128 call :timesync
start "" /w %WINXSHELL%  -code "QuitWindow(nil,'AppStore')"
call :checkrobocopy
exit
goto :EOF

:GetWinXShell
if exist x64\Debug\WinXShell.exe set WINXSHELL=x64\Debug\WinXShell.exe&&goto :EOF
if exist WinXShell.exe set WINXSHELL=WinXShell.exe&&goto :EOF
if exist WinXShell_%PROCESSOR_ARCHITECTURE%.exe set WINXSHELL=WinXShell_x86.exe&&goto :EOF
set WINXSHELL=WinXShell_x64.exe
goto :EOF

:GetFolderName
if "x%~2"=="x1" set "p0=%~n1" && goto :EOF
set "p0=%~1"
set p0=%p0:~0,-1%
call :GetFolderName  "%p0%" 1
goto :EOF

:checkrobocopy
if exist %systemdrive%\windows\system32\robocopy.exe (
robocopy %temp%\AppStore\appstore "X:\Program Files"
robocopy %temp%\AppStore\appstore\appstore "X:\Program Files\AppStore" /mir
robocopy  %temp%\AppStore\appstore\wxsUI\UI_AppStore "X:\Program Files\wxsUI\UI_AppStore" /mir
robocopy  %temp%\AppStore\appstore\wxsUI\UI_NBGI "X:\Program Files\wxsUI\UI_NBGI" /mir
robocopy  %temp%\AppStore\appstore\wxsUI\UI_Tool "X:\Program Files\wxsUI\UI_Tool" /mir
) else (
xcopy /s /e /y %temp%\AppStore\appstore\*.* "X:\Program Files"
)
exit /b

:timesync
start "" /min "%root%timesync.exe" /auto
start "" /w %WINXSHELL% -ui -jcfg wxsUI\\UI_AppStore\\loading.jcfg -top -wait 3 -text "获取数据失败，正在核准时间..."
start "" /w %WINXSHELL% -code "CloseWindow('WindowClass_0', 'TimeSync ')"
cd /d %temp%\AppStore
git clone https://gitee.com/zwj4031/appstore.git
exit /b