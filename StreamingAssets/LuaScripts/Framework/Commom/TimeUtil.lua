--[[
	目的: 通用时间处理类
        1. 时间戳的转换
        2. 时间戳的格式化
        2. 与当前时间差值的格式化输出
]]
local TimeUtil = {}

--[[
    此代码是从nigix－time.c中摘取而来的。用于时间戳转换成tm结构
    input: 时间戳
    此处涉及到时区问题
--]]
local tm = {year=1970, month=1, day=1, yday=1,wday=1,hour=1, min=1, sec=1}
local _ceil = math.ceil 
local _fmod = math.modf
function TimeUtil.gmTime(time, timezone)
	-- body
	-- ngx_int_t   yday;
    -- ngx_uint_t  n, sec, min, hour, mday, mon, year, wday, days, leap;
    -- /* the calculation is valid for positive time_t only */
    --local n = _ceil(time) ?????????????????????? +28800(8小时) 中国所在时区为东8区
    local timezone = UserDataManager:getTimeZone() or 28800
	local n = _ceil(time) + timezone
    local days = _fmod(n / 86400)

    -- /* Jaunary 1, 1970 was Thursday */
    local wday = (4 + days) % 7;

    n = n % 86400
    local hour = _fmod(n / 3600)
    n = n % 3600
    local min = _fmod(n / 60)
    local sec = n % 60
    -- /*
    --  * the algorithm based on Gauss' formula,
    --  * see src/http/ngx_http_parse_time.c
    --  */
    -- /* days since March 1, 1 BC */
    days = days - (31 + 28) + 719527;
    -- /*
    --  * The "days" should be adjusted to 1 only, however, some March 1st's go
    --  * to previous year, so we adjust them to 2.  This causes also shift of the
    --  * last Feburary days to next year, but we catch the case when "yday"
    --  * becomes negative.
    --  */
    -- local year = _fmod((days + 2) * 400 / (365 * 400 + 100 - 4 + 1)) ----
    local year = _fmod((days + 2) * 400 / (146000 + 100 - 4 + 1))
    local yday = days - (365 * year + _fmod(year / 4) - _fmod(year / 100) + _fmod(year / 400))
    if (yday < 0) then
        local leap = (year % 4 == 0) and (year % 100 or (year % 400 == 0))
        local offset = 0
        if leap then
            offset = 1
        end
        yday = 365 + offset + yday;
        year = year - 1
    end
    -- /*
    --  * The empirical formula that maps "yday" to month.
    --  * There are at least 10 variants, some of them are:
    --  *     mon = (yday + 31) * 15 / 459
    --  *     mon = (yday + 31) * 17 / 520
    --  *     mon = (yday + 31) * 20 / 612
    --  */
    local mon = _fmod((yday + 31) * 10 / 306)
    -- /* the Gauss' formula that evaluates days before the month */
    local mday = yday - (_fmod(367 * mon / 12) - 30) + 1;
    if (yday >= 306) then

        year = year + 1
        mon = mon - 10;
        -- /*
        --  * there is no "yday" in Win32 SYSTEMTIME
        --  *
        --  * yday -= 306;
        --  */
    else 
        mon = mon + 2
        -- /*
        --  * there is no "yday" in Win32 SYSTEMTIME
        --  *
        --  * yday += 31 + 28 + leap;
        --  */
    end
    tm.sec = sec
    tm.min = min
    tm.hour = hour
    tm.day = mday
    tm.month = mon
    tm.year = year
    tm.yday = yday  --1年中第几天
    tm.wday = wday  --星期几
    return tm
end

--[[
    返回时间戳
--]]
function TimeUtil.getTime()
	return os.time()
end

--[[
    input: 时间戳
    返回table
--]]
function TimeUtil.getDate(time)
    return os.date("*t", math.ceil(time or os.time()))
end

--[[
    input: 时间戳
    返回时间戳
--]]
function TimeUtil.getUTCTime(time)
    return os.time(os.date("!*t", math.ceil(time or os.time())))
end

--[[
    input: 时间戳
    返回table
--]]
function TimeUtil.getUTCDate(time)
    local t = os.date("!*t", math.ceil(time or os.time()))
    return t
end

-- %a
-- abbreviated weekday name (e.g., Wed)
-- %A
-- full weekday name (e.g., Wednesday)
-- %b
-- abbreviated month name (e.g., Sep)
-- %B
-- full month name (e.g., September)
-- %c
-- date and time (e.g., 09/16/98 23:48:10)
-- %d
-- day of the month (16) [01-31]
-- %H
-- hour, using a 24-hour clock (23) [00-23]
-- %I
-- hour, using a 12-hour clock (11) [01-12]
-- %M
-- minute (48) [00-59]
-- %m
-- month (09) [01-12]
-- %p
-- either "am" or "pm" (pm)
-- %S
-- second (10) [00-61]
-- %w
-- weekday (3) [0-6 = Sunday-Saturday]
-- %x
-- date (e.g., 09/16/98)
-- %X
-- time (e.g., 23:48:10)
-- %Y
-- full year (1998)
-- %y
-- two-digit year (98) [00-99]
-- %%
-- the character '%'
--[[
    input: 时间戳  
    fmtType : 1--09/16/98 23:48:10  2--09/16/98  3---23:48:10 4--
 	输出格式字符串
--]]
function TimeUtil.fmtTime(time, fmtType)
	fmtType = fmtType or 1
	if fmtType == 1 then
		return os.date("%c", math.ceil(time))
	elseif fmtType == 2 then
		return os.date("%x", math.ceil(time))
	elseif fmtType == 3 then
		return os.date("%X", math.ceil(time))
    elseif fmtType == 4 then
        return os.date("%H:%M", math.ceil(time))
	end	
end

-- 时间戳获取当天整点的时间戳
function TimeUtil.getIntTimestamp(time, hour, timezone)
    hour = hour or 0
    timezone = timezone and timezone or UserDataManager:getTimeZone()/3600
    return time - (time + timezone*3600)%86400 + hour*3600
end

-- 比较一个时间是否在当天的刷新时间范围内
function TimeUtil.isInFreshTime(time, hour)
    local flag = false
    local cur_time = UserDataManager:getServerTime()
    local fresh_time = TimeUtil.getIntTimestamp(cur_time, hour)
    if time >= fresh_time and time < fresh_time + 86400 then
        flag = true
    end
    return flag
end

-- 配置的时间字符串转时间戳
function TimeUtil.stringToTimestamp(strDate, strFormat)
    if type(strDate) ~= "string" then
        return
    end
    local dateTab = {}
    strFormat = strFormat or "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)"
    local _, _, year, month, day, hour, min, sec = string.find(strDate, strFormat)
    dateTab = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    local actTime = os.time(dateTab)
    local clientActTime = os.date("*t", actTime)
    local serverTime = UserDataManager:getServerTime()
    local clientTimeZone = os.difftime(serverTime, os.time(os.date"!*t", serverTime))
    local serverTimeZone = UserDataManager:getTimeZone()
    local cutTime = (clientActTime.isdst and 1 or 0)*3600 - (serverTimeZone - clientTimeZone)
    actTime = actTime + cutTime
    return  math.ceil(actTime)
end

return TimeUtil
