------------ DataUpdateHandlers
--[[
    方法名对应client_cache_update中的key
    数组的返回所有，字典的返回变化的数据
    值和数组直接替换数据
]]
local M = {}

-- 衣柜数据更新
function M.closet(udm, key, data)
    local clothes_data = udm.clothes_data
    local clothes = data.clothes
    local colors = data.colors
    if data.backgrounds then
        udm:setBackGround(data.backgrounds)
    end
    if data.wear_clothes then
        udm:updateWearClothes(data.wear_clothes)
    end
    if clothes then
        local update_data = clothes.update
        local remove_data = clothes.remove
        clothes_data:updateMoreClothesData(update_data)
        if #remove_data>0 then
            clothes_data:removeMoreClothesDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "clothes_update", data = clothes})
    end
    if colors then
        local update_data = colors.update
        local remove_data = colors.remove
        clothes_data:updateColorsData(update_data)
        if #remove_data>0 then
            clothes_data:removeColorsDataById(remove_data)
        end
    end
end

function M.closet_suit(udm, key, data)
    local award_suit = data.award_suit
    if award_suit then
        local update_data = award_suit.update
        local remove_data = award_suit.remove
        for k,v in pairs(update_data or {}) do
            udm.award_suit[k] = v
        end

        for k,v in pairs(remove_data or {}) do
            udm.award_suit[k] = nil
        end
    end
end

-- 关卡数据更新
function M.stage(udm, key, data)
    if data.stage_id then
        udm.stage_id = data.stage_id
    end
    if data.stage_clothes then
        udm.stage_clothes = data.stage_clothes
    end
    if data.promote_times then
        udm.promote_times = data.promote_times
    end
    local stage_stars = data.stage_stars
    local chapter_point = data.chapter_point
    local finish_gift = data.finish_gift
    if stage_stars then
        local update_data = stage_stars.update
        local remove_data = stage_stars.remove
        for k,v in pairs(update_data) do
            udm.m_stage_stars[k] = v
        end
        if #remove_data>0 then
            for k,v in pairs(remove_data) do
                udm.m_stage_stars[k] = nil
            end
        end
    end
    if chapter_point then
        local update_data = chapter_point.update
        local remove_data = chapter_point.remove
        for k,v in pairs(update_data) do
            udm.chapter_point[k] = v
        end
        if #remove_data>0 then
            for k,v in pairs(remove_data) do
                udm.chapter_point[k] = nil
            end
        end
    end
    if finish_gift then
        udm.finish_gift = finish_gift
    end
end

function M.package_task(udm, key, data)
    if data.merge_count then
        udm.merge_count = data.merge_count
    end
    if data.merge_star then
        udm.merge_star = data.merge_star
    end
    if data.merge_task and data.merge_task.update then
        for k, v in pairs(data.merge_task.update) do
            udm.merge_task_check[k] = v
        end
    end
end

function M.user(udm, key, data)
    if data.attr_random then
        udm.attr = data.attr_random
    end

    if data.hair_index then
        udm:initHairColor(data)
    end
    if data.partner then
        local update_data = data.partner.update
        local remove_data = data.partner.remove
        for k,v in pairs(update_data) do
            udm.partner[k] = v
        end
        if #remove_data>0 then
            for k,v in pairs(remove_data) do
                udm.partner[v] = nil
            end
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "partner_change"})
    end
end

function M.adv(udm, key, data)
    if data.adv_gold_max then
        udm.adv_gold_max = data.adv_gold_max
    end
    if data.adv_diamond_max then
        udm.adv_diamond_max = data.adv_diamond_max
    end
    if data.adv_times_today then
        udm.adv_times_today = data.adv_times_today
    end

    if data.add_clot_times_today then
        udm.add_clot_times_today = data.add_clot_times_today
    end

    if data.adv_closet_times_today then
        udm.adv_closet_times_today = data.adv_closet_times_today
    end

    
end

function M.title(udm, key, data)
    if data.title then
        udm.m_title = data.title    -- 当前的称号
    end
    if data.title_flags then
        udm:setTitles(data.title_flags)
    end
end

--道具数据更新
function M.item(udm, key, data)
    local item_data = udm.item_data
    local items = data.items
    if items then
        local update_data = items.update
        local remove_data = items.remove
        if next(update_data) then
            item_data:updateItem(update_data)
        end
        --todo
        if next(remove_data) then
            item_data:RemoveItem(remove_data)
        end
    end
end

--故事数据更新
function M.story(udm, key, data)
    local story_data = udm.story_data
    local storys = data.storys
    if storys then
        local update_data = storys.update
        local remove_data = storys.remove
        if next(update_data) then
            story_data:AddStory(update_data)
        end
    --todo
    --if next(remove_data) then
    --    story_data:RemoveItem(remove_data)
    --end
    end
end

