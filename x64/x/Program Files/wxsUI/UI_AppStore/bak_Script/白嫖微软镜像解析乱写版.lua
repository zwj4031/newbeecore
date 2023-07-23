temp = os.getenv("temp")
-- ����ƥ���ȡ����
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

local path = [[e:\products.xml]]
local file = io.open(path, "rb")
text = file:read("*a")
file:close()
--text_ansi = winapi.encode(winapi.CP_UTF16, winapi.CP_ACP, text)
local index_regex = "<File id=\"\">"
local edition_regex = "<Edition>([^<]+)</Edition>"
local lcode_regex = "<LanguageCode>([^<]+)</LanguageCode>"
local filepath_regex = "<FilePath>([^<]+)</FilePath>"

ver={}
for index_str in string.gfind(text, "<File id=*.-</File>") do
local index_name = index_str:match(index_regex)
local index_edition = index_str:match(edition_regex)
local index_filepath = index_str:match(filepath_regex)
local index_lcode = index_str:match(lcode_regex)
if index_lcode == "zh-cn" and index_str:find("CLIENTCHINA") and index_str:find("x64") then 
ver.chinax64url = index_filepath
  
elseif index_lcode == "zh-cn" and index_str:find("CLIENTCHINA") and index_str:find("x86") then 
ver.chinax86url = index_filepath

elseif index_lcode == "zh-cn" and index_str:find("CLIENTBUSINESS") and index_str:find("x64") then 
ver.businessx64url = index_filepath

elseif index_lcode == "zh-cn" and index_str:find("CLIENTBUSINESS") and index_str:find("x86") then 
ver.businessx86url = index_filepath

elseif index_lcode == "zh-cn" and index_str:find("Ultimate") and index_str:find("CLIENTCONSUMER") and index_str:find("x64") then 
ver.consumerx64url = index_filepath

elseif index_lcode == "zh-cn" and index_str:find("Ultimate") and index_str:find("CLIENTCONSUMER") and index_str:find("x86") then 
ver.consumerx86url = index_filepath


end

end
table.insert(ver,string.format("64λ��ͥ���İ�: ���ص�ַ%s", ver.chinax64url))   
table.insert(ver,string.format("32λ��ͥ���İ�: ���ص�ַ%s", ver.chinax86url))  
table.insert(ver,string.format("64λ��ҵ���İ�: ���ص�ַ%s", ver.businessx64url))
table.insert(ver,string.format("32λ��ҵ���İ�: ���ص�ַ%s", ver.businessx86url))
table.insert(ver,string.format("64λ�������İ�: ���ص�ַ%s", ver.consumerx64url))
table.insert(ver,string.format("32λ�������İ�: ���ص�ַ%s", ver.consumerx86url))
all = table.concat(ver, "\n")
alert(all)