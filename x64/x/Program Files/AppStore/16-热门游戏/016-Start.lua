info.id = "start"
info.name = "START云游戏"
info.icon = "start.png"
info.desc = "START云游戏，多端畅享!电视直接玩游戏，一步到位"
info.star = "商店应用(解析)"
info.appmode = "StoreApp_analysis_url"
info.nbapp = "start"
info.download_page = "https://start.qq.com"
info.direct_url = [[https://[^\"]*/win.client/installer/[^\"]*]]
info.app_runpath = "%USERPROFILE%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\腾讯游戏\\START\\START.lnk"
info.app_setup_args = "/S"
info.app_setup = "startsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]