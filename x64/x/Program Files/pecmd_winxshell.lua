local desk = [[X:\Users\Default\DeskTop\]]
local root = [[X:\Windows\System32\]]
local remote = [[%ProgramFiles%\Remote Control Tool\]]
local startmenu = [[X:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\]]
exec('/wait','X:\\ipxefm\\app\\inject\\default\\sysx64.exe')
--startnet.bat����Ǩ��
LINK(desk .. [[iSCSI �������.lnk]], root .. [[iscsicpl.exe]], nil, root .. [[ico\iscsicli.ico]])
LINK(desk .. [[iSCSI �����.lnk]], [[%ProgramFiles%\Others\iscsiconsole.exe]])
LINK(desk .. [[PE �������.lnk]], [[%ProgramFiles%\PENetwork\PENetwork.exe]])
LINK(desk .. [[SkyIAR ����ע��.lnk]] , [[%ProgramFiles%\Others\skyiar.exe]])
LINK(desk .. [[SoftMgr �������.lnk]], [[%ProgramFiles%\SoftMgr\QQPCSoftMgr.exe]])
LINK(desk .. [[IFW ���ݻ�ԭ.lnk]], root .. [[imagew64.exe]])
LINK(desk .. [[BatchTools ��ɫС����.lnk]], [[%ProgramFiles%\BatchTools]], nil,  root .. [[ico\batch.ico]])
LINK(desk .. [[Microsoft Edge.lnk]], [[%ProgramFiles%\edge\edge.bat]], nil, [[%ProgramFiles%\edge\edge.ico]])
LINK(desk .. [[Google Chrome.lnk]], [[%ProgramFiles%\google\Chrome.bat]], nil, [[%ProgramFiles%\google\Chrome.ico]])
LINK(desk .. [[��ѶQQ.lnk]], [[%ProgramFiles%\qq\qq.bat]], nil, [[%ProgramFiles%\QQ\QQ.ico]])
LINK(desk .. [[΢��.lnk]], [[%ProgramFiles%\Wechat\Wechat.bat]], nil, [[%ProgramFiles%\Wechat\WeChat.ico]])
LINK(desk .. [[Ӧ���̵�AppStore.lnk]], [[%ProgramFiles%\wxsUI\UI_AppStore\nbappstore.lua]], nil, [[%ProgramFiles%\wxsUI\UI_AppStore\appstore.ico]])

