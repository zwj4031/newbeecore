@echo off
call :iscsi_logout 192.168.11.141 3260
exit

:iscsi_login
set iscsiip=%1
set iscsiport=%2
iscsicli AddTargetPortal %iscsiip% %iscsiport%
for /f %%a in ('iscsicli ListTargets ^|find "iqn"') do (
@echo ����iscsi�������С���
start /w iscsicli LoginTarget %%a T * * * * * * * * * * * * * * * 0
if "%errorlevel%" == "0" echo �˴������Ϸ����� %%a 
)
exit /b



:iscsi_logout
set iscsiip=%1
set iscsiport=%2
for /f "tokens=3 delims=: " %%i in ('iscsicli SessionList ^|find "�Ự ID"') do iscsicli LogoutTarget %%i
iscsicli RemoveTargetPortal %iscsiip% %iscsiport%
iscsicli listtargets t 
exit /b


