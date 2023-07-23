--init
local exitcode, disk_probe = winapi.execute("diskfire probe --label")
disk_probe = disk_probe:gsub("\r\n", "\n")
partlist = {}
data_label_table = {}
--local cmd = io.popen('cmd /c diskfire ls -l')

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



function get_label(part_str)--根据分区列表获取卷标
label_table = {}
label_str = "没有卷标"
local exitcode, label_total = winapi.execute("diskfire probe --label " .. part_str)
str = label_total:gsub("\r\n", "")
if str ~= nil then
label_str = "" .. str
else
label_str = "没有卷标"
end
end

function get_size(disk_size_str)--根据磁盘或分区获取大小
size_table = {}
local exitcode, size_total = winapi.execute("diskfire probe --size " .. disk_size_str)
size_str = size_total:gsub("\r\n", "")
size_str = size_str - 0
size = bytesToSize(size_str)
end


function get_pid(disk_str)--根据硬盘获取厂商信息
pid_table = {}
local exitcode, disk_str = winapi.execute("diskfire probe --pid " .. part_str)
pid_str = disk_str:gsub("\r\n", "")
end



function add_label_data(label_letter)
data_label_table[label_letter] = label_str
end

function get_part(disk_str)--根据硬盘列表获取分区
part_table = {}
for diskpart_str in string.gfind(disk_probe, disk_str .. "*,.-\n") do
part_str = diskpart_str:match(".+ ")
if part_str ~= nil then
get_size(part_str)
get_label(part_str)
parts = parts + 1
local exitcode, flag_str = winapi.execute("diskfire probe --flag " .. part_str)
flag_str = flag_str:gsub("\r\n", "\n")
local exitcode, letter_str = winapi.execute("diskfire probe --letter " .. part_str)
letter_str = letter_str:gsub("\r\n", "")
if letter_str == nil then
letter_str = "未分配"
end
if flag_str:find("ACTIVE") and flag_str:find("PRIMARY") then
out_part_str = letter_str .. "  主分区 *激活 " .. size .. "  " .. label_str
add_label_data(letter_str)
elseif flag_str:find("EXTENDED") then
add_label_data(letter_str)
out_part_str = letter_str .. "  逻辑分区 " .. size .. "  " .. label_str
elseif not flag_str:find("ACTIVE") and flag_str:find("PRIMARY") then
add_label_data(letter_str)
out_part_str = letter_str .. "  主分区  " .. size .. "  " .. label_str
elseif flag_str:find("ACTIVE") and not flag_str:find("PRIMARY") then
add_label_data(letter_str)
out_part_str = letter_str .. "  *激活 " .. size .. "  " .. label_str
else
add_label_data(letter_str)
out_part_str = letter_str .. "   " .. size .. "  " .. label_str
end
table.insert(part_table, out_part_str)
end
end
end



function get_disk()--获取硬盘列表
diskn = -1
disks = 0
disklist = {}

for diskpart_str in string.gfind(disk_probe, "h*.-\n") do
disk_table = {}
disk_str = diskpart_str:match("hd[%d+]* ")
if disk_str ~= nil then
diskn = diskn + 1
disks = disks + 1
table.insert(disk_table, disk_str)
get_part(disk_str)
get_pid(disk_str)
get_size(disk_str)

local all_part = table.concat(part_table, "\n")
disk_part_str = string.format("%s<b><c #ff0000>磁盘 %s</c> %s %s \n%s</b> ", disk_str, diskn, pid_str, size, all_part)
table.insert(disklist, disk_part_str)
--winapi.show_message("结果如下", disk_part_str)
end
end
end
