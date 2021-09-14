@echo off
cd /d "%~dp0"
if not "x%TRUSTEDINSTALLER%"=="x1" (
    set TRUSTEDINSTALLER=1
    "%~dp0data\tools\NSudo.exe" -U:T -P:E -Wait -UseCurrentConsole cmd /c "%~0"
    ::pause
     exit
    goto :EOF
)
echo .正在初始化....
echo 检测注册表配置单元残留
for %%a in (os-drv os-soft os-sys pe-drv pe-sys pe-soft pe-def) do (
set item=%%a
call :checkitem %item%
)
goto startplay

:checkitem
reg query hklm |find "%item%"
if "%errorlevel%" == "0" echo 存在残留键值%item%, 卸载.&&reg unload hklm\%item%>nul
if "%errorlevel%" == "1" echo 未检出残留
exit /b

:startplay
cls
title WindowsPE  --  2009
:: /c按键列表 /m提示内容 /d默认选择 /t等待秒数   /d 必须和 /t同时出现
echo 版本选择:
echo 1.[20H2] [精简注册表 WinXShell] 
echo 2.[21H2] [精简注册表 WinXShell]  
echo 3.[RAW]  [完整注册表 原生外壳] 
echo 4.[Extract_Features]  [单独解压依赖文件] 
choice  /c 1234 /m "请选择ISO版本 5秒后自动选择1" /d 1 /t 5

::用户选择的结果会按项目序号数字（从1开始）返回在errorlevel变量中
if %errorlevel%==1 set filelist=newbee&&set winver=20h2&&echo 你选择了1
if %errorlevel%==2 set filelist=newbee&&set winver=21h2&&echo 你选择了2
if %errorlevel%==3 set filelist=raw&&set winver=raw&&echo 你选择了3
if %errorlevel%==4 set winver=soft&&echo 你选择了4

set /p cddir=输入虚拟光驱盘符：
if not exist %cddir%:\sources (echo 在%cddir%:\下没有发现需要的文件&&goto startplay) else (goto nextplay)
if /i "%cddir%"=="" (echo 没有输入数据&&goto startplay) else (goto nextplay)


:nextplay
rd /s /Q "%~dp0data\winpe"
md "%~dp0data\winpe"
echo 建立临时目录%~dp0data\temp
if not exist "%~dp0data\temp" md "%~dp0data\temp"
set wimdir=%cddir%:\sources\install.wim
set bootdir=%cddir%:\sources\boot.wim
set /p inwiminfo=输入install分卷号：
if /i "%inwiminfo%"=="" (echo 没有输入数据&&goto nextplay) else (goto peplay)

:peplay
::提取功能文件
if "%winver%" == "soft" (
call :features
exit
)

if "%winver%" == "21h2" (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\21h2.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
)


echo 提取WINPE相关文件
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\install_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" extract "%bootdir%" 2 @"%~dp0data\files\boot_play_%filelist%.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
for /f %%a in ('dir /ad /b %~dp0data\winpe\Windows\System32\DriverStore\FileRepository') do (echo %%a >>%~dp0data\temp\pe-drv-winxshell.txt)

if "%winver%" == "raw" (
echo RAW模式，使用完整注册表! 原生外壳
copy /y "%~dp0x64\x\Program Files\pecmd_explorer.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\software --dest-dir="%~dp0data\winpe\windows\system32\config" --nullglob --no-acls
echo RAW模式，使用完整文件列表
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\21h2.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
echo RAW模式，使用旧版资源管理器
xcopy "%~dp0x64\exp\explorer.exe" "%~dp0data\winpe\windows" /F /Y /S /H /R
) else (
echo %winver%模式，使用%winver%注册表! WinXshell外壳
copy /y "%~dp0x64\x\Program Files\pecmd_winxshell.lua" "%~dp0x64\x\Program Files\pecmd.lua" 
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\software%winver%.7z" -y -o"%~dp0data\winpe\windows\system32\config"
)

echo 解压usb相关文件
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\usbinf.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo 解压CatRoot相关文件
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\catroot.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls


