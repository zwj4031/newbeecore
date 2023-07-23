temp = os.getenv("temp")
systemdrive = os.getenv("systemdrive")
local fwbootmgr_menu_table = {}
local exitcode, stdout = winapi.execute("cmd /c bcdedit /enum all")
stdout = stdout:gsub("\r\n", "\n")
--一次性启动命令Bcdedit /set {fwbootmgr} bootsequence {d0a72d68-494c-11ed-badf-00505626a58c} /addlast
--第一项命令Bcdedit /set {fwbootmgr} displayorder {d0a72d68-494c-11ed-badf-00505626a58c} /addfirst

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

--初始化一些东西 
for def_str in string.gfind(stdout, "标识符                  {default}*.-\n\n") do
def_stdout = def_str
end
def_stdout = def_stdout:gsub("\r\n", "\n")

for bootmgr_str in string.gfind(stdout, "标识符                  {bootmgr}*.-\n\n") do
bootmgr_stdout = bootmgr_str
end
bootmgr_stdout = bootmgr_stdout:gsub("\r\n", "\n")


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

table.insert(fwbootmgr_menu_table, string.format("UEFI序列%s \n GUID:%s \n 设备%s\n", guid_table.item, guid_table.id, guid_table.desc))
end
end
end

function get_bootmgr_def()
bootmgr_def = def_stdout:match("{default}[^*]+\ndescription([^\n]+)\n")
if bootmgr_def ~= nil then
guid_table.def = bootmgr_def
else
guid_table.def = "没有安装操作系统"
end
if stdout:find("{19260817--6666--8888--f00d--caffee000000}") then
NewBeePE_install = "       NewBeePE 已安装"
else
NewBeePE_install = "     当前没有安装NewBeePE"
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
fwbootmgr_menu = string.format(fwbootmgr_menu .. "\n本机离线系统状态:\n默认启动操作系统:" .. guid_table.def .. "\nNewBeePE安装状态:" .. NewBeePE_install)
alert(fwbootmgr_menu)
