info.id = "petools"
info.name = "导出petools示例"
info.icon = "cong.png"
info.desc = "导出petools示例到根目录，方便PE开机后自动固定ip，自动架设网启服务器，自动还原系统镜像，自动叫……"
info.star = "内置应用"
info.appmode = "runapp"
info.nbapp = "petools"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[winxshell -script wxsui\ui_appstore\nbtool_petools.lua]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]