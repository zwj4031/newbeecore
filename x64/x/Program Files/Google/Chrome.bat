@echo off
mode con cols=32 lines=1
title=��������Chrome�����������
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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "δ��⵽Chrome���������ذ�װchrome����"

git clone https://gitee.com/zwj4031/google.git
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "������ɣ� ��װ�С���"
if exist %temp%\google\chromeSetup.exe start "" %temp%\google\chromeSetup.exe&&goto checkchrome
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 2 -text "����ʧ�ܣ��������ء���"
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
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 10 -text "Chrome�Ѱ�װ�����ڴ򿪡���"
start "" "X:\Program Files\BatchTools\����Ĭ�������.bat"

start "" "X:\Program Files\Google\Chrome\Application\chrome.exe"
copy "X:\Users\Default\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Google Chrome.lnk" "X:\Users\Default\DeskTop" /y
exit
