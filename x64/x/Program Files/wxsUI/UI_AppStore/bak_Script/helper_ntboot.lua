local ntbootfile_ext = ""
local bootfile = ""
local getfullpath_func = type(File.GetFullPath)
if getfullpath_func == "function" then
temp = File.GetFullPath(os.getenv("temp"))
else
temp = os.getenv("temp")
end
systemdrive = os.getenv("systemdrive")

-- ��ȡ�̶�ֵ
local exitcode, stdout = winapi.execute("cmd /c mountvol")
stdout = stdout:gsub("\r\n", "\n")
bios_str = stdout:match("EFI ([^\n]+)\n")

-- ��ȡϵͳ�汾
function get_winver()
    local exitcode, stdout = winapi.execute([[ver]])
    local winver_str = stdout:match("10.0.")
    -- stdout = stdout:gsub("\r\n", "\n")
    -- winapi.show_message('����', winver_str)
    if winver_str ~= nil then
        winver = "Win10/Win11"
    else
        winver = "win7"
    end
end

function createBCD(boot_platform)
   if boot_platform == "bios" then
	   
   	    exec("/hide /wait", [[cmd /c mkdir ]] .. bcd_drv .. [[\\Boot]])
		
	    exec("/show /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootmgr" ]] .. bcd_drv .. [[\]])
		exec("/show /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootvhd.dll" ]] .. bcd_drv .. [[\]])
		
	   	exec("/hide /wait", [[bcdedit /createstore ]] .. bcd_drv .. [[\Boot\BCD.tmp]])
		exec("/hide /wait", [[bcdedit.exe /store ]] .. bcd_drv .. [[\\Boot\\BCD.tmp /create {bootmgr} /d "Windows Boot Manager"]])
		exec("/hide /wait", [[bcdedit.exe /import ]] .. bcd_drv .. [[\\Boot\\BCD.tmp]])
		exec("/hide /wait", [[bcdedit.exe /set {bootmgr} device partition=]] .. bcd_drv)
		end
 if boot_platform == "uefi" then
        local bcd_drv = "B:"
	    exec("/hide /wait", [[cmd /c mkdir ]] .. bcd_drv .. [[\\EFI\\Microsoft\\Boot]])
		exec("/hide /wait", [[cmd /c mkdir ]] .. bcd_drv .. [[\\EFI\\Boot]])
	    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootmgfw.efi" ]] .. bcd_drv .. [[\\EFI\\Microsoft\\Boot\\bootmgfw.efi]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootvhd.dll" ]] .. bcd_drv .. [[\\EFI\\Microsoft\\Boot\\bootvhd.dll]])
	    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootmgfw.efi" ]] .. bcd_drv .. [[\\EFI\\Microsoft\\Boot\\bootmgr.efi]])
	    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path .. [[\\ms\\bootmgfw.efi" ]] .. bcd_drv .. [[\\EFI\\Boot\\bootx64.efi]])
		
	
		exec("/hide /wait", [[bcdedit /createstore ]] .. bcd_drv .. [[\EFI\Microsoft\\Boot\\BCD.tmp]])
		exec("/hide /wait", [[bcdedit.exe /store ]] .. bcd_drv .. [[\EFI\Microsoft\\Boot\\BCD.tmp /create {bootmgr} /d "Windows Boot Manager"]])
		exec("/hide /wait", [[bcdedit.exe /import ]] .. bcd_drv .. [[\EFI\Microsoft\\Boot\\BCD.tmp]])
		exec("/hide /wait", [[bcdedit.exe /set {bootmgr} device partition=]] .. bcd_drv)
		end
end

function cs_patition()
   
    
    if boot_platform == "bios" then
	bcd_drv = Dialog:BrowseFolder(
                  "��ǰΪWinPE���������޷��ҵ�����ϵͳ����ѡ������ϵͳ��������",
                  17)
        createBCD(boot_platform)
        exec("/hide /wait", [[reg load hklm\BCD_]] .. boot_platform .. [[ ]] ..
                 bcd_drv .. [[\Boot\BCD]])
    elseif boot_platform == "uefi" and File.exists([[B:\EFI\Microsoft\Boot\BCD]]) then
        
	   exec("/hide /wait",
             [[reg load hklm\BCD_]] .. boot_platform .. [[ B:\EFI\Microsoft\Boot\BCD]])
    elseif boot_platform == "uefi" and
        not File.exists([[B:\EFI\Microsoft\Boot\BCD]]) or not File.exists([[B:\EFI\Boot\Bootx64.efi]]) then
        createBCD(boot_platform)
        exec("/hide /wait",
             [[reg load hklm\BCD_]] .. boot_platform .. [[ B:\EFI\Microsoft\Boot\BCD]])
    end
end


function check_offline_os()
    if exec("/wait", [[bcdedit]]) == 1 then
        cs_patition()
        boot_bcd_var()
    else
        boot_bcd_var()
    end
end

function boot_bcd_var()
    if boot_platform == "bios" then
        local exitcode, boot_drv_stdout = winapi.execute(
                                              "cmd /c bcdedit /enum {bootmgr}")
        boot_drv_stdout = boot_drv_stdout:gsub("\r\n", "\n")
        boot_drv = boot_drv_stdout:match(
                       "device                  partition=([^\n]+)\n")
        bcd_store = boot_drv .. [[\Boot\BCD]]
        bcd_drv = boot_drv
    elseif boot_platform == "uefi" then
        exec("/show /wait", "cmd /c mountvol B: /s")
		local bcd_drv = "B:"
        local exitcode, boot_drv_stdout = winapi.execute(
                                              "cmd /c bcdedit /enum {default}")
        boot_drv_stdout = boot_drv_stdout:gsub("\r\n", "\n")
        boot_drv = boot_drv_stdout:match(
                       "device                  partition=([^\n]+)\n")
        local exitcode, bcd_drv_stdout = winapi.execute(
                                             "cmd /c bcdedit /enum {bootmgr}")
        bcd_drv_stdout = bcd_drv_stdout:gsub("\r\n", "\n")
        bcd_drv = bcd_drv_stdout:match(
                      "device                  partition=([^\n]+)\n")
        bcd_store = bcd_drv .. [[\EFI\Microsoft\Boot\BCD]]
    end
end

-- ��⻷��
function ck_bios()
    if bios_str == nil then
        bios_str = "��ͳBIOS"
        boot_platform = "bios"
        wimwinload = [[\Windows\system32\boot\winload.exe]]
        vhdwinload = [[\Windows\system32\winload.exe]]
    else
	    bcd_drv = "B:"
        bios_str = "UEFI"
        boot_platform = "uefi"
        wimwinload = [[\Windows\system32\boot\winload.efi]]
        vhdwinload = [[\Windows\system32\winload.efi]]
    end
end
ck_bios()
App_platform = sui:find("boot_platform")
App_platform.text = "��ǰ����:" .. bios_str

function ntboot_init()
    if File.exists("X:\\ipxefm\\ipxeboot.txt") or systemdrive == "X:" then
        exec("/hide /wait", [[cmd /c mkdir "X:\program files\ms" ]])
        exec("/hide",
             [[cmd /c copy /y X:\ipxefm\app\wimboot\*.* "X:\program files\ms"]])
        get_winver()
        ntboot_addmode = "pe"

        check_offline_os()
        ntboot_runmode = "WinPE����ģʽ!(����ϵͳ[����]�̷�->" .. bcd_drv ..
                             "] [��������->" .. bios_str .. "]"
        APP_Path = os.getenv("WINXSHELL_MODULEPATH")
    else
        get_winver()
        boot_drv = os.getenv("systemdrive")
        bcd_drv = os.getenv("systemdrive")
        ntboot_addmode = "os"
        ntboot_runmode = "����ϵͳ����!(ϵͳ[����]�̷�)->" .. boot_drv ..
                             "] [��������->" .. bios_str .. "]"
    end
end

function getBootfileExt(bootfile)
    bootfile_ext = bootfile:match(".+%.(%w+)$")
    bootfile_ext = string.lower(bootfile_ext) -- תСд
    -- ת��д bootfile_ext = string.upper(bootfile_ext)
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
        -- vhd
        bootsdi(bootfile)
        ntbootadd(bootfile)
    end
end

-- ����boot.sdi·��
function bootsdi(bootfile)
    -- wim��vhd�ļ� ���ڷ������·��
    boot_file_path = bootfile:match(":([^] %s]+)")
    -- wim��vhd�ļ� ���ڷ���
    boot_file_partition = bootfile:match("([^] %s]+):")
    sdi = [[]] .. bcd_drv .. [[\pe\boot.sdi]]
    -- boot.sdi ���ڷ������·��
    -- alert(sdi)
    boot_sdi_path = sdi:match(":([^] %s]+)")
    -- boot.sdi ���ڷ���
    boot_sdi_partition = sdi:match("([^] %s]+):")
end

function win7_replacebootmgr()
    exec("/show /wait", "cmd /c mountvol B: /s")
    if addfile == "vhd" then
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\bootvhd.dll" B:\\EFI\\Microsoft\\Boot\\bootvhd.dll]])
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\bootvhd.dll" B:\\EFI\\Boot\\bootvhd.dll]])
    end
    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
             [[\ms\bootmgfw.efi" B:\\EFI\\Microsoft\\Boot\\bootmgfw.efi]])
    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
             [[\ms\bootmgfw.efi" B:\\EFI\\Microsoft\\Boot\\bootmgr.efi]])
    exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
             [[\ms\bootmgfw.efi" B:\\EFI\\Boot\\bootx64.efi]])
    exec("/hide /wait", "cmd /c mountvol B: /d")
end

function Add_Boot(addfile)
    if winver == "win7" then win7_replacebootmgr() end
    if addfile == "wim" then
        ID = "{19260817-6666-8888-f00d-caffee000000}"
        exec("/hide /wait", [[bcdedit /delete ]] .. ID)
        exec("/hide /wait",
             [[bcdedit /create {ramdiskoptions} /d "ntboot ramdisk"]])
        exec("/hide /wait",
             [[bcdedit /create {bootmgr} /d "Windows Boot Manager"]])
        exec("/hide /wait",
             [[bcdedit /set {ramdiskoptions} ramdisksdidevice  partition=]] ..
                 boot_sdi_partition .. [[:]])
        exec("/hide /wait",
             [[bcdedit /set {ramdiskoptions} ramdisksdipath ]] .. boot_sdi_path)
        exec("/hide /wait", [[bcdedit -create ]] .. ID ..
                 [[ /d "BootWim With NTBOOT 6.x" /application osloader]])
        exec("/hide /wait",
             [[bcdedit -set ]] .. ID .. " device ramdisk=[" ..
                 boot_file_partition .. ":]" .. boot_file_path ..
                 [[,{ramdiskoptions}]])
        exec("/hide /wait",
             [[bcdedit -set ]] .. ID .. " osdevice ramdisk=[" ..
                 boot_file_partition .. ":]" .. boot_file_path ..
                 [[,{ramdiskoptions}]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ path ]] .. wimwinload)
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ Locale zh-CN]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ systemroot \Windows]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ detecthal yes]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ winpe yes]])
        exec("/hide /wait", [[bcdedit /set {bootmgr} timeout 5]])
        -- exec('/hide', [[bcdedit -set ]] .. ID .. [[ pae forceenable]])
        exec("/hide /wait",
             [[cmd /c bcdedit ]] .. addmode .. [[ ]] .. ID .. [[ /addlast]])
    elseif addfile == "vhd" then
        ID = "{19260817-6666-8888-f00d-caffee000001}"
        exec("/hide /wait", [[bcdedit /delete ]] .. ID)
        exec("/hide /wait",
             [[bcdedit /create {bootmgr} /d "Windows Boot Manager"]])
        exec("/hide /wait", [[bcdedit /set {bootmgr} Locale zh-CN]])
        exec("/hide /wait", [[bcdedit /set {bootmgr} nointegritychecks yes]])
        exec("/hide /wait", [[bcdedit /set {bootmgr} testsigning yes]])
        exec("/hide /wait", [[bcdedit /set {bootmgr} timeout 5]])
        -- exec('/hide', [[bcdedit /set {bootmgr} timeout 30]])
        exec("/hide /wait", [[bcdedit -create ]] .. ID ..
                 [[ /d "Boot from VHD With NTBOOT 6.x" /application osloader]])
        exec("/hide /wait",
             [[bcdedit -set ]] .. ID .. " device vhd=[" .. boot_file_partition ..
                 ":]" .. boot_file_path)
        exec("/hide /wait",
             [[bcdedit -set ]] .. ID .. " osdevice vhd=[" .. boot_file_partition ..
                 ":]" .. boot_file_path)
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ path ]] .. vhdwinload)
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ Locale zh-CN]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ systemroot \Windows]])
        exec("/hide /wait", [[bcdedit -set ]] .. ID .. [[ detecthal yes]])
        -- exec('/hide', [[bcdedit -set ]] .. ID .. [[ winpe yes]])
        -- exec('/hide', [[bcdedit -set ]] .. ID .. [[ pae forceenable]])
        exec("/hide /wait",
             [[cmd /c bcdedit ]] .. addmode .. [[ ]] .. ID .. [[ /addlast]])
    end
