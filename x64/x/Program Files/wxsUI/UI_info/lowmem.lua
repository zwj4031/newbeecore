function check(a) 
if a == "yes" then
--winapi.show_message('����', a)
exec('/hide /wait', 'cmd /c wscript.exe //nologo wxsUI\\UI_info\\page.vbs')	
else
return
end
end


--if memory_use_str > "88" then
local m = mem_info()[3]/1024/1024
if m < 100 then
a=winapi.show_message('����', "�ڴ治��! ��ʣ" .. m ..
 "M��!\n�����Ҫ��װϵͳ���������������ڴ浽Ӳ�����һ������!\n�����Ҫ������������ʱ���������ڴ浽U���ϣ�����ػ����ٰ�U��!", 'yes-no')
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
	
