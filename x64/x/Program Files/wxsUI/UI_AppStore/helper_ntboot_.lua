local ntbootfile_ext = ""
local bootfile = ""
SystemDrive = os.getenv("SystemDrive")
temp = os.getenv("temp")
-- 提取固定值
local exitcode, stdout = winapi.execute("cmd /c mountvol")
stdout = stdout:gsub("\r\n", "\n")
local bios_str = stdout:match("EFI ([^\n]+)\n")
--检测环境
if bios_str == nil then
	bios_str = "传统BIOS"
	wimwinload = [[\Windows\system32\boot\winload.exe]]
	vhdwinload = [[\Windows\system32\winload.exe]]
else
	bios_str = "UEFI"
	wimwinload = [[\Windows\system32\boot\winload.efi]]
	vhdwinload = [[\Windows\system32\winload.efi]]
end

--获取系统版本
function winver()
	local exitcode, stdout = winapi.execute([[ver]])
	local winver_str = stdout:match("10.0.")
	--stdout = stdout:gsub("\r\n", "\n")
	--winapi.show_message('错误', winver_str)
	if winver_str ~= nil then
		winver = "Win10/Win11"
	else
		winver = "win7"
	end
end

winver()

function getBootfileExt(bootfile)
	bootfile_ext = bootfile:match(".+%.(%w+)$")
	if bootfile_ext == "wim" then
		addfile = "wim"
		bootok = "1"
	elseif bootfile_ext == "vhd" or bootfile_ext == "vhdx" then
		addfile = "vhd"
		bootok = "1"
	end
end

function ntboot_args(bootfile)
	getBootfileExt(bootfile)
	if bootok ~= "1" then
		winapi.show_message("错误", "暂未支持启动这种格式")
		return
	end
	if bootnow == "1" then
		bootsdi(bootfile)
		ntbootnow(bootfile)
	else
		bootsdi(bootfile)
		ntbootadd(bootfile)
		--vhd
	end
end

--分离boot.sdi路径
function bootsdi(bootfile)
	--wim或vhd文件 所在分区相对路径
	boot_file_path = bootfile:match(":([^] %s]+)")
	--wim或vhd文件 所在分区
	boot_file_partition = bootfile:match("([^] %s]+):")
	sdi = [[]] .. SystemDrive .. [[\pe\boot.sdi]]
	--boot.sdi 所在分区相对路径
	boot_sdi_path = sdi:match(":([^] %s]+)")
	--boot.sdi 所在分区
	boot_sdi_partition = sdi:match("([^] %s]+):")
end

function win7_replacebootmgr()
	exec("/show /wait", "cmd /c mountvol B: /s")
	if addfile == "vhd" then
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\bootvhd.dll" B:\\EFI\\Microsoft\\Boot\\bootvhd.dll]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\bootvhd.dll" B:\\EFI\\Boot\\bootvhd.dll]])
	end
	exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\bootmgfw.efi" B:\\EFI\\Microsoft\\Boot\\bootmgfw.efi]])
	exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\bootmgfw.efi" B:\\EFI\\Microsoft\\Boot\\bootmgr.efi]])
	exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\bootmgfw.efi" B:\\EFI\\Boot\\bootx64.efi]])
	exec("/hide /wait", "cmd /c mountvol B: /d")
end

function Add_Boot(addfile)
	if winver == "win7" then
		win7_replacebootmgr()
	end
	if addfile == "wim" then
		ID = "{19260817-6666-8888-f00d-caffee000000}"
		exec("/hide /wait", [[bcdedit /delete ]] .. ID)
		exec("/hide /wait", [[bcdedit /create {ramdiskoptions} /d "ntboot ramdisk"]])
		exec("/hide /wait", [[bcdedit /create {bootmgr} /d "Windows Boot Manager"]])
		exec("/hide /wait", [[bcdedit /set {ramdiskoptions} ramdisksdidevice  partition=]] .. boot_sdi_partition .. [[:]])
		exec("/hide /wait", [[bcdedit /set {ramdiskoptions} ramdisksdipath ]] .. boot_sdi_path)
		exec("/hide /wait", [[bcdedit -create ]] .. ID .. [[ /d "BootWim With NTBOOT 6.x" /application osloader]])
		exec(
			"/hide /wait",
			[[bcdedit -set ]] ..
			ID .. " device ramdisk=[" .. boot_file_partition .. ":]" .. boot_file_path .. [[,{ramdiskoptions}]]
		)
		exec(
			"/hide /wait",
			[[bcdedit -set ]] ..
			ID .. " osdevice ramdisk=[" .. boot_file_partition .. ":]" .. boot_file_path .. [[,{ramdiskoptions}]]
		)
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ path ]] .. wimwinload)
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ Locale zh-CN]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ systemroot \Windows]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ detecthal yes]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ winpe yes]])
		--exec('/hide', [[bcdedit -set ]] .. ID .. [[ pae forceenable]])
		exec("/hide /wait", [[cmd /c bcdedit ]] .. addmode .. [[ ]] .. ID .. [[ /addlast]])
	elseif addfile == "vhd" then
		ID = "{19260817-6666-8888-f00d-caffee000001}"
		exec("/hide /wait", [[bcdedit /delete ]] .. ID)
		exec("/hide /wait", [[bcdedit /create {bootmgr} /d "Windows Boot Manager"]])
		exec("/hide /wait", [[bcdedit /set {bootmgr} Locale zh-CN]])
		exec("/hide /wait", [[bcdedit /set {bootmgr} nointegritychecks yes]])
		exec("/hide /wait", [[bcdedit /set {bootmgr} testsigning yes]])
		--exec('/hide', [[bcdedit /set {bootmgr} timeout 30]])
		exec("/hide /wait", [[bcdedit -create ]] .. ID .. [[ /d "Boot from VHD With NTBOOT 6.x" /application osloader]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. " device vhd=[" .. boot_file_partition .. ":]" .. boot_file_path)
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. " osdevice vhd=[" .. boot_file_partition .. ":]" .. boot_file_path)
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ path ]] .. vhdwinload)
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ Locale zh-CN]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ systemroot \Windows]])
		exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ detecthal yes]])
		--exec('/hide', [[bcdedit -set ]] .. ID .. [[ winpe yes]])
		--exec('/hide', [[bcdedit -set ]] .. ID .. [[ pae forceenable]])
		exec("/hide /wait", [[cmd /c bcdedit ]] .. addmode .. [[ ]] .. ID .. [[ /addlast]])
	end
