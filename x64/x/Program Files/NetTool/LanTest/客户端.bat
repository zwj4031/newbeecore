@echo off
cd /d %~dp0
title ���������ܲ��Թ���(�ͻ���)
color 0a
iperf3.exe -v
@echo �ù������ڲ��Է�������ͻ���֮���TCP�������ܡ�
@echo.
@echo Transfer�������ٶ�MB/S
@echo Bandwidth����������Mbits/S
@echo ǧ�������������ʴ���900Mbits/s�����������������ʴ���9000Mbits/s
@echo.
set /p SerIP=���������˵�ip��
iperf3.exe -c %SerIP% -f m -w 64k -t 1200 -i 1