--show_text = " The quick brown fox jumps over a lazy dog"
--文件判断语句备份
--if File.exists([[X:\dxdiag.ico]]) then 
--winapi.show_message("文件检测", "存在")
--else
--winapi.show_message("文件检测", "不存在")
--end
local Gbe_list =
{
  "Gigabit Network Connection",
  "Gigabit Ethernet Controller",
  "GbE Family Controller",
}

function check_adapter(lanname)
for key,value in ipairs(Gbe_list) 
 do
if lanname:find("" .. value .. "") then
lanname = string.gsub(lanname, value, "千兆网卡", 1)
end
end
return lanname .. ""
end		

local show_text = ""
local lshift_index = 0
local char_width = 2
local TIMER_ID_FLUSH_TEXT = 1001
local TIMER_ID_QUIT = 1002
local NETINFO_TIMER_ID = 10086
local received_old_str = "0"
local received_new_str = "0"
local receive_speed_str = "0"
local Sent_new_str = "0"
local Sent_speed_str = "0"
local Sent_old_str = "0"
local diskletters_link_str = ""
local lspanfu_diskN = -1
-- 提取固定值
local temp = os.getenv("temp")
local SystemDrive = os.getenv("SystemDrive")
--local cmd = io.popen("nwinfo --cpu --sys&&mountvol")
--local stdout = cmd:read("*a")
local exitcode, stdout = winapi.execute("nwinfo --cpu --sys&&mountvol")
stdout = stdout:gsub("\r\n", "\n")
local fixed_out = {}
local Brand_str = stdout:match("Brand: ([^\n]+)\n")
local bios_str = stdout:match("EFI ([^\n]+)\n")
local Secure_str = stdout:match("Secure Boot: ([^\n]+)\n")
if Secure_str == "enabled" then
     Secure_str = "开"
elseif Secure_str == "disabled" then
     Secure_str = "关"
end
--检测环境
if bios_str == nil then
    bios_str = "传统 BIOS"
else
    bios_str = "UEFI"
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
function lshift_text()
    local new_text = show_text:sub(lshift_index + 1)
    lshift_index = lshift_index + char_width -- 全汉字，一次移动2个字节
    if lshift_index > show_text:len() then
       lshift_index = 0
    end
    elem_label_info.text = "<b>" .. new_text .. "</b>"
    elem_label_info.bkcolor = "#FEFFFFFF"
end
--界面元素点击事件
function onlink(url)
    if url == "changeip" and SystemDrive == "X:" then
        exec("X:\\Program Files\\PENetwork\\PENetwork.exe")
    elseif url == "changeip" and SystemDrive ~= "X:" then
        wxs_open("netsettings")
    elseif url == "lspanfu" and SystemDrive == "X:" then
        exec("pecmd.exe wxsUI\\UI_info\\lspanfu.wcs")
	 elseif url == "bcdboot" and SystemDrive == "X:" then
        exec("pecmd.exe BCDBOOT -gui")	
	elseif url == "banjia" and SystemDrive == "X:" then
        exec('/hide', 'cmd /c wscript.exe //nologo wxsUI\\UI_info\\banjia.vbs')
	elseif url == "page" and SystemDrive == "X:" then
        exec('/hide', 'cmd /c wscript.exe //nologo wxsUI\\UI_info\\page.vbs')	
	elseif url == "banjia" and SystemDrive ~= "X:" then
        winapi.show_message("文档搬家", "不支持非PE环境")
    elseif url == "changename" then
        winapi.show_message("改计算机名", url)
    else
        --app:run('X:\\Progra~1\\Explorer.exe', '"' .. url .. ':\"')
        app:run(url .. ":\\")
    end
