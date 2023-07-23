show_text = "热烈欢迎各位领导莅临指导。"
lshift_index = 0

TIMER_ID_FLUSH_TEXT = 1001
TIMER_ID_QUIT = 1002

function lshift_text()
    local new_text = show_text:sub(lshift_index + 1)
    lshift_index = lshift_index + 2 -- 全汉字，一次移动2个字节
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

    -- 按文字内容调整窗体宽度
    local def_w, def_h, w
    def_w = 580 -- 默认宽度
    def_h = 152 -- 默认高度

    if has_option("-top") then
        -- 移动到顶部
        sui:move(0, -((Screen:GetY() - def_h) // 2), 0, 0)
    end

    w = #show_text // 2 * 42 -- 全汉字，一个汉字占2个字节
    if w > Screen:GetX() then w = Screen:GetX() end
    if w > def_w then
        w = w - def_w
        sui:move(-w // 2, 0, w, 0)
    end

    if has_option("-scroll") then
        -- 滚动计时器，文字滚动效果
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