end

function ntbootnow(bootfile)
	--创建pe目录
	if addfile == "wim" then
		winapi.execute([[mkdir %systemdrive%\pe"]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\boot.sdi" %systemdrive%\pe]])
	end
	addmode = "/bootsequence"
	dojob = "shutdown -r -t 10"
	say = "添加一次性启动完成，系统将立即重启!"
	Add_Boot(addfile)
	local exitcode, bcdedit_enum = winapi.execute([[bcdedit /enum |find "]] .. ID .. [["]])
	bcdedit_r = bcdedit_enum:match("{.+}")
	if bcdedit_r == nil then
		winapi.show_message("注意", "添加失败，可能没有权限(需要右键->管理员运行)")
	else
		exec("/hide", [[cmd /c ]] .. dojob)
		r = winapi.show_message("系统即将重启", "系统即将重启并进入" .. bootfile .. "\n是否取消？",
			"yes-no", "warning")
	end
	if r == "yes" then
		exec("/hide", [[cmd /c shutdown -a]])
		winapi.show_message("注意", "您虽然取消了立即启动到镜像，\n但重启后还是会启动一次的，\n再重启就好了，莫慌!")
	end
end

function ntboot_ask(bootfile)
	bootsdi(bootfile)
	local r =
	winapi.show_message(
		"操作镜像",
		" [是] 立即重启到镜像并只启动一次\n\n [否] 添加到菜单以后启动\n\n [取消] 不操作\n\n 当前启动文件: "
		..
		bootfile ..
		"\n\n 启动环境: " ..
		bios_str ..
		"\n 当前系统为: " ..
		winver ..
		"\n\n boot.sdi所在分区: " ..
		boot_sdi_partition ..
		"\n boot.sdi相对路径: " ..
		boot_sdi_path .. "\n\n 启动镜像盘符: " .. boot_file_partition .. "\n 启动镜像: " .. boot_file_path,
		"yes-no-cancel",
		"warning"
	)
	if r == "yes" then
		ntbootnow(bootfile)
	elseif r == "no" then
		ntbootadd(bootfile)
	elseif r == "cancel" then
		winapi.show_message("您取消了操作镜像", bootfile)
	end
end

function ntbootadd(bootfile)
	--创建pe目录
	if addfile == "wim" then
		winapi.execute([[mkdir %systemdrive%\pe"]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\boot.sdi" %systemdrive%\pe]])
	end
	addmode = "/displayorder"
	say = "添加永久启动项完成!"
	Add_Boot(addfile)
	local exitcode, bcdedit_enum = winapi.execute([[bcdedit /enum |find "]] .. ID .. [["]])
	bcdedit_r = bcdedit_enum:match("{.+}")
	if bcdedit_r == nil then
		winapi.show_message("注意", "添加失败，可能没有权限(需要右键->管理员运行)")
	else
		winapi.show_message("选择了添加到启动菜单", say)
	end
end

function Add_Boot_Option(addfile)
	if exec("/wait", APP_Path .. "\\bin\\isadmin.exe") == 0 then
		toadmin = winapi.show_message("没有以管理员身份运行!", "请右键管理员身份运行本程序!，\n是否现在就尝试管理员身份重新运行本程序？"
			, "yes-no", "warning")
	end
	if toadmin == "yes" then
		--exec('/hide', [[cmd /c shutdown -a]])
		--winapi.show_message('注意', "执行管理员提升权限操作")
		exec("/admin", [["]] .. APP_Path .. [[\WinXshell.exe" -ui -jcfg wxsUI\UI_AppStore\main.jcfg]])
		sui:close()
		return
	elseif toadmin == "no" then
		return
	end
	--winapi.show_message('添加文件类型', addfile)
	local filter = "启动镜像|*vhdx;*.vhdx|所有文件|*.*"
	if addfile == "wim" then
		filter = "启动镜像|*wim|所有文件|*.*"
	end
	bootfile = Dialog:OpenFile("选择你要启动的" .. addfile .. "文件 ", filter)

	if bootfile == "" then
		winapi.show_message("你犯了个错误!", "你没有选择镜像!")
	else
		ntboot_ask(bootfile)

	end
end

function helper_ntboot_onload()
	--addwim()
	if has_option("-ntboot") then
		bootfile = get_option("-ntboot")
		ntboot_args(bootfile)
	end
	if has_option("-now") then
		bootnow = "1"
	else
		bootnow = "0"
	end
end
