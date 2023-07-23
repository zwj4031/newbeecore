APP_Path = app:info("path")
UI_Path = sui:info("uipath")
temp = os.getenv("temp")
systemdrive = os.getenv("systemdrive")

function env_init()
    fwbootmgr_menu_table = {}
    if File.Exists(UI_Path .. "\\bcd_sample.txt") then
        stdout = File.ReadAll(UI_Path .. "\\bcd_sample.txt")
    else
        exitcode, stdout = winapi.execute("cmd /c bcdedit /enum all")
    end
    stdout = stdout:gsub("\r\n", "\n")
end

env_init()

function File.ReadAll(path)
    local file = io.open(path, "r")
    if file == nil then
        return ""
    end
    local text = file:read("*a")
    file:close()
    return text
end

-- 正则匹配获取多行
function string.gfind(stdout, patten)
    local i, j = 0, 0
    return function()
        i, j = string.find(stdout, patten, j + 1)
        if (i == nil) then -- end find
            return nil
        end
        return string.sub(stdout, i, j)
    end
end

-- 提取固定值
function bcdinit()
    -- 初始化一些东西
    for def_str in string.gfind(stdout, "标识符                  {default}*.-\n\n") do
        if def_str ~= nil then
            def_stdout = def_str
            def_stdout = def_stdout:gsub("\r\n", "\n")
        end
    end

    for bootmgr_str in string.gfind(stdout, "标识符                  {bootmgr}*.-\n\n") do
        if bootmgr_str ~= nil then
            bootmgr_stdout = bootmgr_str
            bootmgr_stdout = bootmgr_stdout:gsub("\r\n", "\n")
        end
    end

    for fwbootmgr_str in string.gfind(stdout, "{fwbootmgr}*.-\n\n") do
        fwbootmgr_menu = fwbootmgr_str
    end
end

function get_fwboot_description(fwboot_guid_regex, stdout, fwboot_guid)
    if guid_table.id:find("{bootmgr}") then
        desc_regex = bootmgr_stdout:match("{bootmgr}[^*]+\ndescription([^\n]+)\n")
    else
	      for stdout_str in string.gfind(stdout, fwboot_guid_regex .. "*.-\n\n") do
         stdout = stdout_str
    end 
	
	 --exitcode, stdout = winapi.execute("cmd /c bcdedit /enum " .. fwboot_guid)
	 desc_regex = "description([^\n]+)\n"
    end
    for desc_str in stdout:gmatch(desc_regex) do
        if desc_str ~= nil then
            guid_table.desc = desc_str
            table.insert(
                fwbootmgr_menu_table,
                string.format("UEFI序列%s \n GUID:%s \n 启动项%s\n", guid_table.item, guid_table.id, guid_table.desc)
            )
            table.insert(sel_item, string.format("%s", guid_table.id))
            build_xml(guid_table.item, guid_table.desc)
            suilib.insertItem(listxml, xml)
        end
    end
end

function get_bootmgr_def()
    if def_stdout ~= nil then
        bootmgr_def = def_stdout:match("{default}[^*]+\ndescription([^\n]+)\n")
    end

    if bootmgr_def ~= nil then
        guid_table.def = bootmgr_def
    else
        guid_table.def = "newbeepe"
    end
    if stdout:find("{19260817--6666--8888--f00d--caffee000000}") then
        NewBeePE_install = "       NewBeePE"
    else
        NewBeePE_install = "     NewBeePE"
    end
end

function get_bcdedit()
    fwboot_item = -1
    guid_table = {}
    sel_item = {}
    for token in string.gmatch(fwbootmgr_menu, " {([^\n]+)\n") do
        fwboot_item = fwboot_item + 1
        guid_table.item = fwboot_item
        fwboot_guid = string.format("{%s", token)
        guid_table.id = fwboot_guid
        fwboot_guid_regex = "" .. fwboot_guid
        if fwboot_guid:find("-") then
		
            fwboot_guid_regex = fwboot_guid:gsub("-", "--")
        end
        get_fwboot_description(fwboot_guid_regex, stdout, fwboot_guid)
    end
end

function suilib.insertItem(sui_obj, xml)
    local str = {}
    table.insert(str, '<ListContainerElement height="40"> ')
    table.insert(str, xml)
    table.insert(str, "   </ListContainerElement> ")
    sui_obj:add(table.concat(str, "\r\n"))
end

function build_xml(index, item_name)
    xml =
        [[
<ListContainerElement height="40">
 
        <HorizontalLayout>         
            <Label text="]] ..
        guid_table.item ..
            [[" textpadding="15,0,0,0" align="center" height="40" width="60" textcolor="#FF5E5E5E" disabledtextcolor="#FFA7A6AA" />  
          <Control width="1" bkcolor="#FFCACACA"/>    
         
         <Label text="]] ..
                item_name ..
                    [[" textpadding="-35,0,0,0" valign="left"  height="40" width="600" textcolor="#FF5E5E5E" disabledtextcolor="#FFA7A6AA" />  
       
      
        </HorizontalLayout>
		  </ListContainerElement>
  
]]
    return xml
end

-- function onload()
--   UI_Inited = 0
--   UI_Inited = 1
-- end
function startinit()
    UI:KillTimer("重写列表")
    env_init()
    bcdinit()

    get_bcdedit()
    get_bootmgr_def()

    UIWindow.Inited = 1

    fwbootmgr_menu = table.concat(fwbootmgr_menu_table, "\n")
    fwbootmgr_menu =
        string.format(
        fwbootmgr_menu .. "\n本机离线系统状态:\n默认启动操作系统:" .. guid_table.def .. "\nNewBeePE安装状态:" .. NewBeePE_install
    )
    --alert(fwbootmgr_menu)
end

function UIWindow.OnLoad()
    listxml = sui:find("$TabLayoutParent")
    startinit()

    --Alert(fwbootmgr_menu)
    UIWindow.Inited = 1
end

UI.OnClick["item_last"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    --alert(selected)
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} displayorder ]] .. selected .. [[ /addlast]])

    UI:SetTimer("重写列表", 10)
end

UI.OnTimer["重写列表"] = function(id)
    listxml.list = "" --清空xml
    fwbootmgr_menu = ""
    startinit()
end

UI.OnClick["item_first"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    --alert(selected)
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} displayorder ]] .. selected .. [[ /addfirst]])

    UI:SetTimer("重写列表", 10)
end


UI.OnClick["item_add"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    a=winapi.show_message('添加:警告', "暂不支持这功能", 'yes-no')
	if a == "yes" then
--winapi.show_message('警告', a)
   return
else
return
end
    UI:SetTimer("重写列表", 10)
end


UI.OnClick["item_del"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    a=winapi.show_message('警告', "将删除序列!\n " .. sel_item[fwindex] .. "，可能会导致系统无法启动，请肾重选择", 'yes-no')
	if a == "yes" then
--winapi.show_message('警告', a)
    exec("/wait /hide", [[Bcdedit /delete ]] .. selected)
else
return
end
    UI:SetTimer("重写列表", 10)
end


UI.OnClick["item_bootsequence"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    --alert(selected)
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} bootsequence ]] .. selected)
	
	  if File.Exists("X:\\windows\\system32\\boot\\winload.efi") then
	  exec("/wait /hide", [[wpeutil reboot]])
        --alert("pe")
    else
	   --alert("os")
	    exec("/wait /hide", [[shutdown -r -t 8]])
        -- exec("/wait /hide", [[wpeutil reboot]])
    end
  
end
