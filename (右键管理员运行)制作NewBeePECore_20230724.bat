@echo off
cd /d "%~dp0"
if not "x%TRUSTEDINSTALLER%"=="x1" (
    set TRUSTEDINSTALLER=1
    "%~dp0data\tools\NSudo.exe" -U:T -P:E -Wait -UseCurrentConsole cmd /c "%~0"
    ::pause
     exit
    goto :EOF
)
echo .���ڳ�ʼ��....
echo ���ע������õ�Ԫ����
for %%a in (os-drv os-soft os-sys pe-drv pe-sys pe-soft pe-def boot-drv boot-sys boot-soft boot-def) do (
set item=%%a
call :checkitem %item%
)
goto startplay

:checkitem
reg query hklm |find "%item%"
if "%errorlevel%" == "0" echo ���ڲ�����ֵ%item%, ж��.&&reg unload hklm\%item%>nul
if "%errorlevel%" == "1" echo δ�������
exit /b

:startplay
echo �ؽ������⡭��
%~dp0\x64\x\Windows\System32\driverindexer.exe create-index %~dp0x64\x\Windows\System32\drivers.7z drivers.index
cls
title WindowsPE  --  2009
:: /c�����б� /m��ʾ���� /dĬ��ѡ�� /t�ȴ�����   /d ����� /tͬʱ����
echo �汾ѡ��:
echo 1.[Win10 20h2-22h2] [����ע��� WinXShell] 
echo 2.[Win11 22h2] [����ע��� WinXShell]  
echo 3.[WinServer 2022] [ѡ��4] [����ע��� WinXShell]  
echo 4.[Windows8.1] [����ע��� WinXShell]  
echo 8.[RAW]  [����ע��� ԭ�����] 
echo 9.[Extract_Features]  [������ѹ�����ļ�] 
::choice  /c 123456789 /m "��ѡ��ISO�汾 5����Զ�ѡ��1" /d 1 /t 5
set La=1
set /p La= �������ְ��س���(ֱ�ӻس�������Ĭ��1��
::�û�ѡ��Ľ���ᰴ��Ŀ������֣���1��ʼ��������errorlevel������&&goto nex
if %La%==1 set filelist=newbee&&set winver=win10&&echo ��ѡ����1&&goto nex
if %La%==2 set filelist=newbee&&set winver=win11&&echo ��ѡ����2&&goto nex
if %La%==3 set filelist=newbee&&set winver=Server2022&&echo ��ѡ����3&&goto nex
if %La%==4 set filelist=newbee&&set winver=win8&&echo ��ѡ����4&&goto nex
if %La%==8 set filelist=newbee&&set winver=raw&&echo ��ѡ����8&&goto nex
if %La%==9 set winver=soft&&echo ��ѡ����9&&goto nex
goto startplay
:nex
set /p cddir=������������̷���
if not exist %cddir%:\sources (echo ��%cddir%:\��û�з�����Ҫ���ļ�&&goto startplay) else (goto nextplay)
if /i "%cddir%"=="" (echo û����������&&goto startplay) else (goto nextplay)


:nextplay
rd /s /Q "%~dp0data\winpe"
md "%~dp0data\winpe"
echo ������ʱĿ¼%~dp0data\temp
if not exist "%~dp0data\temp" md "%~dp0data\temp"
set bootdir=%cddir%:\sources\boot.wim
if exist "%cddir%:\sources\install.wim" (
set wimdir=%cddir%:\sources\install.wim
) else (
if exist "%cddir%:\sources\install.esd" (
set wimdir=%cddir%:\sources\install.esd
) else (
goto nex
))
echo ��������������������������������������������������������
"%~dp0data\tools\wimlib-imagex.exe" info  %wimdir% |find "Image Count:" >vers.txt
set /p count=< vers.txt
set count=%count:~16%
del /f /q vers.txt 1>nul 2>nul
for /L %%i in (1,1,%count%) do (
"%~dp0data\tools\imagex.exe" /xml /info %wimdir% %%i  >tmp.txt
for %%a in (tmp.txt) do (
"%~dp0data\tools\iconv" -c -f utf-8 -t gb2312 "%%a" >"gb%%a"
move /y "gb%%a" "%%a">nul
)
type tmp.txt | find "<NAME>" >vers.txt
for /f "delims=" %%a in ('type vers.txt') do (
	set "str=%%a"
	setlocal enableDelayedExpansion
	if "!str:NAME=!" neq "!str!" set "str=!str:*<NAME>=!"
	for /f "delims=<" %%b in ("!str!") do echo; %%i - %%b
	endlocal
))
del /f /q tmp.txt 1>nul 2>nul
del /f /q vers.txt 1>nul 2>nul
echo ��������������������������������������������������������


set /p inwiminfo=����install�־�ţ�
if /i "%inwiminfo%"=="" (echo û����������&&goto nextplay) else (goto peplay)

:peplay
::��ȡ�����ļ�
if "%winver%" == "soft" (
call :features
exit
)

if "%winver%" == "win11" (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win11.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo win11 ʹ��StateRepository����
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\StateRepository.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo win11 ֧��mtp
rem "%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\mtp.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo .net֧��
rem "%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\NetFramework.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)



if "%winver%" == "Server2022" (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\Server2022.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)



if "%winver%" == "win8" (
set drvtxt=pe-drv-win8.txt
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win8.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\boot_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)


title ��ȡWINPE����ļ�
echo ��ȡWINPE����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\install_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\boot_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

for /f %%a in ('dir /ad /b %~dp0data\winpe\Windows\System32\DriverStore\FileRepository') do (echo %%a >>%~dp0data\temp\pe-drv-winxshell.txt)

if "%winver%" == "raw" (
set drvtxt=pe-drv-all.txt
echo RAWģʽ��ʹ������ע���! ԭ�����
copy /y "%~dp0x64\x\Program Files\pecmd_explorer.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\software --dest-dir="%~dp0data\winpe\windows\system32\config" --nullglob --no-acls
echo RAWģʽ��ʹ�������ļ��б�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win11.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win11catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win8.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\win8catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo RAWģʽ��ʹ������explorer�б�.net����������ӡ����ie
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\explorer.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\NetFramework.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\bluetooth.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\printer.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\admin.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\ie.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo admin֧��
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\admin.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\admin_lite.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo RAWģʽ��ʹ��raw�б�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\raw.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo RAWģʽ,��ȫmun
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.dll') do (
echo \Windows\SystemResources\%%a.mun >>%~dp0data\temp\pe-mui.txt
)
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.exe') do (
echo \Windows\SystemResources\%%a.mun >>%~dp0data\temp\pe-mui.txt
)
echo RAWģʽ��ʹ�þɰ���Դ������
copy "%~dp0x64\exp\explorer.exe" "%~dp0data\winpe\windows\explorer.exe" /Y
) else (
echo %winver%ģʽ��ʹ��%winver%ע���! WinXshell���
set drvtxt=pe-drv.txt
copy /y "%~dp0x64\x\Program Files\pecmd_winxshell.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
call :minireg
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\software%winver%.7z" -y -o"%~dp0data\winpe\windows\system32\config"
)




