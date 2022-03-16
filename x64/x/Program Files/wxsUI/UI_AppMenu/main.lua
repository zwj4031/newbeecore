
APP_Path = app:info('path')
UI_Path = sui:info('uipath')

AppMenu = {}
AppMenu.Folder = get_option('-dir')



dofile(UI_Path .. 'utils.lua')

dofile(UI_Path .. 'nav.lua')
dofile(UI_Path .. 'page.lua')

function onload()
  UI_Inited = 0

  Nav:Init()

  UI_Inited = 1
end


function onclick(ctrl)
  app:print('onclick:' .. ctrl)
  if Nav:OnTabClick(ctrl) then return end
end

