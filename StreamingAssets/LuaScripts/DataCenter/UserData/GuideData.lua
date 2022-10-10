  ---新手引导数据 GuideData
local M = {
    m_main_guide = {},        -- 全部在的guide
    m_is_vaild = false,
    m_cur_guide = nil, 
    m_skip_callback = nil,     -- 跳过引导时回调。
}

function M:init()
    self.m_is_vaild = true
    -- 解析配置信息
    self:analyseCfg()
    -- 重置新手引导
    --self:resetCurGuide()
end

function M:analyseCfg()
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local __guide_team_cfg = ConfigManager:getCfgByName("guide_team")

    local team_ids = {}         -- 引导组id列表
    for id, cfg in pairs(__guide_team_cfg) do
        table.insert(team_ids, {
            id = id,
            sort = cfg.sort,
            start_id = cfg.start_id,
            })
    end
    local sortFunc = function (data1, data2)
        if data1[2] == data2[2] then
            return tonumber(data1.id) < tonumber(data2.id)
        else
            return data1.sort < data2.sort
        end
    end
    table.sort(team_ids, sortFunc)

    local sort_ids = {}
    local sort = nil
    Logger.log(__guide_cfg)
    for id,cfg in pairs(__guide_cfg) do
        sort = cfg.sort
        if sort_ids[sort] then
            table.insert(sort_ids[sort], tonumber(id))
        else
            sort_ids[sort] = {tonumber(id)}
        end
    end

    local sortFunc1 = function (id1, id2)
        return id1 < id2
    end
    for sort,ids in pairs(sort_ids) do
        table.sort(ids, sortFunc1)
    end

    self.m_team_ids = team_ids
    self.m_sort_ids = sort_ids
    --Logger.log(team_ids,"team_ids =====")
    --Logger.log(sort_ids,"sort_ids =====")
end

--[[
    guide_team type == 4 特殊处理    
]]
function M:resetCurGuide( stype )
    if self.m_cur_guide then
        local teamCfg = self.m_cur_guide.team_cfg
        if teamCfg == nil or (teamCfg.type ~= 4 and teamCfg.type ~= 5) then
            return
        end
    end
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local __guide_team_cfg = ConfigManager:getCfgByName("guide_team")

    local level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    local prestige_level = UserDataManager.user_data:getUserStatusDataByKey("star") or 1
    -- 网络记录的新手引导数据
    local guideServer = UserDataManager:getGuide()
    Logger.log(guideServer,"guideServer =====")
    local curTeamId = nil
    local realIndex = 1         -- 真实的引导id在sort_ids中的位置
    local index = 0
    index = math.max(index, 1)
    -- 检查开启的新手引导
    for i = index, #self.m_team_ids do
        local idInfo = self.m_team_ids[i]
        realIndex = 0
        local teamCfg = __guide_team_cfg[idInfo.id]
        local curFlag = false
        if teamCfg.type ~= 4 and teamCfg.type ~= 5 then -- type=4 不进行主动新手引导
            curFlag = true
        end
        if stype == true then -- stype 在特定条件下触发 type=4 得新手引导
            curFlag = true
        end
        if teamCfg.open_level <= prestige_level  and curFlag == true then  -- 已经开启
            -- 检查是否已经引导完成
            local teamId = idInfo.id
            local sortIds = self.m_sort_ids[idInfo.sort]
            if sortIds and #sortIds > 0 then
                local server = guideServer[tostring(idInfo.sort)]
                if not server then  -- 完全没有记录 开始进行引导
                    curTeamId = self:getCurTeamId(teamId, sortIds)
                else
                    server = tonumber(server)
                    -- 有记录，检查引导关键步骤是否已经完成
                    for index,id in ipairs(sortIds) do
                        local cfg = __guide_cfg[tonumber(id)]
                        if cfg.aim == 1 and id > server then
                            curTeamId = teamId
                            break
                        elseif id <= server then
                            realIndex = index
                            if cfg.aim == 1 then--跳过
                                break
                            end
                        end
                    end
                end
            end
            -- 开始引导此id
            if curTeamId then
                break
            end
        end
    end
    if curTeamId then
        self:setCurGuideTeamId(curTeamId, realIndex)
    else
        self:clearCurGuide()
    end
    --if self.m_is_vaild and realIndex == 0 and #self.m_team_ids > 0 and curTeamId == self.m_team_ids[1].sort then
    --    StatisticsUtil:doPoint("startNewGuide")
    --end
    if not next(guideServer) then  --服务器没有引导记录时为第一次开启引导
        StatisticsUtil:doPoint("startNewGuide")
        Logger.log("startNewGuide")
    end
