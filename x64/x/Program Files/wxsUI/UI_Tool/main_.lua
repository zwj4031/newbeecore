local SystemRoot = os.getenv("SystemRoot")
local strDrivers = ""
local letters = winapi.get_logical_drives()

for _, l in ipairs(letters) do
  strDrivers =  strDrivers .. "\n" ..  l

end
strDrivers = strDrivers:gsub("\\", "") 
UPanList = sui:find('UPanList_combo')  
UPanList.list = "��ѡ������޸�" .. strDrivers
UPanList.index = "��ѡ������޸�"

function onchanged(ctrl)
   if ctrl ~= "��ѡ������޸�" then
   exec("/show", [[X:\\windows\\system32\\cmd.exe /k chkdsk /x ]] .. strDrivers)
   --winapi.show_message('�����޸�', UPanList.text)
   end
end

--onchanged(ctrl)