echo 解压注册表单元
for %%a in (default software system Drivers) do (
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% \Windows\System32\config\%%a --dest-dir="%~dp0data\temp\config" --nullglob --no-acls
)


echo Y|choice /c:yn /m:"是否添加第三方OEM驱动："
::echo N |choice /c:yn /m:"是否添加第三方OEM驱动："
if %errorlevel%==1 goto ADDRV
if %errorlevel%==2 goto UINSTALL
:ADDRV
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\Dism_AddDrv.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

set drvfiles=%~dp0data\drivers
::set /p drvfiles=拖入第三方OEM驱动文件夹：
if /i "%drvfiles%"=="" (echo 没有拖入第三方OEM驱动文件夹&&goto ADDRV) else (goto DRVPLAY)
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



echo 加载注册表单元
set soft=software
set sys=system
set drv=DRIVERS
set def=default
for %%a in (def soft sys drv) do (
call call reg load hklm\pe-%%a "%~dp0data\winpe\windows\system32\config\%%%%a%%"
call call reg load hklm\os-%%a "%~dp0data\temp\config\%%%%a%%"
)


echo 导入注册表
for %%a in (pe-diy.reg pe-def-winxshell.reg pe-sys-winxshell.reg pe-soft-winxshell.reg pe-soft-vc.reg pe-soft-hfs.reg pe-drv-winxshell.reg pe-soft-bluetooth.reg) do (
echo 正在导入注册表%%a&&reg import "%~dp0data\reg\%%a"
)

::echo 局域网发现browser服务
::reg import "%~dp0data\reg\pe-sys-browser.reg"
::reg import "%~dp0data\reg\pe-soft-svchost.reg"


echo 增加SMBV1协议
for /f "delims=" %%i in ('dir /b "%~dp0data\winpe\Windows\WinSxS\*_microsoft-windows-smb10-minirdr_*"') do (
echo extracting %%i\mrxsmb10.sys
copy /y "%~dp0data\winpe\Windows\WinSxS\%%i\mrxsmb10.sys" "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys"
echo 处理mrxsmb10.sys
%~dp0data\tools\sxsexp64.exe "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys" "%~dp0data\winpe\windows\system32\drivers\mrxsmb10.sys"
del /f /q "%~dp0data\winpe\Windows\WinSxS\mrxsmb10.sys"
rd /s /q "%~dp0data\winpe\Windows\WinSxS\%%i"
)


echo 增加Browser局域网发现服务smbv1.0专有
::取消
goto addmui
for /f "delims=" %%i in ('dir /b "%~dp0data\winpe\Windows\WinSxS\amd64_microsoft-windows-browserservice_*"') do (
echo extracting %%i\browser.dll
copy /y "%~dp0data\winpe\Windows\WinSxS\%%i\browser.dll" "%~dp0data\winpe\Windows\WinSxS\browser.dll"
echo 处理browser.dll
%~dp0data\tools\sxsexp64.exe "%~dp0data\winpe\Windows\WinSxS\browser.dll" "%~dp0data\winpe\windows\system32\browser.dll"
del /f /q "%~dp0data\winpe\Windows\WinSxS\browser.dll"
rd /s /q "%~dp0data\winpe\Windows\WinSxS\%%i"
)

:addmui
echo 补全dll.mui exe.mui
if exist %~dp0data\temp\pe-mui.txt del /f /q %~dp0data\temp\pe-mui.txt
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.dll') do (
echo \Windows\System32\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\*.exe') do (
echo \Windows\System32\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)
echo 补全drivers-sys.mui
for /f %%a in ('dir /b %~dp0data\winpe\windows\system32\drivers\*.sys') do (
echo \Windows\System32\drivers\zh-CN\%%a.mui >>%~dp0data\temp\pe-mui.txt
)
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-mui.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls

echo 补全loc
::filerepository
dir /b /s %~dp0data\winpe\windows\system32\DriverStore\filerepository\*.inf>%~dp0data\temp\pe-inf.txt
for /f "tokens=*" %%a in (%~dp0data\temp\pe-inf.txt) do echo \windows\system32\DriverStore\zh-CN\%%a_loc >>%~dp0data\temp\pe-loc.txt
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-loc.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
::inf
for /f %%a in ('dir /b %~dp0data\winpe\windows\inf\*.inf') do (
echo \windows\system32\DriverStore\zh-CN\%%a_loc>>%~dp0data\temp\pe-inf-loc.txt
)
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\temp\pe-inf-loc.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls



