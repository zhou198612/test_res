------------ ConfigManager
local M = {}

function M:init()
	local config_path = GlobalConfig.CONFIG_PATH
    local read_data = io.readfile(config_path .. "game_config_version.txt")
	if read_data then		
        self.m_game_config_version = Json.decode(read_data) or {};
    else
        self.m_game_config_version = {}
    end
	self.all_cfg = {}
	self.all_cfg_files = {}
end

-- 返回配置表信息
function M:getCfgByName(key)
	-- body
	if self.all_cfg[key] == nil then
		local find_cfg_keys = self:findCfgKeys(key)
		if #find_cfg_keys > 0 then
			local cfg = {}
			for k,v in pairs(find_cfg_keys) do
				self:loadCfg(v[1], v[2])
			end
		else
			self:loadCfg(key, key)
		end
	end
	return self.all_cfg[key]
end

function M:analysisPreloadCfg()
	 -- 预加载配置
	local preload_cfg = {
		"clothes",
	}
	local all_preload_cfg = {}
	for k, v in pairs(preload_cfg) do
		local find_cfg_keys = self:findCfgKeys(v)
		if #find_cfg_keys > 0 then
			table.insertto(all_preload_cfg, find_cfg_keys)
		else
			table.insert(all_preload_cfg, {v, v})
		end
	end
	return all_preload_cfg
end

function M:findCfgKeys(cfg_key)
	local find_cfg_keys = {}
	local find_str = cfg_key .. "%-"
	for k,v in pairs(self.m_game_config_version) do
		local start_idx, end_idx = string.find(k, find_str)
		if start_idx then
			table.insert(find_cfg_keys, {cfg_key, k})
		end
	end
	return find_cfg_keys
end

function M:loadCfg(src_cfg_name, load_cfg_name)
	local file_name = "DataCenter.Config.".. load_cfg_name
	local cfg_tab = require(file_name)
	table.insert(self.all_cfg_files, file_name)
	if src_cfg_name == load_cfg_name then
		self.all_cfg[src_cfg_name] = cfg_tab or {}
	else
		if self.all_cfg[src_cfg_name] == nil then
			self.all_cfg[src_cfg_name] = {}
		end
		table.merge(self.all_cfg[src_cfg_name], cfg_tab or {})
	end
end

function M:resetCfg()
	self.all_cfg = {}
	for k,v in pairs(self.all_cfg_files) do
		package.loaded[v] = nil	
	end
	self.all_cfg_files = {}
	self:init()
end

function M:getCommonValueById(id, default_value)
	local common = self:getCfgByName("common")
	local common_item = common[id] or {}
	local value = common_item.value or default_value
	return value
end

function M:getVipValueByKey(key, default_value)
	local vip = self:getCfgByName("vip")
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local vip_item = vip[vip_lv] or {}
	local value = vip_item[key] or default_value
	return value
end

function M:getStageCfgById(stage_id)
	local stage = ConfigManager:getCfgByName("stage")
	return stage[stage_id]
end

function M:getQuestLockFlag(stage_id)
	local lock_flag = false
	local lock_text = ""
	local stage = ConfigManager:getCfgByName("stage")
	local cur_stage = UserDataManager:getCurStage()
	stage_id = stage_id or 0
	if cur_stage < stage_id then
    	local stage_item = stage[stage_id]
    	if stage_item then
    		lock_flag = true
			local map_point_name = stage_item.map_point_name or ""
			local name = Language:getTextByKey(map_point_name)
	    	lock_text = Language:getTextByKey("new_str_0059", name)
    	end
	end
	return lock_flag, lock_text
end

function M:getSystemCostValueById(id)
    local system_cost = ConfigManager:getCfgByName("system_cost")
    local system_cost_item = system_cost[id] or {}
    return system_cost_item.cost or {}
end

function M:getTowerStageCfgByRaceAndId(race, id)
	local is_max = false
	local race_tower_stage_item = self:getTowerStageCfgByRace(race)
	if id >= #race_tower_stage_item then
		is_max = true
	end
	local tower_stage_item = race_tower_stage_item[is_max and id or (id + 1)] or {}
	return tower_stage_item, is_max
end

function M:getTowerStageCfgByRace(race)
	local tower_stage = ConfigManager:getCfgByName("tower_stage")
	local race_tower_stage_item = tower_stage[race] or {}
	return race_tower_stage_item
end

function M:getHighArenaCfgByRank(rank)
	rank = rank or -1
	local high_arena = ConfigManager:getCfgByName("high_arena")
	for k, v in pairs(high_arena) do
		if rank >= k and rank <= v.rank_min then
			return v
		end
	end
	return {}
end

function M:getHeroEnumerationUserKeys()
	if self.all_cfg["hero_enumeration_user_keys"] == nil then
		local user_keys = {}
		local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
		for k, v in pairs(hero_enumeration) do
			v.id = k
			user_keys[v.user_key] = v
		end
		self.all_cfg["hero_enumeration_user_keys"] = user_keys
	end
	return self.all_cfg["hero_enumeration_user_keys"]
end

function M:delete()
	self.all_cfg = nil
end

return M