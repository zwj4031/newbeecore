--����������
local getfullpath_func = type(File.GetFullPath)
if getfullpath_func == "function" then
temp = File.GetFullPath(os.getenv("temp"))
else
temp = os.getenv("temp")
end
SystemDrive = os.getenv("SystemDrive")
local fixed_speed_out = {}
local pid = winapi.get_current_pid()
local logfile = pid .. ".log"
TIMER_ID_QUIT = 1002
TIMER_ID_LOADING = 10088
TIMER_ID_CHECK_INSTALLED = 10089
eta_str = 0
dl_str = 0
app_runpath = "temp"
downpath = temp
set_downpath = temp
app_setup_args = "/S"
process_val = 0
function winntsetup()
    install_esd = [[X:\\Program Files\\WinNTSetup\\winntsetup.exe]]
    if File.exists("" .. install_esd .. "") then
        exec("/hide",
            [[cmd /c ftype .esd="]] ..
            install_esd .. [[" nt6 /source:"%1" /unattend:"unattend\���ù���Ա�û�\X64\Panther\Unattend.xml"]])
        exec("/hide",
            [[cmd /c ftype .wim="]] ..
            install_esd .. [[" nt6 /source:"%1" /unattend:"unattend\���ù���Ա�û�\X64\Panther\Unattend.xml"]])
        exec("/hide",
            [[cmd /c ftype 7-Zip.wim="]] ..
            install_esd .. [[" nt6 /source:"%1" /unattend:"unattend\���ù���Ա�û�\X64\Panther\Unattend.xml"]])
    end
end

function ckadmin()
    --if exec("/wait", APP_Path .. "\\bin\\isadmin.exe") == 0 then
	if exec("/wait", [[REG QUERY "HKU\S-1-5-19"]]) == 1 then 
        toadmin = winapi.show_message("����!û���Թ���Ա�������!�����޷�����ʹ��", "���Ҽ�����Ա������б�����!��\n�Ƿ����ھͳ��Թ���Ա����������б�����"
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
end

--other
--�������

function ontimer(id)
    if id == TIMER_ID_QUIT then
        sui:close()
    elseif id == TIMER_ID_LOADING then
        loading()
    elseif id == TIMER_ID_CHECK_INSTALLED then
        check_installed()
    end
end

--���ؿ�ʼ
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

function loading()
    local path = temp .. "\\" .. logfile
    local file = io.open(path, "r")
    if file == nil then
        App_STAR.text = "׼������!"
        App_ProgressBar.value = 0
    else
        local text = file:read("*a")
        file:close()
        local regex = "([^\n]+)[\n]*$" -- ƥ�����һ����Ч�ı� $��ʾƥ���ַ�����βλ��
        complete = text:match("Download complete: ([^] %s]+)")
        for all_str in string.gfind(text, "[[][#].-[]]") do
            table.insert(fixed_speed_out, all_str)
        end
        down_str = table.concat(fixed_speed_out, "\n\n")
        --winapi.show_message("���һ��", down_str)
        --�ļ��ж���䱸��
        if complete ~= nil then
            eta_str = "0S"
            App_STAR.text = "���!"
            App_ProgressBar.value = "100"
            process_val = "100"
            check_app()
        end
        for loading_str in string.gmatch(down_str, regex) do
            dl_str = loading_str:match("DL:([^] %s]+)")
            eta_str = loading_str:match("ETA:([^]]+)")
            process_val = loading_str:match("[((]([^%%]+)")
            if process_val ~= nil and eta_str ~= nil and process_val < "95" then
                App_STAR.text = "�Ѿ����:" .. process_val .. "% "
                --App_STAR.text = "�Ѿ����:" .. process_val .. "% �ٶ�:" .. dl_str .. "/S ʣ��ʱ��:" .. eta_str
                App_ProgressBar.value = process_val
            end
        end
    end
    --local regex = "([^\n]+)$"
end

function check_app()
    App_ProgressBar.value = 100
    process_val = 100
    suilib.call("KillTimer", 10088)
    if File.exists(downpath .. "\\" .. app_setup) and app_runpath ~= "temp" and winpe == nil then
        App_STAR.text = "���ڰ�װ... "
        --App_STAR.text= "���ڰ�װ... [" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" ]] .. downpath .. [[\]] .. app_setup .. " " .. app_setup_args)
        check_installed()
    elseif File.exists(downpath .. "\\" .. app_setup) and app_runpath == "temp" and winpe == nil then
        --winapi.show_message("check_app", "���")
        App_STAR.text = "ִ�г���.. "
        --App_STAR.text= "�밲װ[" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" ]] .. downpath .. [[\]] .. app_setup .. " " .. app_setup_args)
        --��ɺ�ر�sui:close()
			 suilib.call("KillTimer", 1002)
		 suilib.call("KillTimer", 10089)
    elseif winpe ~= nil then
        suilib.call("KillTimer", 10088)
        pepath = downpath .. [[\]] .. app_setup
        pepath = pepath:gsub(":\\\\", ":\\")
        addfile = "wim"
        ntboot_ask(pepath)
        --��ɺ�ر� sui:close()
		 suilib.call("KillTimer", 1002)
		 suilib.call("KillTimer", 10089)
    end
end

function check_installed()

    if File.exists(app_runpath) and app_runpath ~= "temp" and file == nil and winpe == nil then
        App_STAR.text = "��װ���"
        exec("/hide", [[cmd /c start "" "]] .. app_runpath .. [["]])
        suilib.call("KillTimer", 10088)
        Desktop:Refresh()
        exec("/hide", [[cmd /c del /q ]] .. downpath .. [[\]] .. app_setup .. [["]])
        --suilib.call("KillTimer", 10089)
        --��ɺ�ر� sui:close()
			 suilib.call("KillTimer", 1002)
		 suilib.call("KillTimer", 10089)
    elseif File.exists(app_runpath) and app_runpath ~= "temp" and file ~= nil and winpe == nil then
        App_STAR.text = "��װ���"
        --winapi.show_message("������ɺ󲥷��ļ�:", app_file)
        suilib.call("KillTimer", 10088)
        Desktop:Refresh()
        exec("/hide", [[cmd /c del /q ]] .. downpath .. [[\]] .. app_setup .. [["]])
        exec("/hide", [[cmd /c start "" "]] .. file .. [["]])
		--��ɺ�ر�
        --sui:close()
			 suilib.call("KillTimer", 1002)
		 suilib.call("KillTimer", 10089)

    end
end

function app_init()
    App_ProgressBar = sui:find("App_ProgressBar")
    --�����pe������ntboot


    --����װ�ĳ����������ֱ������
    if File.exists(downpath .. [[\]] .. app_setup) and app_runpath == "temp" and winpe == nil or app_runpath == nil then
        exec("/hide", [[cmd /c start "" ]] .. downpath .. [[\]] .. app_setup)
    elseif File.exists(downpath .. [[\]] .. app_setup) and winpe ~= nil then
	    pepath = downpath .. [[\]] .. app_setup
        pepath = pepath:gsub(":\\\\", ":\\")
        addfile = "wim"
        ntboot_ask(pepath)
        --��ɺ�ر�sui:close()
			 suilib.call("KillTimer", 1002)
		 suilib.call("KillTimer", 10089)
    end
    --sui:close()
	

    if app_url ~= nil or user_agent ~= nil then
        exec(
            "/hide",
            [[cmd /c aria2c --allow-overwrite=true ]] ..
            aria2c_args ..
            [[ ]] ..
            user_agent .. [[ "]] .. app_url .. [[" -d ]] .. downpath .. [[ -o ]] .. app_setup .. [[>%temp%\]] .. logfile
        )
    end
    App_ProgressBar = sui:find("$App[" .. ITEMID .. "]ProgressBar")
    App_STAR.text = "��������"
    App_ProgressBar.visible = "1"
    App_ProgressBar.value = 0
    suilib.call("SetTimer", TIMER_ID_CHECK_INSTALLED, 2000)
    suilib.call("SetTimer", TIMER_ID_LOADING, 1000)
end

---���س�ʼ������

function storedl(app_url, user_agent, app_setup, app_setup_args, app_runpath, aria2c_args)
    app_init()
end

function storedl_analysis(
    app_id,
    direct_url,
    user_agent,
    app_setup,
    app_setup_args,
    app_runpath,
    aria2c_args,
    download_page)
    exec(
        "/wait /hide",
        [[cmd /c aria2c ]] ..
        user_agent .. [[ --allow-overwrite=true ]] .. download_page .. [[ -d %temp% -o ]] .. app_id .. ".dl"
    )
    local path = temp .. "\\" .. app_id .. ".dl"
    tmpfile = io.open(path, "r")
    html = tmpfile:read("*a")
    --winapi.show_message("��������", "html����" .. [["]] .. direct_url .. [["]])
    tmpfile:close()
    --����Ľ�����RustDesk���еģ������Ӱ���ɾ��!!!!!!!!!!
    html = html:gsub('\\/', '/')
    app_url = html:match(direct_url)
	
	--�����ƥ���˲�����httpǰ׺�����ͣ�����https://ǰ׺
    if direct_url_prefix ~= nil then
	app_url = direct_url_prefix .. app_url
	end
    if app_url == nil then
        winapi.show_message("����", "����ʧ��")
    else
        app_init()
    end
end

function onlick_app(app_click, appmode)

    ITEMID = AppInfo[app_click].id
    App_STAR = sui:find("$App[" .. ITEMID .. "]STAR")
    pemode = AppInfo[app_click].pemode
    winpe = AppInfo[app_click].winpe
    adminmode = AppInfo[app_click].adminmode
    --pemodeֵ�����Ϊ�� ��ǰ�ֲ���pe��������
    if pemode ~= nil and SystemDrive ~= "X:" then
        msg("��ǰ������֧�����б������������ֻ����PE������!")
        return
    end
    if adminmode ~= nil then
        ckadmin()
	 end
	if toadmin == "yes" then return end	 
    --�����nbapp
    if appmode == "nbapp" then
        nbapp = AppInfo[app_click].nbapp
        exec("/show", [[WinXShell.exe -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp ]] .. nbapp)
    elseif appmode == "nbapp_file" then
        --����Ǳ���Ӧ��
        App_STAR.text = "��װ���" .. file
        exec("/show", [[WinXShell.exe -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp ]] .. nbapp .. [[ -file ]] .. file)
    elseif appmode == "runapp" then
        --������̵�ֱ��
        runapp = AppInfo[app_click].app_runpath
        App_STAR.text = "��������"
        exec(runapp)
        --  if AppStore.config["close_runapp_clicked"] == 1 then
        --     sui:close()
        -- elseif AppStore.config["hide_runapp_clicked"] == 1 then
        --    sui:hide()
        -- end
    elseif appmode == "StoreApp_direct_url" then
        --  --������̵������
        app_url = AppInfo[app_click].direct_url
        app_runpath = AppInfo[app_click].app_runpath
        app_setup_args = AppInfo[app_click].app_setup_args
        app_setup = AppInfo[app_click].app_setup
        user_agent = AppInfo[app_click].user_agent
        aria2c_args = AppInfo[app_click].aria2c_args
        storedl(app_url, user_agent, app_setup, app_setup_args, app_runpath, aria2c_args)
    elseif appmode == "StoreApp_analysis_url" then
        App_STAR.text = "���ڽ���"
        app_id = AppInfo[app_click].id
        direct_url = AppInfo[app_click].direct_url
		direct_url_prefix = AppInfo[app_click].direct_url_prefix
        app_runpath = AppInfo[app_click].app_runpath
        app_setup_args = AppInfo[app_click].app_setup_args
        app_setup = AppInfo[app_click].app_setup
        user_agent = AppInfo[app_click].user_agent
        aria2c_args = AppInfo[app_click].aria2c_args
        download_page = AppInfo[app_click].download_page
        storedl_analysis(
            app_id,
            direct_url,
            user_agent,
            app_setup,
            app_setup_args,
            app_runpath,
            aria2c_args,
            download_page
        )
    elseif appmode == "wimboot" then
        addfile = "raw"
	        Add_Boot_Option(addfile)
			
    elseif appmode == "vhdboot" then
        --ʲô������
	        addfile = "vhd"
	        Add_Boot_Option(addfile)
	elseif appmode == "StoreApp_BaiPiao" then
	BaiPiaoname = AppInfo[app_click].name
	BaiPiaoid = AppInfo[app_click].id
	BaiPiaourl = AppInfo[app_click].download_page
    dofile ("wxsUI\\UI_AppStore\\nbtool_nbdl_BaiPiao.lua")		
    elseif app_click ~= nil and appmode == nil then
        msg("�޷�ʹ�ã�ȱ��info.appmode�����")
    end
end

function helper_nbdl_onload()
    winntsetup()
    --onclick('$App[qq]')
    onclick("$Nav[5]")
end

function helper_nbdl_onclick(ctrl)

    if ctrl == "set_button" then
        set_downpath = Dialog:BrowseFolder('ѡ�����ر���λ��,  ��ǰ:  ' ..
            downpath .. "\n ����ϵͳ����ʱ�����޸ı���λ�û����������ڴ� ", 15)
    end
    if set_downpath == "" then
        downpath = temp
    else
        downpath = set_downpath
    end
    --for _dlhelper_start
    local app_click = ctrl:match("$App%[(.+)%]")
    if app_click ~= nil then
        appmode = AppInfo[app_click].appmode
        onlick_app(app_click, appmode)
    end
end
