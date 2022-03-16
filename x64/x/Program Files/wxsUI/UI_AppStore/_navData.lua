local tab_list = {
  '10-ABC',
  '11-DEF',
  '12-XYZ',
  '13-123',
  '14-456',
  '15-789'
}

local tab_template = [===[
  <VerticalLayout height="40" >
    <Label float="true" pos="20,0,32,32" mosue="false" text="" font="sym16" width="32" />
    <Option float="true" pos="0,0,240,32" group="nav_item" name="$Nav[{$I}]" style="nav_item" text="{$ITEM}" />
  </VerticalLayout>
]===]

local tablayout_head = [===[
  <TabLayout name="$TabLayoutMain" selectedid="-1" topbordersize="1" bordercolor="#ff000000" padding="2,2,2,2" >

    <VerticalLayout padding="20,0,0,0" >
        <Label text="%{Home}" font="24" height="50" />
    </VerticalLayout>
]===]

local tablayout_template = [===[
    <VerticalLayout padding="20,0,0,0" >
        <Label text="{$ITEM}" font="24" height="50" />
        <VerticalLayout name="$Page[{$I}]" />
    </VerticalLayout>
]===]

local tablayout_end = '</TabLayout>'


Nav:SetTabItemXML(tab_template, '.+-(.+)')
Nav:SetTabLayoutXML(tablayout_head, tablayout_end)
Nav:SetTabLayoutItemXML(tablayout_template, '.+-(.+)')

local appstore_path = APP_Path .. '\\AppStore'

tab_list = dir.folders(appstore_path)
Nav:SetTabList(tab_list)

-- load AppStore, CatalogInfo, AppInfo
dofile(appstore_path .. '\\_main.lua')
AppStore.path = appstore_path


