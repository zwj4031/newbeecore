@echo off
mode con cols=32 lines=1
title=��������΢��ͬ��
cd /d %~dp0
set appdir=verysync
set appexe=verysync.exe
set dlurl=http://dl-cn.verysync.com/releases/v2.8.2/verysync-windows-386-v2.8.2.zip
set outfile=very.zip

:downloadapp
if not exist "X:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "δ��װMicrosoft Edge����Ӧ������Microsoft Edge"
exit
) else (
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "�������ذ�װ΢��ͬ������"
aria2c -c %dlurl% -d %temp% -o %outfile%
)

:setrunapp
if not exist %temp%\%appdir% md %temp%\%appdir%
if exist %temp%\%outfile% (
start "" /w "%ProgramFiles%\7-zip\7z.exe" -y x %temp%\%outfile% -o%temp%\%appdir%
) else (
goto downloadapp
)

for /f %%i in ('dir /b /s %temp%\%appdir%\*%appexe%') do set runapp=%%i

:run
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" /min %runapp%
mklink %desktop%\΢��ͬ�� %runapp%
exit