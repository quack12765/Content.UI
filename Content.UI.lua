BaseUI = UI

UI = {}

UI.Content = {}

--[[
    funciton UI.Content:Create(arg)
    table arg: 
        int x
        int y
        int width
        int height
]]

function UI.Content:Create(arg)
    if not (arg.x and arg.y and arg.width and arg.height) then return nil end

    local o = {
        x = arg.x,
        y = arg.y,
        width = arg.width,
        height = arg.height,
        container = {},
        cury = arg.y,
        curx = arg.x,
        LineMaxHeight = 0,
    }

    setmetatable(o, UI.Content)

    return o
end


--[[
    function UI.Content:AddDiv(arg)
    table arg: 
        string class
        string display (optional) (default "inline")
        string position (optional) (default "static")
        string text (optional)
        string font_align (optional) (default "left")

        int width (optional) (default 0)
        int height (optional) (default 0)

        int top (optional) (default 0)
        int left (optional) (default 0)

        int margin (optional) (default 0)
        int margin_top (optional) (default 0)
        int margin_bottom (optional) (default 0)
        int margin_left (optional) (default 0)
        int margin_right (optional) (default 0)

        int padding (optional) (default 0)
        int padding_top (optional) (default 0)
        int padding_bottom (optional) (default 0)
        int padding_left (optional) (default 0)
        int padding_right (optional) (default 0)

        int border (optional) (default 0)
        table border_color (optional) (default nil)

        string font_size (optional) (default "small")
        table font_color (optional) (default nil)
        table background_color (optional) (default nil)
]]

function UI.Content:AddDiv(arg)
    if not arg then return nil end
    local config = {
        class               = arg.class,
        display             = arg.display           or "inline",
        position            = arg.position          or "static",
        width               = arg.width             or 0,
        height              = arg.height            or 0,
        top                 = arg.top               or 0,
        left                = arg.left              or 0,
        margin              = arg.margin            or 0,
        margin_top          = arg.margin_top        ,
        margin_bottom       = arg.margin_bottom     ,
        margin_left         = arg.margin_left       ,
        margin_right        = arg.margin_right      ,
        padding             = arg.padding           or 0,
        padding_top         = arg.padding_top       ,
        padding_bottom      = arg.padding_bottom    ,
        padding_left        = arg.padding_left      ,
        padding_right       = arg.padding_right     ,
        border              = arg.border            or 0,
        font_size           = arg.font_size         or "small",
        font_color          = arg.font_color        or {r = nil, g = nil, b = nil, a = 255},   
        background_color    = arg.background_color  or {r = nil, g = nil, b = nil, a = 255},
        border_color        = arg.border_color      or {r = nil, g = nil, b = nil, a = 255},
        text                = arg.text,
        font_align          = arg.font_align        or "left"
    }
    local R = BaseUI.Rectangle:Create()
    R:Set({
        width = config.width,
        height = config.height,
        r = config.background_color.r,
        g = config.background_color.g,
        b = config.background_color.b,
        a = config.background_color.a,
        stroke = {
            visible = true,
            size = config.border,
            r = config.border_color.r,
            g = config.border_color.g,
            b = config.border_color.b,
            a = config.border_color.a,
        }
    })
    local T = BaseUI.Text.Create()
    T:Set({
        width = config.width,
        height = config.height,
        r = config.font_color.r,
        g = config.font_color.g,
        b = config.font_color.b,
        a = config.font_color.a,
        align = config.font_align,
        font_size = config.font_size,
        text = config.text
    })
    config.div = R
    config.text = T
    table.insert(self.container, config)

    self:Resize()
end

