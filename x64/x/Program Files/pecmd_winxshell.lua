local desk = [[X:\Users\Default\DeskTop\]]
local root = [[X:\Windows\System32\]]
local remote = [[%ProgramFiles%\Remote Control Tool\]]
local startmenu = [[X:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\]]
exec('/wait','X:\\ipxefm\\app\\inject\\default\\sysx64.exe')
--startnet.bat部份迁移
LINK(desk .. [[iSCSI 发起程序.lnk]], root .. [[iscsicpl.exe]], nil, root .. [[ico\iscsicli.ico]])
LINK(desk .. [[iSCSI 服务端.lnk]], [[%ProgramFiles%\Others\iscsiconsole.exe]])
LINK(desk .. [[PE 网络管理.lnk]], [[%ProgramFiles%\PENetwork\PENetwork.exe]])
LINK(desk .. [[SkyIAR 驱动注入.lnk]] , [[%ProgramFiles%\Others\skyiar.exe]])
LINK(desk .. [[SoftMgr 软件管理.lnk]], [[%ProgramFiles%\SoftMgr\QQPCSoftMgr.exe]])
LINK(desk .. [[IFW 备份还原.lnk]], root .. [[imagew64.exe]])
LINK(desk .. [[BatchTools 特色小工具.lnk]], [[%ProgramFiles%\BatchTools]], nil,  root .. [[ico\batch.ico]])
LINK(desk .. [[Microsoft Edge.lnk]], [[%ProgramFiles%\edge\edge.bat]], nil, [[%ProgramFiles%\edge\edge.ico]])
LINK(desk .. [[Google Chrome.lnk]], [[%ProgramFiles%\google\Chrome.bat]], nil, [[%ProgramFiles%\google\Chrome.ico]])
LINK(desk .. [[腾讯QQ.lnk]], [[%ProgramFiles%\qq\qq.bat]], nil, [[%ProgramFiles%\QQ\QQ.ico]])
LINK(desk .. [[微信.lnk]], [[%ProgramFiles%\Wechat\Wechat.bat]], nil, [[%ProgramFiles%\Wechat\WeChat.ico]])
LINK(desk .. [[应用商店AppStore.lnk]], [[%ProgramFiles%\wxsUI\UI_AppStore\nbappstore.lua]], nil, [[%ProgramFiles%\wxsUI\UI_AppStore\appstore.ico]])