LINK(desk .. [[Զ�̹���.lnk]], [[%ProgramFiles%\Remote Control Tool]], nil, root .. [[ico\remote.ico]])
LINK(remote .. [[mstscԶ��_console.lnk]], [[%WinDir%\mstsc.exe]], [[/console]], [[%WinDir%\mstsc.exe]])
LINK(remote .. [[mstscԶ��.lnk]], [[%WinDir%\mstsc.exe]])
LINK(remote .. [[���տ��°�.lnk]], [[%ProgramFiles%\oray\oray.bat]], nil, [[%ProgramFiles%\oray\oray.ico]])
LINK(remote .. [[���տ����ض�.lnk]], [[%ProgramFiles%\oray\oray_lite.bat]], nil, [[%ProgramFiles%\oray\oray.ico]])
LINK(remote .. [[����Զ��.lnk]], [[%ProgramFiles%\DBadmin\DBadmin.bat]], nil, [[%ProgramFiles%\DBadmin\DBadmin.ico]])
LINK(remote .. [[AlpemixԶ��.lnk]], [[%ProgramFiles%\Alpemix\Alpemix.bat]], nil, [[%ProgramFiles%\Alpemix\Alpemix.ico]])
LINK(remote .. [[ToDeskԶ�̱��ض�.lnk]], [[%ProgramFiles%\ToDesk\ToDeskLite.bat]], nil, [[%ProgramFiles%\ToDesk\ToDesk.ico]])
LINK(remote .. [[ToDeskԶ��������.lnk]], [[%ProgramFiles%\ToDesk\ToDesk.bat]], nil, [[%ProgramFiles%\ToDesk\ToDesk.ico]])
LINK(remote .. [[TightVNC-Զ�̿���.lnk]], [[%SystemDrive%\ipxefm\bin\tvnviewer.exe]])
--pecmd.ini����Ǩ��
--���������ݷ�ʽ
LINK(desk .. [[��������.lnk]],[[%ProgramFiles%\PAProCn\PAProCn.EXE]], nil, [[%ProgramFiles%\PAProCn\PAProCn.ico]])
LINK(desk .. [[WinSetup.lnk]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.exe]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.ico]])
LINK(desk .. [[CGI ��ԭ.lnk]],[[%ProgramFiles%\GhostCGI\CGI-plus_x64.exe]])
LINK(desk .. [[SnapShot ���ݻ�ԭ.lnk]],[[%ProgramFiles%\SnapShot\SnapShot64.exe]])
LINK(desk .. [[�����޸�.lnk]],[[%ProgramFiles%\NTpassword\password.EXE]], nil, [[%ProgramFiles%\NTpassword\password.ico]])
LINK(desk .. [[Dism++.lnk]],[[%ProgramFiles%\Dism++\Dism++x64.exe]])
LINK(desk .. [[���̷���.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])
LINK(desk .. [[�����.lnk]],[[%ProgramFiles%\opera\opera.exe]], nil, [[%ProgramFiles%\opera\opera.ico]])

--������ʼ�˵����г����ݷ�ʽ
LINK(startmenu .. [[PE  ����\PECMD.lnk]],[[%SystemRoot%\system32\PECMD.exe]])
LINK(startmenu .. [[PE  ����\���̿������(Ctrl+M).lnk]],[[%ProgramFiles%\OTHERS\mouse.exe]])
LINK(startmenu .. [[PE  ����\��ͼ����(Ctrl+Alt+A).lnk]],[[%SystemRoot%\system32\PECMD.exe]],[[LOAD "%ProgramFiles%\SnapShot\SnapShot.ini"]],[[%ProgramFiles%\SnapShot\SnapShot.exe]])
LINK(startmenu .. [[PE  ����\���������ڴ�.lnk]],[[%ProgramFiles%\OTHERS\SETPAGEFILE.EXE]])
LINK(startmenu .. [[PE  ����\��ʾ���д��̷���.lnk]],[[%ProgramFiles%\OTHERS\showdrive.exe]], nil, [[%SystemRoot%\system32\shell32.dll]], 7)
LINK(startmenu .. [[PE  ����\��Ļ����.lnk]],[[%ProgramFiles%\KeyBoard\KeyBoard.exe]])
LINK(startmenu .. [[PE  ����\ˢ��ϵͳ(Ctrl+K).lnk]],[[x:\windows\system32\pecmd.exe]],[[kill Explorer.exe]],[[%ProgramFiles%\Others\ˢ��ϵͳ.ico]])

LINK(startmenu .. [[��װά��\Windows�����޸�.lnk]],[[%ProgramFiles%\NTpassword\password.EXE]], nil, [[%ProgramFiles%\NTpassword\password.ico]])
LINK(startmenu .. [[��װά��\Windows��װ��.lnk]],[[%ProgramFiles%\WinNTSetup\WinNTSetup.exe]])

LINK(startmenu .. [[��������\UEFI�����޸�.lnk]],[[%ProgramFiles%\FixLegacyUefi\FixLegacyUefi.exe]])
LINK(startmenu .. [[��������\����С����BOOTICE.lnk]],[[%ProgramFiles%\OTHERS\BOOTICE.EXE]])

LINK(startmenu .. [[��������\��������DiskGenius.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])
LINK(startmenu .. [[��������\��������(����).lnk]],[[%ProgramFiles%\PAProCn\PAProCn.EXE]])
LINK(startmenu .. [[��������\ϵͳ�Դ����̹���.lnk]],[[%SystemRoot%\system32\diskmgmt.msc]])

LINK(startmenu .. [[���ݻ�ԭ\�ֶ�����Ghost(Ctrl+G).lnk]],[[%ProgramFiles%\GhostCGI\Ghost64.exe]])
LINK(startmenu .. [[���ݻ�ԭ\CGI���ݻ�ԭ.lnk]],[[%ProgramFiles%\GhostCGI\CGI-plus_x64.exe]])
LINK(startmenu .. [[���ݻ�ԭ\Ghost���ݻ�ԭ.lnk]],[[%ProgramFiles%\GhostCGI\EasyGhost.exe]])
LINK(startmenu .. [[���ݻ�ԭ\Ghostӳ�������.lnk]],[[%ProgramFiles%\GhostCGI\GHOSTEXP.EXE]])

LINK(startmenu .. [[���ݻ�ԭ\Dism++.lnk]],[[%ProgramFiles%\Dism++\Dism++x64.exe]])
LINK(startmenu .. [[���ݻ�ԭ\SnapShot ���ݻ�ԭ.lnk]],[[%ProgramFiles%\SnapShot\SnapShot64.exe]])

LINK(startmenu .. [[Ӳ�����\�����ڴ��⹤��.lnk]],[[%ProgramFiles%\MEMTEST\MEMTEST.EXE]])
LINK(startmenu .. [[Ӳ�����\HDTuneӲ�̼��.lnk]],[[%ProgramFiles%\HDTune\HDTunePro.exe]])
LINK(startmenu .. [[Ӳ�����\CPU����SuperPi.lnk]],[[%ProgramFiles%\OTHERS\super_pi_mod.exe]])
LINK(startmenu .. [[Ӳ�����\CPU-Z.lnk]],[[%ProgramFiles%\OTHERS\cpuz.exe]])
LINK(startmenu .. [[Ӳ�����\AIDA64Ӳ�����.lnk]],[[%ProgramFiles%\OTHERS\AIDA64.exe]])

LINK(startmenu .. [[�ļ�����\FastCopy�ļ�����.lnk]],[[%ProgramFiles%\fastcopy\fastcopy.EXE]])
LINK(startmenu .. [[�ļ�����\HashУ����GHO����鿴.lnk]],[[%ProgramFiles%\OTHERS\GoHash.EXE]])
LINK(startmenu .. [[�ļ�����\7-ZIPѹ����ѹ.lnk]],[[%ProgramFiles%\7-ZIP\7zFM.exe]])
LINK(startmenu .. [[�ļ�����\Imagine��ͼ����.lnk]],[[%ProgramFiles%\Imagine\Imagine64.exe]])
LINK(startmenu .. [[�ļ�����\WinHex���ݻָ���༭.lnk]],[[%ProgramFiles%\winhex\winhex.EXE]])
LINK(startmenu .. [[�ļ�����\�ļ�����.lnk]],[[%ProgramFiles%\EVERYTHING\EVERYTHING.EXE]])

LINK(startmenu .. [[��������\���±�.lnk]],[[%SystemRoot%\system32\notepad.exe]])
LINK(startmenu .. [[��������\������.lnk]],[[%SystemRoot%\system32\calc.exe]])
LINK(startmenu .. [[��������\������ʾ��.lnk]],[[%SystemRoot%\system32\cmd.exe]])
LINK(startmenu .. [[��������\ע���༭��.lnk]],[[%SystemRoot%\regedit.exe]])
LINK(startmenu .. [[��������\���������.lnk]],[[%SystemRoot%\System32\taskmgr.exe]])

LINK(startmenu .. [[������\���������.lnk]],[[%SystemRoot%\system32\compmgmt.msc]])
LINK(startmenu .. [[������\�豸����.lnk]],[[%SystemRoot%\system32\devmgmt.msc]])
LINK(startmenu .. [[������\���̹���.lnk]],[[%SystemRoot%\system32\diskmgmt.msc]])
LINK(startmenu .. [[������\�������.lnk]],[[%SystemRoot%\system32\control.exe]])
--exec('X:\\windows\\explorer.exe')
exec('X:\\Program Files\\WinXShell.exe -winpe')
exec('/wait /hide','X:\\Program Files\\hotplug\\hotplug.bat')
exec('X:\\Program Files\\hotplug\\HotSwap!.EXE')
exec('/hide','X:\\Program Files\\7-zip\\7z.cmd')
exec('/hide','startnet.cmd')
--�����̶�
Volume:SetLevel(30)
-- loader keeper
exec('/wait /hide', 'cmd.exe /k echo alive')