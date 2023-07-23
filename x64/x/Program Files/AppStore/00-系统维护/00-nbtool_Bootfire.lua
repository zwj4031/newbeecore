info.id = "nbtool_bootfire"
info.name = "UEFI序列_BCD编辑"
info.icon = "nbtool_bootfire.png"
info.desc = "调整UEFI序列，选中序列中网启PXE项或BCD菜单项可立即启动(一次性启动)"
info.star = "内置应用"
info.appmode = "runapp"
info.adminmode = "1"
info.nbapp = "bootfire"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[winxshell -ui -jcfg wxsui\ui_appstore\nbtool_bootfire.jcfg]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]
