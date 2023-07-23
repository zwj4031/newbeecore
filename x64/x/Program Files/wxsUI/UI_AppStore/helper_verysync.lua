RUNVERY_TIMER_ID = 11111

USERPROFILE = os.getenv("USERPROFILE")
temp = os.getenv("temp")
cd = os.getenv("cd")
SystemDrive = os.getenv("SystemDrive")
if File.exists("X:\\ipxefm\\ipxeboot.txt") then
  very_runmode = "pe"
  zexe = [[X:\\Program Files\\7-zip\\7z.exe]]
else
  very_runmode = "system"
  zexe = "%temp%\\AppStore\\bin\\7zx64.exe"
end

function dl_verysync()
  if not File.exists(temp .. [[\very.zip]]) then
  
    -- winapi.show_message("添加传输目录",  "不存在")
    exec(
      "/wait",
      [[cmd /c start /w "下载微力中……" aria2c -c --user-agent="Chrome/94.0.4606.71" http://www.verysync.com/download.php?platform=windows-amd64 -d %temp% -o very.zip]]
    )
  end
  exec("/wait", zexe .. [[ -y x %temp%\very.zip -o%temp%\verysync]])
  local exitcode, veryappdir = winapi.execute([[dir /b %temp%\verysync]])
  veryappdir = string.gsub(veryappdir, "\r\n", "")
  verysync = string.format("%s\\verysync\\%s\\verysync.exe", temp, veryappdir)
  verylog = string.format("%s\\AppData\\Local\\Verysync\\verysync.log", USERPROFILE)
  veryhome = string.format("%s\\verysync\\%s\\verysync", temp, veryappdir)
  if very_runmode == "pe" then
  verylog = "X:\\Program Files\\Verysync\\verysync.log"
   verypath = string.format("%s\\verysync\\%s", temp, veryappdir)
   	verypedata = "X:\\Program Files\\Verysync"
    exec("/wait /show", [[cmd /c md "X:\\Program Files\\Verysync"]])
   exec("/wait /show", [[cmd /c mklink /d ]] .. veryhome .. [[ ]] .. [["]] .. verypedata .. [["]])
   --alert(verypath)
	--verylog = string.format("%s\\verysync\\%s\\data\\verysync.log", temp, veryappdir)
	--verylog = string.format("%s\\verydata\\verysync.log", temp, veryappdir)


	
  else
    verylog = string.format("%s\\AppData\\Local\\Verysync\\verysync.log", USERPROFILE)
  end
os.putenv("path", verypath)
  exec("/wait /hide", [[cmd /c del /q /f ]] .. verylog)
  exec("/hide", "cmd /c verysync")
  App:SetTimer('微力检测', 8000)
  alert("初始化微力中……")
  --App:Sleep(5088)
  end

function check_ready()

  if File.exists(verylog) then
    local veryfile = io.open(verylog, "r")
    local text = veryfile:read("*a")
    veryok = text:match("My name is")
    veryfile:close()
  end
  
  App:Sleep(5088)
  if veryok ~= nil then
     App:KillTimer('微力检测')
    local sendpath = Dialog:BrowseFolder("微力同步初始化完毕，请选择要需要传输的目录", 17)
 exec("/show /wait", [[cmd /c verysync folder add ]] .. sendpath)
 exec("/show", [[cmd /k verysync folder list]])

	share_pass = string.gsub(share_pass, "\r\n", "")
	 alert(share_pass)
    veryro = share_pass:match("RO:([^\n]+)\n")
    veryrw = share_pass:match("RW:([^\n]+)\n")

    winapi.show_message("微力密钥", "共享目录为:" .. sendpath .. "\n只读密钥" .. veryro .. "\n读写密钥" .. veryrw)
  end
end

function get_share()
  if File.exists(verylog) then
    local veryfile = io.open(verylog, "r")
    local text = veryfile:read("*a")
    veryro = text:match("RO:([^\n]+)\n")
    veryrw = text:match("RW:([^\n]+)\n")
    veryfile:close()
    winapi.show_message("微力只读密钥", veryro)
    winapi.show_message("添加传输目录", "目录   " .. sendpath .. "   已经共享")
  end
end




AppTimer['微力检测'] = function(tid)
check_ready()
 
end


dl_verysync()
