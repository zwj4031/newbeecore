info.id = "nbtool_Panfu"
info.name = "系统盘符重置"
info.icon = "nbtool_ck.png"
info.desc = "使目标分区的系统盘符重置，即删除注册表项MountedDevices下的所有值"
info.star = "内置应用"
info.appmode = "runapp"
info.nbapp = "notepadtxt"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[winxshell -script wxsui\ui_appstore\nbtool_Panfu.lua]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]
info.pemode = "1"