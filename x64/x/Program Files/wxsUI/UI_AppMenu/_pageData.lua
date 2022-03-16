local tilelayout_head = [===[
  <TileLayout itemsize="150,50">
]===]

local tilelayout_item = [===[
  <HorizontalLayout padding="0,4,0,0">
    <VerticalLayout height="50" width="48">
      <Button name="$App[{$ITEM.ID}]" bkimage="{$ITEM.ICON}" width="32" height="32" />
    </VerticalLayout>
    <VerticalLayout>
        <Label text="{$ITEM.NAME}" tooltip="{$ITEM.DESC}" font="18" height="24" />
        <Label text="{$ITEM.STAR}" height="24" />
    </VerticalLayout>
  </HorizontalLayout>
]===]

local tilelayout_end = '</TileLayout>'

TabPage:SetTileLayoutXML(tilelayout_head, tilelayout_end, tilelayout_item)

function TabPage:FillTileItem(id, name, template)
  local xml = {}
  local tmpl = ''
  items = CatalogInfo[name].item
  local icon_path = string.format("%s\\%s\\", AppMenu.Path, name)
  for i, item in pairs(items) do
    tmpl = template:gsub('{$ITEM.ID}', item.id)

    if string.sub(item.icon, 2, 2) == ':' then
      tmpl = tmpl:gsub('{$ITEM.ICON}', item.icon)
    else
      tmpl = tmpl:gsub('{$ITEM.ICON}', icon_path .. item.icon)
    end

    tmpl = tmpl:gsub('{$ITEM.NAME}', item.name)
    if item.desc then
      tmpl = tmpl:gsub('{$ITEM.DESC}', item.desc)
    else
      tmpl = tmpl:gsub('{$ITEM.DESC}', '')
    end
    if item.star then
      tmpl = tmpl:gsub('{$ITEM.STAR}', item.star)
    else
      tmpl = tmpl:gsub('{$ITEM.STAR}', '-')
    end
    table.insert(xml, tmpl)
  end
  return table.concat(xml, "\r\n")
end
