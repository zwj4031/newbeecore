
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
Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, "��Ҫ��[�û�Ŀ¼]�Ƶ��δ���[�ʺ�С�ڴ����ʹ��QQ΢�ŵȹ���]", OPTIONS, strPath) 
If objFolder Is Nothing Then 
'msgbox "��û��ѡ���κ���ЧĿ¼!" 
End If 
Set objFolderItem = objFolder.Self 
objPath = objFolderItem.Path 
WSHshellA.run  "wxsUI\UI_info\banjia.cmd USERPROFILE " & objPath,0 ,true
'WSHshellA.run  "wxsUI\UI_info\banjia.cmd ProgramFiles(x86) " & objPath,0 ,true
'WSHshellA.run  "wxsUI\UI_info\banjia.cmd programfiles " & objPath,0 ,true
'msgbox "[�û�Ŀ¼]�ѱ�������" & objPath &  "!!!         �����������ˣ��!"
end function