end

function ntbootnow(bootfile)
    -- ����peĿ¼
    if addfile == "wim" then
        exec("/hide /wait", [[cmd /c mkdir ]] .. bcd_drv .. [[\pe]])
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\boot.sdi" ]] .. bcd_drv .. [[\pe]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. bcd_drv ..
                 [[\windows\system32\boot.sdi" ]] .. bcd_drv .. [[\pe]])	 		 
    end
    addmode = "/bootsequence"
    say = "���һ����������ɣ�ϵͳ����������!"
    Add_Boot(addfile)
    if ntboot_addmode == "pe" then
        exec("/hide /wait", [[reg unload hklm\BCD_]] .. boot_platform)
        local exitcode, bcdedit_enum = winapi.execute(
                                           [[bcdedit /enum all|find "]] ..
                                               boot_file_path .. [["]])
        bcdedit_r = bcdedit_enum:match("{.+}")
        dojob = "wpeutil reboot"
    else
        local exitcode, bcdedit_enum = winapi.execute(
                                           [[bcdedit /enum all|find "]] ..
                                               boot_file_path .. [["]])
        bcdedit_r = bcdedit_enum:match("{.+}")
        exec("/hide /wait", [[reg unload hklm\BCD_]] .. boot_platform)
        dojob = "shutdown -r -t 10"
    end

    if bcdedit_r == nil then
        winapi.show_message("ע��",
                            "���ʧ�ܣ�����û��Ȩ��(��Ҫ�Ҽ�->����Ա����)")
        sui:close()
    else
        exec("/hide", [[cmd /c ]] .. dojob)
        r = winapi.show_message("ϵͳ��������",
                                "ϵͳ��������������" .. bootfile ..
                                    "\n�Ƿ�ȡ�����������PE����ȡ����Ч��",
                                "yes-no", "warning")
    end
    if r == "yes" then
        exec("/hide", [[cmd /c shutdown -a]])
        winapi.show_message("ע��",
                            "����Ȼȡ������������������\n���������ǻ�����һ�εģ�\n�������ͺ��ˣ�Ī��!")
        sui:close()
    end
end

function ntboot_ask(bootfile)
    if bios_str == nil then ck_bios() end
    if bcd_drv == nil then
        -- boot_drv = os.getenv("systemdrive")
        ntboot_init()
    end
    if winver == nil then get_winver() end
    bootsdi(bootfile)
    local r = winapi.show_message("��������",
                                  " [��] ��������������ֻ����һ��\n\n [��] ��ӵ��˵��Ժ�����\n\n [ȡ��] ������\n\n ��ǰ�����ļ�: " ..
                                      bootfile .. "\n\n ��������: " ..
                                      bios_str .. "\n ��ǰϵͳΪ: " ..
                                      winver .. "\n\n boot.sdi���ڷ���: " ..
                                      boot_sdi_partition ..
                                      "\n boot.sdi���·��: " ..
                                      boot_sdi_path ..
                                      "\n\n ���������̷�: " ..
                                      boot_file_partition .. "\n ��������: " ..
                                      boot_file_path, "yes-no-cancel", "warning")
    if r == "yes" then
        ntbootnow(bootfile)
    elseif r == "no" then
        ntbootadd(bootfile)
    elseif r == "cancel" then
        return
        -- winapi.show_message("��ȡ���˲�������", bootfile)
    end
end

function ntbootadd(bootfile)
    -- ����peĿ¼
    if addfile == "wim" then
        exec("/hide /wait", [[mkdir ]] .. bcd_drv .. [[\pe]])
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\boot.sdi" ]] .. bcd_drv .. [[\pe]])
    	 exec("/hide /wait", [[cmd /c copy /y "]] .. bcd_drv ..
                 [[\windows\system32\boot.sdi" ]] .. bcd_drv .. [[\pe]])	 		 
    end
    addmode = "/displayorder"
    say = "����������������!"
    Add_Boot(addfile)
    if ntboot_addmode == "pe" then
        -- alert([[bcdedit -store ]] .. bcd_store .. [[ /enum |find "]] .. ID .. [["]])
        local exitcode, bcdedit_enum = winapi.execute(
                                           [[bcdedit /enum |find "]] .. ID ..
                                               [["]])
        bcdedit_r = bcdedit_enum:match("{.+}")
        exec("/hide /wait", [[reg unload hklm\BCD_]] .. boot_platform)
    else
        local exitcode, bcdedit_enum = winapi.execute(
                                           [[bcdedit /enum |find "]] .. ID ..
                                               [["]])
        bcdedit_r = bcdedit_enum:match("{.+}")
    end

    -- alert([[bcdedit /enum |find "]] .. ID .. [["]])
    if bcdedit_r == nil then
        winapi.show_message("ע��",
                            "���ʧ�ܣ�����û��Ȩ��(��Ҫ�Ҽ�->����Ա����)")
    else
        winapi.show_message("ѡ������ӵ������˵�", say)
        sui:close()
    end
end

function Add_Boot_Option(addfile)
    ntboot_init()
    -- if exec("/wait", APP_Path .. "\\bin\\isadmin.exe") == 0 then
    if exec("/wait", [[REG QUERY "HKU\S-1-5-19"]]) == 1 then
        toadmin = winapi.show_message("û���Թ���Ա�������!",
                                      "���Ҽ�����Ա������б�����!��\n�Ƿ����ھͳ��Թ���Ա����������б�����",
                                      "yes-no", "warning")
    end
    if toadmin == "yes" then
        -- exec('/hide', [[cmd /c shutdown -a]])
        -- winapi.show_message('ע��', "ִ�й���Ա����Ȩ�޲���")
        exec("/admin", [["]] .. APP_Path ..
                 [[\WinXshell.exe" -ui -jcfg wxsUI\UI_AppStore\main.jcfg]])
        sui:close()
        return
    elseif toadmin == "no" then
        return
    end
    -- winapi.show_message('����ļ�����', addfile)
    local filter = "��������|*vhd;*.vhdx|�����ļ�|*.*"
    if addfile == "wim" then filter = "��������|*wim|�����ļ�|*.*" end
    bootfile = Dialog:OpenFile("ѡ����Ҫ������" .. addfile ..
                                   "�ļ� ��ǰΪ:" .. ntboot_runmode, filter)

    if bootfile == "" then
        -- winapi.show_message("�㷸�˸�����!", "��û��ѡ����!")
        return
    else
        ntboot_ask(bootfile)
    end
end

function helper_ntboot_onload()
    -- addwim()
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