echo ��ѹvss��������ļ�
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\vss.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹWordpad����ļ�
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\wordpad.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo ��ѹCamera����ͷ����ļ�
rem "%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\camera.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹraspppoe��������ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\raspppoe.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹnetsh����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\netsh.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹusb����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\usbinf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹCatRoot����ļ�

if "%winver%" == "win8" (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\%winver%catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\features\%winver%catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
) else (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\%winver%catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)


echo ��ѹinstall.wimע���Ԫ
for %%a in (default software system Drivers COMPONENTS) do (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\%%a --dest-dir="%~dp0data\temp\config" --nullglob --no-acls
)

echo ��ѹboot.wimע���Ԫ
for %%a in (default software system Drivers COMPONENTS) do (
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2  \Windows\System32\config\%%a --dest-dir="%~dp0data\temp\bootconfig" --nullglob --no-acls
)

call :loadreg

echo Dism��ӳ��������
rem ���Դ���pe����cab
reg copy "hklm\boot-soft\Microsoft\Windows\CurrentVersion\Component Based Servicing" "hklm\pe-soft\Microsoft\Windows\CurrentVersion\Component Based Servicing" /S /F

rem ����ϵͳ����cab
rem reg copy "hklm\os-soft\Microsoft\Windows\CurrentVersion\Component Based Servicing" "hklm\pe-soft\Microsoft\Windows\CurrentVersion\Component Based Servicing" /S /F

echo Y|choice /c:yn /m:"�Ƿ���ӵ�����OEM������"
::echo N |choice /c:yn /m:"�Ƿ���ӵ�����OEM������"
if %errorlevel%==1 goto ADDRV
if %errorlevel%==2 goto UINSTALL
:ADDRV
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\Dism_AddDrv.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

set drvfiles=%~dp0data\drivers
::set /p drvfiles=���������OEM�����ļ��У�
if /i "%drvfiles%"=="" (echo û�����������OEM�����ļ���&&goto ADDRV) else (goto DRVPLAY)
:DRVPLAY
call :unloadreg
rem ���Դ���pe����cab
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\add_driverf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\add_drivers.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

rem ����ϵͳ����cab
rem "%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\add_driverf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
rem "%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\add_drivers.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
DISM.exe /Image:"%~dp0data\winpe" /Add-Driver /Driver:"%drvfiles%" /recurse /ForceUnsigned

echo ���¼���ע���
call :loadreg
rem �Ƴ���ӳ��������������ӵ���ʱ�ļ�
for /f "tokens=*" %%c in (%~dp0data\files\add_driverf.txt) do (
del %~dp0data\winpe\%%c
)
for /f "tokens=*" %%c in (%~dp0data\files\add_drivers.txt) do (
for /d %%f in (%~dp0data\winpe\%%c) do (
rd /s /Q "%%f"
)
)
reg delete "hklm\pe-soft\Microsoft\Windows\CurrentVersion\Component Based Servicing" /f 
SET drvfiles=


::echo ����������browser����
::reg import "%~dp0data\reg\pe-sys-browser.reg"
::reg import "%~dp0data\reg\pe-soft-svchost.reg"


echo ����SMBV1Э��
for /f "delims=" %%i in ('dir /b "%~dp0data\winpe\Windows\WinSxS\*_microsoft-windows-smb10-minirdr_*"') do (
echo extracting %%i\mrxsmb10.sys
copy /y "%~dp0data\winpe\Windows\WinSxS\%%i\mrxsmb10.sys" "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys"
echo ����mrxsmb10.sys
%~dp0data\tools\sxsexp64.exe "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys" "%~dp0data\winpe\windows\system32\drivers\mrxsmb10.sys"
del /f /q "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys"
rd /s /q "%~dp0data\winpe\Windows\WinSxS\%%i"
)