--背包数据更新
function M.bag(udm, key, data)
    local package_data = udm.package_data
    local packages = data.packages
    local goods = data.goods
    local stars = data.stars
    local exp = data.exp
    if packages then
        local update_data = packages.update
        local remove_data = packages.remove
        if next(update_data) then
            package_data:UpdatePackageByPos(update_data)
        end
    end
    if goods then
        local update_data = goods.update
        local remove_data = goods.remove
        if next(update_data) then
            package_data:InitTimes(update_data)
        end
    end
    if stars then
        local update_data = stars.update
        local remove_data = stars.remove
        if next(update_data) then
            package_data:InitMaxLv(update_data)
        end
    end
    if exp then
        package_data:InitPackageExp(exp)
    end

    if data.add_clot_time then
        package_data.last_ad_slotTime = data.add_clot_time
    end

    if data.adv_closet_time then
        package_data.last_adv_clothTime = data.adv_closet_time
    end
end

--背包数据更新
function M.jewelry(udm, key, data)
    local package_data = udm.jewelry_data
    local packages = data.packages
    local goods = data.goods
    local stars = data.stars
    local exp = data.exp
    if packages then
        local update_data = packages.update
        local remove_data = packages.remove
        if next(update_data) then
            package_data:UpdatePackageByPos(update_data)
        end
    end
    if goods then
        local update_data = goods.update
        local remove_data = goods.remove
        if next(update_data) then
            package_data:InitTimes(update_data)
        end
    end
    if stars then
        local update_data = stars.update
        local remove_data = stars.remove
        if next(update_data) then
            package_data:InitMaxLv(update_data)
        end
    end
    if exp then
        package_data:InitPackageExp(exp)
    end

    if data.add_clot_time then
        package_data.last_ad_slotTime = data.add_clot_time
    end

    if data.adv_closet_time then
        package_data.last_adv_clothTime = data.adv_closet_time
    end
end

--任务数据跟新
function M.quest(udm, key, data)
    local quests = data.quests
    if quests then
        local update_data = quests.update
        local remove_data = quests.remove
        if table.nums(update_data) > 0 then
            for k, v in pairs(update_data) do
                if udm.task then
                    udm.task[k] = v
                else
                    Logger.logWarning("task ===== nil")
                end
            end
        end
        if table.nums(remove_data) > 0 then
            for k, v in pairs(remove_data) do
                udm.task[tostring(v)] = nil
            end
        end
    end
end

--红点数据跟新
function M.red_dot(udm, key, data) -- 红点
    local red_dot_data = data.red_dot
    if red_dot_data then
        local update_data = red_dot_data.update or {}
        table.merge(udm.red_dot, update_data)
        local remove_data = red_dot_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.red_dot[v] = nil
        end
        EventDispatcher:dipatchEvent(
            GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT,
            {event = "red_dot_update", data = red_dot_data}
        )
    end
end

function M.makeup(udm, key, data) --化妆
    local clothes_data = udm.clothes_data
    local gift_award = data.gift_award
    local look = data.look
    local max_look_count = data.max_look_count
    if look then
        clothes_data:updateFaceData(look)
    end
end

--推送礼包更新
function M.limit_push(udm, key, data)
    local push_gifts = data.push_gifts
    if push_gifts then
        local update_data = push_gifts.update
        local remove_data = push_gifts.remove
        if table.nums(update_data) > 0 then
            local limit_gift = ConfigManager:getCfgByName("limit_gift")
            for k, v in pairs(update_data) do
                if udm.m_push_gifts then
                    udm.m_push_gifts[k] = v
                end

                local cfg = limit_gift[tonumber(k)]
                if cfg.sort == 1 then
                    if cfg.ifjump and cfg.ifjump > 0 then
                        if udm.m_show_push_gift == nil then
                            udm.m_show_push_gift = k
                        end
                    else
                        udm.m_push_red[k] = 1
                    end
                else
                    if cfg.ifjump and cfg.ifjump > 0 then
                        if udm.m_show_Preference_gift == nil then
                            udm.m_show_Preference_gift = k
                        end
                    else
                        udm.m_Preference_red[k] = 1
                    end
                end
            end
        end
        if table.nums(remove_data) > 0 then
            for k, v in pairs(remove_data) do
                udm.m_push_gifts[tostring(v)] = nil
            end
        end
    end
end

--充值
function M.charge(udm, key, data)
    for k,v in pairs(data) do
        local charge_id = v.charge_id --charge_id
        local reward = v.reward --奖励
        local add_token = v.add_token --充值失败 0 或者没有当前字段 无需处理
        local state = true -- 成功
        if reward and next(reward) then
            RewardUtil:rewardTipsByData(reward)
        else
            if charge_id then
                if static_rootControl then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0533"), delay_close = 2})
                end
            elseif add_token and add_token == 1 then
                state = false
                if static_rootControl then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0534"), delay_close = 2})
                end
            end
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHARGE, {event = "charge", state = state})
    end
end

return M
