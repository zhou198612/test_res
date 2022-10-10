------------------- RewardUtil

local M = {}

local REWARD_TYPE_KEYS = {
	DIAMOND = 1, --钻石
	AP = 2, -- 体力
	GOLD = 3, --金币
	REPUTATION_COIN = 4, --美誉
	FASHION_COIN = 5, -- 时尚币
	CLOTHES = 8, -- 服饰 [服饰id]
	RECHARGE_DIAMOND = 1001,--充值钻石
	GIFT_SORT_BACKGROUND = 9, --背景 
	ITEM = 10, --道具
	WISH_COIN = 11, --星光珠宝
	WISH_COIN2 = 12, --铃铛
	BOYFRIEND = 13, -- 男友
	BOYFRIEND_SKIN = 14, -- 男友皮肤
	BOYFRIEND_LOVE = 15, -- 男友好感度
	HAIRCUT_COIN = 16, -- 理发卷
	ATTR = 17, --角色属性
	PRESTIGE = 18, --角色声望
	COIN2 = 21, --梦幻币
	GACHA_CARD1 = 27, --星光许愿券
	GACHA_CARD2 = 28, --和风许愿券
	GACHA_CARD3 = 29, --婚礼许愿券
	WISH_COIN3 = 30, --爱意玫瑰
	RANFAJI_COIN = 31, --染发剂
	SIGN_CARD = 35, -- 补签卡
	REFRESH_COIN = 33, --刷新券
	GOLD_BAG = 32, --金币礼包
	HAIRCUT_SAFETY_COIN = 36, -- 专属美发币
	SUIT = 37, -- 套装
}

M.REWARD_TYPE_KEYS = REWARD_TYPE_KEYS

--[[
    处理数据  
    @param data 通用数据格式 [类型,id,数量]
]]
function M:getProcessRewardData(data)
    data = data or {}
    local data_type, data_id, data_num = data[1] or -1, data[2] or -1, data[3] or 0
    local item_data = {
        name = "???",
        icon_name = "item_icon_wenhao",
        quality = 0,
        user_num = 0,
        story = "???",
        is_piece = false, --用于道具角标
        data_type = data_type,
        data_id = data_id,
        data_num = data_num,
        atlas_name = "item_icon",
    }
    local user_num = 0
    local item_cfg = nil
    local money_guide = ConfigManager:getCfgByName("money_guide")
    local info = money_guide[data_type] or {}
    local oid = data.oid
    if info.itype == 1 then--货币类型
		if data_type == REWARD_TYPE_KEYS.COIN2 then
			user_num = UserDataManager.user_data:getUserStatusDataByKey("coin2")
		else
			user_num = UserDataManager.user_data:getUserStatusDataByKey(info.user_key) or 0
		end
		if data_type == REWARD_TYPE_KEYS.WISH_COIN or data_type == REWARD_TYPE_KEYS.WISH_COIN2 or data_type == REWARD_TYPE_KEYS.WISH_COIN3
		or data_type == REWARD_TYPE_KEYS.GACHA_CARD1 or  data_type == REWARD_TYPE_KEYS.GACHA_CARD2 or data_type == REWARD_TYPE_KEYS.GACHA_CARD3
		or data_type == REWARD_TYPE_KEYS.GOLD_BAG then
			item_data.atlas_name = ResourceUtil:getLanAtlas()
		end
		self:setDataByCfg(item_data, info)
    elseif info.itype == 2 then
		if data_type == REWARD_TYPE_KEYS.CLOTHES then   -- 服饰
			local data = nil
			data, item_cfg = UserDataManager.clothes_data:getClothesDataById(data_id)
			if item_cfg then
				self:setDataByCfg(item_data, item_cfg)
				item_data.icon_name = item_cfg.icon
				item_data.quality = item_cfg.quality or 0
				item_data.atlas_name = "clothes_icon"
			end
			user_num = data
			--if item_data.is_piece then
			--	item_data.atlas_name = "hero_head_ui"
			--end
		elseif data_type == REWARD_TYPE_KEYS.SUIT then -- 套装
			local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
			item_cfg = clothes_suit[data_id]
			self:setDataByCfg(item_data, item_cfg)
			item_data.quality = item_cfg.quality or 0
			item_data.atlas_name = "clothes_icon"
		elseif data_type == REWARD_TYPE_KEYS.GIFT_SORT_BACKGROUND then -- 背景
			local home_background = ConfigManager:getCfgByName("home_background")
			item_cfg = home_background[data_id]
			self:setDataByCfg(item_data, item_cfg)
			item_data.quality = item_cfg.quality or 0
			item_data.atlas_name = "bg_icon"
		elseif data_type == REWARD_TYPE_KEYS.BOYFRIEND then -- 男友
			local boyfriend = ConfigManager:getCfgByName("boyfriend")
			item_cfg = boyfriend[data_id]
			self:setDataByCfg(item_data, item_cfg)
			item_data.quality = item_cfg.quality or 0
		elseif data_type == REWARD_TYPE_KEYS.BOYFRIEND_SKIN then -- 男友皮肤
			local boyfriend_skin = ConfigManager:getCfgByName("boyfriend_skin")
			item_cfg = boyfriend_skin[data_id]
			self:setDataByCfg(item_data, item_cfg)
			item_data.quality = item_cfg.quality or 0
		elseif data_type == REWARD_TYPE_KEYS.ITEM then
			local item_cfg = UserDataManager.item_data:getItemCfgById(data_id)
			item_data.quality = item_cfg.quality or 0
			self:setDataByCfg(item_data, item_cfg)
			item_data.atlas_name = "item_icon"
			user_num = UserDataManager.item_data:GetNumById(data_id)
        end
    end
    item_data.user_num = user_num
    item_data.item_cfg = item_cfg or info
    item_data.oid = oid
    item_data.quality = data.quality or item_data.quality
    return item_data
