------------ UserDataManager

local DataUpdateHandlers = require("DataCenter.DataUpdateHandlers")

local M = {}
M.new_title = {}
M.new_background = {}

function M:init()
    self.local_data = require("DataCenter.UserData.LocalData")
    self.local_data:init()
    self.client_data = require("DataCenter.UserData.ClientData")
    self.server_data = require("DataCenter.UserData.ServerData")
    self.user_data = require("DataCenter.UserData.UserData")
    self.guide_data = require("DataCenter.UserData.GuideData")
    self.clothes_data = require("DataCenter.UserData.ClothesData")
    self.item_data = require("DataCenter.UserData.ItemData")
    self.story_data = require("DataCenter.UserData.StoryData")
    self.package_data = require("DataCenter.UserData.PackageData")
    self.jewelry_data = require("DataCenter.UserData.JewelryData")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, { self, self.netDataUpdateEvent })
    self.timezone = 0 -- 时区
    self.reg_ts = 0  -- 注册时间(时间戳)
    self.end_ts = 0 -- 今日结束时间
    self.guide = {} -- 新手引导数据
    self.is_first_name = 0 -- 是否第一次起名 0 未起名 1 起名
    self.indulge_level = 0 -- 沉迷级别 1.成年 2.16周岁以上未满18周岁的用户 3.8周岁以上未满16周岁 4.不满8周岁
    self.red_dot = {} -- 红点数据
    self.questions = {} -- [问卷id]
    self.role = 0 --  角色
    self.background = 0 -- 背景
    self.backgrounds = {} -- 所有背景
    self.wear_clothes = {} -- 服饰
    self.last_request_time = 0
    self.server_time = 0
    self.m_ap = 0 --体力
    self.m_coin = 0 --金币
    self.m_diamond = 0 --声望
    self.m_title = 0 -- 当前的称号
    self.m_titles = {} -- 拥有的称号
    self.m_offline_reward = {} -- 离线奖励
    self.offline_ts = 0 -- 离线时长
    self.m_stage_stars = {} -- 关卡累计星星
    self.certification = 0 --0:需要实名认证
    self.merge_star = 0
    self.merge_count = 0
    self.merge_task_check = {}
    self.award_suit = {} -- 已领取的套装收集奖励
    self.adv_times_today = 0
    self.partner = {} -- 男友陪伴
    self.m_actives = {} --开启的活动
    self.m_push_gifts = {} --推送礼包
    self.m_push_red = {} -- 限时礼包红点
    self.m_Preference_red = {} -- 特惠礼包红点
end

function M:initOhterData()

end

--[[--
   缓存更新
]]
function M:clientCacheUpdate(jsonData)
    if jsonData == nil then
        return
    end
    for k, v in pairs(jsonData) do
        if DataUpdateHandlers[k] then
            DataUpdateHandlers[k](self, k, v)
        else
            Logger.log("update handler not found, key is : " .. tostring(k))
        end
    end
end

function M:netDataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "net_data_back" then
        Logger.log(data, "netDataUpdateEvent ==== ")
        self:responseGameData(data.data)
    elseif curEvent == "net_data_sync" then

    end
end

function M:responseGameData(data)
    self:setLastRequestTime()
    self:setServerTime(data.server_time)
    self:clientCacheUpdate(data.client_cache_update)
    self:clientCacheUpdate(data.client_cache_update2)
    self.user_data:setUserData(data.user_status)

    --跟新关卡和玩家数据后再刷新故事数据
    if data.client_cache_update then
        if not data.client_cache_update.story then
            self.story_data:AddStory()
        end
    end
end

function M:setLastRequestTime()
    self.last_request_time = TimeUtil.getUTCTime()
end

function M:getLastRequestTime()
    return self.last_request_time
end

function M:setServerTime(server_time)
    self.server_time = server_time or 0
end

function M:getServerTime()
    local server_time = self.server_time + self:getTimeDifference()
    return server_time
end

--[[--
   获得时间差
]]
function M:getTimeDifference(time)
    time = time or self:getLastRequestTime()
    return TimeUtil.getUTCTime() - time
end

function M:getTimeZone()
    return self.timezone or 0
end

