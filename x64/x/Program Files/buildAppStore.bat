mode con: cols=50 lines=35
::@echo off
@taskkill /f /im Appstore.exe>nul
cls
cd /d %~dp0Appstore
@echo 更新菜单缓存....
call updater.bat
@echo 更新菜单缓存完成!
cd /d ..\..
if exist Appstore.exe del /q /f Appstore*.exe*
@echo 复制空壳文件中...
copy /y AppStore\bin\AppStore.exe Appstore.exe>nul
@echo 打包商店到空壳文件AppStore.exe...
set output=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%wimfile%
Appstore\bin\7zx64 a AppStore.exe AppStore\ >nul
copy Appstore.exe /y %USERPROFILE%\Desktop\AppStore_%output%.exe
echo 新的商店已经保存为%USERPROFILE%\Desktop\AppStore_%output%.exe
echo 生成拥有自主农副产品的软件商店制作完成！快脱下衣服使用吧!
pause

