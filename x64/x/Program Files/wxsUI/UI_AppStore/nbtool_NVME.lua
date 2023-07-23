
function ennvme(syspath)
  if syspath == "" then
   winapi.show_message("NVME启用关闭", "取消")
  else
   exec('/hide /wait', 'reg load hklm\\offline_system ' .. syspath .. '\\Windows\\system32\\Config\\SYSTEM')
   exec('/hide /wait', 'reg delete hklm\\offline_system\\ControlSet001\\Services\\stornvme\\StartOverride /F')
   exec('/wait', 'reg unload hklm\\offline_system')
   winapi.show_message("NVME启用支持开启", [[离线系统所在分区]] .. syspath .. [[已启用NVME启动支持!请重启后测试!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('警告', a)
   local syspath = Dialog:BrowseFolder('启用NVME启动支持', 17)
   ennvme(syspath)
else
return
end
end



a=winapi.show_message('警告', "你将为目标系统开启NVME启动支持!\n 请肾重选择NVME固态硬盘上的系统分区", 'yes-no')
check(a)

