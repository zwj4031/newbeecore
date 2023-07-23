--sys_env
temp = os.getenv("temp")
label_downspd = sui:find("label_downspd")
local fixed_out = {}
local pid = winapi.get_current_pid()
local logfile = pid .. ".log"
--other_env
lshift_index = 0
char_width = 2
TIMER_ID_FLUSH_TEXT = 1001
TIMER_ID_QUIT = 1002
TIMER_ID_LOADING = 10088
TIMER_ID_CHECK_INSTALLED = 10089
eta_str = 0
dl_str = 0
app_runpath = "temp"
app_setup_args = "/S"
process_val = 0
--other
stdout = ""
file = ""
text = ""
file_type = ""
file_ext = ""
show_text = ""
aria2c_args = [[-c -s 2 -x 2 -j 199 --file-allocation=none --user-agent="Chrome/94.0.4606.71"]]


function check_option()
if user_agent ~= nil then 
user_agent = app_user_agent
end
--winapi.show_message("��ǰ������ص�ַ��", "û�õ���ϸ����")
if app_setup_args == nil then 
app_setup_args = "/S"
end
if app_runpath == nil then
app_runpath = "temp"
end

if downpath == nil then
downpath = "%temp%"
end

if app_setup == nil then
app_setup = "setup.exe"
end
if user_agent == nil then 
user_agent = [[--user-agent="Chrome/94.0.4606.71"]]
end
if aria2c_args == nil then
aria2c_args = "-c -j 199 --file-allocation=none"
end
if app_setup == nil then
app_setup = "setup.exe"
end
end




function require(name)
    if not package.loaded[name] then --ģ���Ƿ��Ѽ��أ�
        local loader = findloader(name)
        if loader == nil then
            error("unable to load module"..name)
        end
        package.loaded[name] = true --��ģ����Ϊ�Ѽ���
        local res = loader(name)    --��ʼ��ģ��
        if res ~=nil then
            package.loaded[name] = res
        end 
    end     
    return package.loaded[name]
end

function dofile (filename)
  local f = assert (loadfile (filename))
  return f ()
end -- dofile
 

function app_init()
process_slider = sui:find("process_slider")
label_info = sui:find("label_info")

--����װ�ĳ����������ֱ������

if File.exists(downpath .. [[\]] .. app_setup) and app_runpath == "temp" or app_runpath == nil then 
exec("/hide", [[cmd /c start "" ]] .. downpath .. [[\]] .. app_setup)
sui:close()
end


--local pid = winapi.temp_name()
--winapi.show_message("pid", pid)
if nbapp == "btwim" then
--winapi.show_message("pid", "ϵͳ����")
exec(
    "/hide",
    [[cmd /c aria2c --allow-overwrite=true ]] .. aria2c_args .. [[ ]] .. user_agent .. [[ "]] ..
                app_url .. [[" -d I:\ -o ]] .. app_setup .. [[>%temp%\]] .. logfile
)
elseif app_url ~=nil or user_agent ~= nil and nbapp ~= "btwim" then
--napi.show_message("pid", "��ͨӦ��")
---������appstore���ε��������

exec(
    "/hide",
      [[cmd /c aria2c --allow-overwrite=true ]] ..
            aria2c_args ..
            [[ ]] .. user_agent .. [[ "]] ..
            app_url .. [[" -d ]] .. downpath .. [[ -o ]] .. app_setup .. [[>%temp%\]] .. logfile
)

end

-- ����ƥ���ȡ����
    --exec("/hide", [[cmd /c del /q /f %temp%\]] .. app_setup)
    if File.exists([[wxsUI\UI_DL\app_ico\]] .. app_name .. [[.png]]) then 
    label_info.text = [[���ص���]] .. downpath  .. [[\]] .. app_setup
	else 
	label_info.text = [[<i app_ico\nt6.png> ���ص���]] .. downpath .. [[\]] .. app_setup
	end
	label_downspd.text = "��ʼ������..."
    process_slider.value = 0
    suilib.call("SetTimer", TIMER_ID_CHECK_INSTALLED, 2000)
    suilib.call("SetTimer", TIMER_ID_LOADING, 1000)
 
end

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

function check_app()
    process_slider = sui:find("process_slider")
	    process_slider.value = 100
        process_val = 100
		suilib.call("KillTimer", 10088)	
    if File.exists(downpath .. "\\" .. app_setup)  then
		
        label_downspd.text = "������ϣ����ڰ�װ... [" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" ]] .. downpath .. [[\]] .. app_setup)
       end

     
end

function check_installed()
    if File.exists(app_runpath) and app_runpath ~= "temp" and app_file == nil and nbapp ~= "btwim" and nbapp ~= "btgho" then
	
	    label_downspd.text = "��װ��ɣ�׼������!"
		
        exec("/hide", [[cmd /c start "" "]] .. app_runpath .. [["]])
	    suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "]] .. downpath .. [[\]] .. app_setup .. [["]])
        sui:close()
	elseif File.exists(app_runpath) and app_runpath ~= "temp" and app_file ~= nil then
	
        label_downspd.text = "��װ��ɣ�׼������!"
		--winapi.show_message("������ɺ󲥷��ļ�:", app_file)
     	suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "%temp%\]] .. app_setup .. [["]])
		exec("/hide", [[cmd /c start "" "]] .. app_file .. [["]])
        sui:close()
		--�����ϵͳ��������õ�������װ��
	elseif File.exists(app_runpath) and not File.exists(app_runpath .. ".aria2") and app_runpath ~= "temp" and nbapp == "btwim" then
		
	    label_downspd.text = "ϵͳ����������ɣ�׼������!"
		--winapi.show_message("������ɺ󲥷��ļ�:", app_file)
     	suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/show", [[cmd /k dism /Get-WimInfo /wimfile:"]] .. app_runpath)
        sui:close()	
    end