--[[--
   更新user.game_info接口数据
]]
function M:updateUserGameInfo(data)
    if data == nil then
        return
    end
    
    self.clothes_data:initClothesData(data.clothes)
    self.clothes_data:updateFaceData(data.makeup_look)
    self.clothes_data:updateColorsData(data.colors)
    self.item_data:updateItem(data.items)

    local bag = data.bag
    self.package_data:UpdatePackageByPos(bag.packages)
    self.package_data:InitTimes(bag.goods)
    self.package_data:InitMaxLv(bag.stars)
    self.package_data:InitPackageExp(bag.exp)
    self.package_data.last_ad_slotTime = bag.add_clot_time

    local jewelrys = data.jewelrys
    self.jewelry_data:UpdatePackageByPos(jewelrys.packages)
    self.jewelry_data:InitTimes(jewelrys.goods)
    self.jewelry_data:InitMaxLv(jewelrys.stars)
    self.jewelry_data:InitPackageExp(jewelrys.exp)
    self.package_data.last_ad_slotTime = jewelrys.add_clot_time

    self.stage_id = data.stage_id
    self.stage_clothes = data.stage_clothes
    self.chapter_over = data.chapter_over
    self.timezone = data.timezone or 0
    self.end_ts = data.end_ts
    self.reg_ts = data.reg_ts
    self.guide = data.guide or {}
    self.is_first_name = data.is_first_name or 0
    self.red_dot = data.red_dot or {}
    self.questions = data.questions or {}
    self.role = data.role --  角色
    self.background = data.background -- 背景
    self.backgrounds = data.backgrounds -- 背景
    self.wear_clothes = data.wear_clothes -- 服饰
    self.m_stage_stars = data.stage_stars --累计关卡星星
    self.m_ap = data.ap --体力
    self.m_coin = data.coin --金币
    self.m_xingguangbi_coin = data.coin2 --星光币
    self.m_diamond = data.diamond --声望
    self.m_title = data.title -- 当前的称号
    self.m_titles = data.title_flags -- 拥有的称号
    self.m_offline_reward = data.offline_reward or {} -- 离线奖励
    self.offline_ts = data.offline_ts or 0 -- 离线时长
    self.attr = data.attr_random or {} --角色属性
    self.task = data.main_quests.quests or {} -- 任务
    self.cur_task_id = 0
    self.story_data:updateStory(data.storys)

    self.merge_task_check = data.merge_task
    self.merge_star = data.merge_star
    self.merge_count = data.merge_count

    self.chapter_point = data.chapter_point
    self.finish_gift = data.finish_gift
    self.award_suit = data.award_suit -- 已领取的套装收集奖励
    self.adv_times_today = data.adv_times_today or 0--# 今日观看广告的次数

    self.adv_diamond_max = data.adv_diamond_max or 0 --# 每天看广告补钻石最大次数
    self.adv_gold_max = data.adv_gold_max or 0 --# 每天看广告补金币最大次数
    self.add_clot_times_today = data.add_clot_times_today or 0   --# 今日观看广告护充格子的次数
    self.adv_closet_times_today = data.adv_closet_times_today or 0     --# 背包看广告买衣服的每日次数

    self.promote_times = data.promote_times or 0 --提升途径提示小弹窗弹出次数
    self:initHairColor(data)
    self:initStageStar(data.stage_stars)
    self.partner = data.partner or {}
    self.m_push_gifts = data.push_gifts or {} -- 推送礼包
    Logger.log(self.m_push_gifts,"m_push_gift ====")

    -- self.package_reward_check = {}----已领取背包奖励
    self.guide_data:init()
    self.guide_data:resetCurGuide()
end

function M:initStageStar(stage_stars)
    self.chapter_stars = {}
    local chapter_cfg = ConfigManager:getCfgByName("stage")
    for k, v in pairs(stage_stars) do
        local cfg = chapter_cfg[tonumber(k)]
        if cfg == nil then
            --Logger.log(k,"kkkkkkkkkkkkkk")
        else
            self.chapter_stars[cfg.chapter_id] = (self.chapter_stars[cfg.chapter_id] or 0) + v
        end
    end
end

function M:initHairColor(data)
    self.color_sel = { [tostring(self.wear_clothes["1"])] = data.hair_index}
end

function M:getCurStage()
    local stage_id = self.stage_id or 0
    return stage_id
end

--获取下一关id
function M:getNextStageId()
    if self.stage_id == 0 then
        return 1
    else
        local last_cfg = ConfigManager:getStageCfgById(self.stage_id)
        return last_cfg.next
    end
end

