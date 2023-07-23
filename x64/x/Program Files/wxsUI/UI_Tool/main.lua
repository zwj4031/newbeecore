local SystemRoot = os.getenv("SystemRoot")
local TID_UPANLIST_CHANGED = 20000 + 1
local strDrivers = "请选择分区修复\n一键修复所有分区"
local letters = winapi.get_logical_drives()
drv = {}
function str_drv(ck)
  for i, l in ipairs(letters) do
    if not File.exists(l .. [[Windows\System32\drivers\fbwf.sys]]) then
    strDrivers = strDrivers .. "\n" .. l
	if File.exists(l .. [[windows\system32\winlogon.exe]]) then
	strDrivers = strDrivers .. "    [检测到windows系统]"
	end
    end 
    if ck == "all" and not File.exists(l .. [[Windows\System32\drivers\fbwf.sys]]) then
      drv[i] = l:gsub("\\", "")
	  drv[i] = l:sub(1, 2)
      --winapi.show_message('即将修复', drv[i])
	  exec("/wait /show", SystemRoot .. [[\system32\cmd.exe /c start "正在修复]] .. drv[i] .. [[" chkdsk /x ]] .. drv[i])
	  UPanList.index = 0
    end
  end
end

function onload()
  str_drv()
  UPanList = sui:find("UPanList_combo")
  strDrivers = strDrivers:gsub("\\", "")
  UPanList.list = strDrivers
  UPanList.index = 0
end

function onchanged(ctrl)
  if ctrl == "UPanList_combo" then
    suilib.call("SetTimer", TID_UPANLIST_CHANGED, 200)
  end
end

function ontimer(tid)
  if tid == TID_UPANLIST_CHANGED then
    suilib.call("KillTimer", tid)
    UPanList_combo_onchanged()
  end
end

function UPanList_combo_onchanged()
  if UPanList.index ~= 0 and UPanList.index ~= 1 then
  panfu = UPanList.text:sub(1, 2)
  --winapi.show_message('即将修复', panfu)
    exec("/show", SystemRoot .. [[\system32\cmd.exe /k chkdsk /x ]] .. panfu)
  elseif UPanList.index == 1 then
    ck = "all"
    str_drv(ck)
  end
end
