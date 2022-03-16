--LINK([[%StartMenu%\扇区小工具BOOTICE.lnk]],[[%ProgramFiles%\OTHERS\BOOTICE.EXE]])
--LINK([[%StartMenu%\文件快搜.lnk]],[[%ProgramFiles%\EVERYTHING\EVERYTHING.EXE]])
--LINK([[%StartMenu%\分区工具DiskGenius.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])

--app_url = "https://down.qq.com/qqweb/PCQQ/PCQQ_EXE/PCQQ2021.exe"
app_url = "https://get.videolan.org/vlc/3.0.16/win64/vlc-3.0.16-win64.exe"
app_name = "VLC播放器"
user_agent = [[--user-agent="Chrome/94.0.4606.71 Safari/537.36"]]
aria2c_args = "-c -j 10"
app_setup_args = "/S"

exec('/show',[[X:\\Program Files\\WinXShell.exe -ui -console -jcfg wxsUI\\UI_DL\\main.jcfg -app_url ]] .. app_url ..
[[ -app_name ]] .. app_name .. [[ -user_agent "]] .. user_agent .. [[" -aria2c_args ]] .. 
aria2c_args .. [[ -app_setup_args ]] .. app_setup_args)

