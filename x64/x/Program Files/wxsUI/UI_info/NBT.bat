/*&cls&echo off&cd /d "%~dp0"&rem ����ANSI
title �������������
mode con cols=36 lines=20
set wimfile=NBtools.wim
set vhdfile=X:\nbtools.vhd
set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"
set wimpath=NBtools.wim
set wim1=


:findwim
setlocal enabledelayedexpansion
set n=0
for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D C) do (
    if exist "%%a:\%wimfile%" (
        set /a n+=1
        set wim!n!=%%a:\%wimfile%
		echo;------------------------------------
echo;  �ҵ��������ð���
echo; !n!.%%a:\%wimfile%
echo;-----------------------------------	
)
)
if "%wim1%" == "" echo �Ҳ�������!&&pause&&exit
if "%wim2%" == "" call :menu %wim1%
set /p sel=��ѡ�����ð�:
call :menu !wim%sel%! 
)
exit /b

:menu
cls
set wimpath=%1
call :showmen
echo;
echo;------------------------------------
echo;      ����%wimpath%
echo;
echo;1�����ٹ��ء���ռ���ڴ棬���ɰ��̡�
echo;2����ȫ���ء������ڴ棬�ɰ��̡�
echo;3����    ����
echo;
echo;------------------------------------
echo;
echo;
echo;
echo;
echo;
set "input="
set /p input=ѡ��ѡ��:
if /i "%input%" equ "1" call :mount&&%wimlib% apply %wimpath% Y:\ --wimboot
if /i "%input%" equ "2"  call :mount&&%wimlib% apply %wimpath% Y:\
if /i "%input%" equ "3" (goto :exit)
echo;��������&pause&goto :memu
pause
exit

:mount
echo "%vhdfile%" �����С���
(
echo create vdisk file="%vhdfile%" maximum=131072 type=expandable
echo select vdisk file="%vhdfile%"
echo attach vdisk
echo create partition primary
echo assign letter=Y
echo format fs=NTFS quick label="NBTools"
echo exit
)|diskpart
cls
echo "%vhdfile%" �������! �����������������
%wimlib% apply %wimpath% Y:\ --wimboot
::%wimlib% apply %wimpath% Y:\ %args%
if exist Y:\petools.INI pecmd load Y:\petools.INI
exit

:showmen
type "%~f0"|cscript -nologo -e:jscript "%~f0">".\v.v"
for /f "tokens=1* delims=|" %%a in ('cscript -nologo -e:vbscript ".\v.v" -mem') do (
    echo;                                            ���ڴ�:%%a  ʣ��:%%b
)
del /a /f /q ".\v.v" 2>nul
exit /b

*/