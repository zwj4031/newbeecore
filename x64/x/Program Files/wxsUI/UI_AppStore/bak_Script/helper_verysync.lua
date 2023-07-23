RUNVERY_TIMER_ID = 11111

USERPROFILE = os.getenv("USERPROFILE")
temp = os.getenv("temp")
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
      [[aria2c -c --user-agent="Chrome/94.0.4606.71" http://www.verysync.com/download.php?platform=windows-amd64 -d %temp% -o very.zip]]
    )
  end
  exec("/wait", zexe .. [[ -y x %temp%\very.zip -o%temp%\verysync]])
  local exitcode, veryappdir = winapi.execute([[dir /b %temp%\verysync]])
  veryappdir = string.gsub(veryappdir, "\r\n", "")
  verysync = string.format("%s\\verysync\\%s\\verysync.exe", temp, veryappdir)
  -- verydata = string.format("%s\\verysync\\%s\\data", temp, veryappdir)
  verylog = string.format("%s\\AppData\\Local\\Verysync\\verysync.log", USERPROFILE)
  if very_runmode == "pe" then
    verylog = "X:\\Program Files\\Verysync\\verysync.log"
  else
    verylog = string.format("%s\\AppData\\Local\\Verysync\\verysync.log", USERPROFILE)
  end
  exec("/hide", [[cmd /c del /q /f ]] .. verylog)
  suilib.call("SetTimer", RUNVERY_TIMER_ID, 8000)
  exec("/show", "cmd /c " .. verysync)
end

function check_ready()
  if File.exists(verylog) then
    local veryfile = io.open(verylog, "r")
    local text = veryfile:read("*a")
    veryok = text:match("My name is")
    veryfile:close()
  end
  if veryok ~= nil then
    suilib.call("KillTimer", 11111)
    local sendpath = Dialog:BrowseFolder("微力同步初始化完毕，请选择要需要传输的目录", 17)
    local exitcode, share_pass = winapi.execute([[cmd /c ]] .. verysync .. [[ folder add ]] .. sendpath)
    share_pass = string.gsub(share_pass, "\r\n", "")
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

function ontimer(tid)
  if tid == RUNVERY_TIMER_ID then
    check_ready()
  end
end

dl_verysync()
