@echo off 2>nul 3>nul
mode con cols=16 lines=1
title=��ѯĿ��ϵͳ����......
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
%xsay%
if "%1" == "net" (
%say% �ҵ�ϵͳ��%%i:\,��װ����������.....
start "" /w devcon disable pci\CC_03*
start "" /w /min %root%\driverindexer load-driver "%%i:\Windows\System32\DriverStore\FileRepository"
start "" devcon enable pci\CC_03*
) else (
%say% �ҵ�ϵͳ��%%i:\,��װ����������......
start "" /w /min %root%\driverindexer load-driver "%%i:\Windows\System32\DriverStore\FileRepository"
)
%xsay%
%hello% ��װ���
%xsay%
exit
) else (
%hello% ��������%%i�̡���������
)
)
%xsay%
%hello% �������!

exit