function M:getBattleStage()
    local battle_stage = self.stage_id or 0
    if not self.chapter_over then
        local stage = ConfigManager:getCfgByName("stage")
        local stage_item = stage[battle_stage]
        if stage_item ~= nil then
            local next_stage = stage_item.next_stage
            battle_stage = stage[next_stage] ~= nil and next_stage or battle_stage
        else
            Logger.logError(battle_stage, "battle_stage id not found : ")
        end
    end
    return battle_stage
end

function M:getChapterOver()
    return self.chapter_over
end

function M:delete()
    if self.local_data then
        self.local_data:delete()
        self.local_data = nil
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, { self, self.netDataUpdateEvent })
end

--[[
	cfg_atttrs: 配置属性格式{{901,14}}
	all_attrs: kv格式{hp = 1,atk = 1}
]]
function M:appendAttrs(cfg_atttrs, all_attrs)
    all_attrs = all_attrs or {}
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    for k, v in pairs(cfg_atttrs) do
        local hero_enumeration_item = hero_enumeration[v[1]]
        if hero_enumeration_item then
            if hero_enumeration_item.is_percent and hero_enumeration_item.is_percent == 1 then
                all_attrs[hero_enumeration_item.user_key] = v[2] * 100 + (all_attrs[hero_enumeration_item.user_key] or 0)
            else
                all_attrs[hero_enumeration_item.user_key] = v[2] + (all_attrs[hero_enumeration_item.user_key] or 0)
            end
        end
    end
    return all_attrs
end

--[[
	-- {[id] = value}
]]
function M:appendCfgAttrs(cfg_atttrs, all_attrs)
    all_attrs = all_attrs or {}
    for k, v in pairs(cfg_atttrs) do
        all_attrs[v[1]] = (all_attrs[v[1]] or 0) + v[2]
    end
    return all_attrs
end

function M:setQuickIdleTimes(data)
    self.quick_idle_times = data.quick_idle_times
end

function M:getGuide()
    return self.guide
end

function M:getIsFirstName()
    return self.is_first_name
end

function M:setIsFirstName(value)
    self.is_first_name = value or 0
end

--[[--
	红点数据
]]
function M:getRedDotByKey(key)
    local red_dot = self.red_dot or {}
    local dot_data = red_dot[key]
    if dot_data then
        if dot_data.start_ts and dot_data.start_ts < self:getServerTime() then
            dot_data.status = 1
        end
        return dot_data.status
    else
        return 0
    end
end

function M:setTitle(data)
    if data then
        self.m_title = data
    end
end

--更新穿戴的服装
function M:updateWearClothes(data)
    local update_data = data.update
    local remove_data = data.remove
    if next(remove_data) ~= nil then
        for _, v in pairs(remove_data) do
            self.wear_clothes[tostring(v)] = nil
        end
    end
    if next(update_data) ~= nil then
        for k, v in pairs(update_data) do
            self.wear_clothes[k] = v
        end
    end
end

-- 更新称号
function M:setTitles(data)
    if data then
        local update_data = data.update
        local remove_data = data.remove
        if next(remove_data) ~= nil then
            for _, v in pairs(remove_data) do
                self.m_titles[tostring(v)] = nil
            end
        end
        if next(update_data) ~= nil then
            for k, v in pairs(update_data) do
                local flag = false
                local value = tonumber(k)
                for kk, vv in pairs(self.m_titles) do
                    if tonumber(kk) == value then
                        flag = true
                        break
                    end
                end
                if not flag then
                    table.insert(self.new_title, value)
                end
            end
            for k, v in pairs(update_data) do
                self.m_titles[k] = v
            end
        end
    end
end

-- 更新背景
function M:setBackGround(data)
    if data then
        for i, v in ipairs(data) do
            local index = table.keyof(self.backgrounds, v)
            if not index then
                table.insert(self.new_background, v)
            end
        end
        self.backgrounds = data
    end
end

--最大挂机加成参数
function M:get_max_background_param()
    local max_param = 0
    for k, v in pairs(self.backgrounds) do
        local cfg = ConfigManager:getCfgByName("home_background")[v]
        if cfg.param > max_param then
            max_param = cfg.param
        end
    end
    return max_param
end

-- 获取新称号
function M:getNewTitle()
    local title = nil
    if #self.new_title > 0 then
        title = self.new_title[1]
        table.remove(self.new_title, 1)
    end
    return title
