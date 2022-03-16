local page_itemXML = ''
local page_head = ''
local page_end = ''

TabPage = {}

local pageUI_item = {}

function TabPage:Init()
end

function TabPage:SetTileLayoutXML(_head, _end, item)
  page_head = _head
  page_end = _end
  page_itemXML = item
end

function TabPage:InitPage(id, name)
  if pageUI_item[id] ~= nil then
    return pageUI_item[id]
  end
  local page = sui:find('$Page[' .. id .. ']')
  local xml = TabPage:FillTileItem(id, name, page_itemXML)
  -- msg(xml)
  suilib.insertItem(page, xml, page_head, page_end)
  pageUI_item[id] = page
  return page
end

dofile(UI_Path .. '_pageData.lua')