echo ����Browser���������ַ���smbv1.0ר��
::ȡ��
goto addmui
for /f "delims=" %%i in ('dir /b "%~dp0data\winpe\Windows\WinSxS\amd64_microsoft-windows-browserservice_*"') do (
echo extracting %%i\browser.dll
copy /y "%~dp0data\winpe\Windows\WinSxS\%%i\browser.dll" "%~dp0data\winpe\Windows\WinSxS\browser.dll"
echo ����browser.dll
%~dp0data\tools\sxsexp64.exe "%~dp0data\winpe\Windows\WinSxS\browser.dll" "%~dp0data\winpe\windows\system32\browser.dll"
del /f /q "%~dp0data\winpe\Windows\WinSxS\browser.dll"
rd /s /q "%~dp0data\winpe\Windows\WinSxS\%%i"
)

:addmui
echo ��ȫdll.mui exe.mui
if exist %~dp0data\temp\pe-mui.txt del /f /q %~dp0data\temp\pe-mui.txt
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.dll') do (
echo \Windows\System32\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.exe') do (
echo \Windows\System32\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)
echo ��ȫdrivers-sys.mui
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\drivers\*.sys') do (
echo \Windows\System32\drivers\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)


"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-mui.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ȫloc
::filerepository
dir /b /s %~dp0data\winpe\windows\system32\DriverStore\filerepository\*.inf>%~dp0data\temp\pe-inf.txt
for /f "tokens=*" %%a in (%~dp0data\temp\pe-inf.txt) do echo \windows\system32\DriverStore\zh-CN\%%a_loc >>%~dp0data\temp\pe-loc.txt
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-loc.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
::inf
for /f %%a in ('dir /b %~dp0data\winpe\windows\inf\*.inf') do (
echo \windows\system32\DriverStore\zh-CN\%%a_loc>>%~dp0data\temp\pe-inf-loc.txt
)
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-inf-loc.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls



echo ���ƾ��Ա�Ҫ��softwareע���PE
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-winxshell-mini.txt) do (
echo %%e
reg query "hklm\os-soft\%%e"1>nul 2>nul
if errorlevel 0 echo ����"hklm\os-soft\%%e"&&reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F

)



title ���Ʊ�Ҫ��softwareע���PE
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-winxshell.txt) do (
echo %%e
reg query "hklm\os-soft\%%e"1>nul 2>nul
if errorlevel 0 echo ����"hklm\os-soft\%%e"&&reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F

)

title  ���ư汾����б��ļ�
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-%winver%.txt) do (
echo %%e
reg query "hklm\os-soft\%%e"1>nul 2>nul
if errorlevel 0 echo ����"hklm\os-soft\%%e"&&reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F
)

title ����ԭ���ǲ����softwareע���PE

for /f "tokens=*" %%e in (%~dp0data\reg\fix_soft_20221001.txt) do (
echo %%e
reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F
)



title  ����pppoe������ص�softwareע���PE
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-raspppoe.txt) do (
echo %%e
reg query "hklm\pe-soft\%%e"1>nul 2>nul
if errorlevel 0 echo ����"hklm\os-soft\%%e"&&reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F
)

for /f "tokens=*" %%t in (%~dp0data\reg\pe+soft.txt) do (
echo %%t
reg copy "hklm\os-soft\%%t" "hklm\pe-soft\%%t" /F
)


title  ����.Net֧�����ע���PE
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^"FontCache*^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^".NET^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)


title  ���Ʊ�Ҫ��systemע���PE
for /f "tokens=*" %%c in (%~dp0data\reg\pe-sys-winxshell.txt) do (
echo %%c
reg copy "hklm\os-sys\%%c" "hklm\pe-sys\%%c" /S /F
)

title  ���ư汾��ص�systemע���PE
for /f "tokens=*" %%c in (%~dp0data\reg\pe-sys-%winver%.txt) do (
echo %%c
reg copy "hklm\os-sys\%%c" "hklm\pe-sys\%%c" /S /F
)

title  ���Ʊ�Ҫ��DRIVERSע���PE 
for %%d in (netnwifi wpdmtp netrndis rndiscmp wceisvista display basicdisplay dc1-controller xboxgipsynthetic xboxgip xinputhid xusb22 monitor c_monitor) do (
call :AddDriver %%d
)

title  �����win8���ٸ���
if "%winver%" == "win8" (
for %%d in (displayoverride hdaudio hdaudss) do (
call :AddDriver %%d
) 
)

title  ����ע���
for %%a in (pe-diy.reg pe-sys-xfs_disk pe-def-winxshell.reg pe-sys-winxshell.reg pe-soft-winxshell.reg pe-soft-vc.reg pe-soft-hfs.reg pe-drv-winxshell.reg pe-soft-bluetooth.reg pe-soft-%winver%.reg pe-sys-%winver%.reg) do (
echo ���ڵ���ע���%%a&&reg import "%~dp0data\reg\%%a"
)


title  ����VC���п����ע���PE
for /f "tokens=1-8 delims=^\" %%a in ('reg query HKLM\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\ ^|findstr ^"microsoft.vc[0-9]0^"') do (
echo %%h
reg copy "hklm\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" "hklm\pe-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" /S /F
)






rem �����rawģʽ��ʹ�������������ݿ�
for /f "tokens=*" %%e in (%~dp0data\reg\%drvtxt%) do (
echo %%e
reg copy "hklm\os-drv\%%e" "hklm\pe-drv\%%e" /S /F
)

