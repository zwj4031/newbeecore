info.id = "cleanmaster"
info.name = "系统清理"
info.icon = "cleanmaster.png"
info.desc = "清理谷歌浏览器、其它软件的缓存和上网痕迹"
info.star = "内置应用"
info.appmode = "runapp"
info.adminmode = "1"
info.nbapp = "notepadtxt"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[wxsui\ui_appstore\soft\cleanmaster.exe]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]