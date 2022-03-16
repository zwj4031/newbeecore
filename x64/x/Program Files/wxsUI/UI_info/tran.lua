--show_text = " The quick brown fox jumps over a lazy dog"
show_text = ""
lshift_index = 0
char_width = 2

TIMER_ID_FLUSH_TEXT = 1001
TIMER_ID_QUIT = 1002
NETINFO_TIMER_ID = 10086
received_old_str = "0"
received_new_str = "0"
receive_speed_str = "0"
Sent_new_str = "0"
Sent_speed_str = "0"
Sent_old_str = "0"
-- 提取固定值
temp = os.getenv("temp")
local cmd = io.popen('nwinfo --cpu&&mountvol')
local stdout = cmd:read("*a")
local fixed_out = {}
local Brand_str = stdout:match("Brand: ([^\n]+)\n")
local bios_str = stdout:match("EFI ([^\n]+)\n")
--检测环境
if bios_str == nil then 
bios_str = "传统 BIOS" 
else 
bios_str = "UEFI" 
end

function lshift_text()
   local new_text = show_text:sub(lshift_index + 1)
   lshift_index = lshift_index + char_width  -- 全汉字，一次移动2个字节
   if lshift_index > show_text:len() then lshift_index = 0 end
   elem_label_info.text = "<b>" .. new_text .. "</b>"
   elem_label_info.bkcolor = "#FEFFFFFF"

end

--to kb mb gb tb
function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

-- Convert bytes to human readable format
function bytesToSize(bytes)
  precision = 2
  kilobyte = 1024;
  megabyte = kilobyte * 1024;
  gigabyte = megabyte * 1024;
  terabyte = gigabyte * 1024;

  if((bytes >= 0) and (bytes < kilobyte)) then
    return bytes .. " B";
  elseif((bytes >= kilobyte) and (bytes < megabyte)) then
    return round(bytes / kilobyte, precision) .. ' KB';
  elseif((bytes >= megabyte) and (bytes < gigabyte)) then
    return round(bytes / megabyte, precision) .. ' MB';
  elseif((bytes >= gigabyte) and (bytes < terabyte)) then
    return round(bytes / gigabyte, precision) .. ' GB';
  elseif(bytes >= terabyte) then
    return round(bytes / terabyte, precision) .. ' TB';
  else
   return bytes .. ' B';
  end
