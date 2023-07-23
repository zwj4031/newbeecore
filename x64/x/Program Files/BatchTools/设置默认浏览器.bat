rem 默认浏览器关联
if not exist X:\ exit
set browser_path=X:\Progra~1\opera\opera.exe
if exist "X:\Program Files\opera\Opera\opera.exe" set browser_path=X:\Progra~1\opera\Opera\opera.exe
if exist "X:\Progra~1\Google\Chrome\Application\chrome.exe" set browser_path=X:\Progra~1\Google\Chrome\Application\chrome.exe
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" /f /ve /t REG_SZ /d "\"%browser_path%\""
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" /f /v "Path" /t REG_SZ /d "\"%browser_path%\""
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" /f /ve /t REG_SZ /d "\"%browser_path%\""
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" /f /v "Path" /t REG_SZ /d "\"%browser_path%\""
exit