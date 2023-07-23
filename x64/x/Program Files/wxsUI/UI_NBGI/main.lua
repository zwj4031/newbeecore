local SystemRoot = os.getenv("SystemRoot")
temp = os.getenv("temp")
local listmode = "selimg"
local TID_UPANLIST_CHANGED = 20000 + 1
APP_Path = app:info('path')
UI_Path = sui:info('uipath')
Wimlib_Path = "" .. UI_Path .. "wimlib64\\wimlib-imagex.exe"
--winapi.show_message("", Wimlib_Path)
dofile("" .. UI_Path .. "diskfire_read.lua")
local TID_DISM_JOB = 10086
local pid = winapi.get_current_pid()
local logfile = "nbgi.log"
local strDrivers = "请选择分区还原\n一键分区"
local fixed_out = {}


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

function ghost(bootfile, part)
r = winapi.show_message(
			"警告！数据将丢失!!",
			"[是] 立即恢复" ..	bootfile ..
					"到分区:" .. part ..
										"\n[否] 取消",    
												"yes-no",
			"warning"
		)
		if r == "yes" then	  
	 -- winapi.show_message('即将修复', [[cmd /k ghost.exe -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb]])	
  exec("/wait", [[cmd /c wxsUI\UI_NBGI\ghost64.EXE -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb>X:\nbgiout.log]])
        job.text = "操作完成，不管有没有恢复成功，反正是恢复好了..."
         else
		onload() 
		 end
end

--选择镜像
function selimg(part)
windowspart = part


   	   local filter = "系统镜像|*wim;*.gho;*.esd|所有文件|*.*"
       bootfile = Dialog:OpenFile("请选择一个分区镜像进行恢复，在" .. part .. "上的内容将被覆盖！ ", filter)
  	if bootfile == "" then
      job.text = "你没有选择镜像或选择了无效镜像"
	  onload()
	 else
	  list_index(bootfile)
	 end

	 if bootfile:find("GHO") and indexlist[1] == nil then 
	 
	  job.text = "你选择了Ghost镜像..."
      ghost(bootfile, part)
	 elseif indexlist ~= nil and indexlist[1] == nil then 
	  job.text = "你没有选择镜像或选择了无效镜像..."
	  onload()
	
	 --如果只有1个卷，就默认用第一个卷
	elseif indexlist[2] == nil then
	 job.text = "仅有1个卷，选[是]后直接还原..."
	dojob(windowspart, bootfile, "1")
	 
	elseif indexlist[2] ~= nil then
    job.text = "查找到多个卷...请选择其中一个"
	listmode = "sel_wimindex"
	
	
	end 
	
end	  


--dism方案部署
function dism_job(part)
local path = temp .. "\\" .. logfile
local file = io.open(path, "r")
if file == nil then
job.text = "部署中"
  else
        local text = file:read("*a")
		file:close()
		local regex = "([^\n]+)[\n]*$" -- 匹配最后一行有效文本 $表示匹配字符串结尾位置
		 for loading_str in string.gmatch(text, regex) do
		 percent = loading_str:match("%d+")
	     if loading_str == "操作成功完成。" and r == "yes" then
		 job.value = 100
		 suilib.call("KillTimer", TID_DISM_JOB)	
		 --修复引导
     exec(
    "/hide",
  [[cmd /c bcdboot ]] .. windowspart .. [[\windows /l zh_CN]]
  )      
     	job.text = "释放镜像到 " .. windowspart .. " 完成! 引导修复完成!"
		 elseif loading_str == "操作成功完成。" and r == "no" then
			job.text = "释放镜像到 " .. windowspart .. " 完成!"
		 suilib.call("KillTimer", TID_DISM_JOB)	
    	 else 
		 job.value = percent
		 job.text = "已经释放" .. percent .."%"
		 end 
end
end
end

