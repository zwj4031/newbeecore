@echo off
cd /d %~dp0
title 局域网性能测试工具(客户端)
color 0a
iperf3.exe -v
@echo 该工具用于测试服务器与客户机之间的TCP传输性能。
@echo.
@echo Transfer：传输速度MB/S
@echo Bandwidth：传输速率Mbits/S
@echo 千兆网卡理论速率大于900Mbits/s，万兆网卡理论速率大于9000Mbits/s
@echo.
set /p SerIP=请输入服务端的ip：
iperf3.exe -c %SerIP% -f m -w 64k -t 1200 -i 1