for /d %%f in ("%~dp0data\winpe\windows\system32\DriverStore\FileRepository\netrndis.inf*") do (
echo DriverDatabase\DriverPackages\%%~nf%%~xf
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%~nf%%~xf" "hklm\pe-drv\DriverDatabase\DriverPackages\%%~nf%%~xf" /S /F
)
for /d %%g in ("%~dp0data\winpe\windows\system32\DriverStore\FileRepository\rndiscmp.inf*") do (
echo DriverDatabase\DriverPackages\%%~ng%%~xg
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%~ng%%~xg" "hklm\pe-drv\DriverDatabase\DriverPackages\%%~ng%%~xg" /S /F
)
for /d %%g in ("%~dp0data\winpe\windows\system32\DriverStore\FileRepository\wceisvista.inf*") do (
echo DriverDatabase\DriverPackages\%%~ng%%~xg
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%~ng%%~xg" "hklm\pe-drv\DriverDatabase\DriverPackages\%%~ng%%~xg" /S /F
)
reg import "%~dp0data\reg\pe-drv.reg"


echo ɾ����Դ�������������
reg add hklm\pe-soft\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder /v Attributes /t REG_DWORD /d 0xb0940064 /F

echo ����ϵͳ�Դ�����ͼ���ӳ��
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer" /f /v "MapNetDrvBtn" /t REG_DWORD /d 0
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v "MapNetDrvBtn" /t REG_DWORD /d 0
::����ϵͳ�Դ�����ͼ���ӳ����Ч
reg add "HKLM\PE-DEF\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v "NoNetConnectDisconnect" /t REG_DWORD /d 1
echo �滻c/dΪx��ɾ��Interactive User
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft -y C:\ -y -r X:\
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft -y D:\ -y -r X:\
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft\Classes\AppID -y  Interactive User -r
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo �޸�һЩ���������ʾΪ�ڿڿڵ��������
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent Bold" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent Bold,0" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent,0" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Helv" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Helvetica" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Tms Rmn" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "FangSong_GB2312" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "KaiTi_GB2312" reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent Bold" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent Bold,0" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arabic Transparent,0" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Arial TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Courier New TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Helv" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Helvetica" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman Baltic,186" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman CE,238" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman CYR,204" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman Greek,161" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Times New Roman TUR,162" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "Tms Rmn" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "FangSong_GB2312" 
reg delete "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /f /v "KaiTi_GB2312" 


echo д��imdiskע���
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /f /ve /t REG_SZ /d "���ص� ImDisk �������"
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /f /v "Icon" /t REG_SZ /d "imdisk.cpl,0"
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile\command" /f /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_MountFile %%L"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /f /ve /t REG_SZ /d "�������ݱ���Ϊӳ���ļ�"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /f /v "Icon" /t REG_SZ /d "imdisk.cpl,0"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage\command" /f /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_SaveImageFile %%L"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount" /f /ve /t REG_SZ /d "ж�� ImDisk �������"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount" /f /v "Icon" /t REG_SZ /d "imdisk.cpl,0"
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount\command" /f /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_RemoveDevice %%L"
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "Description" /t REG_SZ /d "Driver for physical memory allocation through AWE"
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "DisplayName" /t REG_SZ /d "AWE Memory Allocation Driver"
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "ErrorControl" /t REG_DWORD /d 0
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\system32\DRIVERS\awealloc.sys"
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "Start" /t REG_DWORD /d 2
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /f /v "Type" /t REG_DWORD /d 1
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "Description" /t REG_SZ /d "Client driver for ImDisk devio proxy mode"
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "DisplayName" /t REG_SZ /d "DevIO Client Driver"
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "ErrorControl" /t REG_DWORD /d 0
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\system32\DRIVERS\deviodrv.sys"
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "Start" /t REG_DWORD /d 2
reg add "HKLM\PE-SYS\ControlSet001\Services\DevIoDrv" /f /v "Type" /t REG_DWORD /d 1
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "Description" /t REG_SZ /d "Disk emulation driver"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "DisplayName" /t REG_SZ /d "ImDisk Virtual Disk Driver"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "ErrorControl" /t REG_DWORD /d 0
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\system32\DRIVERS\imdisk.sys"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "Start" /t REG_DWORD /d 2
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /f /v "Type" /t REG_DWORD /d 1
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "Description" /t REG_SZ /d "Helper service for ImDisk Virtual Disk Driver."
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "DisplayName" /t REG_SZ /d "ImDisk Virtual Disk Driver Helper"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "ErrorControl" /t REG_DWORD /d 0
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "ImagePath" /t REG_EXPAND_SZ /d "%%SystemRoot%%\system32\imdsksvc.exe"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "ObjectName" /t REG_SZ /d "LocalSystem"
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "Start" /t REG_DWORD /d 2
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /f /v "Type" /t REG_DWORD /d 16

rem // Sound Volume Bar
reg add hklm\pe-soft\Microsoft\Windows NT\CurrentVersion\MTCUVC /v EnableMtcUvc /t REG_DWORD /d 0 /f

echo �޸�ע����ر�UAC ��Ҫseclogon����!
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t reg_dword /d 0 /F 
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t reg_dword /d 0 /F 
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t reg_dword /d 0 /F 

echo �޸�ע���,������������
reg add HKLM\PE-SYS\ControlSet001\Control\Lsa /f /v everyoneincludesanonymous /t REG_DWORD /d 1
reg add HKLM\PE-SYS\ControlSet001\Services\LanmanServer\Parameters /f /v "RestrictNullSessAccess /t REG_DWORD /d 0

echo ����Ҽ���ʾ����
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\��ʾ����\command /d "WinXShell.exe ms-settings:display" /f
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\��ʾ���� /f /v "Position" /t REG_SZ /d "Bottom"
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\��ʾ���� /f /v "icon" /t REG_SZ /d "%%programfiles%%\winxshell.exe,31"

