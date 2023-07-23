#!lua
dofile("out.lua")
local i, j, disk, part
for i, disk in ipairs(disks)
do
	print(string.format("DISK%d %-4s %-10s %s %s",
		i,
		disk.name,
		disk.size,
		disk.bus,
		disk.product_id))
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