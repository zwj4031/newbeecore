@echo off
cd /d %~dp0
title 局域网性能测试工具(服务端)
color 0a
iperf3.exe -v
@echo 该工具用于测试服务器与客户机之间的TCP传输性能。
@echo.
iperf3.exe -s