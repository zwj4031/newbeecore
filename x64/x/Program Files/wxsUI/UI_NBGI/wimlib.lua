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


--local exitcode, stdout = winapi.execute([["X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe" info G:\win10.esd -xml]])
exec("/hide /wait", [[cmd /c "X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe" info g:\win10.esd --extract-xml X:\Windows\temp\temp.xml]])
local path = [[X:\Windows\temp\temp.xml]]
local file = io.open(path, "rb")
text = file:read("*a")
file:close()
text_ansi = winapi.encode(winapi.CP_UTF16, winapi.CP_ACP, text)
local index_regex = "<IMAGE INDEX=\"(%d+)\""
local disname_regex = "<DISPLAYNAME>([^<]+)</DISPLAYNAME>"
local name_regex = "<NAME>([^<]+)</NAME>"
local bytes_regex = "<TOTALBYTES>([^<]+)</TOTALBYTES>"


for index_str in string.gfind(text_ansi, "<IMAGE INDEX=*.-</IMAGE>") do
local index_name = index_str:match(disname_regex)
local index_n = index_str:match(index_regex)
local index_bytes = index_str:match(bytes_regex)
if index_name == nil then 
index_name = index_str:match(name_regex)
winapi.show_message("分卷", "卷" .. index_n .. ":".. index_name .. "大小" .. index_bytes)
else
winapi.show_message("分卷", "卷" .. index_n .. ":".. index_name .. "大小" .. index_bytes)
--Alert(index_name)
end

end
