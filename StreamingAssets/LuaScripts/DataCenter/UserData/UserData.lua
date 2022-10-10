local M = {
    user_status = nil,
    old_level = nil,
    old_prestige = nil,
    old_idle_start_time = nil,
    rewards_cd = 0,
    idle_end_time = 0,
    merge_count = 0,
    merge_star = 0,
}

-- 设置玩家基本数据
function M:setUserData(data)
    if data == nil then
        return
    end
    self.user_status = data
    if self.old_level == nil then
        self.old_level = data.level
    end
    if self.old_prestige ~= data.star then
        self.old_prestige = data.star
        local idle_reward = ConfigManager:getCfgByName("idle_reward")
        local star = data.star or 0
        local index = table.bisect(idle_reward, "stars", star)
        self.rewards_cd = idle_reward[index].rewards_cd
    end
    if self.old_idle_start_time ~= data.idle_start_time then
        self.old_idle_start_time = data.idle_start_time
        if self.old_idle_start_time then
            self.idle_end_time = data.idle_start_time + self.rewards_cd
        end
    end
    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, { event = "user_status_update", data = data })
end

function M:getUid()
    if self.user_status and self.user_status.uid then
        return self.user_status.uid
    else
        return ""
    end
end

--[[--
	通过key获得用户基础数据
]]
function M:getUserStatusDataByKey(key)
    if key == "gold" then
        return self:idleEarningsCompute()
    end
    return self.user_status[key]
end

function M:getOldLv()
    return self.old_level, self.user_status.level
end

function M:updateOldLv()
    self.old_level = self.user_status.level
end

function M:getOwnRankData(data)
    local rank = data.rank or 0
    local score = data.score or 0
    local data = { rank = rank, score = score, time = 0 }
    local uid = self:getUserStatusDataByKey("uid")
    local name = self:getUserStatusDataByKey("name")
    local level = self:getUserStatusDataByKey("level")
    local vip = self:getUserStatusDataByKey("vip")
    local avatar = self:getUserStatusDataByKey("avatar")
    local frame = self:getUserStatusDataByKey("frame")
    data.user = { uid = uid, name = name, level = level, vip = vip, avatar = avatar, frame = frame }
    return data
end

function M:addIdleEndTime()
    self.idle_end_time = self.idle_end_time + self.rewards_cd
end

-- 挂机奖励公式
-- 每个间隔挂机奖励=(系数1*(系数2+星级)^2+系数3)*(1+男友挂机加成系数万分比/10000+背景挂机加成系数万分比/10000)/(24*3600)*奖励间隔
--function M:idleSliceEarningsCompute(cd)
--    local prestige = self:getUserStatusDataByKey("prestige")
--    local idle_reward = ConfigManager:getCfgByName("idle_reward")
--    local index = table.bisect(idle_reward, "stars", prestige)
--    local cfg = idle_reward[index]
--    local reward_cd = cfg.rewards_cd
--    if cd then
--        reward_cd = cd
--    end
--    local a = cfg.params[1]
--    local b = cfg.params[2]
--    local c = cfg.params[3]
--    local boyfriend_add = 0
--    local bg_add = UserDataManager:get_max_background_param()
--    local value = (a * (b + prestige) * (b + prestige) + c) * (1 + boyfriend_add / 10000 + bg_add / 10000) / 86400 * reward_cd
--    return value, cfg
--end

-- 每个间隔挂机奖励=(系数1*(系数2+等级)^2+系数3)/(24*3600)*奖励间隔
--function M:idleSliceEarningsCompute(cd)
--    local prestige = self:getUserStatusDataByKey("prestige")
--    local idle_reward = ConfigManager:getCfgByName("idle_reward")
--    local index = table.bisect(idle_reward, "stars", prestige)
--    local cfg = idle_reward[index]
--    local reward_cd = cfg.rewards_cd
--    if cd then
--        reward_cd = cd
--    end
--    local a = cfg.params[1]
--    local b = cfg.params[2]
--    local c = cfg.params[3]
--    local value = (a * (b + prestige) * (b + prestige) + c) / 86400 * reward_cd
--    return value, cfg
--end

-- 每秒挂机奖励 = 直接读表gold字段
function M:idleSliceEarningsCompute(cd)
    local star = self:getUserStatusDataByKey("star")
    local idle_reward = ConfigManager:getCfgByName("idle_reward")
    local index = table.bisect(idle_reward, "stars", star)
    local cfg = idle_reward[index]
    local reward_cd = cfg.rewards_cd
    if cd then
        reward_cd = cd
    end
    local value, unit = GameUtil:formatValue({cfg.gold[1], cfg.gold[2] * reward_cd})
    return value, cfg, unit
end

-- 玩家每次领取获取的挂机奖励=每个间隔挂机奖励*挂机时长/奖励间隔
function M:idleEarningsCompute()
    local server_time = UserDataManager:getServerTime()
    local gold = {}
    gold[2], gold[1] = GameUtil:formatValue(self.user_status["gold"])
    local idle_time = self:getUserStatusDataByKey("idle_start_time")
    local idle_slice_earnings, cfg, unit = self:idleSliceEarningsCompute()
    local num = math.floor((server_time - idle_time) / cfg.rewards_cd)
    local value, value_unit = GameUtil:formatValue({unit, idle_slice_earnings * num})
    if gold[1] == value_unit then
        gold[2], gold[1] = GameUtil:formatValue({value_unit, gold[2] + value})
    elseif gold[1] > value_unit then
        gold[2] = gold[2] + value/(1000 ^ (gold[1] - value_unit))
    elseif gold[1] < value_unit then
        gold[2] = gold[2] + gold[2]/(1000 ^ (value_unit - gold[1]))
    end
    return gold
end

return M