echo 复制必要的software注册表到PE
for /f "tokens=*" %%e in (%~dp0data\reg\pe-soft-winxshell.txt) do (
echo %%e
reg copy "hklm\os-soft\%%e" "hklm\pe-soft\%%e" /S /F
)
for /f "tokens=*" %%t in (%~dp0data\reg\pe+soft.txt) do (
echo %%t
reg copy "hklm\os-soft\%%t" "hklm\pe-soft\%%t" /F
)

echo 复制VC运行库相关注册表到PE
for /f "tokens=1-8 delims=^\" %%a in ('reg query HKLM\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\ ^|findstr ^"microsoft.vc[0-9]0^"') do (
echo %%h
reg copy "hklm\os-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" "hklm\pe-soft\Microsoft\Windows\CurrentVersion\SideBySide\Winners\%%h" /S /F
)

echo 复制.Net支持相关注册表到PE
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^"FontCache*^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)
for /f "tokens=1-5 delims=^\" %%a in ('reg query HKLM\os-Sys\ControlSet001\Services ^|findstr ^".NET^"') do (
echo %%e
reg copy "HKLM\os-Sys\ControlSet001\Services\%%e" "HKLM\pe-Sys\ControlSet001\Services\%%e" /S /F
)


echo 复制必要的system注册表到PE
for /f "tokens=*" %%c in (%~dp0data\reg\pe-sys-winxshell.txt) do (
echo %%c
reg copy "hklm\os-sys\%%c" "hklm\pe-sys\%%c" /S /F
)

echo 复制必要的DRIVERS注册表到PE
for /f "tokens=*" %%h in (%~dp0data\reg\pe-drv-winxshell.txt) do (
echo %%h
reg copy "hklm\os-drv\%%h" "hklm\pe-drv\%%h" /S /F
)
for /f "tokens=*" %%j in (%~dp0data\temp\pe-drv-winxshell.txt) do (
echo %%j
reg copy "hklm\os-drv\DriverDatabase\DriverPackages\%%j" "hklm\pe-drv\DriverDatabase\DriverPackages\%%j" /S /F
)

echo 删除资源管理器左侧网络
reg add hklm\pe-soft\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder /v Attributes /t REG_DWORD /d 0xb0940064 /F

echo 隐藏系统自带网络图标和映射
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer" /f /v "MapNetDrvBtn" /t REG_DWORD /d 0
reg add "HKLM\pe-def\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v "MapNetDrvBtn" /t REG_DWORD /d 0
::隐藏系统自带网络图标和映射有效
reg add "HKLM\PE-DEF\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v "NoNetConnectDisconnect" /t REG_DWORD /d 1



echo 替换c/d为x，删除Interactive User
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft -y C:\ -y -r X:\
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft -y D:\ -y -r X:\
"%~dp0data\tools\regfind" -p HKEY_LOCAL_MACHINE\pe-soft\Classes\AppID -y  Interactive User -r


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo 写入imdisk注册表
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /ve /t REG_SZ /d "装载为 ImDisk 虚拟磁盘" /f
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile" /v "Icon" /t REG_SZ /d "imdisk.cpl,0" /f
reg add "HKLM\PE-SOFT\Classes\*\shell\ImDiskMountFile\command" /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_MountFile %%L" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /ve /t REG_SZ /d "将磁盘内容保存为映像文件" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage" /v "Icon" /t REG_SZ /d "imdisk.cpl,0" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskSaveImage\command" /ve /t REG_SZ /d "rundll32.exe imdisk.cpl,RunDLL_SaveImageFile %%L" /f
reg add "HKLM\PE-SOFT\Classes\Drive\shell\ImDiskUnmount" /ve /t REG_SZ /d "卸载 ImDisk 虚拟磁盘" /f
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

