@echo off
mode con cols=50 lines=3
title NewBeePE�������ű�by:����һ����
rem ��ʼ�������û�������
set loginpass=
set loginname=fuck
::��ȡǰ��λ��������
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig^|find /i "IPv4 ��ַ . . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b') do set myip=%%i
)
for /f "tokens=1,2,3,4 delims=." %%a in ('echo %myip%') do (
set ip1=%%a
set ip2=%%b
set ip3=%%c
)
)

set ip_def=%ip1%.%ip2%.%ip3%.
if "%1" == "netshare" (
set sharedir=%2
set quanxian=full
set qx=��ȫ
goto netshare
)
if not "%1" == "" goto csnetuse

:menu
cls
echo ����Ҫ���ӵĹ����������ַ: [IP��ַ��������]
set /p smbserver=����[�س����]:%ip_def%
if "%smbserver%" == "" set ip_def=&&goto menu
set smbserver=%ip_def%%smbserver%
net use \\%smbserver%\bucunzaidegongxiang "%loginpass%" /user:%loginname%
net use \\%smbserver% "%loginpass%" /user:%loginname%
if "%errorlevel%" == "2" (
goto pwdlogin
) else (
goto connect
)

:connect
cls
mode con cols=36 lines=26
echo ��ȡ��%smbserver%�����б�:
setlocal enabledelayedexpansion
set n=0
for /f "tokens=1-2 delims=- " %%a in ('net view \\%smbserver% ^|findstr /iv "������ ���� ��"') do (
set /a n+=1
set pc!n!=%%a
@echo !n!.%%a 
)
set /p sel=��Ҫ���ӵ��ĸ�������Դ?: 
echo ѡ�� !pc%sel%!
echo !pc%sel%!
net use * /delete /y
net use ^* \\%smbserver%\!pc%sel%! "%loginpass%" /user:%loginname%
if "%errorlevel%" == "2" (
goto pwdlogin
) else (
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
for /f "tokens=1-3 delims= " %%a in ('net use ^|find ":"') do set smbdrv=%%b
)
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "�ɹ�����,��ӳ�䵽%smbdrv%"
if exist %smbdrv%\ start "" %smbdrv%
exit

:pwdlogin
cls
set /p loginname=����ʧ�ܣ������������û���:
set /p loginpass=��������:
net use \\%smbserver% "%loginpass%" /user:%loginname%
if "%errorlevel%" == "2" (
goto pwdlogin
) else (
goto connect
)
exit /b

:csnetuse
title=���ӹ���
echo ���ӵ� %1 
set smbserver=%1
net use * /delete /y
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "��������%smbserver%"
net use * %smbserver% "" /user:11
if "%errorlevel%" == "2" (
call :youlost
) else (
call :youwin
)
for /f "tokens=1-3 delims= " %%a in ('net use ^|find ":"') do set smbdrv=%%b
)
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "�ɹ�����,��ӳ�䵽%smbdrv%"
if exist %smbdrv%\ start "" %smbdrv%
exit



:netshare
mode con cols=60 lines=3
title=%qx%����Ŀ��Ŀ¼
echo ��Ҫ%qx%����%sharedir%
echo [Ĭ��Ϊ��ȫ����,�س��л�����ģʽ]
set /p sharename=������Ҫ���������:
if "%sharename%" == "" set qx=ֻ��&&set quanxian=read&&goto netshare
echo Y|cacls %sharedir%. /t /p everyone:f
echo Y|cacls %sharedir%*.* /t /p everyone:f
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "��%qx%����%sharedir%Ϊ%sharename%..."
net share %sharename%=%sharedir% /grant:everyone,%quanxian% /y
exit

:youlost
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "����ʧ��!"
exit /b
:youwin
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "���ӳɹ�!"
exit /b