--wimlib方案部署
function wimlib_job(part)
local path = temp .. "\\" .. logfile
local file = io.open(path, "r")
if file == nil then
job.text = "部署中"
  else
        local text = file:read("*a")
		text = text:gsub("\r", "\r\n")
		file:close()
		local regex = "([^\n]+)[\n]*$" -- 匹配最后一行有效文本 $表示匹配字符串结尾位置
		 for loading_str in string.gmatch(text, regex) do
		 if loading_str ~= nil then
		 percent = loading_str:match("%d+%%")
		 end
		 if percent ~= nil then
		 percent = percent:gsub("%%", "")
		 end
		 --winapi.show_message("硬盘列表", percent)
		 if elem_check_restart.selected == 1 then
		 end_exec = [[cmd /c wpeutil Reboot]]
		 end_text = [[即将重启....]]
		 end
		 
	     if loading_str == "Done applying WIM image." then
		 job.value = 100
		 suilib.call("KillTimer", TID_DISM_JOB)	
		 --修复引导
     exec(
    "/hide",
  [[cmd /c bcdboot ]] .. windowspart .. [[\windows /l zh_CN]]
  )     
     	job.text = "释放镜像到 " .. windowspart .. " 完成! 引导修复完成!" .. end_text
		
     exec(
    "/hide",
   end_exec
  )   		
	
		 elseif loading_str == "Done applying WIM image." and r == "no" then
			job.text = "释放镜像到 " .. windowspart .. " 完成!"
			suilib.call("KillTimer", TID_DISM_JOB)	
    	 elseif loading_str:find("Creating files:") then
		    job.value = percent
			job.text = "创建文件..." .. percent .. "%"
		 elseif loading_str:find("Extracting file data:") then
		    job.value = percent
			job.text = "提取文件数据..." .. percent .. "%"
		 elseif loading_str:find("Applying metadata to files:") then
		    job.value = percent
			job.text = "将元数据应用到文件..." .. percent .. "%"
		 end 
end
end
end

--初始运行
function onload()
  parts = 0
  job = sui:find("job")
  elem_null = sui:find("null")
  UPanList = sui:find("UPanList_combo")
  elem_check_format = sui:find('check_format')
  elem_check_restart = sui:find('check_restart')
  strDrivers = strDrivers:gsub("\\", "")
  job_str = "就绪,[此版本为演示版，只支持还原WIM格式的镜像"
  end_exec = [[cmd /c]]
  end_text = ""
  --get_label("hd0,msdos5")
--get_disk()
local all_disk = table.concat(disklist, "\n")
mydisk = string.format("共有硬盘数量[%s]个 分区数量[%s]\n%s", disknum, partnum, all_disk)
--winapi.show_message("硬盘列表", mydisk)
  UPanList.list = mydisk
  UPanList.index = 0
end

--超链接事件
function onlink(url)
if url == "ghost" then

exec("/wait", [[cmd /c wxsUI\UI_NBGI\ghost64.EXE]])
end
end


--列表框化变触发事件 
function onchanged(ctrl)
  if ctrl == "UPanList_combo" then
    suilib.call("SetTimer", TID_UPANLIST_CHANGED, 200)
elseif ctrl == "check_format" and elem_check_format.selected == 0 then
--elem_check_format.text = "否"
--job.text = job_str .. ""

  --winapi.show_message('警告', "你不想格式化爽一下?")
elseif ctrl == "check_format" and elem_check_format.selected == 1 then
--elem_check_format.text = "是"
--job.text = job_str .. " "
end 	
end


function onclick(ctrl)
  if ctrl == "btn_reload" then
  job.text = "已重新加载"
  exec("/hide", [[cmd /c WinXShell.exe -ui -jcfg wxsUI\UI_nbgi\main.jcfg]])
  sui:close()
  
end 	
end



function ontimer(tid)
  if tid == TID_UPANLIST_CHANGED then
    suilib.call("KillTimer", tid)
    UPanList_combo_onchanged()
  elseif tid == TID_DISM_JOB then
  --dism_job(part)
    wimlib_job(part)
  end
end

--列出wim或esd文件各个卷dism方法 
--[[
function list_index_dism(bootfile)
indexlist = {}
local exitcode, stdout = winapi.execute("Dism.exe /English /Get-WimInfo /WimFile:" .. bootfile)
stdout = stdout:gsub("\r\n", "\n")
        for dism_str in string.gfind(stdout, "Index*.-bytes") do
		local size_str = dism_str:match("Size : ([^\n ]+)")
		local size_str = bytesToSize(string.gsub(size_str, ",", "") - 0)
	    local index_str = dism_str:match("Index : ([^\n]+)\n")
		local name_str = dism_str:match("Name : ([^\n]+)\n")
	    indexlist_str = string.format("%s  版本:%s 大小:%s", index_str, name_str, size_str)
    	table.insert(indexlist, indexlist_str)	
		end	
 all_index = table.concat(indexlist, "\n")
 myindex = string.format("请选择镜像中的分卷恢复\n%s",all_index)
 UPanList = sui:find("UPanList_combo")
 UPanList.list = myindex
 UPanList.index = 0
end
--]]