end

function loading()
    local path = temp .. "\\" .. logfile
    local file = io.open(path, "r")
    if file == nil then
        label_downspd.text = "�����أ�׼������!"
        process_slider.value = 0
    else
        local text = file:read("*a")
		file:close()
        local regex = "([^\n]+)[\n]*$" -- ƥ�����һ����Ч�ı� $��ʾƥ���ַ�����βλ��
		complete = text:match("Download complete: ([^] %s]+)")
        for all_str in string.gfind(text, "[[][#].-[]]") do
            table.insert(fixed_out, all_str)
        end
        down_str = table.concat(fixed_out, "\n\n")
        --winapi.show_message("���һ��", down_str)
        --�ļ��ж���䱸��
		   	if complete ~= nil then 
		    	eta_str = "0S"
                label_downspd.text = "���!"
                process_slider.value = "100"
				process_val = "100"
                check_app()
            end
        for loading_str in string.gmatch(down_str, regex) do
				dl_str = loading_str:match("DL:([^] %s]+)")
				eta_str = loading_str:match("ETA:([^]]+)")
				process_val = loading_str:match("[((]([^%%]+)")
     		if process_val ~=nil and eta_str ~=nil and process_val < "95" then
               label_downspd.text = "�Ѿ����:" .. process_val .. "% �ٶ�:" .. dl_str .. "/S ʣ��ʱ��:" .. eta_str
               process_slider.value = process_val
			end
        end
    end
    --local regex = "([^\n]+)$"
end

function move_top()
    local w, h = sui:info("wh")
    if has_option("-top") then
        sui:move(((Screen:GetX() - w) // 2) + 2, -((Screen:GetY() - h) // 2) + 22, 0, 0)
    end
end

function onload()
 if has_option("-app_url") then
    app_url = get_option("-app_url")
	app_name = get_option("-app_name")
	app_user_agent = get_option("-app_user_agent")
	aria2c_args = get_option("-aria2c_args")
	app_setup_args = get_option("-app_setup_args")
	app_runpath = get_option("-app_runpath")
	app_setup = get_option("-app_setup")
	app_file = get_option("-app_file")
	downpath = get_option("-downpath")
	
	check_option()
	--winapi.show_message("��ǰ������ص�ַ��", app_url .. "\n\n\nαװ����:" .. user_agent .. "\n\n\n�������:".. app_name)
elseif has_option("-nbapp") then	
   	nbapp = get_option("-nbapp")
	app_file = get_option("-app_file")
	check_option()
	check_nbapp()
	--winapi.show_message("��ǰ������ص�ַ��", app_url .. "\n\n\nαװ����:" .. user_agent .. "\n\n\n�������:".. app_name)
else
default_appenv()
end
app_init()
end

function ontimer(id)
    if id == TIMER_ID_QUIT then
        sui:close()
    elseif id == TIMER_ID_LOADING then
        loading()
    elseif id == TIMER_ID_CHECK_INSTALLED then
        check_installed()
    end
end

function ondisplaychanged()
    move_top()
end
