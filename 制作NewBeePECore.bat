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
for %%a in (os-drv os-soft os-sys pe-drv pe-sys pe-soft pe-def) do (
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
cls
title WindowsPE  --  2009
:: /c�����б� /m��ʾ���� /dĬ��ѡ�� /t�ȴ�����   /d ����� /tͬʱ����
echo �汾ѡ��:
echo 1.[20H2] [����ע��� WinXShell] 
echo 2.[21H2] [����ע��� WinXShell]  
echo 3.[RAW]  [����ע��� ԭ�����] 
echo 4.[Extract_Features]  [������ѹ�����ļ�] 
choice  /c 1234 /m "��ѡ��ISO�汾 5����Զ�ѡ��1" /d 1 /t 5

::�û�ѡ��Ľ���ᰴ��Ŀ������֣���1��ʼ��������errorlevel������
if %errorlevel%==1 set filelist=newbee&&set winver=20h2&&echo ��ѡ����1
if %errorlevel%==2 set filelist=newbee&&set winver=21h2&&echo ��ѡ����2
if %errorlevel%==3 set filelist=raw&&set winver=raw&&echo ��ѡ����3
if %errorlevel%==4 set winver=soft&&echo ��ѡ����4

set /p cddir=������������̷���
if not exist %cddir%:\sources (echo ��%cddir%:\��û�з�����Ҫ���ļ�&&goto startplay) else (goto nextplay)
if /i "%cddir%"=="" (echo û����������&&goto startplay) else (goto nextplay)


:nextplay
rd /s /Q "%~dp0data\winpe"
md "%~dp0data\winpe"
echo ������ʱĿ¼%~dp0data\temp
if not exist "%~dp0data\temp" md "%~dp0data\temp"
set wimdir=%cddir%:\sources\install.wim
set bootdir=%cddir%:\sources\boot.wim
set /p inwiminfo=����install�־�ţ�
if /i "%inwiminfo%"=="" (echo û����������&&goto nextplay) else (goto peplay)

:peplay
::��ȡ�����ļ�
if "%winver%" == "soft" (
call :features
exit
)

if "%winver%" == "21h2" (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\21h2.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)


echo ��ȡWINPE����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\install_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\boot_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
for /f %%a in ('dir /ad /b %~dp0data\winpe\Windows\System32\DriverStore\FileRepository') do (echo %%a >>%~dp0data\temp\pe-drv-winxshell.txt)

if "%winver%" == "raw" (
echo RAWģʽ��ʹ������ע���! ԭ�����
copy /y "%~dp0x64\x\Program Files\pecmd_explorer.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\software --dest-dir="%~dp0data\winpe\windows\system32\config" --nullglob --no-acls
echo RAWģʽ��ʹ�������ļ��б�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\21h2.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo RAWģʽ��ʹ�þɰ���Դ������
xcopy "%~dp0x64\exp\explorer.exe" "%~dp0data\winpe\windows" /F /Y /S /H /R
) else (
echo %winver%ģʽ��ʹ��%winver%ע���! WinXshell���
copy /y "%~dp0x64\x\Program Files\pecmd_winxshell.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\software%winver%.7z" -y -o"%~dp0data\winpe\windows\system32\config"
)

echo ��ѹusb����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\usbinf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo ��ѹCatRoot����ļ�
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls


echo ��ѹע���Ԫ
for %%a in (default software system Drivers) do (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\%%a --dest-dir="%~dp0data\temp\config" --nullglob --no-acls
)


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
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\add_driverf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\add_drivers.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
DISM.exe /Image:"%~dp0data\winpe" /Add-Driver /Driver:"%drvfiles%" /recurse /ForceUnsigned
for /f "tokens=*" %%c in (%~dp0data\files\add_driverf.txt) do (
del %~dp0data\winpe\%%c
)
for /f "tokens=*" %%c in (%~dp0data\files\add_drivers.txt) do (
for /d %%f in (%~dp0data\winpe\%%c) do (
rd /s /Q "%%f"
)
)
SET drvfiles=



echo ����ע���Ԫ
set soft=software
set sys=system
set drv=DRIVERS
set def=default
for %%a in (def soft sys drv) do (
call call reg load hklm\pe-%%a "%~dp0data\winpe\windows\system32\config\%%%%a%%"
call call reg load hklm\os-%%a "%~dp0data\temp\config\%%%%a%%"
)


echo ����ע���
for %%a in (pe-diy.reg pe-def-winxshell.reg pe-sys-winxshell.reg pe-soft-winxshell.reg pe-soft-vc.reg pe-soft-hfs.reg pe-drv-winxshell.reg pe-soft-bluetooth.reg) do (
echo ���ڵ���ע���%%a&&reg import "%~dp0data\reg\%%a"
)

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



echo ���Ʊ�Ҫ��softwareע���PE
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-winxshell.txt) do (
echo %%e
reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F
)
for /f "tokens=*" %%t in (%~dp0data\reg\pe+soft.txt) do (
echo %%t
reg copy "hklm\os-soft\%%t" "hklm\pe-soft\%%t" /F
)