echo 修改注册表，关闭UAC 需要seclogon服务!
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t reg_dword /d 0 /F 
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t reg_dword /d 0 /F 
reg add hklm\pe-soft\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t reg_dword /d 0 /F 

echo 修改注册表,开启来宾共享
reg add HKLM\PE-SYS\ControlSet001\Control\Lsa /f /v everyoneincludesanonymous /t REG_DWORD /d 1
reg add HKLM\PE-SYS\ControlSet001\Services\LanmanServer\Parameters /f /v "RestrictNullSessAccess /t REG_DWORD /d 0

echo 添加右键显示设置
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\显示设置\command /d "WinXShell.exe ms-settings:display" /f
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\显示设置 /f /v "Position" /t REG_SZ /d "Bottom"
reg add HKLM\pe-soft\Classes\DesktopBackground\Shell\显示设置 /f /v "icon" /t REG_SZ /d "%%programfiles%%\winxshell.exe,30"

echo 删除微软基本显示驱动
set DrvFolder=
for /f "tokens=3" %%i in ('reg query HKLM\pe-drv\DriverDatabase\DriverInfFiles\display.inf /v Active') do set DrvFolder=%%i
echo Update Configurations:%DrvFolder%
echo "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA"
::reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%\Configurations\MSBDA" /v service vi /f
reg delete "HKLM\pe-drv\DriverDatabase\DriverPackages\%DrvFolder%" /v version /F
set DrvFolder=

echo 处理msi服务
reg add hklm\pe-sys\ControlSet001\Services\TrustedInstaller /v Start /t REG_DWORD /d 3 /f

echo bitlocker注册表
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v AppliesTo /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v DefaultAppliesTo /f
reg add HKLM\PE-SOFT\Classes\Drive\shell\unlock-bde /v Icon /d bdeunlock.exe /f
reg delete HKLM\PE-SOFT\Classes\Drive\shell\encrypt-bde-elev /f

echo 右下角热插拔设置
reg add "HKLM\PE-DEF\Software\HotSwap!" /v DFlags /t REG_DWORD /d 0x10000003 /f

echo ip高级扫描工具中文显示等配置
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

echo LUA脚本支持
reg add "HKLM\PE-SOFT\Classes\.lua" /f /ve /t REG_SZ /d "luafile"
reg add "HKLM\PE-SOFT\Classes\luafile" /f /ve /t REG_SZ /d "Windows luach File"
reg add "HKLM\PE-SOFT\Classes\luafile" /f /v "EditFlags" /t REG_BINARY /d 30040000
reg add "HKLM\PE-SOFT\Classes\luafile\DefaultIcon" /f /ve /t REG_EXPAND_SZ /d "X:\Windows\System32\ico\lua.ico"
reg add "HKLM\PE-SOFT\Classes\luafile\shell\edit\command" /f /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\NOTEPAD.EXE %%1"
reg add "HKLM\PE-SOFT\Classes\luafile\shell\open\command" /f /ve /t REG_SZ /d "X:\Program Files\WinXShell.exe  -script \"%%1\""

echo 关闭chrome、edge声音沙箱、获取权限
reg add "HKLM\PE-SOFT\Policies\Google\Chrome" /v "AudioSandboxEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\PE-SOFT\Policies\Microsoft\Edge" /v "AudioSandboxEnabled" /t REG_DWORD /d 0 /f
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SOFT\Policies" -ot reg -actn ace -ace "n:Everyone;p:full"
"%~dp0data\tools\SetACL.exe" -on "HKLM\PE-SOFT" -ot reg -actn ace -ace "n:Everyone;p:full"


:::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo 卸载注册表配置单元
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
echo 获取WINPE文件夹所有权
takeown /f "%~dp0data\winpe" /r /d y 1>nul
cacls "%~dp0data\winpe" /T /E /G Everyone:F 1>nul
takeown /f "%~dp0x64" /r /d y 1>nul
cacls "%~dp0x64" /T /E /G Everyone:F 1>nul

echo 压缩注册表配置单元
"%~dp0data\tools\ru.exe" -accepteula -h "%~dp0data\winpe\Windows\System32\config\SOFTWARE" hklm\soft
"%~dp0data\tools\ru.exe" -accepteula -h "%~dp0data\winpe\Windows\System32\config\SYSTEM" hklm\sys

