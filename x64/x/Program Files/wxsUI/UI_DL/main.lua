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
dofile ("wxsUI\\UI_DL\\appstore.lua")
function require(name)
    if not package.loaded[name] then --模块是否已加载？
        local loader = findloader(name)
        if loader == nil then
            error("unable to load module"..name)
        end
        package.loaded[name] = true --将模块标记为已加载
        local res = loader(name)    --初始化模块
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

--不安装的程序如果存在直接运行

if File.exists(temp .. [[\]] .. app_setup) and app_runpath == "temp" or app_runpath == nil then 
exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup)
sui:close()
end


--local pid = winapi.temp_name()
--winapi.show_message("pid", pid)
if app_url ~=nil or user_agent ~=nil then
exec(
    "/hide",
    [[cmd /c aria2c --allow-overwrite=true ]] .. aria2c_args .. [[ ]] .. user_agent .. [[ "]] ..
                app_url .. [[" -d %temp% -o ]] .. app_setup .. [[>%temp%\]] .. logfile
)
end

-- 正则匹配获取多行
    --exec("/hide", [[cmd /c del /q /f %temp%\]] .. app_setup)
    if File.exists([[wxsUI\UI_DL\app_ico\]] .. app_name .. [[.png]]) then 
    label_info.text = "当前下载软件：<i app_ico\\" .. app_name .. ".png>" .. app_name
	else 
	label_info.text = "当前下载软件：<i app_ico\\nt6.png>" .. app_name
	end
	label_downspd.text = "初始化下载..."
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
    if File.exists(temp .. "\\" .. app_setup) and app_runpath ~= "temp" then
        label_downspd.text = "下载完毕！正在安装... [" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup .. " " .. app_setup_args)
        check_installed()
    elseif File.exists(temp .. "\\" .. app_setup) and app_runpath == "temp"  then
		--winapi.show_message("check_app", "完成")
        label_downspd.text = "下载完毕！请手动安装[" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup .. " " .. app_setup_args)
		sui:close()
    end

     
end

function check_installed()
    if File.exists(app_runpath) and app_runpath ~= "temp" and app_file == nil then
        label_downspd.text = "安装完成，准备运行!"
        exec("/hide", [[cmd /c start "" "]] .. app_runpath .. [["]])
	    suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "%temp%\]] .. app_setup .. [["]])
        sui:close()
	elseif File.exists(app_runpath) and app_runpath ~= "temp" and app_file ~= nil then
        label_downspd.text = "安装完成，准备运行!"
		--winapi.show_message("下载完成后播放文件:", app_file)
     	suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "%temp%\]] .. app_setup .. [["]])
		exec("/hide", [[cmd /c start "" "]] .. app_file .. [["]])
        sui:close()
    end
end

function loading()
    local path = temp .. "\\" .. logfile
    local file = io.open(path, "r")
    if file == nil then
        label_downspd.text = "无下载，准备就绪!"
        process_slider.value = 0
    else
        local text = file:read("*a")
		file:close()
        local regex = "([^\n]+)[\n]*$" -- 匹配最后一行有效文本 $表示匹配字符串结尾位置
		complete = text:match("Download complete: ([^] %s]+)")
        for all_str in string.gfind(text, "[[][#].-[]]") do
            table.insert(fixed_out, all_str)
        end
        down_str = table.concat(fixed_out, "\n\n")
        --winapi.show_message("最后一个", down_str)
        --文件判断语句备份
		   	if complete ~= nil then 
		    	eta_str = "0S"
                label_downspd.text = "完成!"
                process_slider.value = "100"
				process_val = "100"
                check_app()
            end
        for loading_str in string.gmatch(down_str, regex) do
				dl_str = loading_str:match("DL:([^] %s]+)")
				eta_str = loading_str:match("ETA:([^]]+)")
				process_val = loading_str:match("[((]([^%%]+)")
     		if process_val ~=nil and eta_str ~=nil and process_val < "95" then
               label_downspd.text = "已经完成:" .. process_val .. "% 速度:" .. dl_str .. "/S 剩余时间:" .. eta_str
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
	check_option()
	--winapi.show_message("当前软件下载地址：", app_url .. "\n\n\n伪装参数:" .. user_agent .. "\n\n\n软件名称:".. app_name)
elseif has_option("-nbapp") then	
   	nbapp = get_option("-nbapp")
	app_file = get_option("-app_file")
	check_option()
	check_nbapp()
	--winapi.show_message("当前软件下载地址：", app_url .. "\n\n\n伪装参数:" .. user_agent .. "\n\n\n软件名称:".. app_name)
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
