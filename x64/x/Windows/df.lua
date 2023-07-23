#!lua

local pd_table = {}
-- disk [i] : name, size, bus, product_id, removable, count, partition
-- partition[i] : name, size, start, fs, flag, label

local function df_probe (opt, disk)
	local str, errno
	str, errno = df.cmd("probe", "--" .. opt, disk)
	if (errno ~= 0) then
		return ""
	end
	return string.sub(str, 0, -2)
end

local function df_check_removable (disk)
	if (df_probe("rm", disk) == "REMOVABLE") then
		return true
	end
	return false
end

local function df_get_label (label)
	if (label == nil or label == "") then
		return ""
	end
	return "[" .. label .. "]"
end

local function df_get_fs (fs)
	if (fs) then
		return string.upper(fs)
	end
	return "UNKNOWN"
end

local function df_get_flag (disk, partmap)
	local flag = df_probe("flag", disk)
	if (partmap == "msdos") then
		if (string.find(flag, "ACTIVE")) then
			return "激活"
		end
	else
		local attr = string.match(flag, "^[%x%-]+ ([%a%s]+)$", 1)
		if (attr) then
			return attr
		end
	end
	return ""
end 

local function df_enum_iter (disk, fs, uuid, label, size)
	local i = string.match(disk, "^hd(%d+)$", 1)
	if (i) then
		pd_table[i + 1] =
		{
			name = disk,
			size = size,
			bus = df_probe("bus", disk),
			product_id = df_probe("pid", disk),
			removable = df_check_removable(disk),
			count = 0,
			partition = {},
		}
		return 0
	end
	local i, partmap = string.match(disk, "^hd(%d+),(%a+)%d+$", 1)
	if (i and partmap) then
		pd_table[i + 1].count = pd_table[i + 1].count + 1
		pd_table[i + 1].partition[pd_table[i + 1].count] =
		{
			name = disk,
			size = size,
			start = df_probe("start", disk),
			fs = df_get_fs(fs),
			flag = df_get_flag(disk, partmap),
			label = df_get_label(label),
		}
		return 0
	end
end

local function df_compare_partition(a, b)
	if (not a or not b) then
		return false
	end
	if (a.start == b.start) then
		return false
	end
	return tonumber(a.start) < tonumber(b.start)
end

df.enum_device(df_enum_iter)
local i, j, disk
for i,disk in ipairs(pd_table)
do
	print(string.format("DISK%d %-4s %-10s %s %s",
		i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id))
	table.sort(disk.partition, df_compare_partition)
	for j, part in ipairs(disk.partition)
	do
		print(string.format("|- PART%d %-12s %-10s %-16s %s %s %s",
			j,
			part.name,
			part.size,
			part.start,
			part.fs,
			part.flag,
			part.label))
	end
end
