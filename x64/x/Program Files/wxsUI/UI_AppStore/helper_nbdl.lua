--下载相关添加
temp = os.getenv("temp")
local fixed_speed_out = {}
local pid = winapi.get_current_pid()
local logfile = pid .. ".log"
TIMER_ID_QUIT = 1002
TIMER_ID_LOADING = 10088
TIMER_ID_CHECK_INSTALLED = 10089
eta_str = 0
dl_str = 0
app_runpath = "temp"
app_setup_args = "/S"
process_val = 0
--other
--下载相关


function ontimer(id)
    if id == TIMER_ID_QUIT then
        sui:close()
    elseif id == TIMER_ID_LOADING then
        loading()
    elseif id == TIMER_ID_CHECK_INSTALLED then
        check_installed()
    end
end




--下载开始
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
        App_STAR.text = "准备就绪!"
        App_ProgressBar.value = 0
    else
        local text = file:read("*a")
		file:close()
        local regex = "([^\n]+)[\n]*$" -- 匹配最后一行有效文本 $表示匹配字符串结尾位置
		complete = text:match("Download complete: ([^] %s]+)")
        for all_str in string.gfind(text, "[[][#].-[]]") do
            table.insert(fixed_speed_out, all_str)
        end
        down_str = table.concat(fixed_speed_out, "\n\n")
        --winapi.show_message("最后一个", down_str)
        --文件判断语句备份
		   	if complete ~= nil then 
		    	eta_str = "0S"
                App_STAR.text= "完成!"
                App_ProgressBar.value = "100"
				process_val = "100"
                check_app()
            end
        for loading_str in string.gmatch(down_str, regex) do
				dl_str = loading_str:match("DL:([^] %s]+)")
				eta_str = loading_str:match("ETA:([^]]+)")
				process_val = loading_str:match("[((]([^%%]+)")
     		if process_val ~=nil and eta_str ~=nil and process_val < "95" then
               App_STAR.text = "已经完成:" .. process_val .. "% "
			   --App_STAR.text = "已经完成:" .. process_val .. "% 速度:" .. dl_str .. "/S 剩余时间:" .. eta_str
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
    if File.exists(temp .. "\\" .. app_setup) and app_runpath ~= "temp" then
	    App_STAR.text= "正在安装... "
        --App_STAR.text= "正在安装... [" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup .. " " .. app_setup_args)
        check_installed()
    elseif File.exists(temp .. "\\" .. app_setup) and app_runpath == "temp"  then
		--winapi.show_message("check_app", "完成")
		App_STAR.text= "执行程序.. "
        --App_STAR.text= "请安装[" .. app_setup .. "]"
        exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup .. " " .. app_setup_args)
		sui:close()
    end

     
end


function check_installed()
    if File.exists(app_runpath) and app_runpath ~= "temp" and file == nil then
        App_STAR.text= "安装完成"
        exec("/hide", [[cmd /c start "" "]] .. app_runpath .. [["]])
	    suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "%temp%\]] .. app_setup .. [["]])
		--suilib.call("KillTimer", 10089)
		sui:close()
	elseif File.exists(app_runpath) and app_runpath ~= "temp" and file ~= nil then
        App_STAR.text= "安装完成"
		--winapi.show_message("下载完成后播放文件:", app_file)
     	suilib.call("KillTimer", 10088)
        Desktop:Refresh()
		exec("/hide", [[cmd /c del /q "%temp%\]] .. app_setup .. [["]])
		exec("/hide", [[cmd /c start "" "]] .. file .. [["]])
		sui:close()
    end
end

