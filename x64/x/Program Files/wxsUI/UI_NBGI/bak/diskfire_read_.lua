local exitcode, disk_probe = winapi.execute("diskfire lua \\windows\\df_to.lua>\\windows\\temp\\out.lua")
--disk_probe = disk_probe:gsub("\r\n", "\n")
dofile("\\windows\\temp\\out.lua")

local i, j, disk, part
disklist = {}
for i, disk in ipairs(disks)
do
   
	print(string.format("DISK%d %-4s %-10s %s %s",
		i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id))
	   
	disks = string.format("DISK%d %-4s %-10s %s %s",
		i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id)
	table.insert(disklist, disks)		
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
	 parts = string.format("|- PART%d %-12s %-10s %-16s %s %s %s",
			j,
			part.name,
			part.size,
			part.start,
			part.fs,
			part.flag,
			part.label)
	table.insert(disklist, parts)		
	--winapi.show_message("²âÊÔ", "·ÖÇø" .. j .. "\n" .. total)		
			
	end
end
