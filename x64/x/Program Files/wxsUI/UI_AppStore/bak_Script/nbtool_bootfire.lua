APP_Path = app:info("path")
UI_Path = sui:info("uipath")
temp = os.getenv("temp")
dofile(UI_Path .. 'helper_ntboot.lua') --helper_ntboot
systemdrive = os.getenv("systemdrive")
local exitcode, stdout = winapi.execute("mountvol")
get_bios_str = stdout:match("EFI ([^\n]+)\n")


function env_init()
      if File.Exists(UI_Path .. "\\bcd_sample.txt") then
        output = File.ReadAll(UI_Path .. "\\bcd_sample.txt")
    else
        exitcode, stdout = winapi.execute("cmd /c bcdedit /enum all")
		output = stdout:gsub("\r\n", "\n")
	   
	    end

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


function get_fw()

-- ���հ���Ϊ�ָ�����ȡ�����ַ�
local fw_boot_order = {}
local fw_boot_menu = {}
for str in output:gmatch("(.-)\n\n") do
if str:find("displayorder") then
table.insert(fw_boot_order, str)
else
table.insert(fw_boot_menu, str.."\n")
end
end

-- ��ȡ��ʾ�����ַ���
local alert_str = ""
for i, str in ipairs(fw_boot_menu) do
local obj_str = str:match("{(.-)}")
if obj_str then

local desc_str = str:match("description%s*(.-)\n")
local device_str = str:match("device%s*(.-)\n")
local default_str = str:match("{default}")
local current_str = str:match("{current}")
--alert_str = alert_str.."fw_boot_menu["..i.."]: {"..obj_str.."}\n" .. desc_str
if desc_str then
fw_boot_menu["{" .. obj_str .. "}"] = desc_str
fw_boot_menu[i] = {object = obj_str, description = desc_str, device = device_str}
end
if device_str  and desc_str then
fw_boot_menu["{" .. obj_str .. "}"] = desc_str .. "  ϵͳ"
end
if default_str and desc_str then
fw_boot_menu["{" .. obj_str .. "}"] = desc_str .. "  ϵͳ[Ĭ��]"
end
if current_str and desc_str then
fw_boot_menu["{" .. obj_str .. "}"] = desc_str .. "  ϵͳ[��ǰ]"
end
end
end



-- ������ʾ��
-- loop over each line of the fw_boot_order table
local tbl_fw = fw_boot_order
local str = ""
for _,v in pairs(tbl_fw) do
    str = str.."\n"..v
end

 
for line in string.gmatch(str,"[^\r\n]+") do
   match_Str = string.match(line,"%b{}")
   matchdev_Str = string.match(line,"device%s*(.-)")
  
  
   if((fw_boot_menu[match_Str]) ~= nil) then
    guid_table.desc = "             " .. fw_boot_menu[match_Str]
	makexml()
   end
   end


end



function makexml()
guid_table.id = string.format("%s", match_Str)
	fwboot_item = fwboot_item + 1
	guid_table.item =  fwboot_item .. "   "
	
	table.insert(sel_item, string.format("%s", guid_table.id))
	
	table.insert(sel_item_name, string.format("%s", guid_table.desc))

	build_xml(guid_table.item, guid_table.desc)
  suilib.insertItem(listxml, xml)
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


function startinit()
UI:KillTimer("��д�б�")
    fw_boot_order = ""
	fw_boot_menu = ""
    fwboot_item = -1
	msboot_item = 0
    guid_table = {}
	ms_stdout_tb = {}
    sel_item = {}
	sel_item_name = {}
	sel_item_type = {}
	
	env_init()
	get_fw() 
    UIWindow.Inited = 1
  

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
	if sel_item_name[fwindex]:find("ϵͳ") then
	exec("/wait /hide", [[Bcdedit /set {bootmgr} displayorder ]] .. selected .. [[ /addlast]])
	else
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} displayorder ]] .. selected .. [[ /addlast]])
     end
    UI:SetTimer("��д�б�", 10)
end

UI.OnTimer["��д�б�"] = function(id)
    listxml.list = "" --���xml
    fwbootmgr_menu = ""
	fw_boot_menu = ""
	
    startinit()
end

UI.OnClick["item_first"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    	if sel_item_name[fwindex]:find("ϵͳ") then
	 exec("/wait /hide", [[Bcdedit /set {bootmgr} displayorder ]] .. selected .. [[ /addfirst]])
		else
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} displayorder ]] .. selected .. [[ /addfirst]])
	end

    UI:SetTimer("��д�б�", 10)
end


UI.OnClick["item_add"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
   addfile = "raw"
 Add_Boot_Option(addfile)

    UI:SetTimer("��д�б�", 10)
end


UI.OnClick["item_del"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    a=winapi.show_message('����', "����ɾ��\n��Ŀ:" .. sel_item_name[fwindex] .. "!\nGUID:" .. selected ..
	"\n�����ܻᵼ��ϵͳ�޷�������������ѡ��", 'yes-no')
	if a == "yes" then
--winapi.show_message('����', a)
    exec("/wait /hide", [[Bcdedit /delete ]] .. selected)
else
return
end
    UI:SetTimer("��д�б�", 10)
end

UI.OnClick["item_def"] = function()
    fwindex = listxml.index + 1
    selected = sel_item[fwindex]
	    	if sel_item_name[fwindex]:find("ϵͳ") then
	   exec("/wait /hide", [[Bcdedit /default ]] .. selected)
		else
    alert("���֧�ִ˲���!\n��֧��ϵͳ�˵�!")
	end

  
    UI:SetTimer("��д�б�", 10)
end




UI.OnClick["item_bootsequence"] = function()
    fwindex = listxml.index + 1
    --alert(sel_item[fwindex])
    selected = sel_item[fwindex]
    --alert(selected)
	
	if sel_item_name[fwindex]:find("ϵͳ") then
	 exec("/wait /hide", [[Bcdedit /set {bootmgr} bootsequence ]] .. selected)
	else
    exec("/wait /hide", [[Bcdedit /set {fwbootmgr} bootsequence ]] .. selected)
	end   
	
	  if File.Exists("X:\\windows\\system32\\boot\\winload.efi") then
	  exec("/wait /hide", [[wpeutil reboot]])
        --alert("pe")
    else
	   --alert("os")
	    exec("/wait /hide", [[shutdown -r -t 8]])
        -- exec("/wait /hide", [[wpeutil reboot]])
    end
  
end
