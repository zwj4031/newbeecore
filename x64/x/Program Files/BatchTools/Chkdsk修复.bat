@echo off 2>nul 3>nul
mode con cols=50 lines=5
setlocal enabledelayedexpansion
set /p Input=输入要修复的系统安装盘符[例如D]：
mode con cols=90 lines=100
   chkdsk /x %Input%:

%0