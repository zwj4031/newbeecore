@echo off
rem Remove the origin 'Safely Remove Hardware' Tray Icon (default Services=#31)
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\SysTray /v Services /t REG_DWORD /d 29 /f
if exist "%windir%\System32\SysTray.exe" start SysTray.exe


setlocal ENABLEDELAYEDEXPANSION
if "%1"=="pci" set ename=PCI && Call :pbegin
set ename=USB && Call :begin
set ename=SD && Call :begin
set ename=SCSI && Call :begin
exit

:begin
set b=1
for /f "tokens=3* delims=\ " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Enum\%ename% /v ContainerID /s') do (
 set /a var=!b!%%2
 if !var! equ 1 (if "%%i"=="CurrentControlSet" (set num=%%i\%%j) else (goto :eof))
 if !var! equ 0 (
    if %ename%==SCSI (
        reg copy "HKLM\SYSTEM\!num!\Properties\{540b947e-8b40-45bc-a8a2-6a0b894cbda2}\0004" HKLM\SYSTEM\CurrentControlSet\Control\DeviceContainers\%%i\Properties\{b725f130-47ef-101a-a5f1-02608c9eebac}\000A /f
    ) else (
        echo n|reg copy "HKLM\SYSTEM\!num!\Properties\{540b947e-8b40-45bc-a8a2-6a0b894cbda2}\0004" HKLM\SYSTEM\CurrentControlSet\Control\DeviceContainers\%%i\Properties\{b725f130-47ef-101a-a5f1-02608c9eebac}\000A
    )
  )
 set /a b=!b!+1
)

:pbegin
set b=1
for /f "tokens=3* delims=\ " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Enum\%ename% /v ContainerID /s') do (
 set /a var=!b!%%2
 if !var! equ 1 (if "%%i"=="CurrentControlSet" (set num=%%i\%%j) else (goto :eof))
 if !var! equ 0 (if not "%%i"=="{00000000-0000-0000-ffff-ffffffffffff}" reg copy "HKLM\SYSTEM\!num!\Properties\{a8b865dd-2e3d-4094-ad97-e593a70c75d6}\0004" HKLM\SYSTEM\CurrentControlSet\Control\DeviceContainers\%%i\Properties\{b725f130-47ef-101a-a5f1-02608c9eebac}\000A /f)
 set /a b=!b!+1
 )