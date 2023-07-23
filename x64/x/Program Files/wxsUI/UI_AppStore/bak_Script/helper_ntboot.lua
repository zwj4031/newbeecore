local ntbootfile_ext = ""
local bootfile = ""
local getfullpath_func = type(File.GetFullPath)
if getfullpath_func == "function" then
temp = File.GetFullPath(os.getenv("temp"))
else
temp = os.getenv("temp")
end
systemdrive = os.getenv("systemdrive")

-- 提取固定值
local exitcode, stdout = winapi.execute("cmd /c mountvol")
stdout = stdout:gsub("\r\n", "\n")
bios_str = stdout:match("EFI ([^\n]+)\n")

-- 获取系统版本
function get_winver()
    local exitcode, stdout = winapi.execute([[ver]])
    local winver_str = stdout:match("10.0.")
    -- stdout = stdout:gsub("\r\n", "\n")
    -- winapi.show_message('错误', winver_str)
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
                  "当前为WinPE环境，但无法找到离线系统，请选择离线系统启动分区",
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

-- 检测环境
function ck_bios()
    if bios_str == nil then
        bios_str = "传统BIOS"
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
App_platform.text = "当前环境:" .. bios_str

function ntboot_init()
    if File.exists("X:\\ipxefm\\ipxeboot.txt") or systemdrive == "X:" then
        exec("/hide /wait", [[cmd /c mkdir "X:\program files\ms" ]])
        exec("/hide",
             [[cmd /c copy /y X:\ipxefm\app\wimboot\*.* "X:\program files\ms"]])
        get_winver()
        ntboot_addmode = "pe"

        check_offline_os()
        ntboot_runmode = "WinPE环境模式!(离线系统[启动]盘符->" .. bcd_drv ..
                             "] [启动环境->" .. bios_str .. "]"
        APP_Path = os.getenv("WINXSHELL_MODULEPATH")
    else
        get_winver()
        boot_drv = os.getenv("systemdrive")
        bcd_drv = os.getenv("systemdrive")
        ntboot_addmode = "os"
        ntboot_runmode = "正常系统环境!(系统[启动]盘符)->" .. boot_drv ..
                             "] [启动环境->" .. bios_str .. "]"
    end
end

function getBootfileExt(bootfile)
    bootfile_ext = bootfile:match(".+%.(%w+)$")
    bootfile_ext = string.lower(bootfile_ext) -- 转小写
    -- 转大写 bootfile_ext = string.upper(bootfile_ext)
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
        -- vhd
        bootsdi(bootfile)
        ntbootadd(bootfile)
    end
end

-- 分离boot.sdi路径
function bootsdi(bootfile)
    -- wim或vhd文件 所在分区相对路径
    boot_file_path = bootfile:match(":([^] %s]+)")
    -- wim或vhd文件 所在分区
    boot_file_partition = bootfile:match("([^] %s]+):")
    sdi = [[]] .. bcd_drv .. [[\pe\boot.sdi]]
    -- boot.sdi 所在分区相对路径
    -- alert(sdi)
    boot_sdi_path = sdi:match(":([^] %s]+)")
    -- boot.sdi 所在分区
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
    -- 创建pe目录
    if addfile == "wim" then
        exec("/hide /wait", [[cmd /c mkdir ]] .. bcd_drv .. [[\pe]])
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\boot.sdi" ]] .. bcd_drv .. [[\pe]])
		exec("/hide /wait", [[cmd /c copy /y "]] .. bcd_drv ..
                 [[\windows\system32\boot.sdi" ]] .. bcd_drv .. [[\pe]])	 		 
    end
    addmode = "/bootsequence"
    say = "添加一次性启动完成，系统将立即重启!"
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
        winapi.show_message("注意",
                            "添加失败，可能没有权限(需要右键->管理员运行)")
        sui:close()
    else
        exec("/hide", [[cmd /c ]] .. dojob)
        r = winapi.show_message("系统即将重启",
                                "系统即将重启并进入" .. bootfile ..
                                    "\n是否取消？【如果是PE环境取消无效】",
                                "yes-no", "warning")
    end
    if r == "yes" then
        exec("/hide", [[cmd /c shutdown -a]])
        winapi.show_message("注意",
                            "您虽然取消了立即启动到镜像，\n但重启后还是会启动一次的，\n再重启就好了，莫慌!")
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
    local r = winapi.show_message("操作镜像",
                                  " [是] 立即重启到镜像并只启动一次\n\n [否] 添加到菜单以后启动\n\n [取消] 不操作\n\n 当前启动文件: " ..
                                      bootfile .. "\n\n 启动环境: " ..
                                      bios_str .. "\n 当前系统为: " ..
                                      winver .. "\n\n boot.sdi所在分区: " ..
                                      boot_sdi_partition ..
                                      "\n boot.sdi相对路径: " ..
                                      boot_sdi_path ..
                                      "\n\n 启动镜像盘符: " ..
                                      boot_file_partition .. "\n 启动镜像: " ..
                                      boot_file_path, "yes-no-cancel", "warning")
    if r == "yes" then
        ntbootnow(bootfile)
    elseif r == "no" then
        ntbootadd(bootfile)
    elseif r == "cancel" then
        return
        -- winapi.show_message("您取消了操作镜像", bootfile)
    end
end

function ntbootadd(bootfile)
    -- 创建pe目录
    if addfile == "wim" then
        exec("/hide /wait", [[mkdir ]] .. bcd_drv .. [[\pe]])
        exec("/hide /wait", [[cmd /c copy /y "]] .. APP_Path ..
                 [[\ms\boot.sdi" ]] .. bcd_drv .. [[\pe]])
    	 exec("/hide /wait", [[cmd /c copy /y "]] .. bcd_drv ..
                 [[\windows\system32\boot.sdi" ]] .. bcd_drv .. [[\pe]])	 		 
    end
    addmode = "/displayorder"
    say = "添加永久启动项完成!"
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
        winapi.show_message("注意",
                            "添加失败，可能没有权限(需要右键->管理员运行)")
    else
        winapi.show_message("选择了添加到启动菜单", say)
        sui:close()
    end
end

function Add_Boot_Option(addfile)
    ntboot_init()
    -- if exec("/wait", APP_Path .. "\\bin\\isadmin.exe") == 0 then
    if exec("/wait", [[REG QUERY "HKU\S-1-5-19"]]) == 1 then
        toadmin = winapi.show_message("没有以管理员身份运行!",
                                      "请右键管理员身份运行本程序!，\n是否现在就尝试管理员身份重新运行本程序？",
                                      "yes-no", "warning")
    end
    if toadmin == "yes" then
        -- exec('/hide', [[cmd /c shutdown -a]])
        -- winapi.show_message('注意', "执行管理员提升权限操作")
        exec("/admin", [["]] .. APP_Path ..
                 [[\WinXshell.exe" -ui -jcfg wxsUI\UI_AppStore\main.jcfg]])
        sui:close()
        return
    elseif toadmin == "no" then
        return
    end
    -- winapi.show_message('添加文件类型', addfile)
    local filter = "启动镜像|*vhd;*.vhdx|所有文件|*.*"
    if addfile == "wim" then filter = "启动镜像|*wim|所有文件|*.*" end
    bootfile = Dialog:OpenFile("选择你要启动的" .. addfile ..
                                   "文件 当前为:" .. ntboot_runmode, filter)

    if bootfile == "" then
        -- winapi.show_message("你犯了个错误!", "你没有选择镜像!")
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
