------------------- RedPointUtil

local M = {}

local __red_point = {}

--主页抽卡
__red_point[1] = function()
	local red_flag = false
	local gacha_status = UserDataManager:getRedDotByKey("gacha") -- 抽卡
	red_flag = gacha_status == 1
	return red_flag
end

--主页签到
__red_point[2] = function()
	local red_flag = false
	local sign_week = UserDataManager:getRedDotByKey("sign_week") -- 签到
	red_flag = sign_week == 1
	return red_flag
end

-- 男友
__red_point[3] = function()
	local red_flag = false
	local boyfriend_open = UserDataManager:getRedDotByKey("boyfriend_open")
	red_flag = boyfriend_open == 1
	if red_flag == false then
		local boyfriend = UserDataManager:getRedDotByKey("boyfriend")
		red_flag = boyfriend == 1
	end
	return red_flag
end

-- 男友故事
__red_point[301] = function(params)
	local red_flag = false
	for k,v in pairs(params.story or {}) do
		if v == 1 or v == 2 then
			red_flag = true
			break
		end
	end
	
	return red_flag
end

-- 理发店
__red_point[4] = function()
	local red_flag = false
	local salon = UserDataManager:getRedDotByKey("salon")
	red_flag = salon == 1
	return red_flag
end

-- 梦幻摩天轮
__red_point[5] = function()
	local red_flag = false
	local roulette = UserDataManager:getRedDotByKey("roulette")
	red_flag = roulette == 1
	return red_flag
end

-- 制作衣服
__red_point[6] = function()
	local red_flag = false
	local package = UserDataManager:getRedDotByKey("package")
	red_flag = package == 1
	return red_flag
end

-- 商业街
__red_point[7] = function()
	local red_flag = false
	return red_flag
end

-- 称号
__red_point[8] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("user_title")
	red_flag = status == 1
	return red_flag
end

-- 图鉴
__red_point[9] = function()
	local red_flag = false
	--local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
	--for i,v in ipairs(clothes_suit or {}) do
	--	if not UserDataManager:getSuitAwardById(i) then
	--		local params = UserDataManager.clothes_data:clothesSuitCollectById(i)
	--		if params.collect_num >= params.total_num then
	--			red_flag = true
	--			break
	--		end
	--	end
	--end
	local closet_suit = UserDataManager:getRedDotByKey("closet_suit")
	red_flag = closet_suit == 1
	return red_flag
end

-- 闯关
__red_point[10] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("stage")
	red_flag = status == 1
	return red_flag
end

-- 等级礼包
__red_point[11] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("level_gift")
	red_flag = status == 1
	return red_flag
end

-- 心动福利
__red_point[12] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("adv_award")
	red_flag = status == 1
	return red_flag
end

-- 累计充值
__red_point[13] = function()
	local red_flag = false
	local status1 = UserDataManager:getRedDotByKey("total_charge")
	local status2 = UserDataManager:getRedDotByKey("once_total_charge")
	red_flag = status1 == 1 or status2 == 1
	return red_flag
end

-- 30天签到
__red_point[14] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("sign_month")
	red_flag = status == 1
	return red_flag
end

-- 首充
__red_point[15] = function()
	local red_flag = false
	local status1 = UserDataManager:getRedDotByKey("first_payment")
	local status2 = UserDataManager:getRedDotByKey("once_first_payment")
	red_flag = status1 == 1 or status2 == 1
	return red_flag
end

-- 女神旅程
__red_point[16] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("quest_recruit")
	red_flag = status == 1
	return red_flag
end

-- T台
__red_point[17] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("arena")
	red_flag = status == 1
	return red_flag
end

-- 化妆
__red_point[18] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("makeup")
	red_flag = status == 1
	return red_flag
end

-- 约会
__red_point[19] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("")
	red_flag = status == 1
	return red_flag
end

-- 节日七天活动（新年）
__red_point[20] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("quest_festival")
	red_flag = status == 1
	return red_flag
end

-- 新手礼包
__red_point[21] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("gift_new")
	red_flag = status == 1
	return red_flag
end

-- 邮件
__red_point[22] = function()
	local red_flag = false
	local status = UserDataManager:getRedDotByKey("mail")
	red_flag = status == 1
	return red_flag
end

--- 是否有小红点
function M:hasRedPointById(red_point_id, params)
	local func = __red_point[red_point_id or -1]
	if func then
		return func(params)
	end
	return false
end

--- 是否有小红点
function M:isFuncRedPointById(button_id)
    local cfg = BtnOpenUtil:getBtnCfg(button_id)
	if cfg == nil then return end
	local buttons = cfg.buttons or {}
	local open_flag = BtnOpenUtil:isBtnOpen(button_id, cfg)
	if open_flag then
		if #buttons > 0 then
			for i, v in ipairs(buttons) do
				if self:isFuncRedPointById(v) then
					return true
				end
			end
		end
		return self:hasRedPointById(cfg.red_point)
	else
		return false
	end
end

function M:localRedPointJudge(key)
	if key == nil then
		return false
	end
	local fresh_time = UserDataManager.local_data:getUserDataByKey(key, 0)
	local server_time = UserDataManager:getServerTime()
	if server_time >= fresh_time then
		return true
	end
	return false
end

function M:saveLocalRedPointFreshTime(key)
	if key == nil then
		return
	end
	local fresh_time = UserDataManager.local_data:getUserDataByKey(key, 0)
	local server_time = UserDataManager:getServerTime()
	if server_time >= fresh_time then
		local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
		UserDataManager.local_data:setUserDataByKey(key, next_fresh_time + 86400)
	end
end

return M
