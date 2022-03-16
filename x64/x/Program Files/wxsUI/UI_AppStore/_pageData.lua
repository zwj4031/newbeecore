local tilelayout_head = [===[
  <TileLayout itemsize="132,108">
]===]

local tilelayout_item = [===[
  <VerticalLayout>
    <VerticalLayout float="true" pos="0,0,128,104" >
        <Label bkimage="{$ITEM.ICON}" width="32" height="32" padding="48,5,0,5" />
        <Label text="{$ITEM.NAME}" font="16" height="24" align="center" />
        <Label name="$App[{$ITEM.ID}]STAR" text="{$ITEM.STAR}" textcolor="#FFA4A4A4" align="center" />

        <Slider name="$App[{$ITEM.ID}]ProgressBar" imm="true" min="1" max="100" step="1" value="100" height="24" padding="0,-10,0,0"
            thumbsize="1,1" thumbimage="file='themes\thumb_.png'"
            bkimage="file='themes\sliderbk.png'" foreimage="file='themes\sliderfr.png'" visible="false" />
    </VerticalLayout>

    <Button  float="true" pos="0,0,128,104" name="$App[{$ITEM.ID}]" tooltip="{$ITEM.DESC}" hotimage="color='#206F6F6F'" />
  </VerticalLayout>
]===]

local tilelayout_end = '</TileLayout>'

TabPage:SetTileLayoutXML(tilelayout_head, tilelayout_end, tilelayout_item)

function TabPage:FillTileItem(id, name, template)
  local xml = {}
  local tmpl = ''
  local icon_path = string.format("%s\\%s\\", AppStore.path, name)
  local items = CatalogInfo[name].item
  local item = nil
  for i = 1, #items do
    item = items[i]
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

