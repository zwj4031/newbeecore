@ECHO OFF&PUSHD %~DP0 &TITLE ʷ����ΰ�������PE������
set root=%systemroot%\system32
if not exist %~dp0client md %~dp0client
mode con cols=36 lines=36

color 0f

:menu

cls


echo ����minipeִ��ʲô����
echo ==============================
echo ����1�������¡-ghost
echo ����2������ͬ��-netcopy
echo ==============================
echo ����3��ȫ�Զ�����-P2P����[MBR]
echo ����4��ȫ�Զ�����-P2P����[GPT]
echo ����5��ȫ�Զ�����-�ಥ����[MBR]
echo ����6��ȫ�Զ�����-�ಥ����[GPT]
echo ����z  ���̲���[��շ�������ʽ��]
echo ==============================
echo ����7����P2P����[������]
echo ����8�����ಥ����[������]
echo ����9, ��HOU�ಥ����[������]
echo ����i, IFW�ಥ����-i[0 1 8]
echo ==============================
echo ����s���Զ���ִ������[CMD����]
echo ����x�������ļ���ִ��[PE�ͻ���]
echo ����d  �����ļ���PE  [PE�ͻ���]
echo ==============================
echo ����b��ǿ����ֹ��ǰ����
echo ����c����տͻ����б�
echo ����r���ָ���һ�οͻ����б�
echo ==============================
echo ����k������PE�ͻ�������
echo ==============================
echo [���س�ˢ��]
for /f %%i in ('dir /b %~dp0client\') do (
@echo ���߿ͻ���%%i  
)

set user_input=no
set /p user_input=�����룺
if %user_input% equ 1 set job=startup.bat netghost mousedos&&set jobname=�����¡-ghost&&call :dojob
if %user_input% equ 2 set job=startup.bat netcopy now&&set jobname=����ͬ��-netcopy&&call :dojob
if %user_input% equ 3 set job=startup.bat p2pmbr now&&echo ���ݽ���ʧ!�س�����ȷ��&&pause&&pause&&pause&&set jobname=P2P�Զ�����-MBR&&call :dojob
if %user_input% equ 4 set job=startup.bat p2pgpt now&&echo ���ݽ���ʧ!�س�����ȷ��&&pause&&pause&&pause&&set jobname=P2P�Զ�����-GPT&&call :dojob
if %user_input% equ 5 set job=startup.bat dbmbr now&&echo ���ݽ���ʧ!�س�����ȷ��&&pause&&pause&&pause&&set jobname=�ಥ�Զ�����-MBR&&call :dojob
if %user_input% equ 6 set job=startup.bat dbgpt now&&echo ���ݽ���ʧ!�س�����ȷ��&&pause&&pause&&pause&&set jobname=�ಥ�Զ�����-GPT&&call :dojob
if %user_input% equ 7 set job=startup.bat btonly now&&set jobname=��P2P����[������]&&call :dojob
if %user_input% equ 8 set job=startup.bat cloud now&&set jobname=���ಥ����[������]&&call :dojob
if %user_input% equ 9 call :houc
if %user_input% equ b set job=startup.bat kill now&&set jobname=�������н���&&call :dojob
if %user_input% equ c call :mvclient
if %user_input% equ r call :reclient
if %user_input% equ s call :shell
if %user_input% equ k call :vncclient
if %user_input% equ m call :menu
if %user_input% equ x call :xrun
if %user_input% equ d call :xdown
if %user_input% equ i call :ifw
if %user_input% equ z goto disk_tools
if %user_input% equ i0 set job=startup.bat ifw now 0&&set jobname=ifw�ಥ����[�ָ���ʲô������]&&call :dojob
if %user_input% equ i1 set job=startup.bat ifw now 1&&set jobname=ifw�ಥ����[�ָ�������]&&call :dojob
if %user_input% equ i8 set job=startup.bat ifw now 8&&set jobname=ifw�ಥ����[�ָ���ػ�]&&call :dojob
if %user_input% equ no goto menu
goto menu

