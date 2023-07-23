dofile("wxsUI\\UI_AppStore\\types\\media")
dofile("wxsUI\\UI_AppStore\\types\\work")
local file_type = "未知类型"
local file_ext = ""

-- 获取扩展名
function getExtension(str)
	file_ext = str:match(".+%.(%w+)$")

	for key, value in ipairs(media_list) do
		if file_ext:find("" .. value .. "") then
			soft_list = "media"
			file_type = "多媒体类"
		end
	end

	for key, value in ipairs(work_list) do
		if file_ext:find("" .. value .. "") then
			soft_list = "work"
			file_type = "文档办公类"
		end
	end

	if soft_list == "media" then
		onclick("$Nav[3]")
	elseif soft_list == "work" then
		onclick("$Nav[4]")
	elseif file_ext == "vmx" then
		exec("/hide", [[cmd /c ftype .vmx="%ProgramFiles%\vmware\vmware.exe" %1]])
		soft_list = "vm"
		file_type = "虚拟机"
		onclick("$Nav[6]")
	elseif file_ext == "wim" then
		exec("/show", [[cmd /k echo %1]])
		soft_list = "wimfile"
		file_type = "镜像"
		onclick("$Nav[6]")
	else
	    openwithsoft = Dialog:OpenFile("未知类型，请选择一个程序打开" .. str .. "文件:", filter)
		exec("/show", openwithsoft .. [[ "]] .. str .. [["]])
		 sui:close() 
		--onclick("$Nav[7]")
		--return str
	end
end

function helper_openfile_onload()
	if has_option("-file") then
		file = get_option("-file")
	end
	if file ~= nil then
		getExtension(file)
	end
end

function helper_openfile_onclick(ctrl)
	-- for _helper_openfile_start
end
