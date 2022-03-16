
on error resume next 
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
Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, "请选择分区:", OPTIONS, strPath) 
If objFolder Is Nothing Then 
msgbox "您没有选择任何有效目录!" 
End If 
Set objFolderItem = objFolder.Self 
objPath = objFolderItem.Path 
msgbox "您选择的分区：" & objPath 
end function
