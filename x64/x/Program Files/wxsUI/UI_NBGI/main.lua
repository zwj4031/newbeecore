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
local strDrivers = "��ѡ�������ԭ\nһ������"
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
			"���棡���ݽ���ʧ!!",
			"[��] �����ָ�" ..	bootfile ..
					"������:" .. part ..
										"\n[��] ȡ��",    
												"yes-no",
			"warning"
		)
		if r == "yes" then	  
	 -- winapi.show_message('�����޸�', [[cmd /k ghost.exe -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb]])	
  exec("/wait", [[cmd /c wxsUI\UI_NBGI\ghost64.EXE -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb>X:\nbgiout.log]])
        job.text = "������ɣ�������û�лָ��ɹ��������ǻָ�����..."
         else
		onload() 
		 end
end

--ѡ����
function selimg(part)
windowspart = part


   	   local filter = "ϵͳ����|*wim;*.gho;*.esd|�����ļ�|*.*"
       bootfile = Dialog:OpenFile("��ѡ��һ������������лָ�����" .. part .. "�ϵ����ݽ������ǣ� ", filter)
  	if bootfile == "" then
      job.text = "��û��ѡ�����ѡ������Ч����"
	  onload()
	 else
	  list_index(bootfile)
	 end

	 if bootfile:find("GHO") and indexlist[1] == nil then 
	 
	  job.text = "��ѡ����Ghost����..."
      ghost(bootfile, part)
	 elseif indexlist ~= nil and indexlist[1] == nil then 
	  job.text = "��û��ѡ�����ѡ������Ч����..."
	  onload()
	
	 --���ֻ��1������Ĭ���õ�һ����
	elseif indexlist[2] == nil then
	 job.text = "����1����ѡ[��]��ֱ�ӻ�ԭ..."
	dojob(windowspart, bootfile, "1")
	 
	elseif indexlist[2] ~= nil then
    job.text = "���ҵ������...��ѡ������һ��"
	listmode = "sel_wimindex"
	
	
	end 
	
end	  


--dism��������
function dism_job(part)
local path = temp .. "\\" .. logfile
local file = io.open(path, "r")
if file == nil then
job.text = "������"
  else
        local text = file:read("*a")
		file:close()
		local regex = "([^\n]+)[\n]*$" -- ƥ�����һ����Ч�ı� $��ʾƥ���ַ�����βλ��
		 for loading_str in string.gmatch(text, regex) do
		 percent = loading_str:match("%d+")
	     if loading_str == "�����ɹ���ɡ�" and r == "yes" then
		 job.value = 100
		 suilib.call("KillTimer", TID_DISM_JOB)	
		 --�޸�����
     exec(
    "/hide",
  [[cmd /c bcdboot ]] .. windowspart .. [[\windows /l zh_CN]]
  )      
     	job.text = "�ͷž��� " .. windowspart .. " ���! �����޸����!"
		 elseif loading_str == "�����ɹ���ɡ�" and r == "no" then
			job.text = "�ͷž��� " .. windowspart .. " ���!"
		 suilib.call("KillTimer", TID_DISM_JOB)	
    	 else 
		 job.value = percent
		 job.text = "�Ѿ��ͷ�" .. percent .."%"
		 end 
end
end
end

--wimlib��������
function wimlib_job(part)
local path = temp .. "\\" .. logfile
local file = io.open(path, "r")
if file == nil then
job.text = "������"
  else
        local text = file:read("*a")
		text = text:gsub("\r", "\r\n")
		file:close()
		local regex = "([^\n]+)[\n]*$" -- ƥ�����һ����Ч�ı� $��ʾƥ���ַ�����βλ��
		 for loading_str in string.gmatch(text, regex) do
		 if loading_str ~= nil then
		 percent = loading_str:match("%d+%%")
		 end
		 if percent ~= nil then
		 percent = percent:gsub("%%", "")
		 end
		 --winapi.show_message("Ӳ���б�", percent)
		 if elem_check_restart.selected == 1 then
		 end_exec = [[cmd /c wpeutil Reboot]]
		 end_text = [[��������....]]
		 end
		 
	     if loading_str == "Done applying WIM image." then
		 job.value = 100
		 suilib.call("KillTimer", TID_DISM_JOB)	
		 --�޸�����
     exec(
    "/hide",
  [[cmd /c bcdboot ]] .. windowspart .. [[\windows /l zh_CN]]
  )     
     	job.text = "�ͷž��� " .. windowspart .. " ���! �����޸����!" .. end_text
		
     exec(
    "/hide",
   end_exec
  )   		
	
		 elseif loading_str == "Done applying WIM image." and r == "no" then
			job.text = "�ͷž��� " .. windowspart .. " ���!"
			suilib.call("KillTimer", TID_DISM_JOB)	
    	 elseif loading_str:find("Creating files:") then
		    job.value = percent
			job.text = "�����ļ�..." .. percent .. "%"
		 elseif loading_str:find("Extracting file data:") then
		    job.value = percent
			job.text = "��ȡ�ļ�����..." .. percent .. "%"
		 elseif loading_str:find("Applying metadata to files:") then
		    job.value = percent
			job.text = "��Ԫ����Ӧ�õ��ļ�..." .. percent .. "%"
		 end 
end
end
end

