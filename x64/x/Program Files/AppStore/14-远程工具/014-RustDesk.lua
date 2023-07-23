info.id = "RustDesk"
info.name = "RustDesk"
info.icon = "RustDesk.png"
info.desc = "RustDesk远程"
info.star = "商店应用(解析)"
info.appmode = "StoreApp_analysis_url"
info.nbapp = "RustDesk"
info.download_page = "http://RustDesk.com/zh/"
info.direct_url = [[http:*[^\"]*[^\"]*/download/*[^\"]*x64.zip]]
info.app_runpath = "temp"
info.app_setup_args = ""
info.app_setup = "RustDesk.7z"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]