@echo off
mode con:cols=80 lines=20
:menu
set key=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private
set valueName=autosetup
set openValue=1
set closeValue=0

REM ���ע����ֵ�Ƿ����
reg query "%key%" /v "%valueName%" >nul 2>&1

if %errorlevel% equ 0 (
  REM �����ֵ���ڣ��������ֵ
  for /f "tokens=3" %%i in ('reg query "%key%" /v "%valueName%"') do (
    if %%i equ %openValue% (
      set p_autosetup=����
    ) else (
      set p_autosetup=�ر�
    )
  )
) else (
  REM �����ֵ�����ڣ�Ĭ��Ϊ����
  set p_autosetup=����
)

echo autosetup��״̬Ϊ��%p_autosetup%

rem ��ѯĬ�ϴ�ӡ�����ƺͶ˿�
for /f "tokens=2 delims==" %%a in ('wmic printer where default^="true" get portname /value') do set df_printer_port=%%a
for /f "tokens=2 delims==" %%a in ('wmic printer where default^="true" get name /value') do set df_printer=%%a
echo Default Printer: %df_printer% on port %df_printer_port%
title AppStore-��ӡ��ά������
cls
echo ================================
echo         ��ӡ��ά������
echo ================================
echo 0. �򿪾ɵ�"Ӳ���ʹ�ӡ���ļ���"
echo 1. �򿪸߼���������
echo 2. ����LPD��ӡ��������
echo 3. �������������豸���Զ�����(���緢��) ��ǰ״̬Ϊ��%p_autosetup%
echo 4. ����Ĭ�ϴ�ӡ�� ��ǰ: %df_printer%  �˿�:%df_printer_port%
echo 5. ���LPD��ӡ��
echo 6. �ֶ���Ӵ�ӡ��
echo 7. �����ӡ����
echo 8. ��ӡ����[����]
echo 9. �޸�SMB����[���÷���������!���Ƽ�]
echo x. �˳�

set /p choice=������ѡ������֣�

if "%choice%"=="0" start "" shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}&&goto menu
if "%choice%"=="1" start "" control.exe /name Microsoft.NetworkAndSharingCenter /page Advanced&&goto menu
if "%choice%"=="2" goto AddLPD
if "%choice%"=="3" REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" /v "AutoSetup" /t REG_DWORD /d 0 /f&&goto menu
if "%choice%"=="4" call :set_printer&&goto menu
if "%choice%"=="5" call :add_lpd_printer&&goto menu
if "%choice%"=="6" start "" rundll32 printui.dll,PrintUIEntry /il&&goto menu
if "%choice%"=="7" call :del_jobs&&goto menu
if "%choice%"=="8" start "" %systemroot%\system32\printmanagement.msc&&goto menu
if "%choice%"=="9" call :fix_smb_printer&&goto menu
if "%choice%"=="x" exit

echo ��Ч��ѡ������ԡ�
pause
goto menu



:AddLPD
@echo ����LPD��ӡ��ع��ܡ���
@echo off

ver | find "6.1." > nul && set os=win7
ver | find "10.0." > nul && set os=win10

if "%os%"=="win7" (
    echo Windows 7 detected
    REM ִ�� Win7 ϵͳ�µĲ���
    call :win7
   
) else if "%os%"=="win10" (
    echo Windows 10 detected
    REM ִ�� Win10 ϵͳ�µĲ���
    call :win10
 
) else (
    echo Unsupported OS version
)

pause




:win10
rem windows10
dism /online /enable-feature /featurename:"Printing-Foundation-InternetPrinting-Client" /all
dism /online /enable-feature /featurename:"Printing-Foundation-LPDPrintService" /all
dism /online /enable-feature /featurename:"Printing-Foundation-LPRPortMonitor" /all
exit /b

:win7
rem windows7
dism /online /enable-feature /featurename:"Printing-Foundation-Features" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-LPDPrintService" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-LPRPortMonitor" /norestart
dism /online /enable-feature /featurename:"Printing-Foundation-InternetPrinting-Client" /norestart
exit /b


:set_printer
setlocal enabledelayedexpansion

rem �г����д�ӡ��
echo "����ö�����д�ӡ��..."
set counter=0
for /f "tokens=2 delims==" %%a in ('wmic printer get name /value^|find "="') do (
  set /a counter+=1
  set printer[!counter!]=%%a
  echo !counter!. %%a
)

rem �û�ѡ��Ĭ�ϴ�ӡ��
set /p choice="������Ҫ����ΪĬ�ϴ�ӡ���ı�ţ�"
if %choice% gtr %counter% exit /b
set defaultprinter=!printer[%choice%]!
echo �� "%defaultprinter%" ����ΪĬ�ϴ�ӡ��...
rundll32 printui.dll,PrintUIEntry /y /n "%defaultprinter%"

rem ɾ������Ĵ�ӡ��
set skipdelete=
set /p deletelabel="�Ƿ�ɾ������Ҫ�Ĵ�ӡ������y/n����"
if /i "%deletelabel%"=="y" (
    set skipdelete=1
    echo ����׼��ɾ������Ĵ�ӡ��...
    for /f "tokens=2 delims==" %%a in ('wmic printer get default /value^|find "="') do (
        set defaultprinter=%%a
    )
    for /f "tokens=2 delims==" %%a in ('wmic printer get name^|find ":"') do (
        if /i not "%%a"=="%defaultprinter%" (
            rundll32 printui.dll,PrintUIEntry /dl /n "%%a"
            echo ��ɾ����ӡ�� "%%a".
        )
    )
)

if not defined skipdelete (
    echo ����ѡ���ˡ��񡱣����������д�ӡ��.
)

echo ��ӡ��������ɡ�
timeout 1 /nobreak
exit /b

:add_lpd_printer
echo �������÷���ǽ...
netsh advfirewall firewall add rule name="LPR Port" dir=in action=allow protocol=TCP localport=515
netsh advfirewall firewall add rule name="LPD Port" dir=in action=allow protocol=TCP localport=721-731
echo ����ǽ�Ѿ�������ɣ�
set /p ip=������Ҫ��ӵ�LPD��ӡ��ip:
set /p queue=������Ҫ��ӵĴ�ӡ����(����)����(�����ÿո�):
set /p p_inf=������Ҫ��ӵ������ļ�·��(��inf��β):
rundll32 printui.dll,PrintUIEntry /if /b "%queue%" /f "%p_inf%" /r "IP_%ip%" /m "LPD Printer" /z
echo �������!
exit /b


:del_jobs
echo ֹͣ��ӡ����...
echo Y|net stop spooler
echo ɾ�����д�ӡ����...
del /Q /F /S "%SystemRoot%\System32\spool\PRINTERS\*"
echo ������ӡ����
net start spooler
echo ��ӡ�����������!
timeout 1 /nobreak
exit /b

:fix_smb_printer
rem Ҫͨ��ע����л������ӡ����
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
rem Ҫ����������������
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcProtocols /t REG_DWORD /d 0x7 /f
rem Ҫǿ��ִ�� Kerberos �����֤��
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v ForceKerberosForRpc /t REG_DWORD /d 1 /f
rem ����ע���(�����ṩ)
Reg add "HKLM\System\CurrentControlSet\Control\Print" /v "RpcAuthnLevelPrivacyEnabled" /t REG_DWORD /d "0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v "RestrictDriverInstallationToAdministrators" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v "RpcUseNamedPipeProtocol" /t REG_DWORD /d 1 /f

gpupdate /force
echo ����SMB1 ֧��
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol /norestart
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f 
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnableForcedLogoff /t REG_DWORD /d 0 /f
exit /b