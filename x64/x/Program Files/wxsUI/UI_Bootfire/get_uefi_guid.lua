temp = os.getenv("temp")
systemdrive = os.getenv("systemdrive")
local fwbootmgr_menu_table = {}
local exitcode, stdout = winapi.execute("cmd /c bcdedit /enum all")
stdout = stdout:gsub("\r\n", "\n")


-- ����ƥ���ȡ����
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


-- ��ȡ�̶�ֵ
function bcdinit()

--��ʼ��һЩ���� 
for def_str in string.gfind(stdout, "��ʶ��                  {default}*.-\n\n") do
if def_str ~= nil then
def_stdout = def_str
def_stdout = def_stdout:gsub("\r\n", "\n")
end
end

for bootmgr_str in string.gfind(stdout, "��ʶ��                  {bootmgr}*.-\n\n") do
if bootmgr_str ~= nil then
bootmgr_stdout = bootmgr_str
bootmgr_stdout = bootmgr_stdout:gsub("\r\n", "\n")
end
end


for fwbootmgr_str in string.gfind(stdout, "{fwbootmgr}*.-\n\n") do
fwbootmgr_menu = fwbootmgr_str
end
end

function get_fwboot_description(fwboot_guid_regex, stdout)
if guid_table.id:find("{bootmgr}") then
desc_regex = bootmgr_stdout:match("{bootmgr}[^*]+\ndescription([^\n]+)\n")
else
desc_regex = fwboot_guid_regex .. "\ndescription([^\n]+)\n"
end
for desc_str in stdout:gmatch(desc_regex) do
if desc_str ~= nil then
guid_table.desc = desc_str

table.insert(fwbootmgr_menu_table, string.format("UEFI����%s \n GUID:%s \n �豸%s\n", guid_table.item, guid_table.id, guid_table.desc))
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
guid_table.def = "û�а�װ����ϵͳ"
end
if stdout:find("{19260817--6666--8888--f00d--caffee000000}") then
NewBeePE_install = "       NewBeePE �Ѱ�װ"
else
NewBeePE_install = "     ��ǰû�а�װNewBeePE"
end
end

function get_bcdedit()
fwboot_item = 0
guid_table = {}
for token in string.gmatch(fwbootmgr_menu, " {([^\n]+)\n") do
fwboot_item = fwboot_item + 1
guid_table.item = fwboot_item
fwboot_guid = string.format("{%s", token)
guid_table.id = fwboot_guid
fwboot_guid_regex = "" .. fwboot_guid
if fwboot_guid:find("-") then
fwboot_guid_regex = fwboot_guid:gsub("-", "--")
end
get_fwboot_description(fwboot_guid_regex, stdout)
end
end

bcdinit()

get_bcdedit()
get_bootmgr_def()

fwbootmgr_menu = table.concat(fwbootmgr_menu_table, "\n")
fwbootmgr_menu = string.format(fwbootmgr_menu .. "\n��������ϵͳ״̬:\nĬ����������ϵͳ:" .. guid_table.def .. "\nNewBeePE��װ״̬:" .. NewBeePE_install)
alert(fwbootmgr_menu)
