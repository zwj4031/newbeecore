local panfu_list =
{
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

local fixed_out = {}

function findfile(file)
	for key,value in ipairs(panfu_list) 
	do
		if File.exists(value .. [[:]] .. file) then 
		    havefile = "1"
			table.insert(fixed_out, string.format("�̷�%s:", value))
     	end
	end
find_str = table.concat(fixed_out, "\n")	
if havefile == "1" then
winapi.show_message("�ļ�����", [[�ҵ�]] .. file .. [[�ļ�, ��]]  .. find_str)
else
winapi.show_message("�ļ�����", "û���ҵ���Ҫ���ļ�!")
end
end

findfile([[\boot\grubfm\diy.gz]])