end

-- 获取新背景
function M:getNewBackGround()
    local background = nil
    if #self.new_background > 0 then
        background = self.new_background[1]
        table.remove(self.new_background, 1)
    end
    return background
end

-- 是否以获得称号
function M:isTitleHasbeen(id)
    id = tostring(id)
    local has = false
    if self.m_titles[id] then
        has = true
    end
    return has
end

-- 是否新称号
function M:isNewTitle(id)
    id = tostring(id)
    local new = false
    if self.m_titles[id] then
        new = self.m_titles[id] == 1
    end
    return new
end

--累计星星
function M:getAccruingStar()
    local num = 0
    for k, v in pairs(self.m_stage_stars) do
        num = num + v
    end
    return num
end

function M:getCurBackGround()
    local tab = ConfigManager:getCfgByName("home_background")
    local cfg = tab[self.background] or tab[1]
    return cfg.bg
end

function M:getCurTask()
    local id = nil
    for k, v in pairs(self.task) do
        id = tonumber(k)
        local task_cfg = ConfigManager:getCfgByName("task")[id]
        if task_cfg then
            if v.status == 1 then
                self.cur_task_id = task_cfg.pre_id --id
            else
                self.cur_task_id = task_cfg.pre_id
            end
        else
            self.cur_task_id = nil
        end
    end
    if next(self.task) == nil then
        local task_cfg = ConfigManager:getCfgByName("task")
        local star = self.user_data:getUserStatusDataByKey("star")
        if star > 0 then
            self.cur_task_id = table.nums(task_cfg)
        end
    end
    return id, self.task[tostring(id)]
end

function M:getSuitAwardById(suit_id)
    suit_id = tostring(suit_id)
    return self.award_suit[suit_id]
end

function M:getActivesByOpenId(id)
    local active_tab = ConfigManager:getCfgByName("active")
    for i,v in ipairs(self.m_actives or {}) do
        local m_a_cfg = active_tab[v.id]
        if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
            return true
        end
    end
    return false
end

function M:getActivesDataByOpenId(id)
    local active_tab = ConfigManager:getCfgByName("active")
    for i,v in ipairs(self.m_actives or {}) do
        local m_a_cfg = active_tab[v.id]
        if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
            return v
        end
    end
    return nil
end

function M:getActivesRechargeByOpenId(id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for i,v in ipairs(self.m_active_recharge or {}) do
        local m_a_cfg = active_tab[v.id]
        if m_a_cfg and m_a_cfg.open_id == id and v.open_status > 0 then
            return true
        end
    end
    return false
end

function M:getAvatars()
    return self.avatars or {}
end

-- 移除超时礼包
function M:pushGiftTimeOut()
    local server_time = self:getServerTime()
    local remove_list = {}
    for k,v in pairs(self.m_push_gifts) do
        if server_time >= v then
            table.insert(remove_list, k)
        end
    end
    for k,v in pairs(remove_list) do
        self.m_push_gifts[v] = nil
    end
end

-- 拆分限时和特惠礼包
function M:splitPushGift()
    local push_gift = {}
    local preference_gift = {}
    local limit_gift = ConfigManager:getCfgByName("limit_gift")
    for k,v in pairs(self.m_push_gifts) do
        local cfg = limit_gift[tonumber(k)]
        if cfg then
            if cfg.sort == 1 then
                push_gift[k] = v
            elseif cfg.sort == 2 then
                preference_gift[k] = v
            end
        end
    end
    return push_gift, preference_gift
end

-- 移除问卷
function M:questionTimeOut()
    local server_time = self:getServerTime()
    local remove_list = {}
    for k,v in pairs(self.questions) do
        if server_time >= v.end_ts then
            table.insert(remove_list, k)
        end
    end
    for k,v in pairs(remove_list) do
        self.questions[v] = nil
    end
end

function M:setNewBieActivityShow()
    local flag_stage = ConfigManager:getCommonValueById(128)
    local cur_stage_id = self:getCurStage()
    if flag_stage == cur_stage_id then
        self.show_newbie_activity = true
    end
end

function M:setFirstChargeActivityShow()
    local flag_stage = ConfigManager:getCommonValueById(129)
    local cur_lv = self.user_data:getUserStatusDataByKey("star")
    if flag_stage == cur_lv then
        self.show_firstCharge_activity = true
    end
end

return M