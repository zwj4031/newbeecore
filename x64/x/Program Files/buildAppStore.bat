mode con: cols=50 lines=35
::@echo off
@taskkill /f /im Appstore.exe>nul
cls
cd /d %~dp0Appstore
@echo ���²˵�����....
call updater.bat
@echo ���²˵��������!
cd /d ..\..
if exist Appstore.exe del /q /f Appstore*.exe*
@echo ���ƿտ��ļ���...
copy /y AppStore\bin\AppStore.exe Appstore.exe>nul
@echo ����̵굽�տ��ļ�AppStore.exe...
set output=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%wimfile%
Appstore\bin\7zx64 a AppStore.exe AppStore\ >nul
copy Appstore.exe /y %USERPROFILE%\Desktop\AppStore_%output%.exe
echo �µ��̵��Ѿ�����Ϊ%USERPROFILE%\Desktop\AppStore_%output%.exe
echo ����ӵ������ũ����Ʒ������̵�������ɣ��������·�ʹ�ð�!
pause

