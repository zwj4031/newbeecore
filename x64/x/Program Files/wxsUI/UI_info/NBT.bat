/*&cls&echo off&cd /d "%~dp0"&rem 编码ANSI
title 加载外置软件包
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
echo;  找到以下外置包：
echo; !n!.%%a:\%wimfile%
echo;-----------------------------------	
)
)
if "%wim1%" == "" echo 找不到外置!&&pause&&exit
if "%wim2%" == "" call :menu %wim1%
set /p sel=请选择外置包:
call :menu !wim%sel%! 
)
exit /b

:menu
cls
set wimpath=%1
call :showmen
echo;
echo;------------------------------------
echo;      加载%wimpath%
echo;
echo;1【快速挂载】不占用内存，不可拔盘。
echo;2【完全挂载】载入内存，可拔盘。
echo;3【退    出】
echo;
echo;------------------------------------
echo;
echo;
echo;
echo;
echo;
set "input="
set /p input=选择选项:
if /i "%input%" equ "1" call :mount&&%wimlib% apply %wimpath% Y:\ --wimboot
if /i "%input%" equ "2"  call :mount&&%wimlib% apply %wimpath% Y:\
if /i "%input%" equ "3" (goto :exit)
echo;输入有误&pause&goto :memu
pause
exit

:mount
echo "%vhdfile%" 创建中……
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
echo "%vhdfile%" 创建完成! 加载外置软件包……
%wimlib% apply %wimpath% Y:\ --wimboot
::%wimlib% apply %wimpath% Y:\ %args%
if exist Y:\petools.INI pecmd load Y:\petools.INI
exit

:showmen
type "%~f0"|cscript -nologo -e:jscript "%~f0">".\v.v"
for /f "tokens=1* delims=|" %%a in ('cscript -nologo -e:vbscript ".\v.v" -mem') do (
    echo;                                            总内存:%%a  剩余:%%b
)
del /a /f /q ".\v.v" 2>nul
exit /b

*/