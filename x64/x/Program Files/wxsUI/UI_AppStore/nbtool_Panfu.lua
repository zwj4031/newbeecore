
function ennvme(syspath)
  if syspath == "" then
   winapi.show_message("离线系统盘符重置", "取消")
  else
   exec('/hide /wait', 'reg load hklm\\offline_system ' .. syspath .. '\\Windows\\system32\\Config\\SYSTEM')
   exec('/hide /wait', 'reg delete hklm\\offline_system\\MountedDevices /va /F')
   exec('/wait', 'reg unload hklm\\offline_system')
   winapi.show_message("离线系统盘符重置", [[离线系统所在分区]] .. syspath .. "\n" .. [[已重置盘符!请重启后测试!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('警告', a)
   local syspath = Dialog:BrowseFolder('离线系统盘符重置', 17)
   ennvme(syspath)
else
return
end
end



a=winapi.show_message('警告', "你将为目标系统系统盘符重置!即删除MountedDevices \n 请肾重选择系统分区", 'yes-no')
check(a)