echo 破解USB弹出功能文件
%~dp0data\tools\binmay -u "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll" -s u:SystemSetupInProgress -r u:DisableDeviceSetupMgr

echo 删除dll备份文件
del "%~dp0data\winpe\Windows\System32\DeviceSetupManager.dll.org"

echo 复制一份DRIVERS到ipxefm文件制作mini.wim使用
copy /y "%~dp0data\winpe\Windows\System32\config\DRIVERS" %~dp0x64\x\ipxefm\mini\Windows\System32\config\DRIVERS

echo 删除多余的注册表临时文件
del /f /q /ah "%~dp0data\winpe\Windows\System32\config\*.*"

echo 解压WINPE预配置文件
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePE_winxshell.dll" -y -o"%~dp0data\winpe"
::"%~dp0data\tools\7z.exe" x "%~dp0data\tools\LitePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\onePEx64.dll" -y -o"%~dp0data\winpe"
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\pe-audio.7z" -y -o"%~dp0data\winpe"
echo 解压Dism文件
"%~dp0data\tools\7z.exe" x "%~dp0data\tools\dism.7z" -y -o"%~dp0data\winpe"

echo 解压ISO镜像文件，为制作ISO镜像做准备
%~dp0data\tools\7z.exe x %bootdir% -y -o%~dp0data\temp 2\windows\boot
xcopy "%~dp0data\temp\2\windows\boot\pcat\bootmgr" "%~dp0data\temp\iso\" /F /Y /S /H /R
xcopy "%~dp0data\temp\2\windows\boot\dvd\efi\bcd" "%~dp0data\temp\iso\efi\microsoft\boot\" /F /Y /S /H /R
rem uefi下可调分辨率设置
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


rem 增肥功能
rem 开启原生Net4.8
::"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\NetFramework.txt" --dest-dir="%~dp0data\winpe" --nullglob --no-acls



echo 打包%~dp0data\winpe文件夹到%~dp0data\temp\iso\sources\boot.wim
"%~dp0data\tools\wimlib-imagex.exe" capture "%~dp0data\winpe" "%~dp0data\temp\iso\sources\boot.wim" "WindowsPE" --boot --compress=lzx --rebuild

set bootwim=%~dp0data\temp\iso\sources\boot.wim
echo. & echo 开始时间：%time% & set startT=%time%

bin\wimlib dir %bootwim% 1 --path=Windows\SysWOW64 | find ".exe" >NUL && (set FD=x64) || (set FD=x86)
bin\wimlib update %bootwim%<%FD%\add2wimnewbee.txt>NUL
bin\wimlib optimize %bootwim%
copy /y %bootwim% %~dp0NewBeecore.wim
echo. & echo  制作完成 & echo.


echo 打包NewBeePlus.iso
"%~dp0data\tools\oscdimg.exe" -h -d -m -o -u1 -lWindowsPE -bootdata:2#p00,e,b"%~dp0data\temp\etfsboot.com"#pEF,e,b"%~dp0data\temp\efisys_noprompt.bin" "%~dp0data\temp\iso" "%~dp0NewBeecore.iso"

echo 删除临时目录%~dp0data\temp
rd /s /Q "%~dp0data\temp"

echo 建立临时目录%~dp0data\temp
md "%~dp0data\temp"

exit

:features

echo 当前文件清单:
setlocal enabledelayedexpansion
set n=0
for /f %%i in ('dir /b %~dp0data\files\features\') do (
set /a n+=1
set file!n!=%%i
@echo !n!.%%i  
)
set /p sel=请选择文件清单并从install.wim解压: 
echo 选中
"%~dp0data\tools\wimlib-imagex.exe" extract "%wimdir%" %inwiminfo% @"%~dp0data\files\features\!file%sel%!" --dest-dir="%~dp0data\winpe" --nullglob --no-acls
"%~dp0data\tools\wimlib-imagex.exe" capture "%~dp0data\winpe" "%~dp0!file%sel%!.wim" "WindowsPE" --boot --compress=lzx --rebuild
goto features