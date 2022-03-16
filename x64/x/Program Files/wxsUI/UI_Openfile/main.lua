dofile ("wxsUI\\UI_Openfile\\types\\media")
dofile ("wxsUI\\UI_Openfile\\types\\work")
local file_type = "未知类型"
local file_ext = ""
local show_text = ""
local lshift_index = 0
local char_width = 2
local TIMER_ID_FLUSH_TEXT = 1001
local TIMER_ID_QUIT = 1002
local openfile_TIMER_ID = 10088
local process_val = 0
local eta_str = ""
local dl_str = ""
local stdout = ""
local str = ""
local temp = os.getenv("temp")
local root = os.getenv("WINXSHELL_MODULEPATH")


function lshift_text()
    local new_text = show_text:sub(lshift_index + 1)
    lshift_index = lshift_index + char_width -- 全汉字，一次移动2个字节
    if lshift_index > show_text:len() then
       lshift_index = 0
    end
    elem_label_info.text = "" .. new_text .. "</b>"
    elem_label_info.bkcolor = "#FEFFFFFF"
end


function show_message()
local all_str = table.concat(fixed_out, "\n")
    elem_label_title = sui:find("label_title")
  	elem_label_title.text = "[" .. file_type .. "]"
	elem_label_info = sui:find("label_info")
   	elem_label_info.text = "" .. all_str .. ""
Hinfo = sui:find("label_info")	
Hinfo_text = Hinfo.text
h = #Hinfo_text // 2
if h > 480 then
Hinfo.height = "1920"
--winapi.show_message("字符数", h .. "超出界面，上滚动条") 
else 
Hinfo.height = "370"
end	
end
--界面元素点击事件
function onlink(url)
    if url == "vlc" and file ~= nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp vlc -app_file ]] .. file)
	elseif url == "vlc" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp vlc]])
	elseif url == "qq" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp qq]]) 
	elseif url == "wechat" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp wechat]]) 
	elseif url == "Alpemix" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp Alpemix]])   
	 
	elseif url == "dbadmin" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp dbadmin]])   
	 	 
	elseif url == "todesk" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp todesk]]) 
    elseif url == "todesklite" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp todesklite]])   	 
	 
	elseif url == "oray" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp oray]]) 
    elseif url == "oraynew" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp oraynew]])   
	 
	elseif url == "wps2016" then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp wps2016]])
	elseif url == "potplayer" and file ~= nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp potplayer -app_file ]] .. file)
	elseif url == "potplayer" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp potplayer]])
	elseif url == "kodi" then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp kodi]]) 
	 
    elseif url == "vm16" and file ~= nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp vm16 -app_file ]] .. file) 
    elseif url == "vm16" and file == nil then
     exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp vm16]])  
    elseif url == "notepad" then
     exec('/show', [["X:\\Program Files\\Notepad++\\notepad++.exe" ]] .. file) 
	elseif url == "changename" then
    winapi.show_message("改计算机名", url)
	else	   
	exec('/show', [["WinXShell.exe" -ui -jcfg wxsUI\\UI_openfile\\main.jcfg -file ]] .. url) 
       --app:run(url .. ":\\")
   end
  sui:close()	
end


function onclick(ctrl)
   if ctrl == 'media' then
    dofile ("wxsUI\\UI_Openfile\\rules\\media.lua")
	file_type = "影音娱乐"
	show_message()
	elseif ctrl == "work" then
	dofile ("wxsUI\\UI_Openfile\\rules\\work.lua")
	file_type = "文档办公"
	show_message()
	elseif ctrl == "vm" then
    dofile ("wxsUI\\UI_Openfile\\rules\\vm.lua")
	file_type = "虚拟机类"
	show_message()
	else
	dofile ("wxsUI\\UI_Openfile\\rules\\" .. ctrl .. ".lua")
	show_message()
  end

end

function move_top()
    local w, h = sui:info("wh")
    if has_option("-top") then
          sui:move(((Screen:GetX() - w) // 2) + 2, -((Screen:GetY() - h) // 2) + 22, 0, 0)
    end
end

--获取扩展名
function getExtension(str)
    file_ext = str:match(".+%.(%w+)$")
	
for key,value in ipairs(media_list) 
    do
	if file_ext:find("" .. value .. "") then

	soft_list = "media"
	file_type = "多媒体类"
	end
end
	
for key,value in ipairs(work_list) 
    do
	if file_ext:find("" .. value .. "") then
	soft_list = "work"
	file_type = "文档办公类"
    end
end

if file_ext == "vmx" then
soft_list = "vm"
file_type = "虚拟机"
end
left_bk = sui:find("" .. soft_list)
left_bk.bkimage = "wxsUI\\UI_Openfile\\themes\\text.png"	
return str

end


function openfile_init()
fixed_out = {}
if file ~= nil then
file_ext = getExtension(file)
end
if soft_list == "media" or url == "media" then
 --colorbak FFFF00		
dofile ("wxsUI\\UI_Openfile\\rules\\media.lua")
show_message()
elseif soft_list == "work" or url == "work" then
show_message()
--colorbak FFFF00		
dofile ("wxsUI\\UI_Openfile\\rules\\work.lua")
show_message()
elseif soft_list == "vm" or url == "vm" then
dofile ("wxsUI\\UI_Openfile\\rules\\vm.lua")
show_message()
else
table.insert(
                fixed_out,
                string.format("当前格式暂不支持!")
            )				
	
table.insert(
                fixed_out,
                string.format("<i ..\\UI_DL\\app_ico\\Notepad++.png><a notepad><c #000000>用Notepad++打开</c></a> \n以文本方式打开\n")
            )
end
show_message()

end



function onload()
    local text = get_option("-text")
    local wait = get_option("-wait")
	file = get_option("-file")
	if text then
        if text:sub(1, 1) == '"' then
            text = text:sub(2, -2)
        end
        show_text = text
    end
    elem_label_info = sui:find("label_info")
  
    -- 按文字内容调整窗体宽度
    local def_w, w
    def_w = sui:info("wh")
    move_top()
    w = #show_text // char_width * 2 -- 全汉字，一个汉字占2个字节   w = #show_text // char_width * 2 -- 全汉字，一个汉字占2个字节
    if show_text:sub(1, 1) == " " then
        char_width = 1
        show_text = show_text:sub(2, -1)
        w = #show_text * 10
    end
    if w > Screen:GetX() then
        w = Screen:GetX()
    end
    if w > def_w then
        w = w - def_w
        sui:move(-w // 2, 0, w, 0)
    end
    if has_option("-scroll") then
        -- 滚动计时器，文字滚动效果
        suilib.call("SetTimer", TIMER_ID_FLUSH_TEXT, 300)
    end
	if has_option("-file") then
	openfile_init()
	else
	dofile ("wxsUI\\UI_Openfile\\rules\\media.lua")
	file_type = "影音娱乐"
	show_message()
	end	
	
--suilib.call("SetTimer", openfile_TIMER_ID, wait * 5000)

	
    if wait then
        suilib.call("SetTimer", TIMER_ID_QUIT, wait * 1000)
    end
end

function ontimer(id)
    if id == TIMER_ID_QUIT then
        sui:close()
    elseif id == TIMER_ID_FLUSH_TEXT then
        lshift_text()
    end
end

function ondisplaychanged()
    move_top()
end
