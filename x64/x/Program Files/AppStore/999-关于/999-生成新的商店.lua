info.id = "buildappstore"
info.name = "�������̵�"
info.icon = "build.png"
info.desc = "����ӵ���������Ʋ�Ȩ�����̵�"
info.star = "ϵͳӦ��"
info.appmode = "runapp"
info.nbapp = "update"
info.download_page = "https://im.qq.com/pcqq"
info.direct_url = [[https://[^\"]*/qqfile/qq/[^\"]*]]
info.app_runpath = [[buildAppStore.bat]]
info.app_setup_args = "/S"
info.app_setup = "qqsetup.exe"
info.user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
info.aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]