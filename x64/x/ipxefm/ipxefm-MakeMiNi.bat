cd /d %~dp0
@echo off
mode con cols=50 lines=2
for /f %%a in ('dir /b /s \pe_*.txt') do del /s /f %%a
title ����MINI.WIM��......
copy "X:\Program Files\GhostCGI\ghost64.exe" X:\ipxefm\mini\Windows\System32\. /y
ver |find "22"
if errorlevel 0 set pelist=mini_ntfs_win11.txt&&echo win11
if errorlevel 1 set pelist=mini_ntfs_win10.txt&&echo win10
echo ��������ͼ��
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCANetwork /t REG_DWORD /d 1 /f
if exist "mini\Program Files\PENetwork\penetwork.reg" reg import "mini\Program Files\PENetwork\penetwork.reg"


set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "��������MiNi.Wim,���Ժ�"
echo ��ȡWINPE�ļ�������Ȩ
title ��ȡWINPE�ļ�������Ȩ...
takeown /f "%~dp0" /r /d y 1>nul
cacls "%~dp0data" /T /E /G Everyone:F 1>nul
takeown /f "%~dp04" /r /d y 1>nul
cacls "%~dp0" /T /E /G Everyone:F 1>nul
%wimlib% capture "mini " "mini.wim" "WindowsPE" --boot --compress=lzx --rebuild
title ��һ�׶�������Ч�б��ļ����Ժ�...

del /s /f pe_*.txt
find "\" mini\%pelist%>pe_list.txt
type pe_list.txt|findstr /v /m "*">pe_add.txt
type pe_list.txt|findstr /I "*">pe_dir.txt


for /f "delims=" %%i in (pe_dir.txt) do (
dir /s /b "%%i">>pe_tmp.txt
)
for /f "delims=" %%i in (pe_add.txt) do (
if exist "X:%%i" echo X:%%i>>pe_tmp.txt
)


title �ڶ��׶�����wimlib�б��ļ�...
for /f "tokens=1,2 delims=:" %%a in (pe_tmp.txt) do (
echo add "%%b" "%%b">>pe_excel.txt
)
title �����׶ΰ��ļ���ӵ�wim
%wimlib% update mini.wim<pe_excel.txt
title ��β�׶��ٴθ��������ļ�
echo �ٴθ��������ļ�
%wimlib% update mini.wim --command="add mini \ "
%wimlib% optimize mini.wim
start "" "%programfiles%\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "�������,����Դӿͻ�����������PE��!"
exit



::������ļ���
for /f "tokens=1,2 delims=: " %%a in ('echo %1') do (
set path=%%a
set wim=%%b
)