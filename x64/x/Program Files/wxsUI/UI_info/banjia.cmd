::@echo off
::mode con cols=32 lines=1
set args1=%1
set args2=%2
set nbpath=%args2%
::if not exist %args2%NBstore md %args2%NBstore
echo %args1%

if "%args1%" == "USERPROFILE" (
call :setx_userprofile
rem call :setx_x86
rem call :setx_program
call :setx_program_reg
) 
exit

:setx_program_reg
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "ProgramFilesDir" /t REG_SZ /d "%args2%NBStore\Program Files"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "CommonFilesDir" /t REG_SZ /d "%args2%NBStore\Common Files"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "ProgramFilesDir (x86)" /t REG_SZ /d %args2%NBStore\Program Files (x86)"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "CommonFilesDir (x86)" /t REG_SZ /d "%args2%NBStore\Program Files (x86)\Common Files"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "ProgramFilesPath" /t REG_EXPAND_SZ /d "%args2%NBStore\ProgramFiles"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /f /v "ProgramW6432Dir" /t REG_SZ /d "%args2%NBStore\ProgramFiles"
exit /b

:setx_userprofile
set mklinkpath=%USERPROFILE%
set dirname=用户目录
set NBStore=%args2%NBStore
set relative=Users\Default
call :check_link
call :setx_dir USERPROFILE
exit /b

:setx_program
set mklinkpath=%programfiles%
set dirname=程序目录
set NBStore=%args2%NBStore
set relative=program^ files
call :check_link
call :setx_dir ProgramFiles
call :setx_dir ProgramW6432
exit /b

:setx_x86
set mklinkpath=%ProgramFiles(x86)%
set dirname=x86程序目录
set NBStore=%args2%NBStore
set relative=Program Files (x86)
call :check_link
call :setx_dir ProgramFiles(x86)
exit /b


:setx_dir
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 8 -text "设置%dirname%到%NBstore%"
::echo 正在设置环境变量%args1% 到 %args2%稍候
if not exist "%NBstore%\%relative%" md "%NBstore%\%relative%"
setx %1 "%NBstore%\%relative%"
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
echo 完成!
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 1 -text "[%dirname%]已被移至%NBstore%\%relative%"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "你可以愉快地玩耍了!"
exit /b

:check_link
Setlocal enabledelayedexpansion 
for /f "delims=*" %%a in ('dir /b /s "%mklinkpath%"') do (
::dir/ad "%%a" >nul 2>nul&&echo %%a 是文件夹 &&set mklinkargs=/d||echo %%a 是文件&&set mklinkargs=
dir/ad "%%a" >nul 2>nul&&echo %%a 是文件夹&&set do_file=mkfile||echo %%a 是文件&&set do_file=
set storefile=%%a
call :linkfile
)
echo done
exit /b

:linkfile
set storefile=!%storefile:NBStore=%!
if "%do_file%" == "mkfile" (
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 1 -text "创建目录%storefile%"
if not exist "%NBStore%%storefile%" mkdir "%NBStore%%storefile%"
) else (
call :cplnk
)
exit /b

:cplnk
echo %storefile%|find /i ".LNK"
if errorlevel 1 mklink "%NBStore%%storefile%" "X:%storefile%"
if errorlevel 0 copy /y "X:%storefile%" "%NBStore%%storefile%"
exit /b
:show
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 1 -text "%1 %2"
exit /b