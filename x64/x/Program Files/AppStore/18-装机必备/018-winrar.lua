info.id = "winrarx64"
info.name = "WinRAR压缩x64"
info.icon = "winrar压缩.png"
info.desc = "winrar压缩 使用最广泛的压缩软件"
info.star = "商店应用(解析)"
info.download_page = "https://www.win-rar.com/postdownload.html?&L=7"
info.direct_url = [[fileadmin/[^\"]*/winrar/[^\"]*]]
info.direct_url_prefix = [[https://www.win-rar.com/]]
info.appmode = "StoreApp_analysis_url"
info.nbapp = "winrar"
info.app_runpath = "%USERPROFILE%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\WinRAR\\WinRAR.lnk"
info.app_setup_args = "/S"
info.app_setup = "WinRAR压缩x64.exe"
info.user_agent = [[--user-agent="Chrome/94.0.4606.71"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]