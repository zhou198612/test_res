------------------- QuickOpenFuncUtil

local M = {}

local __funcs = {}

-- 前往衣柜
__funcs[1] = function(control, jump_id, params)
    control:openView("Clothes")
end

-- 前往许愿
__funcs[2] = function(control, jump_id, params)
    control:openView("Gacha", { entrance = 1 })
end

-- 前往回忆
__funcs[3] = function(control, jump_id, params)
    control:openView("StageList")
end

-- 男友互动
-- params 男友id
__funcs[4] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendTouchPop", {id = params})
end

-- 前往男友
__funcs[5] = function(control, jump_id, params)
    control:openView("GoodFeel")
end

-- 男友送礼
-- params 男友id
__funcs[6] = function(control, jump_id, params)
    control:openView("GoodFeel.BoyInteract", {id = params})
end

-- 前往七日签到(活动一)
__funcs[8] = function(control, jump_id, params)
    control:openView("Activity", {open_id = 33})
end

-- 前往主线任务
__funcs[9] = function(control, jump_id, params)
    control:openView("TaskInfo")
end

-- 前往闯关
__funcs[10] = function(control, jump_id, params)
    local id = params and params.stage_id
    local cfg = nil
    local stage_id = id or UserDataManager:getNextStageId()
    if type(id) == "table" then
        cfg = id
    else
        cfg = ConfigManager:getCfgByName("stage")[stage_id]
    end
    if cfg then
        local avg_id = cfg.pre_story
        if cfg.type == 1 then
            local story_id = cfg.pre_story
            local finish_click = function()
                local function callfunc(response)
                    control:updateMsg("open_func", nil, "parent")
                end
                control.m_model:getNetData("stage_action", {stage_id = stage_id, clothes = {}, story_id = story_id}, callfunc,false,nil, GlobalConfig.POST)
            end
            control:openView("Story", { id = story_id , finish_click = finish_click})
        else
            if id then  --有关卡id时不打开关卡详情直接进换装
                local finish_click = function()
                    control:openView("SelectClothes",{stage_id = stage_id, is_temp_stage = params.is_temp_stage, type = params.type, mask = params.mask})
                end
                if avg_id == 0 then
                    finish_click()
                else
                    control:openView("Story", { id = tonumber(avg_id), finish_click = finish_click})
                end
            else
                control:openView("StageInfo")
            end
        end
    end
end

-- 前往背包(上衣)
__funcs[11] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 1, cur_type = 1})
end

-- 前往背包(下衣)
__funcs[12] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 1, cur_type = 2})
end

-- 前往背包(鞋子)
__funcs[13] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 1, cur_type = 3})
end

-- 前往背包(耳环)
__funcs[15] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 2, cur_type = 1})
end

-- 前往背包(项链)
__funcs[16] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 2, cur_type = 2})
end

-- 前往背包(手链)
__funcs[17] = function(control, jump_id, params)
    if control.m_chilrenList.Package then
        return
    end
    control:openView("Package2", {plane = 2, cur_type = 3})
end

-- T台
__funcs[18] = function(control, jump_id, params)
    local arena_season = ConfigManager:getCfgByName("arena_season")
    local server_time = UserDataManager:getServerTime()
    local title = ""
    local open_date = nil
    local open_time = nil
    for i,v in ipairs(arena_season or {}) do
        start_time = TimeUtil.stringToTimestamp(v.start_time)
        show_time = TimeUtil.stringToTimestamp(v.show_time)
        if start_time <= server_time and show_time >= server_time then
            control:openView("TShow.TShowMain")
            return
        elseif start_time > server_time then
            if open_time == nil or open_time > start_time then
                open_time = start_time
                title = Language:getTextByKey(v.title)
                open_date = v.start_time
            end
        end
    end
    if open_date then
         GameUtil:lookInfoTips(static_rootControl, { msg = string.format(Language:getTextByKey("tshow_str_0025"),title ,open_date), delay_close = 2})
     else
         GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("tshow_str_0026"), delay_close = 2})
    end
end

-- T台商店
__funcs[19] = function(control, jump_id, params)
    control:openView("Shop", {type = 5})
end

-- 化妆
__funcs[20] = function(control, jump_id, params)
    control:openView("Face")
end

-- 前往理发
__funcs[21] = function(control, jump_id, params)
    control:openView("HairSalon")
end

-- 前往染发
__funcs[22] = function(control, jump_id, params)
    control:openView("HairSalon")
end

-- 前往许愿商店
__funcs[23] = function(control, jump_id, params)
    control:openView("Shop")
end

-- 前往和风许愿
__funcs[24] = function(control, jump_id, params)
    control:openView("Gacha", { entrance = 1, type = 3 })
end

-- 前往星光转盘
__funcs[25] = function(control, jump_id, params)
    control:openView("Compass")
end

-- 女神旅程
__funcs[27] = function(control, jump_id, params)
    local data = UserDataManager:getActivesByOpenId(56)
    if data then
        control:openView("Activity.SevenDayTrip")
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0539"), delay_close = 2})
    end
end

-- 等级礼包
__funcs[28] = function(control, jump_id, params)
    control:openView("Activity", {open_id = 33, tog_index = 34})
end

