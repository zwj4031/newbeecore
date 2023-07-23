info.id = "centbrowser"
info.name = "百分浏览器"
info.icon = "centbrowser.png"
info.desc = "追求速度、简约和安全的网络浏览器"
info.star = "商店应用(解析)"
info.appmode = "StoreApp_analysis_url"
info.nbapp = "centbrowser"
info.download_page = "https://www.centbrowser.cn/"
info.direct_url = [[https://[^\"]*/win_stable/[^\"]*/[^\"]*x64.exe]]
info.app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\Cent Browser.lnk"
info.app_setup_args = "--cb-auto-update"
info.app_setup = "百分浏览器.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]