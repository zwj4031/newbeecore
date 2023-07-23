info.id = "cmd"
info.name = "CMD命令行"
info.icon = app.call('varstr', [[%SystemDrive%\windows\system32\cmd.exe,F]])
info.desc = "cmd"
info.star = "本地应用"
info.appmode = "runapp"
info.nbapp = "cmd"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[%SystemDrive%\windows\system32\cmd.exe]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]