@echo off 2>nul 3>nul
mode con cols=50 lines=5
title=��ѯĿ��ϵͳIP......
setlocal enabledelayedexpansion
set /p Input=����Ҫ��ѯ��ϵͳ��װ�̷�[����D]��
echo ��ѯ�У��Ժ򡭡�
if /i "%Input%:" neq "%systemDrive%" (
    for %%a in (software system) do (
        if not exist "%Input%:\Windows\System32\config\%%a" echo,�����&pause & exit/b
    )
    reg load HKLM\Temp_HIV1 %Input%:\Windows\System32\config\software >nul
    reg load HKLM\Temp_HIV2 %Input%:\Windows\System32\config\system >nul
    call :GetIPInfo Temp_HIV1 Temp_HIV2
    reg unload HKLM\Temp_HIV1 >nul
    reg unload HKLM\Temp_HIV2 >nul
) else call :GetIPInfo SOFTWARE SYSTEM
start "" "%~dp0IPInfo.txt" & exit/b

:GetIPInfo
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%2\select"') do (
    if /i "%%a" == "Default" set /a x=%%c
)
set "v1=Microsoft\Windows NT\CurrentVersion\NetworkCards"
set "v2=ControlSet00%x%\Control\Network"
set "v3=ControlSet00%x%\services\Tcpip\Parameters"
set "s=EnableDHCP NameServer IPAddress SubnetMask DefaultGateway"
set "s=%s% DHCPNameServer DHCPIPAddress DHCPSubnetMask DHCPDefaultGateway"

for /f "delims=" %%a in ('reg query "HKLM\%1\%v1%"') do (
    set "v=%%a"
    if "!v:%v1%\=!" neq "!v!" (
        set /a n+=1
        for /f "tokens=1,2*" %%b in ('reg query "%%a"') do (
            if /i "%%b" == "ServiceName" (
                set "Guid!n!=%%d"
            ) else if /i "%%b" == "Description" set "NetCard!n!=%%d"
        )
    )
)
if not defined n echo,�Ҳ�������&pause & exit

(for /f "tokens=1,2*" %%a in ('reg query "HKLM\%2\%v3%"') do (
    if /i "%%a" == "Domain" (
        if "%%c" neq "" (echo,�������ƣ�%%c)else echo,�������ƣ�^<nul^>
    ) else if /i "%%a" == "HostName" echo,�������ƣ�%%c
))>"%~dp0IPInfo.txt"

for %%a in (%s%) do set "_%%a=1"
(for /l %%a in (1 1 %n%) do (
    echo,&echo,�������ƣ�!NetCard%%a!
    for %%b in (%s%) do set "%%b="
    for /f "delims=" %%b in ('reg query "HKLM\%2\%v2%" /s') do (
        if defined flag (
            for /f "tokens=1,2*" %%c in ("%%b") do (
                if /i "%%c" == "Name" echo,�������ƣ�%%e& set "flag="
            )
        ) else (
            set "v=%%b"
            for %%c in ("\!Guid%%a!") do if "!v:%%~c=!" neq "!v!" set flag=1
        )
    )
    for /f "tokens=1,2*" %%b in ('reg query "HKLM\%2\%v3%\Interfaces\!Guid%%a!"') do (
        if defined _%%b if "%%d" neq "" set "v=%%d" & set "%%b=!v:\0=!"
    )
    if /i "!EnableDHCP!" == "0x1" (
        echo,IP �� ַ��!DHCPIPAddress!
        echo,�������룺!DHCPSubnetMask!
        echo,Ĭ�����أ�!DHCPDefaultGateway!
        echo,DNS ��ַ��!DHCPNameServer!
    ) else (
        echo,IP �� ַ��!IPAddress!
        echo,�������룺!SubnetMask!
        echo,Ĭ�����أ�!DefaultGateway!
        echo,DNS ��ַ��!NameServer!
    )
))>>"%~dp0IPInfo.txt"