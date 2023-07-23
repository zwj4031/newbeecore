@echo off
mode con cols=50 lines=3
title NewBeePE共享辅助脚本by:江南一根葱
rem 初始化连接用户名密码
set loginpass=
set loginname=fuck
::提取前三位方便输入
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig^|find /i "IPv4 地址 . . . . . . . . . . . . :"') do (
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
set qx=完全
goto netshare
)
if not "%1" == "" goto csnetuse

:menu
cls
echo 输入要连接的共享服务器地址: [IP地址或计算机名]
set /p smbserver=输入[回车清空]:%ip_def%
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
echo 获取到%smbserver%共享列表:
setlocal enabledelayedexpansion
set n=0
for /f "tokens=1-2 delims=- " %%a in ('net view \\%smbserver% ^|findstr /iv "共享名 命令 在"') do (
set /a n+=1
set pc!n!=%%a
@echo !n!.%%a 
)
set /p sel=你要连接到哪个共享资源?: 
echo 选中 !pc%sel%!
echo !pc%sel%!
net use * /delete /y
net use ^* \\%smbserver%\!pc%sel%! "%loginpass%" /user:%loginname%
if "%errorlevel%" == "2" (
goto pwdlogin
) else (
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
for /f "tokens=1-3 delims= " %%a in ('net use ^|find ":"') do set smbdrv=%%b
)
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "成功连接,已映射到%smbdrv%"
if exist %smbdrv%\ start "" %smbdrv%
exit

:pwdlogin
cls
set /p loginname=连接失败，请重新输入用户名:
set /p loginpass=输入密码:
net use \\%smbserver% "%loginpass%" /user:%loginname%
if "%errorlevel%" == "2" (
goto pwdlogin
) else (
goto connect
)
exit /b

:csnetuse
title=连接共享
echo 连接到 %1 
set smbserver=%1
net use * /delete /y
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "正在连到%smbserver%"
net use * %smbserver% "" /user:11
if "%errorlevel%" == "2" (
call :youlost
) else (
call :youwin
)
for /f "tokens=1-3 delims= " %%a in ('net use ^|find ":"') do set smbdrv=%%b
)
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "成功连接,已映射到%smbdrv%"
if exist %smbdrv%\ start "" %smbdrv%
exit



:netshare
mode con cols=60 lines=3
title=%qx%共享目标目录
echo 将要%qx%共享%sharedir%
echo [默认为完全共享,回车切换共享模式]
set /p sharename=输入你要共享的名称:
if "%sharename%" == "" set qx=只读&&set quanxian=read&&goto netshare
echo Y|cacls %sharedir%. /t /p everyone:f
echo Y|cacls %sharedir%*.* /t /p everyone:f
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "已%qx%共享%sharedir%为%sharename%..."
net share %sharename%=%sharedir% /grant:everyone,%quanxian% /y
exit

:youlost
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "连接失败!"
exit /b
:youwin
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 3 -text "连接成功!"
exit /b