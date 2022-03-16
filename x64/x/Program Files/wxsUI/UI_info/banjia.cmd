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
set dirname=�û�Ŀ¼
set NBStore=%args2%NBStore
set relative=Users\Default
call :check_link
call :setx_dir USERPROFILE
exit /b

:setx_program
set mklinkpath=%programfiles%
set dirname=����Ŀ¼
set NBStore=%args2%NBStore
set relative=program^ files
call :check_link
call :setx_dir ProgramFiles
call :setx_dir ProgramW6432
exit /b

:setx_x86
set mklinkpath=%ProgramFiles(x86)%
set dirname=x86����Ŀ¼
set NBStore=%args2%NBStore
set relative=Program Files (x86)
call :check_link
call :setx_dir ProgramFiles(x86)
exit /b


:setx_dir
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 8 -text "����%dirname%��%NBstore%"
::echo �������û�������%args1% �� %args2%�Ժ�
if not exist "%NBstore%\%relative%" md "%NBstore%\%relative%"
setx %1 "%NBstore%\%relative%"
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
echo ���!
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 1 -text "[%dirname%]�ѱ�����%NBstore%\%relative%"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "�����������ˣ��!"
exit /b

:check_link
Setlocal enabledelayedexpansion 
for /f "delims=*" %%a in ('dir /b /s "%mklinkpath%"') do (
::dir/ad "%%a" >nul 2>nul&&echo %%a ���ļ��� &&set mklinkargs=/d||echo %%a ���ļ�&&set mklinkargs=
dir/ad "%%a" >nul 2>nul&&echo %%a ���ļ���&&set do_file=mkfile||echo %%a ���ļ�&&set do_file=
set storefile=%%a
call :linkfile
)
echo done
exit /b

:linkfile
set storefile=!%storefile:NBStore=%!
if "%do_file%" == "mkfile" (
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 1 -text "����Ŀ¼%storefile%"
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