-- 心动福利
__funcs[29] = function(control, jump_id, params)
    control:openView("Activity", {open_id = 33, tog_index = 35})
end

-- 前往称号
__funcs[31] = function(control, jump_id, params)
    control:openView("Title")
end

-- 男友互动-男友1
__funcs[32] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendTouchPop", {id = 1})
end

-- 男友互动-男友2
__funcs[33] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendTouchPop", {id = 2})
end

-- 男友互动-男友3
__funcs[34] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendTouchPop", {id = 3})
end

-- 男友互动-男友4
__funcs[35] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendTouchPop", {id = 4})
end

-- 男友送礼-男友1
__funcs[36] = function(control, jump_id, params)
    control:openView("GoodFeel.BoyInteract", {id = 1})
end

-- 男友送礼-男友2
__funcs[37] = function(control, jump_id, params)
    control:openView("GoodFeel.BoyInteract", {id = 2})
end

-- 男友送礼-男友3
__funcs[38] = function(control, jump_id, params)
    control:openView("GoodFeel.BoyInteract", {id = 3})
end

-- 男友送礼-男友4
__funcs[39] = function(control, jump_id, params)
    control:openView("GoodFeel.BoyInteract", {id = 4})
end

-- 前往和风许愿商店
__funcs[40] = function(control, jump_id, params)
    control:openView("Shop", {type = 3})
end

-- 前往婚礼许愿
__funcs[41] = function(control, jump_id, params)
    control:openView("Gacha", { entrance = 1, type = 4 })
end

-- 前往婚礼许愿商店
__funcs[42] = function(control, jump_id, params)
    control:openView("Shop", {type = 4})
end

-- 前往星光许愿
__funcs[43] = function(control, jump_id, params)
    control:openView("Gacha", { entrance = 1, type = 2 })
end

-- 前往星光许愿商店
__funcs[44] = function(control, jump_id, params)
    control:openView("Shop", {type = 2})
end

-- 过关攻略
__funcs[45] = function(control, jump_id, params)
    local help_list = params.cfg.help
    local param = {list = help_list, img_title = "ui_gq_txt_title2", progress = params.progress}
    control:openView("SelectClothes.SelectClothesStrategy", param)
end

-- 图鉴
__funcs[47] = function(control, jump_id, params)
    control:openView("DesignList")
end

-- 累计充值
__funcs[48] = function(control, jump_id, params)
    control:openView("Activity", {open_id = 59, tog_index = 52})
end

-- 福利-月签
__funcs[49] = function(control, jump_id, params)
    control:openView("Activity", {open_id = 33, tog_index = 53})
end

-- 首充
__funcs[50] = function(control, jump_id, params)
    local data = UserDataManager:getActivesByOpenId(54)
    if data then
        control:openView("Activity.FirstCharge")
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0540"), delay_close = 2})
    end
end

-- 商城
__funcs[51] = function(control, jump_id, params)
    control:openView("Shop.ShoppingMall", params)
end

-- 新年7天活跃活动
__funcs[54] = function(control, jump_id, params)
    local data = UserDataManager:getActivesByOpenId(62)
    if data then
        control:openView("Activity.SevenDayNewyear")
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0539"), delay_close = 2})
    end
end

-- 特惠礼包活动获得
__funcs[55] = function(control, jump_id, params)
    local _, preference_gift = UserDataManager:splitPushGift()
    if next(preference_gift) ~= nil then
        control:openView("Activity.PreferenceGift")
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0539"), delay_close = 2})
    end
end

-- 新手礼包活动获得
__funcs[56] = function(control, jump_id, params)
    local data = UserDataManager:getActivesByOpenId(66)
    if data then
        control:openView("Activity", {open_id = 59, tog_index = 66})
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0539"), delay_close = 2})
    end
end

-- 限时礼包活动获得
__funcs[57] = function(control, jump_id, params)
    local push_gift = UserDataManager:splitPushGift()
    if next(push_gift) ~= nil then
        control:openView("Activity.PushGift")
    else
        GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0539"), delay_close = 2})
    end
end

-- 男友约会1
__funcs[58] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendInfo", {id= 1})
end

-- 男友约会2
__funcs[59] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendInfo", {id= 2})
end

-- 男友约会3
__funcs[60] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendInfo", {id= 3})
end

-- 男友约会4
__funcs[61] = function(control, jump_id, params)
    control:openView("GoodFeel.FriendInfo", {id= 4})
end

-- 男友约会
__funcs[62] = function(control, jump_id, params)
    control:openView("GoodFeel")
end

function M:openFunc(jump_id, params)
    jump_id = jump_id or {}
    if type(jump_id) == "number" then
        jump_id = {jump_id}
    end
    local func_id = jump_id[1]
    if func_id then
        local jump = ConfigManager:getCfgByName("jump")
        local jump_item = jump[func_id]
        if jump_item then
            local open_condition_id = jump_item.open_condition_id or 0
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
            if open_condition_id > 0 and not open_flag then
                GameUtil:lookInfoTips(static_rootControl, { msg = tips_str, delay_close = 2})
                return
            end
        end

	    local func = __funcs[func_id]
	    if func then
	        func(static_rootControl, jump_id, params)
	    else
	        Logger.logError("go to func id not found : " .. tostring(func_id))
	    end
	end
end

return M
