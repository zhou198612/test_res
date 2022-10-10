------------------- BtnOpenUtil

local M = {}
M.callback = {}

function M:getBtnCfg(id)
    local open_condition = ConfigManager:getCfgByName("open_condition")
    return open_condition[id or -1]
end

-- 按钮开启解锁判断
--[[
    解锁类型：
    stage_id: 通过关卡解锁
    star: 制作星级
]]
function M:isBtnOpen(id, cfg, old_prestige, old_stage_id, old_task_id)
    cfg = cfg or self:getBtnCfg(id)
    local open_flag = false
    local old_flag = false
    local tips_str = Language:getTextByKey("new_str_0493")
    if cfg then
        local unlock_condition = cfg.unlock_condition
        local unlock_condition_param = cfg.unlock_condition_param or 0

        if unlock_condition == "stage_id" then
            local cur_stage = UserDataManager:getCurStage()
            if old_stage_id then
                if old_stage_id >= unlock_condition_param then
                    old_flag = true
                end
            else
                old_flag = true
            end
            if cur_stage >= unlock_condition_param then
                open_flag = true
            else
                local open_name = Language:getTextByKey(cfg.name or "")

                local stage_cfg = ConfigManager:getCfgByName("stage")[unlock_condition_param]
                if stage_cfg then
                    local id = math.fmod(unlock_condition_param, 10)
                    if id == 0 then
                        id = 10
                    end
                    local stage_name = string.format("%s-%s", stage_cfg.chapter_id, id)
                    tips_str = Language:getTextByKey("new_str_0518",stage_name, open_name)
                else
                    tips_str = Language:getTextByKey("new_str_0518",unlock_condition_param, open_name)
                end
            end
        elseif unlock_condition == "star" then
            if old_prestige then
                if old_prestige >= unlock_condition_param then
                    old_flag = true
                end
            else
                old_flag = true
            end
            local prestige = UserDataManager.user_data:getUserStatusDataByKey("star")
            if prestige >= unlock_condition_param then
                open_flag = true
            else
                local open_name = Language:getTextByKey(cfg.name or "")
                tips_str = Language:getTextByKey("new_str_0517",unlock_condition_param, open_name)
            end
        elseif unlock_condition == "task_id" then
            if old_task_id then
                if old_task_id >= unlock_condition_param then
                    old_flag = true
                end
            else
                old_flag = true
            end
            local cur_task_id = UserDataManager.cur_task_id
            if cur_task_id then
                if cur_task_id >= unlock_condition_param then
                    open_flag = true
                else
                    --tips_str = ""
                end
            else
                open_flag = true
            end
        end
        
    end
    return open_flag, tips_str, old_flag, cfg.name, cfg.icon, cfg.lose_icon, cfg.lose_priority
end

-- 获得功能开启后引导的组id
function M:getGuideTeam(open_id)
    local cfg = self:getBtnCfg(open_id)
    if cfg then
        local unlock_condition = cfg.unlock_condition
        local unlock_condition_param = cfg.unlock_condition_param or 0
        local unlock_max = cfg.unlock_max or unlock_condition_param
        if unlock_condition == "star" then
            local prestige = UserDataManager.user_data:getUserStatusDataByKey("star")
            if prestige >= unlock_condition_param and prestige <= unlock_max then
                return cfg.guide_team
            end
        elseif unlock_condition == "stage_id" then
            local cur_stage = UserDataManager:getCurStage()
            if cur_stage >= unlock_condition_param and  cur_stage <= unlock_max then
                return cfg.guide_team
            end
        end
    end
end

return M
