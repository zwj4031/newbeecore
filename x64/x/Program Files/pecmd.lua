--LINK([[%StartMenu%\����С����BOOTICE.lnk]],[[%ProgramFiles%\OTHERS\BOOTICE.EXE]])
--LINK([[%StartMenu%\�ļ�����.lnk]],[[%ProgramFiles%\EVERYTHING\EVERYTHING.EXE]])
--LINK([[%StartMenu%\��������DiskGenius.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])
exec('X:\\Program Files\\WinXShell.exe -winpe')
exec('/wait /hide','X:\\Program Files\\hotplug\\hotplug.bat')
exec('X:\\Program Files\\hotplug\\HotSwap!.EXE')
exec('/min','startnet.cmd')
-- loader keeper
exec('/wait /hide', 'cmd.exe /k echo alive')