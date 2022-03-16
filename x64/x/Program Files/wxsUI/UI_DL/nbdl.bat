cd /d "%~dp0"
set nbsoft=%2
::mode con: cols=36 lines=1 
::@echo off
call :GetWinXShell
if not "%1" == "" set app_url=%1
if "%app_url%" == "-nbapp" goto getnbsoft
if "%app_url%" == "" set nbsoft=todesk&&goto getnbsoft
if not "%2" == "" set app_name=%2
if not "%3" == "" set app_setup=%3
if not "%4" == "" set app_setup_args=%4
if not "%5" == "" set user_agent=%5
if not "%6" == "" set aria2c_args=%6

if "%app_url%" == "" set app_url=https://dldir1.qq.com/qqfile/qq/PCQQ9.5.6/QQ9.5.6.28129.exe
if "%app_name%" == "" set app_name=我的软件
if "%app_setup%" == "" set app_setup=setup.exe
if "%app_setup_args%" == "" set app_setup_args=/S
if "%user_agent%" == "" set user_agent=qq_user_agent
rem set user_agent=chrome_user_agent
if "%aria2c_args%" == "" set aria2c_args=-c -j 10 --file-allocation^=none

echo 下载地址: %app_url%
echo 软件名称:%app_name%
echo 软件包名称:%app_setup%
echo 软件包参数:%app_setup_args%
echo 伪装参数:%user_agent%
echo 下载参数:%aria2c_args%


rem set app_name=VLC
rem set user_agent=chrome_user_agent
rem set aria2c_args=-c -j 10
rem set app_setup_args=/S

%WinXShell% -ui -jcfg wxsUI\\UI_DL\\main.jcfg -app_url %app_url% -app_name %app_name% -app_setup %app_setup% -app_setup_args %app_setup_args% -aria2c_args %aria2c_args% -user_agent %user_agent% 
exit

:getnbsoft
%WinXShell% -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp %nbsoft% 
exit
:GetWinXShell
if exist WinXShell.exe set WINXSHELL=WinXShell.exe 
if exist ..\..\WinXShell.exe set WINXSHELL=..\..\WinXShell.exe
exit /b