echo ͨ���޸�ע���ʵ�ֽ���StateRepository����
reg add "HKLM\PE-SYS\ControlSet001\Services\StateRepository" /f /v "Start" /t REG_DWORD /d 4

echo ɾ��΢�������ʾ����
set DrvFolder=
for /f "tokens=3" %%i in ('reg query HKLM\pe-drv\DriverDatabase\DriverInfFiles\display.inf /v Active') do set DrvFolder=%%i
echo Update Configurations:%DrvFolder%
echo "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA"
::reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA" /v service vi /f
::ȫ����ʱ��Ҫ����reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%" /v version /F
set DrvFolder=

echo ����msi����
reg add hklm\pe-sys\ControlSet001\Services\TrustedInstaller /v Start /t REG_DWORD /d 3 /f

echo bitlockerע���
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v AppliesTo /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v DefaultAppliesTo /f
reg add HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v Icon /d bdeunlock.exe /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\encrypt-bde-elev /f

echo ����iscsi����������������
:::reg delete HKLM\PE-SOFT\Microsoft\Windows\CurrentVersion\WINEVT /f
rem ��ֻ��Ҫ��\Windows\System32\winevt\logs\System.evtx����ļ�����

echo ���½��Ȳ������
reg add "HKLM\PE-DEF\Software\HotSwap!" /v DFlags /t REG_DWORD /d 0x10000003 /f

echo ip�߼�ɨ�蹤��������ʾ������
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "locale" /t REG_SZ /d "zh_cn"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "show_alive" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "show_dead" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_radmin" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_shares" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_http" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_https" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_ftp" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_netbios" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_username" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "high_accuracy" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "thread_count" /t REG_DWORD /d 256
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "ssh_client" /t REG_SZ /d "plink"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_rdp" /t REG_SZ /d "true"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "scan_datetimezone" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "ftp_client" /t REG_SZ /d ""
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "http_client" /t REG_SZ /d ""
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "telnet_client" /t REG_SZ /d ""
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "alternate_bg_in_tables" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner" /f /v "show_unknown" /t REG_SZ /d "false"
reg add "HKLM\PE-DEF\Software\famatech\advanced_ip_scanner\Settings" /f /v "check_updates" /t REG_SZ /d "false"

echo LUA�ű�֧��
reg add "HKLM\PE-SOFT\Classes\.lua" /f /ve /t REG_SZ /d "luafile"
reg add "HKLM\PE-SOFT\Classes\luafile" /f /ve /t REG_SZ /d "Windows luach File"
reg add "HKLM\PE-SOFT\Classes\luafile" /f /v "EditFlags" /t REG_BINARY /d 30040000
reg add "HKLM\PE-SOFT\Classes\luafile\DefaultIcon" /f /ve /t REG_EXPAND_SZ /d "X:\Windows\System32\ico\lua.ico"
reg add "HKLM\PE-SOFT\Classes\luafile\shell\edit\command" /f /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\NOTEPAD.EXE %%1"
reg add "HKLM\PE-SOFT\Classes\luafile\shell\open\command" /f /ve /t REG_SZ /d "X:\Program Files\WinXShell.exe  -script \"%%1\""

echo �ر�chrome��edge����ɳ�䡢��ȡȨ��
reg add "HKLM\PE-SOFT\Policies\Google\Chrome" /v "AudioSandboxEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\PE-SOFT\Policies\Microsoft\Edge" /v "AudioSandboxEnabled" /t REG_DWORD /d 0 /f
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SOFT\Policies" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SOFT" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SYS" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-DRV" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-def" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SOFT\Microsoft\Windows\CurrentVersion\MMDevices" -ot reg -actn ace -ace "n:Everyone;p:full"

