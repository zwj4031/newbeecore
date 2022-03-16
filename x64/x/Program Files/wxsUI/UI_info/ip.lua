--show_text = " The quick brown fox jumps over a lazy dog"
show_text = ""
lshift_index = 0
char_width = 2

TIMER_ID_FLUSH_TEXT = 1001
TIMER_ID_QUIT = 1002
ipinfo_TIMER_ID = 10087

-- ��ȡ�̶�ֵ
temp = os.getenv("temp")

function lshift_text()
   local new_text = show_text:sub(lshift_index + 1)
   lshift_index = lshift_index + char_width  -- ȫ���֣�һ���ƶ�2���ֽ�
   if lshift_index > show_text:len() then lshift_index = 0 end
   elem_label_info.text = "<b>" .. new_text .. "</b>"
   elem_label_info.bkcolor = "#FEFFFFFF"

end


function move_top()
  local w, h = sui:info('wh')
  if  has_option('-top') then
    -- �ƶ�������
    sui:move( 0, - ((Screen:GetY() - h) // 2)+18, 0, 0)
	 --sui:move( 0, - ((Screen:GetX() - t) // 2), 0, 0)
  end
end



local function ipinfo_init()
local cmd = io.popen('ipconfig')
local stdout = cmd:read("*a")
cmd:close()
local fixed_out = {}
local lanip_str = stdout:match("IPv4 ��ַ . . . . . . . . . . . . : ([^\n]+)\n")
if lanip_str == nil or lanip_str == "127.0.0.1" then
table.insert(fixed_out, 
	string.format("������ַ <c #ff0000>����Ͽ�</c>")
)
else 
table.insert(fixed_out, 
	string.format("������ַ <c #FFFF00>%s</c> ", lanip_str)
)
end
local all_str = table.concat(fixed_out, "\n")
show_text = "<b>" ..  all_str .. "</b>"
elem_label_info.text = "<b>" ..  all_str .. "</b>"
end


function onload()   
  local text = get_option('-text')
  local wait = get_option('-wait')
  if text then
    if text:sub(1, 1) == '"' then text = text:sub(2, -2) end
    show_text = text
  end
  elem_label_info = sui:find('label_info')
  elem_label_info.text = "<b>" ..  show_text .. "</b>"
   -- ���������ݵ���������
  local def_w, w
  def_w = sui:info('wh')
  move_top()
  w = #show_text // char_width * 42 -- ȫ���֣�һ������ռ2���ֽ�
  if show_text:sub(1, 1) == ' ' then
    char_width = 1
    show_text = show_text:sub(2, -1)
    w = #show_text * 20
  end
  if w > Screen:GetX() then w = Screen:GetX() end
  if w > def_w then
    w = w - def_w
    sui:move(- w // 2, 0, w, 0)
  end

  if  has_option('-ipinfo') then
    -- ��Ϣ��ʾ��ʱ������ʾ��Ϣ
	ipinfo_init()
    suilib.call('SetTimer', ipinfo_TIMER_ID, 10087)
  end

  if  has_option('-scroll') then
    -- ������ʱ�������ֹ���Ч��
    suilib.call('SetTimer', TIMER_ID_FLUSH_TEXT, 300)
  end

  if wait then
    suilib.call('SetTimer', TIMER_ID_QUIT, wait * 1000)
  end
  
  
end

function ontimer(id)
   if id == TIMER_ID_QUIT then
     sui:close()
   elseif id == ipinfo_TIMER_ID then	
   	 ipinfo_init()
 elseif id == TIMER_ID_FLUSH_TEXT then
     lshift_text()
   end
end

function ondisplaychanged()
  move_top()
end