--列出wim或esd文件各个卷wimlib方法
function list_index(bootfile)
indexlist = {}
exec("/hide /wait", [[cmd /c "del /q /f %temp%\temp.xml]])
exec("/hide /wait", [[cmd /c "wxsUI\UI_NBGI\wimlib64\wimlib-imagex.exe" info ]] .. bootfile .. [[ --extract-xml %temp%\temp.xml]])
local path = [[X:\Windows\temp\temp.xml]]
if File.exists("" .. path .. "") then
local file = io.open(path, "rb")
text = file:read("*a")
file:close()
text_ansi = winapi.encode(winapi.CP_UTF16, winapi.CP_ACP, text)

local index_regex = "<IMAGE INDEX=\"(%d+)\""
local disname_regex = "<DISPLAYNAME>([^<]+)</DISPLAYNAME>"
local name_regex = "<NAME>([^<]+)</NAME>"
local bytes_regex = "<TOTALBYTES>([^<]+)</TOTALBYTES>"
--循环
for index_s in string.gfind(text_ansi, "<IMAGE INDEX=*.-</IMAGE>") do
local name_str = index_s:match(disname_regex)
local index_str = index_s:match(index_regex)
local size_str = index_s:match(bytes_regex)
local size_str = bytesToSize(size_str - 0)

if name_str == nil then 
name_str = index_s:match(name_regex)
indexlist_str = string.format("%s  版本:%s 大小:%s", index_str, name_str, size_str)
table.insert(indexlist, indexlist_str)
else
--Alert(indexlist_str)
indexlist_str = string.format("%s  版本:%s 大小:%s", index_str, name_str, size_str)
table.insert(indexlist, indexlist_str)
end
end

end

 all_index = table.concat(indexlist, "\n")
 myindex = string.format("请选择镜像中的分卷恢复\n%s",all_index)
 UPanList = sui:find("UPanList_combo")
 UPanList.list = myindex
 UPanList.index = 0
end



--timer列表框事件检测
function UPanList_combo_onchanged()
  panfu = UPanList.text:sub(1, 2)
  if listmode == "selimg" and UPanList.index ~= 0 and panfu ~= "hd" then
  selimg(panfu)
  elseif listmode == "selimg" and panfu == "hd" then
  panfu = UPanList.text:sub(1, 3)
  -- winapi.show_message('警告', wim_index)
  job.text = "硬盘 " .. panfu .. " 将被清空所有数据并分区，请确认!" 
 elseif listmode == "sel_wimindex" and UPanList.index ~= 0 then
 wim_index = UPanList.text:sub(1, 1)  
  -- winapi.show_message('警告', wim_index)
 dojob(windowspart, bootfile,  wim_index) 
 end 
 end
--按钮事件检测 


 
 --实际部署
function dojob(part, bootfile, wim_index)
			r = winapi.show_message(
			"操作镜像",
			"[是] 立即恢复" ..	bootfile .. " 第" .. wim_index .. "个卷" ..
					"到分区:" .. part ..
										"\n[否] 取消",    
												"yes-no",
			"warning"
		)
		if r == "yes" and elem_check_format.selected == 0  then
		

		
	 --  winapi.show_message('即将修复', [[cmd /k ghost.exe -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb]])	
		suilib.call("SetTimer", TID_DISM_JOB, 200)
--dism方案
--exec("/hide", [[cmd /c Dism /Apply-Image /ImageFile:]] .. bootfile .. [[ /index:1 /ApplyDir:]] .. part .. [[>%temp%\]] .. logfile)     
--wimlib方案

exec(
    "/hide",
  [[cmd /c wxsUI\UI_NBGI\wimlib64\wimlib-imagex.exe apply "]] .. bootfile .. [[" "]] .. wim_index .. [[" "]] .. part .. [[">%temp%\]] .. logfile
)  
		
	elseif r == "yes" and elem_check_format.selected == 1 then	
	job.text = "正在格式化" .. part
		exec(
    "/hide /wait",
  [[cmd /c echo ]] .. data_label_table[part] .. [[|format ]] .. part .. [[ /y /q >%temp%\format.log]]
)  
	suilib.call("SetTimer", TID_DISM_JOB, 200)
	exec(
    "/hide",
  [[cmd /c wxsUI\UI_NBGI\wimlib64\wimlib-imagex.exe apply "]] .. bootfile .. [[" "]] .. wim_index .. [[" "]] .. part .. [[">%temp%\]] .. logfile
)  
			--suilib.call("KillTimer", TID_DISM_JOB)
	     elseif r == "no" then
        job.text = "操作被取消"
			--winapi.show_message("您取消了操作镜像", bootfile)
		end	
end	