echo ���Ժ쾯������
reg add "HKLM\PE-DEF\software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "D:\\RA2\\ra2.exe" /t REG_SZ /d "WIN98"
reg add "HKLM\PE-DEF\software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f /v "D:\\RA2\\YURI.exe" /t REG_SZ /d "WIN98"
echo ����·��ת������
reg add "hklm\pe-sys\ControlSet001\Services\Tcpip\Parameters" /v IPEnableRouter /D 1 /f
echo ָ��δ֪���ʹ򿪷�ʽ
reg add "HKLM\PE-SOFT\Classes\Unknown\shell\openas\command" /f /ve /t REG_EXPAND_SZ /d "X:\progra~1\WinXShell.exe -ui -jcfg X:\progra~1\wxsUI\UI_AppStore\main.jcfg -file \"%%1\""
reg delete "HKLM\PE-SOFT\Classes\Unknown\shell\openas\command" /f /v "DelegateExecute" 
echo wimfltmgr����
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "Type" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "Start" /t REG_DWORD /d 3
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "ErrorControl" /t REG_DWORD /d 1
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "Tag" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "ImagePath" /t REG_EXPAND_SZ /d "system32\DRIVERS\wimfltr.sys"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "DisplayName" /t REG_SZ /d "@wimfltr.inf,%%WimFltrServiceName%%;WimFltr"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "Group" /t REG_SZ /d "FSFilter Compression"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "DependOnService" /t REG_MULTI_SZ /d "FltMgr"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "Description" /t REG_SZ /d "@wimfltr.inf,%%WimFltrServiceDescription%%;Windows Image Mini-Filter Driver"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr" /f /v "DebugFlags" /t REG_DWORD /d 1
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr\Instances" /f /v "DefaultInstance" /t REG_SZ /d "WimFltr Instance"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr\Instances\WimFltr Instance" /f /v "Altitude" /t REG_SZ /d "170500"
reg add "HKLM\pe-sys\ControlSet001\Services\WimFltr\Instances\WimFltr Instance" /f /v "Flags" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "EnabledOnAllSkus" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "DebugFlags" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "DisplayName" /t REG_SZ /d ""
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "ErrorControl" /t REG_DWORD /d 1
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "Group" /t REG_SZ /d "FSFilter System Recovery"
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "ImagePath" /t REG_EXPAND_SZ /d "system32\drivers\fbwf.sys"
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "Start" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "Tag" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "Type" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF" /f /v "DependOnService" /t REG_MULTI_SZ /d "FltMgr"
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF\Instances" /f /v "DefaultInstance" /t REG_SZ /d "Fbwf Instance"
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF\Instances\Fbwf Instance" /f /v "Altitude" /t REG_SZ /d "226000"
reg add "HKLM\pe-sys\ControlSet001\Services\FBWF\Instances\Fbwf Instance" /f /v "Flags" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "DebugFlags" /t REG_DWORD /d 0
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "Description" /t REG_SZ /d "@%%SystemRoot%%\system32\drivers\wimmount.sys,-102"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "DisplayName" /t REG_SZ /d "@%%SystemRoot%%\system32\drivers\wimmount.sys,-101"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "ErrorControl" /t REG_DWORD /d 1
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "Group" /t REG_SZ /d "FSFilter Infrastructure"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "ImagePath" /t REG_EXPAND_SZ /d "system32\drivers\wimmount.sys"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "Start" /t REG_DWORD /d 3
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "SupportedFeatures" /t REG_DWORD /d 3
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "Tag" /t REG_DWORD /d 1
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount" /f /v "Type" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount\Instances" /f /v "DefaultInstance" /t REG_SZ /d "WIMMount"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount\Instances\WIMMount" /f /v "Altitude" /t REG_SZ /d "180700"
reg add "HKLM\pe-sys\ControlSet001\Services\WIMMount\Instances\WIMMount" /f /v "Flags" /t REG_DWORD /d 0

  rem use yamingw's ring0 kernel driver
echo MTP_support
::reg add HKLM\pe-sys\ControlSet001\Services\mtpHelper /v ImagePath /t REG_EXPAND_SZ /d "System32\Drivers\mtpHelper.sys" /f
::reg add HKLM\pe-sys\ControlSet001\Services\mtpHelper /v Start /t REG_DWORD /d 1 /f
::reg add HKLM\pe-sys\ControlSet001\Services\mtpHelper /v ErrorControl /t REG_DWORD /d 0 /f
::reg add HKLM\pe-sys\ControlSet001\Services\mtpHelper /v Type /t REG_DWORD /d 1 /f
::reg add HKLM\pe-sys\ControlSet001\Services\mtpHelper /v DisplayName /t REG_SZ /d "mtpHelper" /f
reg add "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs /d mtpHelper.dll /f
reg add "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\Windows" /v LoadAppInit_DLLs /t REG_DWORD /d 1 /f
reg add "HKLM\pe-soft\Microsoft\Windows NT\CurrentVersion\Windows" /v RequireSignedAppInit_DLLs /t REG_DWORD /d 0 /f


rem Server2022_Audio
reg add "HKLM\pe-sys\ControlSet001\Services\AudioEndpointBuilder" /f /v "Start" /t REG_DWORD /d 2
reg add "HKLM\pe-sys\ControlSet001\Services\Audiosrv" /f /v "Start" /t REG_DWORD /d 2

rem ����ͼ������ʾ���������
reg delete "HKLM\pe-soft\Classes\AppID\{AB8902B4-09CA-4BB6-B78D-A8F59079A8D5}" /f 
rem ����lua�ļ�Ԥ��(winxshellΪ�ļ�������ʱ)
reg add "HKLM\pe-soft\Classes\.lua\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}" /f /ve /t REG_SZ /d "{1531d583-8375-4d3f-b5fb-d23bbd169f22}"
rem psd֮��������ļ�Ԥ��
reg add "HKLM\pe-soft\Classes\.psd\ShellEx\{E357FCCD-A995-4576-B01F-234630154E96}" /f /ve /t REG_SZ /d "{4A34B3E3-F50E-4FF6-8979-7E4176466FF2}"
reg add "HKLM\pe-soft\Classes\CLSID\{4A34B3E3-F50E-4FF6-8979-7E4176466FF2}\InprocServer32" /f /ve /t REG_SZ /d "X:\Program Files\SageThumbs\64\SageThumbs.dll"
reg add "HKLM\pe-soft\Classes\SageThumbsImage.psd\ShellEx\IconHandler" /f /ve /t REG_SZ /d "{4A34B3E3-F50E-4FF6-8979-7E4176466FF2}"
rem win8.1�޸�net useӳ������ӱ��������
reg add "HKLM\pe-sys\ControlSet001\Control\Lsa" /v DisableDomainCreds /t REG_DWORD /d 1 /f
rem Ŀ¼����.url�ļ��ᱨ�������
reg delete "HKLM\PE-SOFT\Classes\.URL" /f 
rem ����dism++�״δ�ʱ�ķ�������
reg add "HKLM\PE-SYS\Setup" /f /v "WorkGUID" /t REG_BINARY /d 4fed002f6b75df419a9d1e7535f7ffc7
rem ��Ӳ��԰�NTQQ֧��
reg add "HKLM\PE-SYS\ControlSet001\Control\Session Manager\Environment" /f /v "AppData" /t REG_EXPAND_SZ /d "%%SystemDrive%%\Users\Default\AppData\Roaming"

