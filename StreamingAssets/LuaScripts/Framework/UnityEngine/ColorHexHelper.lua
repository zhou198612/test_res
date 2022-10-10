
--[[
备注 : 色值格式化、转换和定义
]]
----------------------------------------------------------------------------------------------
local strfmt = string.format
local strsub = string.sub
----------------------------------------------------------------------------------------------
--[[doc: 通道默认数值]]
local channel_default = 255

--[[doc: 24位默认十六进制字符串]]
local hex24_default = '#FFFFFF'

--[[doc: 32位默认十六进制字符串]]
local hex32_default = '#FFFFFFFF'

--[[doc: 24位默认RGB色值]]
local rgb_default = {
    r = channel_default,
    g = channel_default,
    b = channel_default
}

--[[doc: 32位默认RGB色值]]
local rgba_default = {
    r = rgb_default.r,
    g = rgb_default.g,
    b = rgb_default.b,
    a = channel_default
}

--[[func: 转换为可用的色位]]
local function to_color_bit(color)
    color = tonumber(color)
    if color and color <= channel_default and channel_default >= 0 then
        return color
    end
    return channel_default
end

--[[func: 转换为有效的色值]]
local function to_valid_color(color)
    if type(color) ~= 'table' then
        return rgba_default
    end

    color.r = to_color_bit(color.r)
    color.g = to_color_bit(color.g)
    color.b = to_color_bit(color.b)
    color.a = to_color_bit(color.a)
end

--[[func: 从十六进制字符串转为色位 -- 将16进制 转换成 10 进制。 如： tonumber("FF", 16) = 255]]
local function str_to_hex_num(hex)
    return tonumber(hex, 16) or channel_default
end

--[[func: 数值转换为十六进制字符串 -- 将10进制数字 转换成 16进制 字符串。如 string.format('%02X', 255) = "FF"]]
local function num_to_hex_str(value)
    return strfmt('%02X', to_color_bit(value))
end

--[[func: 从十六进制字符串转换 -- 将16进制表示的颜色值 转换成 10进制表示的颜色值。如 "#7FFFFF00" -> color = {r = 127,g = 255,b = 255,a = 00} ]]
local function hex_to_color(hex)
    local len = string.len(hex)
    if len < 7 then
        return rgb_default
    end

    if strsub(hex, 1, 1) ~= '#' then
        return rgb_default
    end

    local color = {
        r = to_color_bit(str_to_hex_num(strsub(hex, 2, 3))),
        g = to_color_bit(str_to_hex_num(strsub(hex, 4, 5))),
        b = to_color_bit(str_to_hex_num(strsub(hex, 6, 7))),
        a = channel_default
    }

    if len == 9 then
        color.a = to_color_bit(str_to_hex_num(strsub(hex, 8, 9)))
    end

    return color
end

--[[func: 从十六进制字符串转换 并将颜色单位化 -- 将16进制表示的颜色值 转换成 10进制表示的颜色值。如 "#7FFFFF00" -> color = {r = 0.5,g = 1.0,b = 1.0,a = 0.0} ]]
local function hex_to_color_unit(hex)
    local color = hex_to_color(hex)
    local color_unit = {
        r = color.r / channel_default,
        g = color.g / channel_default,
        b = color.b / channel_default,
        a = color.a / channel_default,
    }
    return color_unit
end

--[[func: 从数值表转换 -- {255,0,255,128} -> {r = 255,g = 0,b = 255,a = 128}]]
local function tab_to_color(tbl)
    return {
        r = to_color_bit(tbl[1]),
        g = to_color_bit(tbl[2]),
        b = to_color_bit(tbl[3]),
        a = to_color_bit(tbl[4])
    }
end

--[[func: 转为为数值表 -- {r = 255,g = 0,b = 255,a = 128} -> {255,0,255,128}]]
local function color_to_tab(color)
    to_valid_color(color)
    return { color.r, color.g, color.b, color.a }
end

--[[func: 转换为十六进制（24位）-- {r = 255,g = 255,b = 0} -> '#FFFF00']]
local function color_to_hex24(color)
    if type(color) ~= 'table' then
        return hex24_default
    end

    if not color.r or not color.g or not color.b then
        return hex24_default
    end

    local hex = '#'
    hex = hex .. num_to_hex_str(color.r)
    hex = hex .. num_to_hex_str(color.g)
    hex = hex .. num_to_hex_str(color.b)
    return hex
end

--[[func: 转换为十六进制（32位）-- {r = 255,g = 255,b = 0,a = 255} -> '#FFFF00FF']]
local function color_to_hex32(color)
    return color_to_hex24(color) .. num_to_hex_str(color.a)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
ColorHexHelper = {
    --[[doc: 方法定义]]
    FromHex = hex_to_color,
    FromHexUnit = hex_to_color_unit,
    FromTab = tab_to_color,
    ToTab = color_to_tab,
    ToHex24 = color_to_hex24,
    ToHex32 = color_to_hex32,
    ToHex = color_to_hex24,

    --[[doc: 色值定义]]
    Hex = {
        --[[doc: 红色 光的三原色之一]]
        Red    = '#FF0000',
        --[[doc: 绿色 光的三原色之一]]
        Green = '#00FF00',
        --[[doc: 蓝色 光的三原色之一]]
        Blue    = '#0000FF',
        --[[doc: 白色 等量的三原色光相加为白光]]
        White = '#FFFFFF',
        --[[doc: 黄色 颜料三原色之一]]
        Yellow = '#FFFF00',
        --[[doc: 品红 颜料三原色之一]]
        Magenta = '#FF00FF',
        --[[doc: 青色 颜料三原色之一 与 Cyan 异名同色]]
        Aqua    = '#00FFFF',
        Cyan    = '#00FFFF',
        --[[doc: 黑色 颜料三原色混合为黑色]]
        Black = '#000000',
    }
}
return ColorHexHelper