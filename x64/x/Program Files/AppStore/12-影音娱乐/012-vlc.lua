info.id = "vlc"
info.name = "vlc播放器"
info.icon = "vlc播放器.png"
info.desc = "I'm QQ，每一天 乐 - 在 - 沟 - 通"
info.star = "商店应用(解析)"
info.download_page = "https://www.videolan.org/"
info.direct_url = [[get.videolan.org/[^\"]*/win64/[^\"]*win64.exe]]
info.direct_url_prefix = [[https://]]
info.appmode = "StoreApp_analysis_url"
info.nbapp = "vlc"
info.app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\VideoLAN\\VLC media player.lnk"
info.app_setup_args = "/S"
info.app_setup = "vlcsetup.exe"
info.user_agent = [[--user-agent="Chrome/94.0.4606.71"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]