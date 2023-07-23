--[=[ 2>nul

set WINXSHELL_LUASCRIPT=WinXShellTest.lua
set WINXSHELL_LOGFILE=C:\Windows\Temp\WinXShell.log

set WINXSHELL=WinXShell.exe
set x8664=x64
if not "x%PROCESSOR_ARCHITECTURE%"=="xAMD64" set x8664=x86
if not exist %WINXSHELL% set WINXSHELL=WinXShell_%x8664%.exe
if not exist %WINXSHELL%  set WINXSHELL=x64\Debug\WinXShell.exe


%WINXSHELL% -console -script "%~dpnx0"
type "%WINXSHELL_LOGFILE%"

goto :EOF
]=]

--- -- ====================  lua script  ====================



Alert('abc', 123, App:Version())


App:Sleep(50)
App:Error("[ERROR] Failed to do something.")
App:Warn("CAUTION !!!")
App:InfoLog("notice message")
App:Debug("message in one line")
App:Debug("one", "two")

App:SetTimer('测试App计时器', 3000)

AppTimer['测试App计时器'] = function(tid)
    Alert('时间到')
end

Alert('OK to Finish')