:::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
call :unloadreg
goto UINSTALL

:UINSTALL
echo ��ȡWINPE�ļ�������Ȩ
takeown /f "%~dp0data\winpe" /r /d y 1>nul
cacls "%~dp0data\winpe" /T /E /G Everyone:F 1>nul
takeown /f "%~dp0x64" /r /d y 1>nul
cacls "%~dp0x64" /T /E /G Everyone:F 1>nul

echo ѹ��ע������õ�Ԫ
"%~dp0data\tools\ru.exe" -accepteula -h "%~dp0data\winpe\Windows\System32\config\SOFTWARE" hklm\soft
"%~dp0data\tools\ru.exe" -accepteula -h "%~dp0data\winpe\Windows\System32\config\SYSTEM" hklm\sys

echo �ƽ�USB���������ļ�
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll" -s u:SystemSetupInProgress -r u:DisableDeviceSetupMgr

echo �ƽ�����״ָ̬ʾ��
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\netprofmsvc.dll" -s u:SystemSetupInProgress -r u:DisableNetworkListMgr

rem update spoolsv.exe binary
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\spoolsv.exe" -s u:SystemSetupInProgress -r u:DisableSpoolsvInWinPE
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\spoolsv.exe" -s "BA C0 D4 01 00 48" -r "BA E8 03 00 00 48"

rem Patch Windows.UI.CredDialogController.dll to use the Credentials Window than Credentials Console
rem M.i.n.i.N.T => N.i.n.i.N.T
rem %~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\Windows.UI.CredDialogController.dll" -s u:MiniNT -r u:NiniNT
 
 rem DsmSvc Patch Feature
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll" -s u:SystemSetupInProgress -r u:DisableDeviceSetupMgr
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll" -s "81 FE 20 03 00 00" -r "81 FE 02 00 00 00"

echo �ƽ�System���ܽ�
if "%winver%" == "win11" (
%~dp0data\tools\binmay -u  "%~dp0data\winpe\Windows\System32\AudioSrvPolicyManager.dll" -s "83 FB 01 0F 84 92 00 00 00" -r "83 FB 01 E9 93 00 00 00 00"
rem >900
%~dp0data\tools\binmay -u  "%~dp0data\winpe\Windows\System32\AudioSrvPolicyManager.dll" -s "83 FF 01 74 FF" -S "FF FF FF FF 00" -r "83 FE 01 EB FF" -R "FF FF FF FF 00"
%~dp0data\tools\binmay -u  "%~dp0data\winpe\Windows\System32\AudioSrvPolicyManager.dll" -s "83 FE 01 74 FF" -S "FF FF FF FF 00" -r "83 FE 01 EB FF" -R "FF FF FF FF 00"
)
echo ɾ��dll�����ļ�
del "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll.org"

echo ����һ��DRIVERS��ipxefm�ļ�����mini.wimʹ��
if not exist %~dp0x64\x\ipxefm\mini\Windows\System32\config md %~dp0x64\x\ipxefm\mini\Windows\System32\config
copy /y "%~dp0data\winpe\Windows\System32\config\DRIVERS" %~dp0x64\x\ipxefm\mini\Windows\System32\config\DRIVERS
echo ����clientĿ¼��ipxefm
mkdir %~dp0x64\x\ipxefm\client
mkdir %~dp0data\winpe\Windows\WinSxS\Catalogs
echo ɾ�������ע�����ʱ�ļ�
del /f /q /ah "%~dp0data\winpe\Windows\System32\config\*.*"

echo ��ѹWINPEԤ�����ļ�
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePE_winxshell.dll" -y -o"%~dp0data\winpe"
::"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\onePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\pe-audio.7z" -y -o"%~dp0data\winpe"

if "%winver%" == "raw" (
echo RAWģʽ������ʹ��ʹ������explorer�б�.net������
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\explorer.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo RAWģʽ��ʹ�þɰ���Դ������
copy "%~dp0x64\exp\explorer.exe" "%~dp0data\winpe\windows\explorer.exe" /Y
) else (
echo ��������
)

echo �ƽ�Drvinst.exe
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\DRVINST%winver%.7z" -y -o"%~dp0data\winpe"

echo ��ѹDism�ļ�
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\dism.7z" -y -o"%~dp0data\winpe"
goto makeiso

:makewifidrivers
echo �ͷ�ϵͳ�Դ���������
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\netdrv.txt" --dest-dir="%~dp0data\temp" --nullglob --no-acls

echo ��������������
"%~dp0data\tools\DriverIndexer.exe" classify-driver "%~dp0data\temp\Windows\System32\DriverStore\FileRepository"

echo ������������������
"%~dp0data\tools\DriverIndexer.exe" create-index "%~dp0data\temp\Windows\System32\DriverStore\FileRepository"
cls
echo ѹ������������
"%~dp0data\tools\7z.exe" a "%~dp0data\winpe\Program Files\wifidrivers.7z" "%~dp0data\temp\Windows\System32\DriverStore\*"


