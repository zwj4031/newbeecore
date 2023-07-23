local SystemRoot = os.getenv("SystemRoot")
temp = os.getenv("temp")
local listmode = "selimg"
local TID_UPANLIST_CHANGED = 20000 + 1
partnum = 0
APP_Path = app:info('path')
UI_Path = sui:info('uipath')
disklist = {}
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

--local cmd = io.popen([[diskfire lua "]] .. UI_Path .. [[df_to.lua"]])
--local stdout = cmd:read("*a")
--stdout = stdout:gsub("\r\n", "\n")
local exitcode, stdout = winapi.execute([[cmd /c diskfire lua "]] .. UI_Path .. [[df_to.lua"]])
stdout = stdout:gsub("\r\n", "\n")
load(stdout)()
--winapi.show_message("结果如下", stdout)
--exec("/hide", [[cmd /c diskfire lua "]] .. UI_Path .. [[df_to.lua">\windows\temp\out.lua]])
--disk_probe = disk_probe:gsub("\r\n", "\n")
--dofile("\\windows\\temp\\out.lua")

local i, j, disk, part
for i, disk in ipairs(disks)
do
   
	print(string.format("%-4s %-10s %s %s",
		--i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id))
	disknum = i   
	disk_all = string.format("%-4s <b><c #ff0000>%-10s %s %s</c></b>",
		--i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id)
	table.insert(disklist, disk_all)		
	for j, part in ipairs(disk.partition)
	do
	partnum = partnum + 1
	--print(string.format("|- PART%d %-12s %-10s %-16s %s %s %s",
	data_label_table[part.letter] = part.label
	print(string.format("%s %s %-10s %s %s %s",
	        part.letter,
			i .. ":" .. j,
			--part.name,
			part.size,
			--part.start,
			part.fs,
			part.flag,
			part.label))
   --part_all = string.format("|- PART%d %-12s %-10s %-16s %s %s %s",
	part_all = string.format("%s %s %-10s %s %s %s",
	        part.letter,
			i .. ":" .. j,
			--part.name,
			part.size,
			--part.start,
			part.fs,
			part.flag,
			part.label)
	table.insert(disklist, part_all)		
		
	end
end
