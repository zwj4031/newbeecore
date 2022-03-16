APP_Path = app:info('path')
UI_Path = sui:info('uipath')
dofile(UI_Path .. 'utils.lua')
dofile(UI_Path .. 'nav.lua')
dofile(UI_Path .. 'page.lua')
dofile(UI_Path .. 'helper_nbdl.lua') --helper_nbdl
dofile(UI_Path .. 'helper_openfile.lua') --helper_openfile
function onload()
  UI_Inited = 0
  Nav:Init()
  helper_nbdl_onload() --helper_nbdl
  helper_openfile_onload() --helper_openfile
  UI_Inited = 1
end



function onclick(ctrl)
   app:print('onclick:' .. ctrl)
  helper_nbdl_onclick(ctrl) --helper_nbdl
   if Nav:OnTabClick(ctrl) then return end
end