function UI.Content:Resize()
    self.curx = self.x
    self.cury = self.y
    self.LineMaxHeight = 0
    for i = 1, #(self.container) do
        local curConfig = self.container[i]
        local curDiv = curConfig.div
        local curText = curConfig.text
        if curConfig.position == "absolute" then
            curDiv:Set({
                x = self.x + curConfig.left + (curConfig.margin_left or curConfig.margin) + curConfig.border,
                y = self.y + curConfig.top + (curConfig.margin_top or curConfig.margin) + curConfig.border
            })
        else
            curDiv:Set({
                x = self.curx + curConfig.left + (curConfig.margin_left or curConfig.margin) + curConfig.border,
                y = self.cury + curConfig.top + (curConfig.margin_top or curConfig.margin) + curConfig.border
            })
            if self.LineMaxHeight < curConfig.height + 2 * curConfig.border + (curConfig.margin_top or curConfig.margin) + (curConfig.margin_bottom or curConfig.margin) + curConfig.top then
                self.LineMaxHeight = curConfig.height + 2 * curConfig.border + (curConfig.margin_top or curConfig.margin) + (curConfig.margin_bottom or curConfig.margin) + curConfig.top
            end
            if i ~= #(self.container) then
                if self.container[i + 1].display == "inline" then
                    self.curx = self.curx + curConfig.left + (curConfig.margin_left or curConfig.margin) + (curConfig.margin_right or curConfig.margin) + curConfig.width + 2 * curConfig.border
                else
                    self.curx = self.x
                    self.cury = self.cury + self.LineMaxHeight
                    self.LineMaxHeight = 0
                end
            end
            if not curConfig.position == "relative" then
                self.curx = self.curx - curConfig.left
                self.cury = self.cury - curConfig.top
            end
        end
        curDiv:Set({
            width = curConfig.width,
            height = curConfig.height,
            r = curConfig.background_color.r,
            g = curConfig.background_color.g,
            b = curConfig.background_color.b,
            a = curConfig.background_color.a,
            stroke = {
                visible = true,
                size = curConfig.border,
                r = curConfig.border_color.r,
                g = curConfig.border_color.g,
                b = curConfig.border_color.b,
                a = curConfig.border_color.a,
            }
        })
        curText:Set({
            width = curConfig.width - (curConfig.padding_left or curConfig.padding) - (curConfig.padding_right or curConfig.padding),
            height = curConfig.height - (curConfig.padding_top or curConfig.padding) - (curConfig.padding_bottom or curConfig.padding),
            r = curConfig.font_color.r,
            g = curConfig.font_color.g,
            b = curConfig.font_color.b,
            a = curConfig.font_color.a,
            align = curConfig.font_align,
            font_size = curConfig.font_size,
            x = curDiv:Get().x + (curConfig.padding_left or curConfig.padding),
            y = curDiv:Get().y + (curConfig.padding_top or curConfig.padding),
        })
    end
end



--[[
    function UI.Content:Set(class, arg)
    string class
    table arg
        same top
]]

function UI.Content:Set(class, arg)
    if not class then return nil end

    if class == "*" then
        for i = 1, #(self.container)do
            for k , l in pairs(arg) do
                self.container[i][k] = l
            end
        end
    else
        for i , j in pairs(self.container) do
            if j.class == class then
                for k , l in pairs(arg) do
                    self.container[i][k] = l
                end
            end
        end
    end

    self:Resize()
end

function UI.Content:Hide(class)
    if not class then return nil end

    if class == "*" then
        for i = 1, #(self.container)do
            self.container[i].div:Hide()
            self.container[i].text:Hide()
        end
    else
        for i , j in pairs(self.container) do
            if j.class == class then
                self.container[i].div:Hide()
                self.container[i].text:Hide()
            end
        end
    end
end

function UI.Content:Show(class)
    if not class then return nil end

    if class == "*" then
        for i = 1, #(self.container)do
            self.container[i].div:Show()
            self.container[i].text:Show()
        end
    else
        for i , j in pairs(self.container) do
            if j.class == class then
                self.container[i].div:Show()
                self.container[i].text:Show()
            end
        end
    end
end

UI.Content.__index = UI.Content

_G.UI = table.extend( BaseUI , UI )