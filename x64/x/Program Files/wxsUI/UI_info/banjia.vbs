
on error resume next 
dim WSHshellA
set WSHshellA = wscript.createobject("wscript.shell")


SelectFolder 
function SelectFolder() 
Const MY_COMPUTER = &H11& 
Const WINDOW_HANDLE = 0 
Const OPTIONS = 0 
Set objShell = CreateObject("Shell.Application") 
Set objFolder = objShell.Namespace(MY_COMPUTER) 
Set objFolderItem = objFolder.Self 
strPath = objFolderItem.Path 
Set objShell = CreateObject("Shell.Application") 
Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, "你要把[用户目录]移到何处？[适合小内存机器使用QQ微信等工具]", OPTIONS, strPath) 
If objFolder Is Nothing Then 
'msgbox "您没有选择任何有效目录!" 
End If 
Set objFolderItem = objFolder.Self 
objPath = objFolderItem.Path 
WSHshellA.run  "wxsUI\UI_info\banjia.cmd USERPROFILE " & objPath,0 ,true
'WSHshellA.run  "wxsUI\UI_info\banjia.cmd ProgramFiles(x86) " & objPath,0 ,true
'WSHshellA.run  "wxsUI\UI_info\banjia.cmd programfiles " & objPath,0 ,true
'msgbox "[用户目录]已被移至：" & objPath &  "!!!         你可以愉快地玩耍了!"
end function