end
function move_top()
  local w, h = sui:info('wh')
  if  has_option('-top') then
    -- 移动到顶部
    sui:move( ((Screen:GetX() - w) // 2)+2, - ((Screen:GetY() - h) // 2)+18, 0, 0)
	 --sui:move( 0, - ((Screen:GetX() - t) // 2), 0, 0)
  end
end



local function netinfo_init()
--exec('/hide', 'cmd /c nwinfo --net=active --sys --disk>%temp%nwinfo.log')
local cmd = io.popen('nwinfo --disk --net=active --sys')
--local cmd = io.popen('%temp%/nwinfo.log')
--local cmd = io.open(temp .. "\nwinfo.log", "r")
local stdout = cmd:read("*a")
--cmd:close()
local fixed_out = {}
local pcname_str = stdout:match("Computer Name: ([^\n]+)\n")
local memory_str = stdout:match("Physical memory %(free/total%): ([^\n]+)\n")
local memory_use_str = stdout:match("Memory in use: ([^\n]+)%%\n")
local memory_free_str = memory_str:match("([^/]+)/")
local memory_total_str = memory_str:match("/([^\n]+)")
local lanip_str = stdout:match("Unicast address [%d]+:[(]IPv4[)] ([^\n]+)\n")
local trans_str = stdout:match("Transmit link speed: ([^\n]+)\n")
local receive_str = stdout:match("Receive link speed: ([^\n]+)\n")
--local received_old_str = stdout:match("Received: ([^\n]+)Octets\n")
received_new_str = stdout:match("Received: ([^\n]+)Octets\n")
receive_speed_str = (received_new_str - received_old_str) // 5
receive_speed_str = bytesToSize(receive_speed_str)
received_old_str = received_new_str
--local received_str = tonumber(received_str)
Sent_new_str = stdout:match("Sent: ([^\n]+)Octets\n")
Sent_speed_str = (Sent_new_str - Sent_old_str) // 5
Sent_speed_str =  bytesToSize(Sent_speed_str)
Sent_old_str = Sent_new_str
local match_str = stdout:match("Description: ([^\n]+)\n")
--check_disk0
local disk0_str = stdout:match("Product ID: ([^\n]+)\n")
if disk0_str == nil then disk0_str = "------" end
local disk0_size_str = stdout:match("  Size: ([^\n]+)\n") 
if disk0_size_str == nil then disk0_size_str = "------" end
local disk0letters_str = stdout:match("Drive Letters: ([^\n]+)\n")
if disk0letters_str == nil then disk0letters_str = "------" end
--received_str = tostring(1111)


table.insert(fixed_out, 
	string.format("计算机名 <c #FFFF00>%s</c>  启动环境 <c #FFFF00>%s</c>", pcname_str, bios_str)
	
)
if lanip_str == "127.0.0.1" then
table.insert(fixed_out, 
	string.format("内网地址 <c #ff0000>网络断开了</c><i duanwang.png>")
)
table.insert(fixed_out, 
	string.format("网络速率 <c #ff0000>网络断开了</c><i duanwang.png>")
)
else 
table.insert(fixed_out, 
	string.format("内网地址 <c #FFFF00>%s</c> ", lanip_str)
)
table.insert(fixed_out, 
	string.format("网络速率 <c #FFFF00>%s</c> 下载 <c #FFFF00>%s/秒</c> 上传 <c #FFFF00>%s/秒</c>", receive_str, receive_speed_str, Sent_speed_str)
)

end


--内存占用告警
--[[
local memory_use_num = tonumber(memory_use_str)
memory_use_num = int(memory_use_num)
if memory_use_num > 0.1 then
table.insert(fixed_out, 
	string.format("内存使用  <c #ff0000>可用/总数 %s  %s</c> ", memory_str, memory_use_str)
)
else
--]]


table.insert(fixed_out, 
	string.format("主硬盘型号 <c #FFFF00>%s</c>", disk0_str)
	
)
table.insert(fixed_out, 
	string.format("主硬盘容量 <c #FFFF00>%s</c>", disk0_size_str)
	
)

table.insert(fixed_out, 
	string.format("主硬盘分区 <c #FFFF00>%s</c>", disk0letters_str)
	
)
if memory_use_str > "95" then 
table.insert(fixed_out, 
	string.format("内存可用 <c #FFFF00>%s</c>  总共 <c #FFFF00>%s</c>  占用率 <c #ff0000>%s%% 占用高 小心宕机</c>", memory_free_str, memory_total_str, memory_use_str)
)
else 
table.insert(fixed_out, 
	string.format("内存可用 <c #FFFF00>%s</c>  总共 <c #FFFF00>%s</c>  占用率 <c #FFFF00>%s%%</c>", memory_free_str, memory_total_str, memory_use_str)
)
end

table.insert(fixed_out, 

	string.format("CPU型号 <c #FFFF00>%s</c>", Brand_str)
	
)

local all_str = table.concat(fixed_out, "\n")
--elem_label_info = sui:find('label_info')
show_text = "<b>" ..  all_str .. "</b>"
elem_label_info.text = "<b>" ..  all_str .. "</b>"
elem_label_info.bkcolor = "#FEFFFFFF"
--a=winapi.show_message('title', all_str .."-", 'yes-no')

end


function onload()   
  local text = get_option('-text')
  local wait = get_option('-wait')
  -- winapi.show_message(text, wait)
  if text then
    if text:sub(1, 1) == '"' then text = text:sub(2, -2) end
    show_text = text
  end
  elem_label_info = sui:find('label_info')
  elem_label_info.text = "<b>" ..  show_text .. "</b>"
   -- 按文字内容调整窗体宽度
  local def_w, w
  def_w = sui:info('wh')
  move_top()
  w = #show_text // char_width * 42 -- 全汉字，一个汉字占2个字节
  if show_text:sub(1, 1) == ' ' then
    char_width = 1
    show_text = show_text:sub(2, -1)
    w = #show_text * 20
  end
  if w > Screen:GetX() then w = Screen:GetX() end
  if w > def_w then
    w = w - def_w
    sui:move(- w // 2, 0, w, 0)
  end

  if  has_option('-nwinfo') then
    -- 信息显示计时器，显示信息

	netinfo_init()
    suilib.call('SetTimer', NETINFO_TIMER_ID, 5000)
  end

  if  has_option('-scroll') then
    -- 滚动计时器，文字滚动效果
    suilib.call('SetTimer', TIMER_ID_FLUSH_TEXT, 300)
  end

  if wait then
    suilib.call('SetTimer', TIMER_ID_QUIT, wait * 1000)
  end
  
  
end

function ontimer(id)
   if id == TIMER_ID_QUIT then
     sui:close()
   elseif id == NETINFO_TIMER_ID then	
   	 netinfo_init()
 elseif id == TIMER_ID_FLUSH_TEXT then
     lshift_text()
   end
end

function ondisplaychanged()
  move_top()
end