LINK(desk .. [[远程工具.lnk]], [[%ProgramFiles%\Remote Control Tool]], nil, root .. [[ico\remote.ico]])
LINK(remote .. [[mstsc远程_console.lnk]], [[%WinDir%\mstsc.exe]], [[/console]], [[%WinDir%\mstsc.exe]])
LINK(remote .. [[mstsc远程.lnk]], [[%WinDir%\mstsc.exe]])
LINK(remote .. [[向日葵新版.lnk]], [[%ProgramFiles%\oray\oray.bat]], nil, [[%ProgramFiles%\oray\oray.ico]])
LINK(remote .. [[向日葵被控端.lnk]], [[%ProgramFiles%\oray\oray_lite.bat]], nil, [[%ProgramFiles%\oray\oray.ico]])
LINK(remote .. [[深蓝远程.lnk]], [[%ProgramFiles%\DBadmin\DBadmin.bat]], nil, [[%ProgramFiles%\DBadmin\DBadmin.ico]])
LINK(remote .. [[Alpemix远程.lnk]], [[%ProgramFiles%\Alpemix\Alpemix.bat]], nil, [[%ProgramFiles%\Alpemix\Alpemix.ico]])
LINK(remote .. [[ToDesk远程被控端.lnk]], [[%ProgramFiles%\ToDesk\ToDeskLite.bat]], nil, [[%ProgramFiles%\ToDesk\ToDesk.ico]])
LINK(remote .. [[ToDesk远程完整版.lnk]], [[%ProgramFiles%\ToDesk\ToDesk.bat]], nil, [[%ProgramFiles%\ToDesk\ToDesk.ico]])
LINK(remote .. [[TightVNC-远程控制.lnk]], [[%SystemDrive%\ipxefm\bin\tvnviewer.exe]])
--pecmd.ini部份迁移
--创建桌面快捷方式
LINK(desk .. [[分区助手.lnk]],[[%ProgramFiles%\PAProCn\PAProCn.EXE]], nil, [[%ProgramFiles%\PAProCn\PAProCn.ico]])
LINK(desk .. [[WinSetup.lnk]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.exe]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.ico]])
LINK(desk .. [[CGI 还原.lnk]],[[%ProgramFiles%\GhostCGI\CGI-plus_x64.exe]])
LINK(desk .. [[SnapShot 备份还原.lnk]],[[%ProgramFiles%\SnapShot\SnapShot64.exe]])
LINK(desk .. [[密码修改.lnk]],[[%ProgramFiles%\NTpassword\password.EXE]], nil, [[%ProgramFiles%\NTpassword\password.ico]])
LINK(desk .. [[Dism++.lnk]],[[%ProgramFiles%\Dism++\Dism++x64.exe]])
LINK(desk .. [[磁盘分区.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])
LINK(desk .. [[浏览器.lnk]],[[%ProgramFiles%\opera\opera.exe]], nil, [[%ProgramFiles%\opera\opera.ico]])

--创建开始菜单所有程序快捷方式
LINK(startmenu .. [[PE  工具\PECMD.lnk]],[[%SystemRoot%\system32\PECMD.exe]])
LINK(startmenu .. [[PE  工具\键盘控制鼠标(Ctrl+M).lnk]],[[%ProgramFiles%\OTHERS\mouse.exe]])
LINK(startmenu .. [[PE  工具\截图工具(Ctrl+Alt+A).lnk]],[[%SystemRoot%\system32\PECMD.exe]],[[LOAD "%ProgramFiles%\SnapShot\SnapShot.ini"]],[[%ProgramFiles%\SnapShot\SnapShot.exe]])
LINK(startmenu .. [[PE  工具\设置虚拟内存.lnk]],[[%ProgramFiles%\OTHERS\SETPAGEFILE.EXE]])
LINK(startmenu .. [[PE  工具\显示所有磁盘分区.lnk]],[[%ProgramFiles%\OTHERS\showdrive.exe]], nil, [[%SystemRoot%\system32\shell32.dll]], 7)
LINK(startmenu .. [[PE  工具\屏幕键盘.lnk]],[[%ProgramFiles%\KeyBoard\KeyBoard.exe]])
LINK(startmenu .. [[PE  工具\刷新系统(Ctrl+K).lnk]],[[x:\windows\system32\pecmd.exe]],[[kill Explorer.exe]],[[%ProgramFiles%\Others\刷新系统.ico]])

LINK(startmenu .. [[安装维护\Windows密码修改.lnk]],[[%ProgramFiles%\NTpassword\password.EXE]], nil, [[%ProgramFiles%\NTpassword\password.ico]])
LINK(startmenu .. [[安装维护\Windows安装器.lnk]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.exe]])

LINK(startmenu .. [[引导工具\UEFI引导修复.lnk]],[[%ProgramFiles%\FixLegacyUefi\FixLegacyUefi.exe]])
LINK(startmenu .. [[引导工具\扇区小工具BOOTICE.lnk]],[[%ProgramFiles%\OTHERS\BOOTICE.EXE]])