:makeiso
echo ��ѹISO�����ļ���Ϊ����ISO������׼��
%~dp0data\tools\7z.exe x %bootdir% -y -o%~dp0data\temp 2\windows\boot
xcopy "%~dp0data\temp\2\windows\boot\pcat\bootmgr" "%~dp0data\temp\iso\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\bcd" "%~dp0data\temp\iso\efi\microsoft\boot\" /F /Y /S /H /R
rem uefi�¿ɵ��ֱ�������
md "%~dp0data\temp\iso\efi\microsoft\boot\Fonts"
xcopy "%~dp0data\temp\2\windows\boot\Fonts\wgl4_boot.ttf" "%~dp0data\temp\iso\efi\microsoft\boot\Fonts" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\boot.sdi" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
::xcopy "%~dp0x64\exfat\boot.sdi" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\pcat\bcd" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
echo f|xcopy "%~dp0data\temp\2\windows\boot\efi\bootmgfw.efi" "%~dp0data\temp\iso\efi\boot\bootx64.efi" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\en-US\efisys_noprompt.bin" "%~dp0data\temp\iso\efi\microsoft\boot\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\pcat\etfsboot.com" "%~dp0data\temp\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\efi\bootmgr.efi" "%~dp0data\temp\iso\" /F /Y /S /H /R
rem xcopy "%cddir%:\efi\microsoft\boot" "%~dp0data\temp\iso\efi\microsoft\boot\"  /F /Y /S /H /R
xcopy "%cddir%:\efi\microsoft\boot\efisys_noprompt.bin" "%~dp0data\temp\iso\efi\microsoft\boot\"  /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\pcat\etfsboot.com" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
xcopy "%~dp0bin\grldr" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
md "%~dp0data\temp\iso\sources"


echo Ԥ������Ŀ¼�ṹ
data\tools\wimlib-imagex.exe dir "%wimdir%" %inwiminfo% | findstr /v "\.">%~dp0data\temp\pe-dir.txt
for /f %%a in (%~dp0data\temp\pe-dir.txt) do (
if not exist %~dp0data\winpe%%a mkdir %~dp0data\winpe%%a
)

rem ���ʹ���
rem ����ԭ��Net4.8
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\NetFramework.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls


echo ���%~dp0data\winpe�ļ��е�%~dp0data\temp\iso\sources\boot.wim
"%~dp0data\tools\wimlib-imagex.exe" capture "%~dp0data\winpe" "%~dp0data\temp\iso\sources\boot.wim" "WindowsPE" --boot --compress=lzx --rebuild

set bootwim=%~dp0data\temp\iso\sources\boot.wim
echo. & echo ��ʼʱ�䣺%time% & set startT=%time%

bin\wimlib dir %bootwim% 1 --path=Windows\SysWOW64 | find ".exe" >NUL && (set FD=x64) || (set FD=x86)
bin\wimlib update %bootwim%<%FD%\add2wimnewbee.txt>NUL
bin\wimlib optimize %bootwim%
copy /y %bootwim% %~dp0NewBeecore.wim
echo. & echo  ������� & echo.


echo ���NewBeePlus.iso

"%~dp0data\tools\oscdimg.exe" -bootdata:2#p0,e,b"%~dp0data\temp\etfsboot.com"#pEF,e,b"%~dp0data\temp\iso\efi\microsoft\boot\efisys_noprompt.bin" -h -l"Windows PE x64" -m -u2 -udfver102 "%~dp0data\temp\iso" "%~dp0NewBeecore.iso"

echo ɾ����ʱĿ¼%~dp0data\temp
rd /s /Q "%~dp0data\temp"

echo ������ʱĿ¼%~dp0data\temp
md "%~dp0data\temp"

exit

:features
echo ��ǰ�ļ��嵥:
setlocal enabledelayedexpansion
set n=0
for /f %%i in ('dir /b %~dp0data\files\features\') do (
set /a n+=1
set file!n!=%%i
@echo !n!.%%i  
)
set /p sel=��ѡ���ļ��嵥����install.wim��ѹ: 
echo ѡ��
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\!file%sel%!" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" capture "%~dp0data\winpe" "%~dp0!file%sel%!.wim" "WindowsPE" --boot --wimboot --compress=lzx --rebuild
goto features

:AddDriver
set drvinf=%1
for /d %%f in (%~dp0data\winpe\windows\system32\DriverStore\FileRepository\%drvinf%*) do (
echo ����hklm\os-drv\DriverDatabase\DriverPackages\%%~nf%%~xf
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%~nf%%~xf" "hklm\pe-drv\DriverDatabase\DriverPackages\%%~nf%%~xf" /S /F
)
exit /b

:loadreg
echo ����ע���Ԫ
set soft=software
set sys=system
set drv=DRIVERS
set def=default
for %%a in (def soft sys drv) do (
call call reg load hklm\pe-%%a "%~dp0data\winpe\windows\system32\config\%%%%a%%"
call call reg load hklm\boot-%%a "%~dp0data\temp\bootconfig\%%%%a%%"
call call reg load hklm\os-%%a "%~dp0data\temp\config\%%%%a%%"
)
exit /b

:unloadreg
echo ж��ע������õ�Ԫ
reg unload hklm\os-drv
reg unload hklm\os-soft
reg unload hklm\os-sys
reg unload hklm\os-def
reg unload hklm\pe-drv
reg unload hklm\pe-soft
reg unload hklm\pe-sys
reg unload hklm\pe-def
reg unload hklm\boot-drv
reg unload hklm\boot-soft
reg unload hklm\boot-sys
reg unload hklm\boot-def
exit /b

:minireg
rem ����������ע���
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\software --dest-dir="%~dp0data\winpe\windows\system32\config" --nullglob --no-acls
echo ����ԭ��ע������õ�Ԫ
reg load hklm\pe-soft %~dp0data\winpe\windows\system32\config\software
echo �ú������ļ�����ע���
for /f %%r in ('dir /b %~dp0data\reg_black\*black*.reg') do (
echo ���ھ��� %~dp0data\reg_black\%%r
reg import %~dp0data\reg_black\%%r
)
echo ж��ע���Ԫ
reg unload hklm\pe-soft

exit /b