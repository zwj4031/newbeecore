
function petoolspath(panfupath)
  if panfupath == "" then
   winapi.show_message("petools", "ȡ��")
  else
   exec('/show /wait', [[cmd /c xcopy /s /e /y wxsUI\\UI_AppStore\soft\petools ]] .. panfupath .. [[\petools\]])
   winapi.show_message("����petoolsʾ��", [[petools�ļ��ѵ�����]] .. panfupath .. [[petools���밴��Ƶ�̳��޸���ʹ��!!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('����', a)
   local panfupath = Dialog:BrowseFolder('����petoolsʾ��', 17)
   petoolspath(panfupath)
else
return
end
end



a=winapi.show_message('��ʾ', "�㽫����petoolsʾ������Ŀ¼ \n PEÿ�������󽫻�ִ��petoolsĿ¼��petools.ini�е����! \n ��ע���޸�!", 'yes-no')
check(a)