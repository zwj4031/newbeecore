local SystemRoot = os.getenv("SystemRoot")

local letters = winapi.get_logical_drives()
drv = {}

  for i, l in ipairs(letters) do
  
	if File.exists(l .. [[windows\system32\winlogon.exe]]) and not File.exists(l .. [[Windows\System32\drivers\fbwf.sys]]) then
	 exec("/wait /show",
            [[mkdir ]] .. l .. [[client]])
	 exec("/wait /show",
            [[cmd /c xcopy X:\petools\Client\*.* /s /e /y ]] .. l .. [[client\.]])
  exec('/hide /wait', 'reg load hklm\\offline_system ' .. l .. '\\Windows\\system32\\Config\\software')
 exec('/hide /wait', 'reg add "HKLM\\offline_system\\Microsoft\\Windows\\CurrentVersion\\Run" /f /v "SEBarClt" /t REG_SZ /d "C:\\Client\\SEBarClt.exe"')
 exec('/wait', 'reg unload hklm\\offline_system')		
 alert("注入客户端到".. l .. "完成")	
end
end
