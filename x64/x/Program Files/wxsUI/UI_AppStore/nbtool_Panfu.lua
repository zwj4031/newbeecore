
function ennvme(syspath)
  if syspath == "" then
   winapi.show_message("����ϵͳ�̷�����", "ȡ��")
  else
   exec('/hide /wait', 'reg load hklm\\offline_system ' .. syspath .. '\\Windows\\system32\\Config\\SYSTEM')
   exec('/hide /wait', 'reg delete hklm\\offline_system\\MountedDevices /va /F')
   exec('/wait', 'reg unload hklm\\offline_system')
   winapi.show_message("����ϵͳ�̷�����", [[����ϵͳ���ڷ���]] .. syspath .. "\n" .. [[�������̷�!�����������!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('����', a)
   local syspath = Dialog:BrowseFolder('����ϵͳ�̷�����', 17)
   ennvme(syspath)
else
return
end
end



a=winapi.show_message('����', "�㽫ΪĿ��ϵͳϵͳ�̷�����!��ɾ��MountedDevices \n ������ѡ��ϵͳ����", 'yes-no')
check(a)

