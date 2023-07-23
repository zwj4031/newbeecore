
function petoolspath(panfupath)
  if panfupath == "" then
   winapi.show_message("petools", "取消")
  else
   exec('/show /wait', [[cmd /c xcopy /s /e /y wxsUI\\UI_AppStore\soft\petools ]] .. panfupath .. [[\petools\]])
   winapi.show_message("导出petools示例", [[petools文件已导出到]] .. panfupath .. [[petools，请按视频教程修改来使用!!]])
  end  
end

function check(a) 
if a == "yes" then
--winapi.show_message('警告', a)
   local panfupath = Dialog:BrowseFolder('导出petools示例', 17)
   petoolspath(panfupath)
else
return
end
end



a=winapi.show_message('提示', "你将导出petools示例到根目录 \n PE每次启动后将会执行petools目录下petools.ini中的语句! \n 请注意修改!", 'yes-no')
check(a)