end

function M:getCurTeamId(teamId, sortIds)
    local curTeamId = nil
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local __guide_team_cfg = ConfigManager:getCfgByName("guide_team")
    local teamCfg = __guide_team_cfg[teamId]
    if teamCfg.type == 3 or teamCfg.type == 6 then -- 带有触发条件的引导，3强引导，6若引导
        local cfg = __guide_cfg[tonumber(sortIds[1])]
        local trigger = cfg.trigger or {}
        local trigger_type = trigger[1]
        local trigger_value = trigger[2]
        if trigger_type == 1 then -- 通关触发
            local stage = UserDataManager:getCurStage()
            -- Logger.log(stage,"stage ======")
            if trigger_value and trigger_value == stage then
                curTeamId = teamId
            end
        elseif trigger_type == 3 then -- 星级触发
            local prestige_level = UserDataManager.user_data:getUserStatusDataByKey("star") or 1
            if trigger_value and trigger_value == prestige_level then
                curTeamId = teamId
            end
        elseif trigger_type == 4 then -- 任务触发
            local task_id = UserDataManager.cur_task_id
            if trigger_value and trigger_value <= task_id then
                curTeamId = teamId
            end
        end
    elseif teamCfg.type == 2 then -- 界面触发引导
        
    else
        curTeamId = teamId
    end
    return curTeamId
end

function M:setCurGuideTeamId(curTeamId, realIndex)
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local __guide_team_cfg = ConfigManager:getCfgByName("guide_team")
    local teamCfg = __guide_team_cfg[curTeamId]
    local ids = self:getValidGuideIds(teamCfg.sort, teamCfg.start_id, __guide_cfg)
    self.m_cur_guide = {
        need_reset = true,
        sort = teamCfg.sort,
        id = teamCfg.start_id,
        ids = ids,
        index = 1,
        real_index = realIndex,
        cfg = __guide_cfg,
        team_cfg = teamCfg,
        team_id = curTeamId
    }
    self:resetRightIndex()
end

--- 设置任意组引导
function M:setAnyTeamGuide(teamId)
    teamId = tonumber(teamId)
    local level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    local prestige_level = UserDataManager.user_data:getUserStatusDataByKey("star") or 1
    local guideServer = UserDataManager:getGuide()
    local realIndex = 0
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local __guide_team_cfg = ConfigManager:getCfgByName("guide_team")

    local teamCfg = __guide_team_cfg[teamId]
    local isHave = false
    if teamCfg and teamCfg.open_level <= prestige_level then  -- 已经开启
        local sortIds = self.m_sort_ids[teamCfg.sort]
        if sortIds and #sortIds > 0 then
            local server = guideServer[tostring(teamCfg.sort)]
            if server then  -- 完全没有记录 开始进行引导
                -- 有记录，检查引导关键步骤是否已经完成
                for index,id in ipairs(sortIds) do
                    local cfg = __guide_cfg[tonumber(id)]
                    if cfg.aim == 1 and id > server then
                        isHave = true
                        break
                    elseif id <= server then
                        realIndex = index
                        if cfg.aim == 1 then--跳过
                            break
                        end
                    end
                end
                if teamCfg.type == 4 then
                    isHave = true
                    local tempIndex = realIndex
                    realIndex = 0
                    if tempIndex > 0 then
                        -- 如果引导过并且第一段是对话就跳过
                        local cfg = __guide_cfg[tonumber(sortIds[1])]
                        local drama_type = type(cfg.drama)
                        if cfg.action == 0 and (cfg.drama ~= 0 or (drama_type == "table" and _G.next(drama_type))) then
                            realIndex = 2
                        end
                    end
                    
                end
            else
                isHave = true
            end
        end
    end
    if isHave then
        self:setCurGuideTeamId(teamId, realIndex)
    end
    return isHave
