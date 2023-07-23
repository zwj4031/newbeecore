info.id = "121"
info.name = "kodi"
info.icon = "kodi.png"
info.desc = "I'm Kodi，每一天 乐 - 在 - P - O -R -*"
info.star = "商店应用(解析)"
info.download_page = "https://kodi.tv/download/windows"
info.direct_url = [[https://[^\"]*/releases/windows/win64/kodi[^\"]*]]
info.appmode = "StoreApp_analysis_url"
info.nbapp = "kodi"
info.app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\Kodi\\Kodi.lnk"
info.app_setup_args = "/S"
info.app_setup = "kodisetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]