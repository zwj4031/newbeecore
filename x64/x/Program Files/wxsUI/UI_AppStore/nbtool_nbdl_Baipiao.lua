local TID_LISTWINVER_CHANGED = 20001 + 1
USERPROFILE = os.getenv("USERPROFILE")
temp = os.getenv("temp") .. [[\]]
SystemDrive = os.getenv("SystemDrive")
listwinver = sui:find("listwinver")
listwinver.visible="1"



if File.exists("X:\\ipxefm\\ipxeboot.txt") then
  very_runmode = "pe"
  zexe = [[X:\\Program Files\\7-zip\\7z.exe]]
else
  very_runmode = "system"
  zexe = "%temp%\\AppStore\\bin\\7zx64.exe"
end
-- 正则匹配获取多行
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
user_agent = [[--user-agent="Chrome/94.0.4606.71"]]

if not File.exists(temp .. [[\]] .. BaiPiaoid .. [[.cab]]) then

    exec(
        "/wait /hide",
        [[cmd /c aria2c ]] ..
        user_agent .. [[ --allow-overwrite=true ]] .. BaiPiaourl .. [[ -d %temp% -o ]] .. BaiPiaoid .. [[.cab]]
		)
	
end

if File.exists(temp .. [[\]] .. BaiPiaoid .. [[.cab]]) then
exec("/wait /hide", zexe .. [[ -y x %temp%\]] .. BaiPiaoid .. [[.cab -owxsUI\UI_AppStore\]])
else
Alert("白嫖失败!")

end

local path = "wxsUI\\UI_AppStore\\products.xml"
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
--64位全加入
table.insert(ver,string.format("64位家庭中文版 下载地址:%s", ver.chinax64url))  
table.insert(ver,string.format("64位商业中文版 下载地址:%s", ver.businessx64url))
table.insert(ver,string.format("64位零售中文版 下载地址:%s", ver.consumerx64url))
--32位检测
if ver.chinax86url ~= nil then
table.insert(ver,string.format("32位家庭中文版 下载地址:%s", ver.chinax86url)) 
end
if ver.businessx86url ~= nil then
table.insert(ver,string.format("32位商业中文版 下载地址:%s", ver.businessx86url))
end
if ver.consumerx86url ~= nil then
table.insert(ver,string.format("32位零售中文版 下载地址:%s", ver.consumerx86url))
end
all = table.concat(ver, "\n")
 myindex = string.format("已获取到%s相关链接，点这里选择镜像下载(网址已批量复制,请粘贴到记事本！)\n%s", BaiPiaoname, all)
 clipboard_url = winapi.set_clipboard(myindex)
 listwinver = sui:find("listwinver")
 listwinver.list = myindex
 listwinver.index = 0
 
 
 

--timer列表框事件检测
function listwinver_onchanged()
   esdurl = ver[listwinver.index]:match("http[^\"]*/[^\"]*/[^\"]*")
   esdname = string.format("%s.esd", ver[listwinver.index]:match("[^\"]+ "))
   esdname = string.gsub(esdname, " ", "")
   


   
    exec(
        "/wait /hide",
        [[cmd /c  start "" WINXSHELL -ui -jcfg wxsUI\UI_AppStore\nbtool_nbdl.jcfg -app_url "]] .. esdurl .. [["]] ..
		" -app_name " .. esdname .. 
		" -downpath " .. downpath ..
		" -app_setup " .. esdname
	
		)
end
--按钮事件检测 

--列表框化变触发事件 
function onchanged(ctrl)
  if ctrl == "listwinver" then
    suilib.call("SetTimer", TID_LISTWINVER_CHANGED, 200)

end 	
end






function ontimer(tid)
  if tid == TID_LISTWINVER_CHANGED then
    suilib.call("KillTimer", tid)
    listwinver_onchanged()

  end
end

--alert(all)