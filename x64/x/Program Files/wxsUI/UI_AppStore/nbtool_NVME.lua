
function ennvme(syspath)
  if syspath == "" then
   winapi.show_message("NVME���ùر�", "ȡ��")
  else
   exec('/hide /wait', 'reg load hklm\\offline_system ' .. syspath .. '\\Windows\\system32\\Config\\SYSTEM')
   exec('/hide /wait', 'reg delete hklm\\offline_system\\ControlSet001\\Services\\stornvme\\StartOverride /F')
   exec('/wait', 'reg unload hklm\\offline_system')
   winapi.show_message("NVME����֧�ֿ���", [[����ϵͳ���ڷ���]] .. syspath .. [[������NVME����֧��!�����������!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('����', a)
   local syspath = Dialog:BrowseFolder('����NVME����֧��', 17)
   ennvme(syspath)
else
return
end
end



a=winapi.show_message('����', "�㽫ΪĿ��ϵͳ����NVME����֧��!\n ������ѡ��NVME��̬Ӳ���ϵ�ϵͳ����", 'yes-no')
check(a)