:dojob
cls
echo ִ�������С���
echo ִ��%jobname%����
for /f %%i in ('dir /b %~dp0client\') do (
echo %%iִ��%jobname%����
echo %%job%%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

:shell
echo ����ָ��:[������������format��porn]
echo �ػ�ָ��:wpeutil shutdown
echo ����ָ��:wpeutil reboot
echo ��ʽ��ָ��:format /q /x /y I:
if "%command%" == "" set /p command=�����룺
set jobname=ִ��ָ��Ϊ%command% command
for /f %%i in ('dir /b %~dp0client\') do (
echo %%iִ��%command%
echo startup.bat "%%command%%" shell| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b


:xrun
cls
echo ���ز�ִ���ļ� ��������EXE�ļ���
if "%xrunfile%" == "" set /p xrunfile=����Ҫ����ִ�е��ļ���
for /f %%i in ('dir /b %~dp0client\') do (
echo %%i����%xrunfile%
echo startup.bat xrun %xrunfile%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

:xdown
cls
echo �������ļ���X:\ �������ű������ӡ�
set /p xrunfile=����Ҫ���ص��ļ���
for /f %%i in ('dir /b %~dp0client\') do (
echo %%i����%xrunfile%
echo startup.bat xdown %xrunfile%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

::::::::::::::::Σ�յĴ��̲�������
:disk_tools
cls
echo �����пͻ�������ִ��ʲô������
echo ����"d0"��ʾ��������̷���
echo ==============================
echo ����d[n]����մ������з���
echo ==============================
echo ����0��   �������˵�
set user_input=no
set /p user_input=�����룺
if %user_input% equ d0 set diskn=0&&call :clean_disk
if %user_input% equ 0 goto menu
exit /b

:clean_disk
(
::�������pe���˳�
echo if not exist X: exit
echo ^( 
echo echo sel disk %diskn%
echo echo clean
echo ^)^|diskpart
echo exit
)>%~dp0_temp.bat
set xrunfile=_temp.bat&&call :xrun
if exist %~dp0_temp.bat del /q /f %~dp0_temp.bat
exit /b
::::::::::::::::Σ�յĴ��̲�������


:houc
echo HOU�ಥ��I:\
set command=start "" houcx86 I:\
set jobname=ִ��ָ��Ϊ%command% command
for /f %%i in ('dir /b %~dp0client\') do (
echo %%iִ��%command%
echo startup.bat "%%command%%" shell| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

:ifw
cls
echo ����1��ʲô������
echo ����2���ָ�������
echo ����3���ָ���ػ�
echo ����4, ֻ����imagew64
echo ==============================
echo ����0���������˵�
set /p user_input=IFW�ಥ��ԭ��ɺ�ִ��ʲô������:
if %user_input% equ 1 set job=startup.bat ifw now 0&&set jobname=ifw�ಥ����[�ָ���ʲô������]&&call :dojob
if %user_input% equ 2 set job=startup.bat ifw now 1&&set jobname=ifw�ಥ����[�ָ�������]&&call :dojob
if %user_input% equ 3 set job=startup.bat ifw now 8&&set jobname=ifw�ಥ����[�ָ���ػ�]&&call :dojob
if %user_input% equ 4 set command=imagew64&&goto shell
if %user_input% equ 0 call :menu



:mvclient
if not exist %~dp0client\local md %~dp0client\local
::attrib +h %~dp0client
move /y %~dp0client\*.* %~dp0client\local.
exit /b

:reclient
if not exist %~dp0client\local md %~dp0client\local
::attrib +h %~dp0client
move /y %~dp0client\local\*.* %~dp0client\
exit /b

:vncclient
cls
echo ��ǰ���߿ͻ���:
setlocal enabledelayedexpansion
set n=0
for /f %%i in ('dir /b %~dp0client\') do (
set /a n+=1
set pc!n!=%%i
@echo !n!.%%i  
)
set /p sel=��ҪԶ�̵���̨��: 
echo ѡ�� !pc%sel%!
start "" %~dp0bin\tvnviewer.exe !pc%sel%!
call :menu
exit /b 