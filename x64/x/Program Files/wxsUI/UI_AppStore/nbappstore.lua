--LINK([[%StartMenu%\扇区小工具BOOTICE.lnk]],[[%ProgramFiles%\OTHERS\BOOTICE.EXE]])
--LINK([[%StartMenu%\文件快搜.lnk]],[[%ProgramFiles%\EVERYTHING\EVERYTHING.EXE]])
--LINK([[%StartMenu%\分区工具DiskGenius.lnk]],[[%ProgramFiles%\DiskGenius\DiskGenius.exe]])

exec('/hide /wait','X:\\Program Files\\wxsUI\\UI_AppStore\\AppStoreUP.bat')

exec('/show','X:\\Program Files\\WinXShell.exe -ui -jcfg wxsUI\\UI_AppStore\\main.jcfg')
