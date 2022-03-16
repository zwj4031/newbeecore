temp = os.getenv("temp")
--------------------------------------------------------------download_url
vlcurl = "https://get.videolan.org/vlc/3.0.16/win64/vlc-3.0.16-win64.exe"
qqurl = "https://dldir1.qq.com/qqfile/qq/PCQQ9.5.6/QQ9.5.6.28129.exe"
wechaturl = "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe"
todeskurl = "https://dl.todesk.com/windows/ToDesk_Setup.exe"
todeskliteurl = "https://dl.todesk.com/windows/ToDesk_Lite.exe"
orayurl = "https://api.hanximeng.com/lanzou/?url=https://wwi.lanzouo.com/ihLjvygoxgd&type=down"
oraynewurl = "https://sunlogin.oray.com/zh_CN/download/download?id=65&x64=1"
dbadminurl = "http://down.slser.com/down.php"
Alpemixurl = "https://www.alpemix.com/site/Alpemix.exe"
wps2016url = "https://wdl1.cache.wps.cn/wps/download/W.P.S.7400.12012.0.exe"
potplayerurl = "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup.exe"
vm16url = "https://pan.bilnn.cn/api/v3/file/sourcejump/LWrx2LcM/pIf0htSTViFq5ePgkvFQl-DOKJqF1AVg82xmkGIIoqM*"
-------------------------------------------------------------aria2c_args
aria2c_args = [[-c -s 2 -x 2 -j 10 --file-allocation=none]]
qq_user_agent = [[--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"]]
chrome_user_agent = [[--user-agent="Chrome/94.0.4606.71"]]
--------------------------------------------------------------------------



function check_option()
if user_agent ~= nil then 
user_agent = app_user_agent
end
--winapi.show_message("当前软件下载地址：", "没得到详细参数")
if app_setup_args == nil then 
app_setup_args = "/S"
end
if app_runpath == nil then
app_runpath = "temp"
end
if app_setup == nil then
app_setup = "setup.exe"
end
if user_agent == nil then 
user_agent = [[--user-agent="Chrome/94.0.4606.71 Safari/537.36"]]
end
if aria2c_args == nil then
aria2c_args = "-c -j 10 --file-allocation=none"
end
if app_setup == nil then
app_setup = "setup.exe"
end
end

function check_nbapp()
if nbapp == "qq" then
--qq_appenv()
qqnew_appenv()
elseif nbapp == "dbadmin" then
dbadmin_appenv()
elseif nbapp == "Alpemix" then
Alpemix_appenv()
elseif nbapp == "wechat" then
wechat_appenv()
elseif nbapp == "vlc" then
vlc_appenv()
elseif nbapp == "wps2016" then
wps_appenv()
elseif nbapp == "potplayer" then
potplayer_appenv()
elseif nbapp == "kodi" then
kodi_appenv()
elseif nbapp == "qqnew" then
qqnew_appenv()
elseif nbapp == "vm16" then
vm_appenv()
elseif nbapp == "todesk" or nbapp == "todesklite" then
todesk_appenv()
elseif nbapp == "oray" or nbapp == "oraynew" then
oray_appenv()
elseif nbapp == nil then
default_appenv()
else
suilib.call("KillTimer", 10088)	
suilib.call("KillTimer", 10089)	
--label_info = sui:find("label_info")
--label_info.text = "FBI Warning: 狠抱倩，内置列表中没有你需要的" .. nbapp .
winapi.show_message("FBI Warning:白嫖失败!", "肥肠抱倩，内置列表里没有你需要的" .. nbapp ..
 "软件！\n 你可以联系史上最伟大网管在云上添加" .. nbapp .. "软件")
sui:close()
end
end

function default_appenv()
user_agent = qq_user_agent
app_url = qqurl
app_name = "腾讯QQ"
app_setup = "qqsetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\腾讯软件\\QQ\\腾讯QQ.lnk"
--local app_runpath = "%ProgramFiles(x86)%\\Tencent\\QQ\\Bin\\QQScLauncher.exe"
app_setup_args = "/S"
end

function kodi_appenv()
user_agent = qq_user_agent
exec( "/wait /hide", [[cmd /c aria2c --user-agent="Chrome/94.0.4606.71" --allow-overwrite=true https://kodi.tv/download/windows -d %temp% -o kodi.dl]] )
local path = temp .. "\\kodi.dl"
file = io.open(path, "r")
html = file:read("*a")
file:close()
app_url = html:match("https://[^\"]*/releases/windows/win64/kodi[^\"]*")
app_name = "Kodi"
app_setup = "kodisetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\Kodi\\Kodi.lnk"
app_setup_args = "/S"
end

function qqnew_appenv()
user_agent = qq_user_agent
exec( "/wait /hide", [[cmd /c aria2c --user-agent="Chrome/94.0.4606.71" --allow-overwrite=true https://im.qq.com/pcqq -d %temp% -o qq.dl]] )
local path = temp .. "\\qq.dl"
file = io.open(path, "r")
html = file:read("*a")
file:close()
app_url = html:match("https://[^\"]*/qqfile/qq/[^\"]*")
app_name = "腾讯QQ"
app_setup = "qqsetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\腾讯软件\\QQ\\腾讯QQ.lnk"
app_setup_args = "/S"
end

function vm_appenv()
exec( "/hide", [[cmd /c ftype .vmx="%ProgramFiles%\vmware\vmware.exe" %1]] )
user_agent = qq_user_agent
app_url = vm16url
app_name = "vmware"
app_setup = "vmware.exe"
app_runpath = "temp"
app_setup_args = ""
end


function wps_appenv()
--exec( "/hide", [[cmd /c ftype .doc="%USERPROFILE%\AppData\Local\kingsoft\WPS Office\ksolaunch.exe" /wps /w "%1"]] )
--exec( "/hide", [[cmd /c ftype .docx="%USERPROFILE%\AppData\Local\kingsoft\WPS Office\ksolaunch.exe" /wps /w "%1"]] )
--exec( "/hide", [[cmd /c ftype .xls="%USERPROFILE%\AppData\Local\kingsoft\WPS Office\ksolaunch.exe" /wps /et "%1"]] )
--exec( "/hide", [[cmd /c ftype .xlsx="%USERPROFILE%\AppData\Local\kingsoft\WPS Office\ksolaunch.exe" /wps /et "%1"]] )
user_agent = qq_user_agent
app_url = wps2016url
app_name = "wps"
app_setup = "wpssetup.exe"
app_runpath = "%USERPROFILE%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\WPS Office\\产品更新信息.lnk"
app_setup_args = "/S"
end

function potplayer_appenv()
user_agent = qq_user_agent
app_url = potplayerurl
app_name = "potplayer"
app_setup = "potplayersetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\Potplayer\\PotPlayer.lnk"
app_setup_args = "/S"
end

function qq_appenv()
user_agent = qq_user_agent
app_url = qqurl
app_name = "腾讯QQ"
app_setup = "qqsetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\腾讯软件\\QQ\\腾讯QQ.lnk"
app_setup_args = "/S"
end

function wechat_appenv()
user_agent = qq_user_agent
app_url = wechaturl
app_name = "微信"
app_setup = "wechatsetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\微信\\微信.LNK"
app_setup_args = "/S"
end


function dbadmin_appenv()
user_agent = chrome_user_agent
app_url = dbadminurl
app_name = "深蓝远程"
app_setup = "dbadmin.7z"
app_runpath = "temp"
app_setup_args = ""
end

function Alpemix_appenv()
user_agent = chrome_user_agent
app_url = Alpemixurl
app_name = "Alpemix远程"
app_setup = "Alpemix.exe"
app_runpath = "temp"
app_setup_args = ""
end

function vlc_appenv()
user_agent = chrome_user_agent
app_url = vlcurl
app_name = "vlc播放器"
app_setup = "vlcsetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\VideoLAN\\VLC media player.lnk"
app_setup_args = "/S"
end

function todesk_appenv()
if nbapp == "todesk" then 
user_agent = chrome_user_agent
app_url = todeskurl
app_name = "todesk"
app_setup = "todesksetup.exe"
app_runpath = "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\ToDesk\\ToDesk.lnk"
app_setup_args = "/S"
elseif nbapp == "todesklite" then 
user_agent = chrome_user_agent
app_url = todeskliteurl
app_name = "todesk"
app_setup = "todesklite.exe"
app_runpath = "temp"
app_setup_args = ""
end
end

function oray_appenv()
if nbapp == "oray" then 
user_agent = chrome_user_agent
app_url = orayurl
app_name = "向日葵"
app_setup = "向日葵.exe"
app_setup_args = "--mod=green --admin=1"
app_runpath = "temp"
elseif nbapp == "oraynew" then 
user_agent = chrome_user_agent
app_url = oraynewurl
app_name = "向日葵"
app_setup = "向日葵.exe"
app_runpath = "temp"
app_setup_args = "/S"
end
end
