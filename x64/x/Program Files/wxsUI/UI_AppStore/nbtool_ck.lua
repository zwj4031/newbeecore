local SystemRoot = os.getenv("SystemRoot")
local TID_UPANLIST_CHANGED = 20000 + 1
local strDrivers = "请选择分区修复\n一键修复所有分区"
local letters = winapi.get_logical_drives()
drv = {}
i = 0
function str_drv(ck)
  for _, l in ipairs(letters) do
    strDrivers = strDrivers .. "\n" .. l
    i = i + 1
    if ck == "all" then
      drv[i] = l:gsub("\\", "")
      --winapi.show_message('即将修复', drv[i])
      exec("/wait /show", SystemRoot .. [[\system32\cmd.exe /c start "正在修复]] .. drv[i] .. [[" chkdsk /x ]] .. drv[i])
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
    exec("/show", SystemRoot .. [[\system32\cmd.exe /k chkdsk /x ]] .. UPanList.text)
  elseif UPanList.index == 1 then
    ck = "all"
    str_drv(ck)
  end
end
