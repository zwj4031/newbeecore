local ntbootfile_ext = ""
local bootfile = ""
SystemDrive = os.getenv("SystemDrive")
temp = os.getenv("temp")
-- ��ȡ�̶�ֵ
local exitcode, stdout = winapi.execute("cmd /c mountvol")
stdout = stdout:gsub("\r\n", "\n")
local bios_str = stdout:match("EFI ([^\n]+)\n")
--��⻷��
if bios_str == nil then
	bios_str = "��ͳBIOS"
	wimwinload = [[\Windows\system32\boot\winload.exe]]
	vhdwinload = [[\Windows\system32\winload.exe]]
else
	bios_str = "UEFI"
	wimwinload = [[\Windows\system32\boot\winload.efi]]
	vhdwinload = [[\Windows\system32\winload.efi]]
end

--��ȡϵͳ�汾
function winver()
	local exitcode, stdout = winapi.execute([[ver]])
	local winver_str = stdout:match("10.0.")
	--stdout = stdout:gsub("\r\n", "\n")
	--winapi.show_message('����', winver_str)
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
		winapi.show_message("����", "��δ֧���������ָ�ʽ")
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

--����boot.sdi·��
function bootsdi(bootfile)
	--wim��vhd�ļ� ���ڷ������·��
	boot_file_path = bootfile:match(":([^] %s]+)")
	--wim��vhd�ļ� ���ڷ���
	boot_file_partition = bootfile:match("([^] %s]+):")
	sdi = [[]] .. SystemDrive .. [[\pe\boot.sdi]]
	--boot.sdi ���ڷ������·��
	boot_sdi_path = sdi:match(":([^] %s]+)")
	--boot.sdi ���ڷ���
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
	--����peĿ¼
	if addfile == "wim" then
		winapi.execute([[mkdir %systemdrive%\pe"]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\boot.sdi" %systemdrive%\pe]])
	end
	addmode = "/bootsequence"
	dojob = "shutdown -r -t 10"
	say = "���һ����������ɣ�ϵͳ����������!"
	Add_Boot(addfile)
	local exitcode, bcdedit_enum = winapi.execute([[bcdedit /enum |find "]] .. ID .. [["]])
	bcdedit_r = bcdedit_enum:match("{.+}")
	if bcdedit_r == nil then
		winapi.show_message("ע��", "���ʧ�ܣ�����û��Ȩ��(��Ҫ�Ҽ�->����Ա����)")
	else
		exec("/hide", [[cmd /c ]] .. dojob)
		r = winapi.show_message("ϵͳ��������", "ϵͳ��������������" .. bootfile .. "\n�Ƿ�ȡ����",
			"yes-no", "warning")
	end
	if r == "yes" then
		exec("/hide", [[cmd /c shutdown -a]])
		winapi.show_message("ע��", "����Ȼȡ������������������\n���������ǻ�����һ�εģ�\n�������ͺ��ˣ�Ī��!")
	end
end

function ntboot_ask(bootfile)
	bootsdi(bootfile)
	local r =
	winapi.show_message(
		"��������",
		" [��] ��������������ֻ����һ��\n\n [��] ��ӵ��˵��Ժ�����\n\n [ȡ��] ������\n\n ��ǰ�����ļ�: "
		..
		bootfile ..
		"\n\n ��������: " ..
		bios_str ..
		"\n ��ǰϵͳΪ: " ..
		winver ..
		"\n\n boot.sdi���ڷ���: " ..
		boot_sdi_partition ..
		"\n boot.sdi���·��: " ..
		boot_sdi_path .. "\n\n ���������̷�: " .. boot_file_partition .. "\n ��������: " .. boot_file_path,
		"yes-no-cancel",
		"warning"
	)
	if r == "yes" then
		ntbootnow(bootfile)
	elseif r == "no" then
		ntbootadd(bootfile)
	elseif r == "cancel" then
		winapi.show_message("��ȡ���˲�������", bootfile)
	end
end

function ntbootadd(bootfile)
	--����peĿ¼
	if addfile == "wim" then
		winapi.execute([[mkdir %systemdrive%\pe"]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\ms\boot.sdi" %systemdrive%\pe]])
	end
	addmode = "/displayorder"
	say = "����������������!"
	Add_Boot(addfile)
	local exitcode, bcdedit_enum = winapi.execute([[bcdedit /enum |find "]] .. ID .. [["]])
	bcdedit_r = bcdedit_enum:match("{.+}")
	if bcdedit_r == nil then
		winapi.show_message("ע��", "���ʧ�ܣ�����û��Ȩ��(��Ҫ�Ҽ�->����Ա����)")
	else
		winapi.show_message("ѡ������ӵ������˵�", say)
	end
end

function Add_Boot_Option(addfile)
	if exec("/wait", APP_Path .. "\\bin\\isadmin.exe") == 0 then
		toadmin = winapi.show_message("û���Թ���Ա�������!", "���Ҽ�����Ա������б�����!��\n�Ƿ����ھͳ��Թ���Ա����������б�����"
			, "yes-no", "warning")
	end
	if toadmin == "yes" then
		--exec('/hide', [[cmd /c shutdown -a]])
		--winapi.show_message('ע��', "ִ�й���Ա����Ȩ�޲���")
		exec("/admin", [["]] .. APP_Path .. [[\WinXshell.exe" -ui -jcfg wxsUI\UI_AppStore\main.jcfg]])
		sui:close()
		return
	elseif toadmin == "no" then
		return
	end
	--winapi.show_message('����ļ�����', addfile)
	local filter = "��������|*vhdx;*.vhdx|�����ļ�|*.*"
	if addfile == "wim" then
		filter = "��������|*wim|�����ļ�|*.*"
	end
	bootfile = Dialog:OpenFile("ѡ����Ҫ������" .. addfile .. "�ļ� ", filter)

	if bootfile == "" then
		winapi.show_message("�㷸�˸�����!", "��û��ѡ����!")
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
