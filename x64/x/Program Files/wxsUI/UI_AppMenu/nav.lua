local tab_list = {}
local tab_itemXML = '<VerticalLayout><Label name="$Nav[%d]" text="%s" /></VerticalLayout>'
local tab_item_regex = nil

local tablayout_head = [[<TabLayout name="$TabLayoutMain" selectedid="-1">]]
local tablayout_itemXML = '<VerticalLayout></VerticalLayout>'
local tablayout_end = '</TabLayout>'
local tablayout_item_regex = nil
local tab_layout = nil

local nav_map = {}
local navUI_item = {}

Nav = {}

function Nav:Init()

  -- init UI tab options
  app:print('==========Nav:Init()============')
  nav_list = sui:find('$TabList')
  local xml = suilib.genItemXML(tab_itemXML, tab_list, tab_item_regex)
  suilib.insertItem(nav_list, xml)

  local tablayout_parent = sui:find('$TabLayoutParent')

  xml = suilib.genItemXML(tablayout_itemXML, tab_list, tablayout_item_regex)
  suilib.insertItem(tablayout_parent, xml, tablayout_head, tablayout_end)

  tab_layout = sui:find('$TabLayoutMain')
  Nav:GetTabMap()
end

function Nav:SetTabList(list)
  tab_list = list
end

function Nav:SetTabItemXML(template, item_regex)
  tab_itemXML = template
  tab_item_regex = item_regex
end

function Nav:SetTabLayoutXML(_head, _end)
  tablayout_head = _head
  tablayout_end = _end
end

function Nav:SetTabLayoutItemXML(template, item_regex)
  tablayout_itemXML = template
  tablayout_item_regex = item_regex
end

function Nav:GetTabMap()
  local tab_id = -1
  local tab = #tab_list

  for i = 1, #tab_list do
    nav_map['$Nav[' .. i .. ']'] = tab_list[i]
    navUI_item[i] = sui:find('$Nav[' .. i .. ']')
  end
  return nav_map
end

function Nav:SwitchTab(id)
  TabPage:InitPage(id, tab_list[tonumber(id)])
  tab_layout.selectedid = tonumber(id)
end

function Nav:OnTabClick(ctrl)
  local handled = true
  local nav_id = ctrl:match('$Nav%[(%d)%]')
  if nav_id then
    Nav:SwitchTab(nav_id)
  else
    handled = false
  end
  return handled
end

dofile(UI_Path .. '_navData.lua')