end

function M:setDataByCfg(item_data, item_cfg)
	if item_cfg then
	    item_data.name = Language:getTextByKey(item_cfg.name)
	    item_data.icon_name = item_cfg.icon
	    item_data.story = Language:getTextByKey(item_cfg.story or item_cfg.des)
	end
end

--[[
	合并后端奖励
]]
function M:mergeRewardAndFormat(normal_reward, extra_reward)
	if not normal_reward and not extra_reward then
		return {}
	end
	local rewards = {}
	self:processReward(rewards, normal_reward, false)
	if extra_reward then 
		self:processReward(rewards, extra_reward, true)
	end
	return rewards
end

function M:processReward(rewards, reward, is_extra_reward)
	for k,v in pairs(reward) do
		local key = string.upper(k)
		local key_value = REWARD_TYPE_KEYS[key]
		if key_value == REWARD_TYPE_KEYS.CLOTHES then
			for i,id in ipairs(v) do
				--local clothes_data = UserDataManager.clothes_data:getClothesDataById(id)
				rewards[#rewards + 1] = {key_value, id, 1, oid = id, is_extra_reward = is_extra_reward}
			end
		elseif key_value ~= nil then
			if type(v) == "table" then
				if key_value == REWARD_TYPE_KEYS.GOLD then
					rewards[#rewards + 1] = {key_value,v[1],v[2], is_extra_reward = is_extra_reward}
				elseif key_value == REWARD_TYPE_KEYS.GIFT_SORT_BACKGROUND then
					for k,v in pairs(v) do
						rewards[#rewards + 1] = {key_value,v,1, is_extra_reward = is_extra_reward}
					end
				else
					for k,v in pairs(v) do
						rewards[#rewards + 1] = {key_value,tonumber(k),v, is_extra_reward = is_extra_reward}
					end
				end
			else
				rewards[#rewards + 1] = {key_value,0,v, is_extra_reward = is_extra_reward}
			end
		else
			Logger.logError("not reward key : " .. k)
		end
	end
end

--[[
	通用奖励
]]
function M:rewardTipsByData(normal_reward, extra_reward, call_back)
	local rewards = self:mergeRewardAndFormat( normal_reward, extra_reward )
	return self:rewardTipsByRewards( rewards, call_back)
end

--[[ 
    通用数据格式 [类型,id,数量]
]]
function M:mergeCfgReward(rewards, add_reward)
	for i,v in ipairs(add_reward) do
		local is_new = true
		for ii,vv in ipairs(rewards) do
			if v[1] == vv[1] then
				vv[3] = vv[3] + v[3]
				is_new = false
				break 
			end
		end
		if is_new then
			rewards[#rewards + 1] = table.copy(v)
		end
	end
end

--- 通过奖励表展示奖励提示
function M:rewardTipsByRewards(rewards, call_back)
	rewards = rewards or {}
	local index = 1
	local new_reward_indexs = {}
	local function doNextRewardAnim()
		if index > #rewards then
			local reward_count = #rewards
			local show_data = {}
			for i=1,reward_count do
				local item_reward = rewards[i]
				-- if item_reward[1] ~= REWARD_TYPE_KEYS.HEROS then
				if new_reward_indexs[i] == nil then
					table.insert(show_data, item_reward)
				end
			end
			-- TODO:添加通用奖励弹出框
			static_rootControl:openView("Pops.CommonRewardPop", {reward = show_data, callback = call_back})
		else		
			local item_reward = rewards[index] or {}
			index = index + 1
			if item_reward[1] == REWARD_TYPE_KEYS.HEROS then-- 单独展示
				if UserDataManager.hero_data:isNewHero(item_reward[2]) then
					UserDataManager.hero_data:removeNewHero(item_reward[2])
					new_reward_indexs[index-1] = item_reward
					static_rootControl:openView("HeroInfo.HeroNewPop", {hero_id = item_reward[2], is_new = true, callback = doNextRewardAnim})
				 else
					doNextRewardAnim()
				end
			else
				doNextRewardAnim()
			end
		end
	end
	doNextRewardAnim()
end

--[[
	剧情奖励
]]
function M:avgRewardTipsByData(normal_reward, extra_reward, call_back, delay)
	local rewards = self:mergeRewardAndFormat( normal_reward, extra_reward )
	return self:avgRewardTipsByRewards( rewards, call_back, delay)
end

--- 通过奖励表展示奖励提示
function M:avgRewardTipsByRewards(rewards, call_back, delay)
	rewards = rewards or {}
	local index = 1
	local new_reward_indexs = {}
	local function doNextRewardAnim()
		if index > #rewards then
			local reward_count = #rewards
			local show_data = {}
			for i=1,reward_count do
				local item_reward = rewards[i]
				-- if item_reward[1] ~= REWARD_TYPE_KEYS.HEROS then
				if new_reward_indexs[i] == nil then
					table.insert(show_data, item_reward)
				end
			end
			if #show_data > 0 then
				-- TODO:添加通用奖励弹出框
				static_rootControl:openView("Pops.StoryRewardPop", {reward = show_data, callback = call_back})
			else
				if call_back then
					call_back()
				end
			end
		else
			local item_reward = rewards[index] or {}
			index = index + 1
			if item_reward[1] == REWARD_TYPE_KEYS.ATTR then-- 属性单独展示
				if UserDataManager.hero_data:isNewHero(item_reward[2]) then
					UserDataManager.hero_data:removeNewHero(item_reward[2])
					new_reward_indexs[index-1] = item_reward
					static_rootControl:openView("HeroInfo.HeroNewPop", {hero_id = item_reward[2], is_new = true, callback = doNextRewardAnim})
				else
					doNextRewardAnim()
				end
			else
				doNextRewardAnim()
			end
		end
	end
	doNextRewardAnim()
end

return M