echo ����VC���п����ע���PE
for /f "tokens=1-8 delims=^\" %%a in ('reg query HKLM\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\ ^|findstr ^"microsoft.vc[0-9]0^"') do (
echo %%h
reg copy "hklm\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" "hklm\pe-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" /S /F
)

echo ����.Net֧�����ע���PE
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^"FontCache*^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^".NET^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)


echo ���Ʊ�Ҫ��systemע���PE
for /f "tokens=*" %%c in (%~dp0data\reg\pe-sys-winxshell.txt) do (
echo %%c
reg copy "hklm\os-sys\%%c" "hklm\pe-sys\%%c" /S /F
)

echo ���Ʊ�Ҫ��DRIVERSע���PE
for /f "tokens=*" %%h in (%~dp0data\reg\pe-drv-winxshell.txt) do (
echo %%h
reg copy "hklm\os-drv\%%h" "hklm\pe-drv\%%h" /S /F
)
for /f "tokens=*" %%j in (%~dp0data\temp\pe-drv-winxshell.txt) do (
echo %%j
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%j" "hklm\pe-drv\DriverDatabase\DriverPackages\%%j" /S /F
)

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

echo д��imdiskע���
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /ve /t REG_SZ /d "װ��Ϊ ImDisk �������" /f
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /v "Icon" /t REG_SZ /d "imdisk.cpl,0" /f
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile\command" /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_MountFile %%L" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /ve /t REG_SZ /d "���������ݱ���Ϊӳ���ļ�" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /v "Icon" /t REG_SZ /d "imdisk.cpl,0" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage\command" /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_SaveImageFile %%L" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount" /ve /t REG_SZ /d "ж�� ImDisk �������" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount" /v "Icon" /t REG_SZ /d "imdisk.cpl,0" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount\command" /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_RemoveDevice %%L" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "Type" /t REG_DWORD /d "1" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "ErrorControl" /t REG_DWORD /d "0" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\system32\DRIVERS\awealloc.sys" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "DisplayName" /t REG_SZ /d "AWE Memory Allocation Driver" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\AWEAlloc" /v "Description" /t REG_SZ /d "Driver for physical memory allocation through AWE" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "Type" /t REG_DWORD /d "1" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "ErrorControl" /t REG_DWORD /d "0" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "ImagePath" /t REG_EXPAND_SZ /d "\SystemRoot\system32\DRIVERS\imdisk.sys" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "DisplayName" /t REG_SZ /d "ImDisk Virtual Disk Driver" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDisk" /v "Description" /t REG_SZ /d "Disk emulation driver" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "Type" /t REG_DWORD /d "16" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "Start" /t REG_DWORD /d "2" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "ErrorControl" /t REG_DWORD /d "0" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "ImagePath" /t REG_EXPAND_SZ /d "X:\windows\system32\imdsksvc.exe" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "DisplayName" /t REG_SZ /d "ImDisk Virtual Disk Driver Helper" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "ObjectName" /t REG_SZ /d "LocalSystem" /f
reg add "HKLM\PE-SYS\ControlSet001\Services\ImDskSvc" /v "Description" /t REG_SZ /d "Helper service for ImDisk Virtual Disk Driver." /f

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
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\��ʾ���� /f /v "icon" /t REG_SZ /d "%%programfiles%%\winxshell.exe,30"