end
--to kb mb gb tb
function round(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
-- Convert bytes to human readable format
function bytesToSize(bytes)
    precision = 2
    kilobyte = 1024
    megabyte = kilobyte * 1024
    gigabyte = megabyte * 1024
    terabyte = gigabyte * 1024
    if ((bytes >= 0) and (bytes < kilobyte)) then
        -- return bytes .. " B";
        return "<1KB "
    elseif ((bytes >= kilobyte) and (bytes < megabyte)) then
        return round(bytes / kilobyte, precision) .. " KB"
    elseif ((bytes >= megabyte) and (bytes < gigabyte)) then
        return round(bytes / megabyte, precision) .. " MB"
    elseif ((bytes >= gigabyte) and (bytes < terabyte)) then
        return round(bytes / gigabyte, precision) .. " GB"
    elseif (bytes >= terabyte) then
        return round(bytes / terabyte, precision) .. " TB"
    else
        -- return bytes .. ' B';
        return "<1KB "
    end
end
function move_top()
    local w, h = sui:info("wh")
    if has_option("-top") then
        -- 移动到顶部
        sui:move(((Screen:GetX() - w) // 2) + 2, -((Screen:GetY() - h) // 2) + 22, 0, 0)
    --sui:move( 0, - ((Screen:GetX() - t) // 2), 0, 0)
    end
end
local function netinfo_init()
    --exec('/hide', 'cmd /c nwinfo --net=active --sys --disk>%temp%nwinfo.log')
    --*local cmd = io.popen("nwinfo --disk --net=active --sys")
    --local cmd = io.popen('%temp%/nwinfo.log')
    --local cmd = io.open(temp .. "\nwinfo.log", "r")
    --*local stdout = cmd:read("*a")
    --cmd:close()
    local exitcode, stdout = winapi.execute("nwinfo.exe --disk --net=active --sys")
    stdout = stdout:gsub("\r\n", "\n")
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
    Sent_speed_str = bytesToSize(Sent_speed_str)
    Sent_old_str = Sent_new_str
    local match_str = stdout:match("Description: ([^\n]+)\n")
    --check_disk0
    local disk0_str = stdout:match("Product ID: ([^\n]+)\n")
    if disk0_str == nil then
        disk0_str = "------"
    end
    local disk0_size_str = stdout:match("  Size: ([^\n]+)\n")
    if disk0_size_str == nil then
        disk0_size_str = "------"
    end
    local disk0letters_str = stdout:match("Drive Letters: ([^\n]+)\n")
    if disk0letters_str == nil then
        disk0letters_str = "------"
    end
    --received_str = tostring(1111)
    if bios_str == "UEFI" then
        table.insert(
            fixed_out,
            string.format(
                "计算机名 <c #FFFF00>%s</c>  启动环境 <c #FFFF00>%s</c>  安全启动: <c #FFFF00>%s</c>",
                pcname_str,
                bios_str,
                Secure_str
            )
        )
    else
        table.insert(fixed_out, string.format("计算机名 <c #FFFF00>%s</c>  启动环境 <c #FFFF00>%s</c>", pcname_str, bios_str))
    end
    if memory_use_str > "95" then
        table.insert(
            fixed_out,
            string.format(
                "内存可用 <c #FFFF00>%s</c>  总共 <c #FFFF00>%s</c>  <c #ff0000>占用率高 小心宕机 %s%%</c>",
                memory_free_str,
                memory_total_str,
                memory_use_str
            )
        )
    else
        table.insert(
            fixed_out,
            string.format(
                "内存可用 <c #FFFF00>%s</c>  总共 <c #FFFF00>%s</c>  占用率 <c #FFFF00>%s%%</c>",
                memory_free_str,
                memory_total_str,
                memory_use_str
            )
        )
    end
    if lanip_str == "127.0.0.1" then
        table.insert(fixed_out, string.format("<c #ff0000>网络断开了</c><i duanwang.png>"))
    else
        table.insert(
            fixed_out,
            string.format(
                "网络速率 <c #FFFF00>%s</c> 下载 <c #FFFF00>%s/秒</c> 上传 <c #FFFF00>%s/秒</c>",
                receive_str,
                receive_speed_str,
                Sent_speed_str
            )
        )
        --多个网卡
        eths = 0
        for eth_str in string.gfind(stdout, "Network adapter*.-Sent") do
            local lanip_str = eth_str:match("Unicast address [%d]+:[(]IPv4[)] ([^\n]+)\n")
            local lanname_str = eth_str:match("Description: ([^\n]+)\n")
            local lanmac_str = eth_str:match("MAC address: ([^\n]+)\n")
            local landhcp_str = eth_str:match("DHCP Enabled: ([^\n]+)\n")
            --判断ip是静态还是动态获取--网启服务器必须静态
            if landhcp_str == "YES" then
                landhcp_str = "动态"
            elseif landhcp_str == "NO" then
                landhcp_str = "静态"
            end
            if not lanname_str:find("Loopback") and not lanname_str:find("VMware") then
                eths = eths + 1
				lanname_str = check_adapter(lanname_str)
			    table.insert(fixed_out, string.format("网卡<c #FFFF00>%s</c>: <c #FFFF00>%s</c>", eths, lanname_str))
                table.insert(
                    fixed_out,
                    string.format(
                        "         IP(<c #FFFF00>%s</c>): <A changeip><c #FFFF00>%s</c></A> MAC <c #FFFF00>%s</c>",
                        landhcp_str,
                        lanip_str,
                        lanmac_str
                    )
                )
				
            end
        end
    end
    ---多个硬盘
    disks = 0
    for disk_str in string.gfind(stdout .. "\\.", "\\*.-\n\\") do
        --local diskname_str = disk_str:match("Product ID: ([^\n]+)\n")
        local diskname_str = disk_str:match("HW Name: ([^\n]+)\n")
        local disk_size_str = disk_str:match("Size: ([^\n]+)\n")
        local diskletters_str = disk_str:match("Drive Letters: ([^\n]+)\n")
        local diskletters_str = disk_str:match("Drive Letters: ([^\n]+)\n")
        local disktype_str = disk_str:match("Type: ([^\n]+)\n")
        diskletters_link_str = ""
        if diskletters_str == nil then
            diskletters_str = " 未分配 "
        end
        for token in string.gmatch(diskletters_str, "[^%s]+") do
            diskletters_link_str = diskletters_link_str .. "{a " .. token .. "}<c #FFFF00>" .. token .. "</c>{/a} "
        end
        if disktype_str:find("Removable") or disktype_str:find("USB") and diskname_str ~= nil then
            table.insert(
                fixed_out,
                string.format("磁盘<c #FFFF00>%s</c>(<c #FFFF00>U盘</c>): <c #FFFF00>%s</c>", disks, diskname_str)
            )
        elseif diskname_str ~= nil then
            table.insert(fixed_out, string.format("磁盘<c #FFFF00>%s</c>: <c #FFFF00>%s</c>", disks, diskname_str))
        elseif diskname_str == nil then
            table.insert(fixed_out, string.format("磁盘<c #FFFF00>0</c>:<c #ff0000>PE没有找到任何磁盘</c><i duanwang.png>"))
        end
        if diskname_str ~= nil then
            table.insert(
                fixed_out,
                string.format("         容量 <c #FFFF00>%s</c> 分区 <c #FFFF00>%s</c>", disk_size_str, diskletters_link_str)
            )
            if lspanfu_diskN == -1 then
                -- 记录第一次有分区的位置(table的当前数据个数)
                lspanfu_diskN = #fixed_out
            end
        end
        disks = disks + 1
    end
    -- 给第一次有分区的信息后面追加 理顺 超链接
    if lspanfu_diskN > -1 then
        fixed_out[lspanfu_diskN] = fixed_out[lspanfu_diskN] .. " <a lspanfu><c #FFFF00>理顺</c></a> <a bcdboot><c #FFFF00>引导</c></a> <a banjia><c #FFFF00>搬家</c></a> <a page><c #FFFF00>页面</c></a>"
    end
    table.insert(fixed_out, string.format("CPU <c #FFFF00>%s</c>", Brand_str))
    local all_str = table.concat(fixed_out, "\n")
    --elem_label_info = sui:find('label_info')
    show_text = "<b>" .. all_str .. "</b>"
    --elem_label_info.text = "<b>" .. all_str .. "</b>"
	elem_label_info.text = all_str
    --a=winapi.show_message('title', diskname_str .."-", 'yes-no')
end
function onload()
    local text = get_option("-text")
    local wait = get_option("-wait")
    -- winapi.show_message(text, wait)
    if text then
        if text:sub(1, 1) == '"' then
            text = text:sub(2, -2)
        end
        show_text = text
    end
    elem_label_info = sui:find("label_info")
    elem_label_info.text = "<b>" .. show_text .. "</b>"
    -- 按文字内容调整窗体宽度
    local def_w, w
    def_w = sui:info("wh")
    move_top()
    w = #show_text // char_width * 42 -- 全汉字，一个汉字占2个字节
    if show_text:sub(1, 1) == " " then
        char_width = 1
        show_text = show_text:sub(2, -1)
        w = #show_text * 20
    end
    if w > Screen:GetX() then
        w = Screen:GetX()
    end
    if w > def_w then
        w = w - def_w
        sui:move(-w // 2, 0, w, 0)
    end
    if has_option("-nwinfo") then
        -- 信息显示计时器，显示信息
        netinfo_init()
        suilib.call("SetTimer", NETINFO_TIMER_ID, 5000)
    end
    if has_option("-scroll") then
        -- 滚动计时器，文字滚动效果
        suilib.call("SetTimer", TIMER_ID_FLUSH_TEXT, 300)
    end
    if wait then
        suilib.call("SetTimer", TIMER_ID_QUIT, wait * 1000)
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
