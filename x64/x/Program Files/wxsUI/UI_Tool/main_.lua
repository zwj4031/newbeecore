local SystemRoot = os.getenv("SystemRoot")
local strDrivers = ""
local letters = winapi.get_logical_drives()

for _, l in ipairs(letters) do
  strDrivers =  strDrivers .. "\n" ..  l

end
strDrivers = strDrivers:gsub("\\", "") 
UPanList = sui:find('UPanList_combo')  
UPanList.list = "请选择分区修复" .. strDrivers
UPanList.index = "请选择分区修复"

function onchanged(ctrl)
   if ctrl ~= "请选择分区修复" then
   exec("/show", [[X:\\windows\\system32\\cmd.exe /k chkdsk /x ]] .. strDrivers)
   --winapi.show_message('即将修复', UPanList.text)
   end
end

--onchanged(ctrl)