echo ɾ��΢�������ʾ����
set DrvFolder=
for /f "tokens=3" %%i in ('reg query HKLM\pe-drv\DriverDatabase\DriverInfFiles\display.inf /v Active') do set DrvFolder=%%i
echo Update Configurations:%DrvFolder%
echo "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA"
::reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA" /v service vi /f
reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%" /v version /F
set DrvFolder=

echo ����msi����
reg add hklm\pe-sys\ControlSet001\Services\TrustedInstaller /v Start /t REG_DWORD /d 3 /f

echo bitlockerע���
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v AppliesTo /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v DefaultAppliesTo /f
reg add HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v Icon /d bdeunlock.exe /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\encrypt-bde-elev /f

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


:::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo ж��ע������õ�Ԫ
reg unload hklm\os-drv
reg unload hklm\pe-drv
reg unload hklm\os-soft
reg unload hklm\os-sys
reg unload hklm\pe-soft
reg unload hklm\pe-sys
reg unload hklm\pe-def
reg unload hklm\os-def

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

echo ɾ��dll�����ļ�
del "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll.org"

echo ����һ��DRIVERS��ipxefm�ļ�����mini.wimʹ��
copy /y "%~dp0data\winpe\Windows\System32\config\DRIVERS" %~dp0x64\x\ipxefm\mini\Windows\System32\config\DRIVERS

echo ɾ�������ע�����ʱ�ļ�
del /f /q /ah "%~dp0data\winpe\Windows\System32\config\*.*"

echo ��ѹWINPEԤ�����ļ�
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePE_winxshell.dll" -y -o"%~dp0data\winpe"
::"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\onePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\pe-audio.7z" -y -o"%~dp0data\winpe"
echo ��ѹDism�ļ�
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\dism.7z" -y -o"%~dp0data\winpe"

echo ��ѹISO�����ļ���Ϊ����ISO������׼��
%~dp0data\tools\7z.exe x %bootdir% -y -o%~dp0data\temp 2\windows\boot
xcopy "%~dp0data\temp\2\windows\boot\pcat\bootmgr" "%~dp0data\temp\iso\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\bcd" "%~dp0data\temp\iso\efi\microsoft\boot\" /F /Y /S /H /R
rem uefi�¿ɵ��ֱ�������
md "%~dp0data\temp\iso\efi\microsoft\boot\Fonts"
xcopy "%~dp0data\temp\2\windows\boot\Fonts\wgl4_boot.ttf" "%~dp0data\temp\iso\efi\microsoft\boot\Fonts" /F /Y /S /H /R
::xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\boot.sdi" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
xcopy "%~dp0x64\exfat\boot.sdi" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\pcat\bcd" "%~dp0data\temp\iso\boot\" /F /Y /S /H /R
echo f|xcopy "%~dp0data\temp\2\windows\boot\efi\bootmgfw.efi" "%~dp0data\temp\iso\efi\boot\bootx64.efi" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\en-US\efisys_noprompt.bin" "%~dp0data\temp\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\pcat\etfsboot.com" "%~dp0data\temp\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\efi\bootmgr.efi" "%~dp0data\temp\iso\" /F /Y /S /H /R
md "%~dp0data\temp\iso\sources"


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
"%~dp0data\tools\oscdimg.exe" -h -d -m -o -u1 -lWindowsPE -bootdata:2#p00,e,b"%~dp0data\temp\etfsboot.com"#pEF,e,b"%~dp0data\temp\efisys_noprompt.bin" "%~dp0data\temp\iso" "%~dp0NewBeecore.iso"

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
"%~dp0data\tools\wimlib-imagex.exe" capture "%~dp0data\winpe" "%~dp0!file%sel%!.wim" "WindowsPE" --boot --compress=lzx --rebuild
goto features