end

function M:reset()
    self:init()
end

function M:isGuiding()
    return self.m_cur_guide and self.m_is_vaild
end

function M:getCurGuide()
    return self.m_cur_guide
end

-- 获取当前引导的id
function M:getCurGuideId()
    if self.m_cur_guide then
        local curGuide = self.m_cur_guide
        return curGuide.ids[curGuide.index]
    end
end

-- 返回当前引导信息
function M:getCurGuideInfo()
    if self.m_cur_guide then
        local curGuide = self.m_cur_guide
        local id = self:getCurGuideId()
        if curGuide.cfg then
            return curGuide.cfg[id], id
        else
            local __guide_cfg = ConfigManager:getCfgByName("guide")
            return __guide_cfg[tonumber(id)], id
        end
    end
end

-- 判断当前引导是否是强制引导
function M:curGuideIsForce()
    if self.m_cur_guide then
        local team_cfg = self.m_cur_guide.team_cfg
        if team_cfg and (team_cfg.type == 1 or team_cfg.type == 2 or team_cfg.type == 3) then
            return true
        end
    end
    return false
end

--- force 任务引导标记  此种引导为弱引导，使用箭头代替手指
function M:getValidGuideIds(sort, id, cfgs, force)
    local ids = {}
    local cfg = nil
    while true do
        cfg = cfgs[tonumber(id)]
        if (not cfg) or cfg.sort ~= sort  then
            break
        end
        cfg.id = id
        if force then
            cfg.free = true
            cfg.finger = 2
        end
        table.insert(ids, tonumber(id))
        id = id + 1
    end
    return ids
end

--- 设置正确的索引,当curIndex<realIndex时，我们为快速到要引导到指定的步骤，略过不重要的中间步骤(level决定)
function M:resetRightIndex()
    self.m_skip_callback = nil

    local curGuide = self.m_cur_guide
    if curGuide.index <= curGuide.real_index then
        local sort_ids = self.m_sort_ids
        local allIds = sort_ids and sort_ids[curGuide.sort]
        if allIds then
            local ids = {}
            while curGuide.index <= curGuide.real_index do
                local id = tonumber(allIds[curGuide.index])
                local cfg = curGuide.cfg[id]
                if not cfg then
                    break
                elseif cfg.level ~= 0 then
                    break
                end
                curGuide.index = curGuide.index + 1
            end
        end
    end
end

