@echo off 2>nul 3>nul
mode con cols=16 lines=1
title=��ѯĿ��ϵͳ......
set root=%systemroot%:\windows\system32
cd /d %systemroot%\system32

::::��ʼ
set desktop=%USERPROFILE%\desktop
set QuickLaunch=X:\users\Default\AppData\Roaming\Microsoft\internet Explorer\Quick Launch\User Pinned\TaskBar
set StartMenu=X:\users\Default\AppData\Roaming\Microsoft\windows\Start Menu
set root=X:\windows\system32
set wait=pecmd wait 1000 
::::������ʾ
if not exist "X:\Program Files\WinXShell.exe" (
set say=%root%\pecmd.exe TEAM TEXT "
set hello=echo ...
set font="L300 T300 R768 B768 $30^|wait 800 
set wait=echo ...
set xsay=echo ...
set show=echo ...
set xshow=echo ...
) else (
set font=
set say=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -text
set hello=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -wait 2 -text
set show=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_show.zip -top -text
set xsay=start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
set xshow=start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_show')"
set wait=%root%\pecmd.exe wait 800
)
if not "%2" == "" set args1=%1&&set args2=%2&&goto startjob
::���ýű�1����

for %%i in (C D E F G H I J K L M N O P Q R S T U V W Y Z B A) do (
%hello% ��������%%i�̡�������
if exist "%%i:\Windows\System32\DriverStore\FileRepository" (
set sysdrv=%%i
%xsay%
if "%1" == "net" (
%say% �ҵ�ϵͳ��%%i:\,����.net��.....
ren "X:\Windows\Microsoft.NET" "Microsoft.NET_old"
mklink /d "X:\Windows\Microsoft.NET" "%%i:\Windows\Microsoft.NET"
call :linkframework
) else (
%say% �ҵ�ϵͳ��%%i:\,����.net�������ļ�.....
set sysdrv=%%i
call :linkall
ren "X:\Windows\Microsoft.NET" "Microsoft.NET_old"
mklink /d "X:\Windows\Microsoft.NET" "%%i:\Windows\Microsoft.NET"
call :linkframework
)
%xsay%
%hello% �������,��ʳ��...
%xsay%
exit
) else (
%hello% ��������%%i�̡���������
)
)
%xsay%
%hello% �������!
exit

:linkall
call :loadfile windows\system32
call :loadfile windows\syswow64
call :loadfile windows\inf
call :loadfile windows\system32\drivers
call :loadfile Windows\system32\drivers\zh-CN
call :loadfile Windows\System32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}
call :loadfile Windows\system32\zh-CN
call :loadfile Windows\SysWOW64\zh-CN
exit /b

:loadfile
%xsay%
%say% ��������%sysdrv%:\%1�µ��ļ�
for /f %%i in ('dir /b %sysdrv%:\%1\*.*') do (
if not exist "X:\%1\%%i" mklink "X:\%1\%%i" "%sysdrv%:\%1\%%i"
)
%xsay%
exit /b

:linkframework
call :loadfile Windows\System32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}
for /f "delims= " %%a in (X:\progra~1\BatchTools\features\NetFramework.txt) do (
if not exist X:%%a mklink "X:%%a" "%sysdrv%:%%a"
)
exit /b

