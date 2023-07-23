
function setpage(pagepath)
  if pagepath == "" then
   winapi.show_message("虚拟内存", "页面文件设置取消")
  else
   --System:CreatePageFile(pagepath, 8192,8192)
   exec('/hide', 'pecmd PAGE ' .. pagepath .. 'PAGEFILE.SYS 8192 8192')
   winapi.show_message("虚拟内存", [[页面文件]] .. pagepath .. [[\PAGEFILE.SYS 已经建立]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('警告', a)
   local pagepath = Dialog:BrowseFolder('你要把[虚拟内存页面文件]设置何处？适合小内存机器使用QQ微信等工具，默认8G', 17)
   setpage(pagepath)
else
return
end
end


--if memory_use_str > "88" then
local m = mem_info()[3]/1024/1024
if m < 200 then
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
	