-- 设置下一个引导id
function M:nextGuideId()
    if not self.m_cur_guide then
        return
    end

    self.m_cur_guide.index = self.m_cur_guide.index + 1
    -- 检查本组引导全部结束
    if self.m_cur_guide and (self.m_cur_guide.index > #self.m_cur_guide.ids) then  
        self:clearCurGuide()
        self:resetCurGuide()    -- 重置到下一组新手引导
        return
    end

    -- 重置到下一个正确步骤
    self:resetRightIndex()

    -- 检查本组引导全部结束
    if self.m_cur_guide and (self.m_cur_guide.index > #self.m_cur_guide.ids) then  
        self:clearCurGuide()
        self:resetCurGuide()    -- 重置到下一组新手引导
    end
end

-- 向服务器发送已完成引导数据
function M:sendGuideData()
    if not(self.m_cur_guide) or self.m_cur_guide.locate then    -- 本地引导不需要发送服务器
        return
    end
    local guideServer = UserDataManager:getGuide()
    local cfg, guide_id = self:getCurGuideInfo()
    local server_id = guideServer[tostring(cfg.sort)] or 0
    if guide_id > server_id then
        local params = {sort = cfg.sort, guide_id = guide_id}
        local function responseMethod(gameData)
            if GameVersionConfig.Debug then
                local guideServer = UserDataManager:getGuide()
                Logger.log(guideServer, "user_guide guideServer-->")
            end
            if gameData == nil then
                Logger.log(params, "send user_guide failed-->")
                if GameVersionConfig.Debug then
                    local str = json.encode(params)
                    game_util:addMoveTips({text = "send user_guide failed : " .. str})
                end
            end
        end

        local key = NetUrl.getUrlForKey("user_guide")
        NetWork:httpRequest(responseMethod, key, GlobalConfig.POST, params, key, 3, true)
        -- 本地存储网络数据        
        local guideServer = UserDataManager:getGuide()
        guideServer[tostring(cfg.sort)] = guide_id and tonumber(guide_id)
        
    else
        Logger.log("sendGuideData id not send ; guide_id = " .. guide_id .. " ; server_id = " .. server_id)
    end
end

-- 跳过当前引导
function M:skipCurGuide()
    if self.m_cur_guide and not self.m_cur_guide.free then
        self.m_cur_guide.index = #self.m_cur_guide.ids
        self:sendGuideData()
    end

    -- 跳过引导时的回调。
    if self.m_skip_callback then 
        self.m_skip_callback()
    end

    self:clearCurGuide()
end

-- 跳过所有引导
function M:skipAllGuide()
    if self.m_cur_guide then
        if not self.m_cur_guide.free then
            local function responseMethod(gameData)  
                self:resetCurGuide()
                self:init()
            end
            local key = game_url.getUrlForKey("user_guide")
            NetWork:sendHttpRequest(responseMethod, key, http_request_method.POST, {skip = 1}, key, 3, true)
        end
    end

    -- 跳过引导时的回调。
    if self.m_skip_callback then 
        self.m_skip_callback()
    end

    self:clearCurGuide()
end

function M:clearCurGuide()
    self.m_cur_guide = nil
    self.m_skip_callback = nil
end

--- 注册新手引导
function M:registerMain(guide)
    self.m_main_guide[guide.__cname] = guide
end

function M:removeMain(guide)
    self.m_main_guide[guide.__cname] = nil
end

function M:getMain(name)
    return self.m_main_guide[name]
end

--- 是否在新手引导
function M:isInNewGuide()
    local guide = UserDataManager:getGuide()
    local sort, id = self:getLastNewGuideSortAndID()

    if guide[sort] and tonumber(guide[sort]) >= tonumber(id) then
        return false
    else
        return true
    end
end

function M:getLastNewGuideSortAndID()
    local cfg_guide_team = getConfigTable(game_config_field.guide_team)
    local cfg_guide = getConfigTable(game_config_field.guide)
    local info_guide_team = cfg_guide_team[tonumber(util.getTableLen(cfg_guide_team))]
    if not info_guide_team then return end
    local start_id = tonumber(info_guide_team.start_id)
    local temp_id = start_id
    local last_have_aim_id = nil

    while true do 
        local info_guide = cfg_guide[tonumber(temp_id)]

        if info_guide then 
            if 1 == tonumber(info_guide.aim) then 
                last_have_aim_id = temp_id
            end
            temp_id = temp_id + 1
        else 
            break
        end
    end
    -- 如果引导组的步骤中有步骤配了aim，那么判定通过新手引导就是配了aim这一步。
    -- 否则均没有aim，则判定通过新手引导是此引导组中第一步。
    if last_have_aim_id then 
        temp_id = last_have_aim_id
    else 
        temp_id = start_id
    end

    local info_guide = cfg_guide[tonumber(temp_id)]

    return tonumber(info_guide.sort), tonumber(temp_id)
end

function M:setSkipCallback(callback)
    self.m_skip_callback = callback
end

function M:setAliveGuide(guide)
    self.m_alive_guide = guide
end

function M:getGuideTeamAndIds()
    return self.m_team_ids, self.m_sort_ids
end

--- 指定引导步
function M:goToGuideId(goto_id)
    goto_id = goto_id or 0
    if self.m_cur_guide and goto_id > 0 then
        local sort_ids = self.m_sort_ids
        local ids = sort_ids[self.m_cur_guide.sort]
        local curId = ids[self.m_cur_guide.index]
        local addIndex = goto_id - curId
        self.m_cur_guide.index = self.m_cur_guide.index + addIndex
        if self.m_cur_guide.index >= #ids then
            self:resetCurGuide()
        end
    end
end

return M