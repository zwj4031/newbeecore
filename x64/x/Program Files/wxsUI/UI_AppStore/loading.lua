show_text = "���һ�ӭ��λ�쵼ݰ��ָ����"
lshift_index = 0

TIMER_ID_FLUSH_TEXT = 1001
TIMER_ID_QUIT = 1002

function lshift_text()
    local new_text = show_text:sub(lshift_index + 1)
    lshift_index = lshift_index + 2 -- ȫ���֣�һ���ƶ�2���ֽ�
    if lshift_index > show_text:len() then lshift_index = 0 end
    elem_label_info.text = "<b>" .. new_text .. "</b>"
    elem_label_info.bkcolor = "#FEFFFFFF"
end

function onload()
    local text = get_option("-text")
    local wait = get_option("-wait")
    if text then
        if text:sub(1, 1) == '"' then text = text:sub(2, -2) end
        show_text = text
    end
    elem_label_info = sui:find("label_info")
    elem_label_info.text = "<b>" .. show_text .. "</b>"

    -- ���������ݵ���������
    local def_w, def_h, w
    def_w = 580 -- Ĭ�Ͽ��
    def_h = 152 -- Ĭ�ϸ߶�

    if has_option("-top") then
        -- �ƶ�������
        sui:move(0, -((Screen:GetY() - def_h) // 2), 0, 0)
    end

    w = #show_text // 2 * 42 -- ȫ���֣�һ������ռ2���ֽ�
    if w > Screen:GetX() then w = Screen:GetX() end
    if w > def_w then
        w = w - def_w
        sui:move(-w // 2, 0, w, 0)
    end

    if has_option("-scroll") then
        -- ������ʱ�������ֹ���Ч��
        suilib.call("SetTimer", TIMER_ID_FLUSH_TEXT, 300)
    end

    if wait then suilib.call("SetTimer", TIMER_ID_QUIT, wait * 1000) end
end

function ontimer(id)
    if id == TIMER_ID_QUIT then
        sui:close()
    elseif id == TIMER_ID_FLUSH_TEXT then
        lshift_text()
    end
end