--��ʼ����
function onload()
  parts = 0
  job = sui:find("job")
  elem_null = sui:find("null")
  UPanList = sui:find("UPanList_combo")
  elem_check_format = sui:find('check_format')
  elem_check_restart = sui:find('check_restart')
  strDrivers = strDrivers:gsub("\\", "")
  job_str = "����,[�˰汾Ϊ��ʾ�棬ֻ֧�ֻ�ԭWIM��ʽ�ľ���"
  end_exec = [[cmd /c]]
  end_text = ""
  --get_label("hd0,msdos5")
--get_disk()
local all_disk = table.concat(disklist, "\n")
mydisk = string.format("����Ӳ������[%s]�� ��������[%s]\n%s", disknum, partnum, all_disk)
--winapi.show_message("Ӳ���б�", mydisk)
  UPanList.list = mydisk
  UPanList.index = 0
end

--�������¼�
function onlink(url)
if url == "ghost" then

exec("/wait", [[cmd /c wxsUI\UI_NBGI\ghost64.EXE]])
end
end


--�б�򻯱䴥���¼� 
function onchanged(ctrl)
  if ctrl == "UPanList_combo" then
    suilib.call("SetTimer", TID_UPANLIST_CHANGED, 200)
elseif ctrl == "check_format" and elem_check_format.selected == 0 then
--elem_check_format.text = "��"
--job.text = job_str .. ""

  --winapi.show_message('����', "�㲻���ʽ��ˬһ��?")
elseif ctrl == "check_format" and elem_check_format.selected == 1 then
--elem_check_format.text = "��"
--job.text = job_str .. " "
end 	
end


function onclick(ctrl)
  if ctrl == "btn_reload" then
  job.text = "�����¼���"
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

--�г�wim��esd�ļ�������dism���� 
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
	    indexlist_str = string.format("%s  �汾:%s ��С:%s", index_str, name_str, size_str)
    	table.insert(indexlist, indexlist_str)	
		end	
 all_index = table.concat(indexlist, "\n")
 myindex = string.format("��ѡ�����еķ־�ָ�\n%s",all_index)
 UPanList = sui:find("UPanList_combo")
 UPanList.list = myindex
 UPanList.index = 0
end
--]]

--�г�wim��esd�ļ�������wimlib����
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
--ѭ��
for index_s in string.gfind(text_ansi, "<IMAGE INDEX=*.-</IMAGE>") do
local name_str = index_s:match(disname_regex)
local index_str = index_s:match(index_regex)
local size_str = index_s:match(bytes_regex)
local size_str = bytesToSize(size_str - 0)

if name_str == nil then 
name_str = index_s:match(name_regex)
indexlist_str = string.format("%s  �汾:%s ��С:%s", index_str, name_str, size_str)
table.insert(indexlist, indexlist_str)
else
--Alert(indexlist_str)
indexlist_str = string.format("%s  �汾:%s ��С:%s", index_str, name_str, size_str)
table.insert(indexlist, indexlist_str)
end
end

end

 all_index = table.concat(indexlist, "\n")
 myindex = string.format("��ѡ�����еķ־�ָ�\n%s",all_index)
 UPanList = sui:find("UPanList_combo")
 UPanList.list = myindex
 UPanList.index = 0
end



--timer�б���¼����
function UPanList_combo_onchanged()
  panfu = UPanList.text:sub(1, 2)
  if listmode == "selimg" and UPanList.index ~= 0 and panfu ~= "hd" then
  selimg(panfu)
  elseif listmode == "selimg" and panfu == "hd" then
  panfu = UPanList.text:sub(1, 3)
  -- winapi.show_message('����', wim_index)
  job.text = "Ӳ�� " .. panfu .. " ��������������ݲ���������ȷ��!" 
 elseif listmode == "sel_wimindex" and UPanList.index ~= 0 then
 wim_index = UPanList.text:sub(1, 1)  
  -- winapi.show_message('����', wim_index)
 dojob(windowspart, bootfile,  wim_index) 
 end 
 end
--��ť�¼���� 


 
 --ʵ�ʲ���
function dojob(part, bootfile, wim_index)
			r = winapi.show_message(
			"��������",
			"[��] �����ָ�" ..	bootfile .. " ��" .. wim_index .. "����" ..
					"������:" .. part ..
										"\n[��] ȡ��",    
												"yes-no",
			"warning"
		)
		if r == "yes" and elem_check_format.selected == 0  then
		

		
	 --  winapi.show_message('�����޸�', [[cmd /k ghost.exe -clone,mode=pload,src="]] .. bootfile .. [[":1,dst=@os:]] .. part .. [[ -batch -noide -nousb]])	
		suilib.call("SetTimer", TID_DISM_JOB, 200)
--dism����
--exec("/hide", [[cmd /c Dism /Apply-Image /ImageFile:]] .. bootfile .. [[ /index:1 /ApplyDir:]] .. part .. [[>%temp%\]] .. logfile)     
--wimlib����

exec(
    "/hide",
  [[cmd /c wxsUI\UI_NBGI\wimlib64\wimlib-imagex.exe apply "]] .. bootfile .. [[" "]] .. wim_index .. [[" "]] .. part .. [[">%temp%\]] .. logfile
)  
		
	elseif r == "yes" and elem_check_format.selected == 1 then	
	job.text = "���ڸ�ʽ��" .. part
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
        job.text = "������ȡ��"
			--winapi.show_message("��ȡ���˲�������", bootfile)
		end	
end	
