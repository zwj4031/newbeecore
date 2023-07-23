-- 正则匹配获取多行
local indexlist = {}
function string.gfind(stdout, patten)
    local i, j = 0, 0
    return function()
        i, j = string.find(stdout, patten, j + 1)
        if (i == nil) then -- end find
            return nil
        end
        return string.sub(stdout, i, j)
    end
end


local exitcode, stdout = winapi.execute("Dism.exe /English /Get-WimInfo /WimFile:" .. bootfile)
stdout = stdout:gsub("\r\n", "\n")
        for dism_str in string.gfind(stdout, "Index*.-bytes") do
		local size_str = dism_str:match("Size : ([^\n]+)")	
         local index_str = dism_str:match("Index : ([^\n]+)\n")
		local name_str = dism_str:match("Name : ([^\n]+)\n")
	    indexlist_str = string.format("卷:%s  版本:%s 大小:%s", index_str, name_str, size_str)
    	table.insert(indexlist, indexlist_str)	
	
		end	

 all_index = table.concat(indexlist, "\n")
 myindex = string.format("请选择镜像中的分卷恢复\n%s",all_index)