function app_init()
App_ProgressBar = sui:find("App_ProgressBar")
--不安装的程序如果存在直接运行
if File.exists(temp .. [[\]] .. app_setup) and app_runpath == "temp" or app_runpath == nil then 
exec("/hide", [[cmd /c start "" %temp%\]] .. app_setup)
--sui:close()
end
if app_url ~=nil or user_agent ~=nil then
exec(
    "/hide",
    [[cmd /c aria2c --allow-overwrite=true ]] .. aria2c_args .. [[ ]] .. user_agent .. [[ "]] ..
                app_url .. [[" -d %temp% -o ]] .. app_setup .. [[>%temp%\]] .. logfile
)
end
   App_ProgressBar = sui:find("$App[" .. ITEMID .. "]ProgressBar")
   App_STAR.text = "正在下载"
   App_ProgressBar.visible = "1"
   App_ProgressBar.value = 0
    suilib.call("SetTimer", TIMER_ID_CHECK_INSTALLED, 2000)
    suilib.call("SetTimer", TIMER_ID_LOADING, 1000)
 
end
---下载初始化结束

function storedl(app_url,user_agent,app_setup,app_setup_args,app_runpath,aria2c_args)
app_init()
 end 

function storedl_analysis(app_id,direct_url,user_agent,app_setup,app_setup_args,app_runpath,aria2c_args,download_page)
exec( "/wait /hide", [[cmd /c aria2c ]] .. user_agent .. [[ --allow-overwrite=true ]] .. download_page ..[[ -d %temp% -o ]] .. app_id .. ".dl")
local path = temp .. "\\" .. app_id .. ".dl"
tmpfile = io.open(path, "r")
html = tmpfile:read("*a")
--winapi.show_message("解析下载", "html代码" .. [["]] .. direct_url .. [["]])
tmpfile:close()
app_url = html:match(direct_url)
if app_url == nil then
winapi.show_message("错误", "解析失败")
else
app_init()
end
end 

function onlick_app(app_click,appmode)
    ITEMID = AppInfo[app_click].id  
	App_STAR = sui:find("$App[" .. ITEMID .. "]STAR")
--如果是nbapp	
 if appmode == "nbapp" then 
   nbapp = AppInfo[app_click].nbapp
   exec('/show', [[WinXShell.exe -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp ]] .. nbapp)
   elseif appmode == "nbapp_file" then
   App_STAR.text = "安装后打开" .. file
   exec('/show', [[WinXShell.exe -ui -jcfg wxsUI\\UI_DL\\main.jcfg -nbapp ]] .. nbapp .. [[ -file ]] .. file)  
  --如果是本地应用 
   elseif appmode == "runapp" then
   runapp = AppInfo[app_click].app_runpath
   App_STAR.text = "正在运行"
  exec(runapp)
   if AppStore.config['close_runapp_clicked'] == 1 then
        sui:close()
   elseif AppStore.config['hide_runapp_clicked'] == 1 then
        sui:hide()
   end
   --如果是商店直链
   elseif appmode == "StoreApp_direct_url" then 
   app_url = AppInfo[app_click].direct_url
   app_runpath  = AppInfo[app_click].app_runpath
   app_setup_args = AppInfo[app_click].app_setup_args
   app_setup = AppInfo[app_click].app_setup
   user_agent = AppInfo[app_click].user_agent
   aria2c_args = AppInfo[app_click].aria2c_args 
   storedl(app_url,user_agent,app_setup,app_setup_args,app_runpath,aria2c_args)
  --  --如果是商店解析链
   elseif appmode == "StoreApp_analysis_url" then 
   App_STAR.text = "正在解析"
   app_id = AppInfo[app_click].id
   direct_url = AppInfo[app_click].direct_url
   app_runpath  = AppInfo[app_click].app_runpath
   app_setup_args = AppInfo[app_click].app_setup_args
   app_setup = AppInfo[app_click].app_setup
   user_agent = AppInfo[app_click].user_agent
   aria2c_args = AppInfo[app_click].aria2c_args 
   download_page = AppInfo[app_click].download_page
   storedl_analysis(app_id,direct_url,user_agent,app_setup,app_setup_args,app_runpath,aria2c_args,download_page)
  --什么都不是
   elseif app_click ~= nil and appmode == nil then
   msg("无法使用，缺少info.appmode相关项")
 end

end   

function  helper_nbdl_onload()
    --onclick('$App[qq]')
  onclick('$Nav[5]')
end


function helper_nbdl_onclick(ctrl)
 --for _dlhelper_start
   local app_click = ctrl:match('$App%[(.+)%]')
   if app_click ~=nil then 
   --msg(app_click)
   appmode = AppInfo[app_click].appmode
   onlick_app(app_click,appmode)
   end
end