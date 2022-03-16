function check(a) 
if a == "yes" then
--winapi.show_message('警告', a)
exec('/hide /wait', 'cmd /c wscript.exe //nologo wxsUI\\UI_info\\page.vbs')	
else
return
end
end


--if memory_use_str > "88" then
local m = mem_info()[3]/1024/1024
if m < 100 then
a=winapi.show_message('警告', "内存不足! 仅剩" .. m ..
 "M了!\n如果你要安装系统，必须设置虚拟内存到硬盘最后一个分区!\n如果你要分区，可以暂时设置虚拟内存到U盘上，但请关机后再拔U盘!", 'yes-no')
check(a)
else
return
end

--[[
    local exitcode, stdout = winapi.execute("nwinfo.exe --sys")
    stdout = stdout:gsub("\r\n", "\n")
    local fixed_out = {}
    local memory_str = stdout:match("Physical memory %(free/total%): ([^\n]+)\n")
    local memory_use_str = stdout:match("Memory in use: ([^\n]+)%%\n")
    local memory_free_str = memory_str:match("([^/]+)/")
    local memory_total_str = memory_str:match("/([^\n]+)")
--]]
	