LINK(startmenu .. [[分区工具\分区工具DiskGenius.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])
LINK(startmenu .. [[分区工具\分区助手(无损).lnk]],[[%ProgramFiles%\PAProCn\PAProCn.EXE]])
LINK(startmenu .. [[分区工具\系统自带磁盘管理.lnk]],[[%SystemRoot%\system32\diskmgmt.msc]])

LINK(startmenu .. [[备份还原\手动运行Ghost(Ctrl+G).lnk]],[[%ProgramFiles%\GhostCGI\Ghost64.exe]])
LINK(startmenu .. [[备份还原\CGI备份还原.lnk]],[[%ProgramFiles%\GhostCGI\CGI-plus_x64.exe]])
LINK(startmenu .. [[备份还原\Ghost备份还原.lnk]],[[%ProgramFiles%\GhostCGI\EasyGhost.exe]])
LINK(startmenu .. [[备份还原\Ghost映像浏览器.lnk]],[[%ProgramFiles%\GhostCGI\GHOSTEXP.EXE]])

LINK(startmenu .. [[备份还原\Dism++.lnk]],[[%ProgramFiles%\Dism++\Dism++x64.exe]])
LINK(startmenu .. [[备份还原\SnapShot 备份还原.lnk]],[[%ProgramFiles%\SnapShot\SnapShot64.exe]])

LINK(startmenu .. [[硬件检测\物理内存检测工具.lnk]],[[%ProgramFiles%\MEMTEST\MEMTEST.EXE]])
LINK(startmenu .. [[硬件检测\HDTune硬盘检测.lnk]],[[%ProgramFiles%\HDTune\HDTunePro.exe]])
LINK(startmenu .. [[硬件检测\CPU测速SuperPi.lnk]],[[%ProgramFiles%\OTHERS\super_pi_mod.exe]])
LINK(startmenu .. [[硬件检测\CPU-Z.lnk]],[[%ProgramFiles%\OTHERS\cpuz.exe]])
LINK(startmenu .. [[硬件检测\AIDA64硬件检测.lnk]],[[%ProgramFiles%\OTHERS\AIDA64.exe]])

LINK(startmenu .. [[文件工具\FastCopy文件复制.lnk]],[[%ProgramFiles%\fastcopy\fastcopy.EXE]])
LINK(startmenu .. [[文件工具\Hash校验与GHO密码查看.lnk]],[[%ProgramFiles%\OTHERS\GoHash.EXE]])
LINK(startmenu .. [[文件工具\7-ZIP压缩解压.lnk]],[[%ProgramFiles%\7-ZIP\7zFM.exe]])
LINK(startmenu .. [[文件工具\Imagine看图工具.lnk]],[[%ProgramFiles%\Imagine\Imagine64.exe]])
LINK(startmenu .. [[文件工具\WinHex数据恢复与编辑.lnk]],[[%ProgramFiles%\winhex\winhex.EXE]])
LINK(startmenu .. [[文件工具\文件快搜.lnk]],[[%ProgramFiles%\EVERYTHING\EVERYTHING.EXE]])

LINK(startmenu .. [[附件工具\记事本.lnk]],[[%SystemRoot%\system32\notepad.exe]])
LINK(startmenu .. [[附件工具\计算器.lnk]],[[%SystemRoot%\system32\calc.exe]])
LINK(startmenu .. [[附件工具\命令提示符.lnk]],[[%SystemRoot%\system32\cmd.exe]])
LINK(startmenu .. [[附件工具\注册表编辑器.lnk]],[[%SystemRoot%\regedit.exe]])
LINK(startmenu .. [[附件工具\任务管理器.lnk]],[[%SystemRoot%\System32\taskmgr.exe]])

LINK(startmenu .. [[管理工具\计算机管理.lnk]],[[%SystemRoot%\system32\compmgmt.msc]])
LINK(startmenu .. [[管理工具\设备管理.lnk]],[[%SystemRoot%\system32\devmgmt.msc]])
LINK(startmenu .. [[管理工具\磁盘管理.lnk]],[[%SystemRoot%\system32\diskmgmt.msc]])
LINK(startmenu .. [[管理工具\控制面板.lnk]],[[%SystemRoot%\system32\control.exe]])
--exec('X:\\windows\\explorer.exe')
exec('X:\\Program Files\\WinXShell.exe -winpe')
exec('/wait /hide','X:\\Program Files\\hotplug\\hotplug.bat')
exec('X:\\Program Files\\hotplug\\HotSwap!.EXE')
exec('/hide','X:\\Program Files\\7-zip\\7z.cmd')
exec('/hide','startnet.cmd')
--音量固定
Volume:SetLevel(30)
-- loader keeper
exec('/wait /hide', 'cmd.exe /k echo alive')