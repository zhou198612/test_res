-- 新手引导
local M = class("OOGuideBase")

M.m_listener = nil -- 只有一个监听者,用来对比收到的数据

M.m_isMain = false  -- 是否是主引导

--- 引导分成主引导，子引导
--  子引导为主引导分散到其他界面的引导控制
M.m_subGuide = nil -- 子引导
M.is_next = true

function M:ctor(control)
    self.m_control = control
    self.m_view = control.m_view
    self.m_model = control.m_model
    UserDataManager.guide_data:setAliveGuide(self)
    if self.m_isMain then
        UserDataManager.guide_data:registerMain(self)
    else
        local main = UserDataManager.guide_data:getMain(self.__cname)
        if main then
            main:addSubGuide(self)
        end
    end
    self.onHandle = self.onHandle1
    self:init()
end

function M:init()
    if type(self.onHandle) == "function" then
        -- 重置control的方法
        local onHandle = self.m_control.onHandle
        self.m_control.onHandle = function (control, ...)
            self:onHandle(...)
            onHandle(control, ...)
        end

        -- 重置updateMsg方法
        local updateMsg = self.m_control.updateMsg
        self.m_control.updateMsg = function (control, ...)
            self:updateMsg(...)
            updateMsg(control, ...)
        end
    end
    self:onCreate()
end

function M:onCreate()

end

function M:setParams(params)
    self.m_scene = params and params.scene
end

-- 设置
function M:preset()
    
end

-- 标记进行新手引导进行中
function M:markGuide()
    G_GUIDE_FORCE_NET_COMPLETE = true
end

-- 启动
function M:start()
    self:checkGuide()
end

-- 检查并准备进行新手引导
function M:checkGuide(...)
    -- 无效新手引导
    if not UserDataManager.guide_data.m_is_vaild then
        return
    end
    -- 如果没有在引导 就重置引导
    if not UserDataManager.guide_data:isGuiding() then
        UserDataManager.guide_data:resetCurGuide(...)
    end
    if self.m_isMain then
        if self:realCheck(...) then
            return
        end
        if self.m_subGuide then
            for i,v in ipairs(self.m_subGuide) do
                if v:realCheck(...) then
                    break
                end
            end
        end
    else

        local main = UserDataManager.guide_data:getMain(self.__cname)
        if main then
            main:checkGuide(...)
        else
            self:realCheck(...)
        end
    end
end

function M:realCheck(...)
    local info = self:hasGuide()
    Logger.log(self.__cname,"<color=red> +++++++++++++++++++++++++++realCheck guide key --></color>")
    Logger.log(info,"<color=red>+++++++++++++++++++++++++++++++realCheck guide info --></color>")
    if info then
        self:markGuide()
        if not self:isTrigger(info, ...) then
            return
        end
        if self:getExcuteFunc(info) then
            -- 添加容错。
            if self.m_control.m_view then 
                self.m_control.m_view:lockTouch("TAG:will guide")
            else
                return false
            end
            self.m_control:closeView("Guide.GuideDialog")
            local delay = info.delay or 0
            local excute = function ()
                self.m_update_key = nil
                self:willExcuteGuide(info)
                -- 半自由引导时，玩家可以点击界面任意地方导致可以点击返回按钮，已经离开界面
                if self.m_control.m_view then
                    self.m_control.m_view:unlockTouch("TAG:will guide")
                end
            end
            if delay > 0 then
                self.m_update_key = self.__cname .. "_control_update_" .. tostring(excute)
                EventDispatcher:registerTimeEvent(self.m_update_key, excute, delay, delay)
            else
                excute()
            end
            return true
        end
    else
        Logger.log(self.__cname,"self.__cname no guide ->")
    end
end

function M:willExcuteGuide(info)
    self:startExcuteGuide(info)
end

-- 开始引导
function M:startExcuteGuide(info)
    if info.action == 0 and info.drama and info.drama ~= 0 then
        self:excuteGuideFunc0(info) -- 执行对话
    else
        self.m_excute_info = info
        self:excuteGuide(info)  -- 执行指引
    end
end

-- 执行对话
function M:excuteGuideFunc0(info)
    local params = {
        dialog_id = info.drama,
        guide = true,
        callback = function ()
            self:doNextGuide()
        end,
        -- guide = self,
    }
    static_rootControl:openView("Guide.GuideDrama", params);
end

--- 跳过引导
function M:excuteGuideFunc88888(info)
    local function jumpFunc()
        local team_ids, sort_ids = UserDataManager.guide_data:getGuideTeamAndIds()
        local guideServer = UserDataManager:getGuide()
        local netparams = {}
        for i,v in ipairs(info.target or {}) do
            local ids = sort_ids[v]
            if ids then
                local guide_id = ids[#ids]
                guideServer[tostring(v)] = guide_id and tonumber(guide_id)
                netparams[tostring(v)] = guide_id and tonumber(guide_id)
            end
        end

        local function responseMethod(gameData)
            if GameVersionConfig.Debug then
                local guideServer = UserDataManager:getGuide()
                Logger.log(guideServer, "user_guide guideServer-->")
            end
        end
        local key = NetUrl.getUrlForKey("user_skip_guide")
        NetWork:httpRequest(responseMethod, key, GlobalConfig.POST, {skip_data = netparams}, key, 3, true)

        UserDataManager.guide_data:clearCurGuide()
        UserDataManager.guide_data:resetCurGuide()
        if not self:hasGuide() then        -- 当前系列新手引导结束后，取消锁定touch
            local control = static_rootControl:getRootControl()
            control.m_view:unlockTouch("TAG:next dialog")
            G_GUIDE_FORCE_NET_COMPLETE = false
        end
    end

    local params = {
        on_ok_call = function(msg)
            local params = {
                on_ok_call = function(msg)
                    jumpFunc()
                end,
                on_cancel_call = function(msg)
                    self:doNextGuide()
                end,
                no_close_btn = false,
                tow_close_btn = true,
                text = Language:getTextByKey("tid#GuideDes_178")
            }
            static_rootControl:openView("Pops.CommonPop", params, nil, true)
        end,
        on_cancel_call = function(msg)
            self:doNextGuide()
        end,
        no_close_btn = false,
        tow_close_btn = true,
        ok_text = Language:getTextByKey("new_str_0467"),
        cancel_text = Language:getTextByKey("new_str_0468"),
        text = Language:getTextByKey("tid#GuideDes_174")
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

--- 左上角返回按钮
function M:excuteGuideFunc99999(info)
    self.m_listener = {
        key = 99999,
    }
    local btn = self.m_view:findGameObject("close_btn")
    if btn then
        self:guideTargetNode(btn.transform, 1, 1,nil,nil,nil,nil,nil,Vector3(0,180,90))
    end
end

-- 获取引导信息
function M:hasGuide()
    local info = UserDataManager.guide_data:getCurGuideInfo()
    Logger.log(info,"+++++++++++++++++hasGuide ===")
    if info then
        if info.key == self.__cname then 
            return info
        elseif self.is_next and info.next == 1 then
            self:sendGuideData()
            UserDataManager.guide_data:nextGuideId()
            return self:hasGuide()
        elseif info.next > 10000 then
            for i=1, info.next - 10001 do
                UserDataManager.guide_data:nextGuideId()
            end
            UserDataManager.guide_data:nextGuideId()
            return self:hasGuide()
        end
    end
end

function M:isTrigger(info)
    return true
end

-- 执行指引，子类重新相关逻辑
function M:excuteGuide(info)
    local action = info.action
    local jump = info.jump or 0
    local jump_condition_func = self:getJumpConditionFunc(info)
    if jump > 0 and jump_condition_func and jump_condition_func(self, info) then
        UserDataManager.guide_data:goToGuideId(jump)
        self:checkGuide()
        return
    end
    
    local func = self:getExcuteFunc(info)
    if self.m_control.m_view then 
        func(self, info)
    end
end

function M:getExcuteFunc(info)
    local func = self["excuteGuideFunc" .. tostring(info and info.action)]
    if type(func) == "function" then
        return func
    end
end

function M:getJumpConditionFunc(info)
    local func = self["jumpConditionFunc" .. tostring(info and info.action)]
    if type(func) == "function" then
        return func
    end
end

-- 执行下一个引导
function M:doNextGuide()
    -- 刚刚完成的任务信息。
    local last_info = UserDataManager.guide_data:getCurGuideInfo()

    if last_info and last_info.reward then
        local reward = last_info.reward or {}
        if #reward > 0 and reward[1][1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
            --self.m_control:openView("HeroInfo", {tj_data = reward[1][2], look_model = 2, show_new = true})
        end
    end
    self:sendGuideData()
    UserDataManager.guide_data:nextGuideId()
    if not UserDataManager.guide_data:getCurGuideInfo() then        -- 当前系列新手引导结束后，取消锁定touch
        local control = static_rootControl:getRootControl()
        control.m_view:unlockTouch("TAG:next dialog")
        G_GUIDE_FORCE_NET_COMPLETE = false
    end

    --[[ 下一个任务是同一系列的任务，但不是自己界面的引导，则不引导。
         放在这里的原因是，hasGuide内部会判断，如果不是当前自己，就doNextGuide()，不能执行这一步。
         下一个任务非同一系列的任务，则继续引导。]]
    local current_info = UserDataManager.guide_data:getCurGuideInfo()
    if last_info and current_info and last_info.sort == current_info.sort and current_info.key ~= self.__cname then 
        return
    else 
        self:checkGuide()
    end
end

function M:skipNextGuide(count)
    assert(count >= 1, "skip guide count must > 0")
    for i=1, count - 1 do
        UserDataManager.guide_data:nextGuideId()
    end
    self:sendGuideData()
    UserDataManager.guide_data:nextGuideId()
    self:checkGuide()
end

function M:sendGuideData()
    UserDataManager.guide_data:sendGuideData()
end

-- 显示交互层
function M:showGuideDialog(control, params)
    static_rootControl.m_view:lockTouch("TAG:will dialog")
    static_rootControl:openView("Guide.GuideDialog", params);
    static_rootControl.m_view:unlockTouch("TAG:will dialog")
end

-- 通过交互节点创建交互层
function M:guideTargetNode(targetTrans, maskType, eventType, speed, nofinger, finger_offset, forceSize, target_pos, finger_rotation, endCallFunc, left_skip)
    local info = self.m_excute_info
    if targetTrans then
        local params = {
            target_trans = targetTrans,
            target_pos = target_pos,
            maskType = maskType,
            eventType = eventType,
            guide = self,
            speed = speed,
            nofinger = nofinger,
            finger_offset = finger_offset, 
            info = info,
            forceSize = forceSize,
            finger_rotation = finger_rotation,
            guideIsForce = UserDataManager.guide_data:curGuideIsForce(),
            endCallFunc = endCallFunc, -- 关闭引导界面回调
            left_skip = left_skip,
        }
        self:showGuideDialog(self.m_control, params);
    else
        self:doNextGuide()
    end
end

-- 显示拖动交互层
function M:showGuideDragDialog(control, params)
    static_rootControl.m_view:lockTouch("TAG:will dragDialog")
    self.m_control:closeView("Guide.GuideMoveDialog")
    static_rootControl:openView("Guide.GuideMoveDialog", params);
    static_rootControl.m_view:unlockTouch("TAG:will dragDialog")
end

-- 通过两个屏幕坐标创建交拖动互层
function M:guideTargetDragNode(startPos, targetPos, moveCall, maskType, eventType, speed, nofinger, finger_offset, forceSize)
    local info = self.m_excute_info
    if startPos and targetPos then
        local params = {
            start_pos = startPos,
            target_pos = targetPos,
            move_call = moveCall,
            maskType = maskType,
            eventType = eventType,
            guide = self,
            speed = speed,
            nofinger = nofinger,
            finger_offset = finger_offset, 
            info = info,
            forceSize = forceSize,
            guideIsForce = UserDataManager.guide_data:curGuideIsForce()
        }
        self:showGuideDragDialog(self.m_control, params);
    else
        self:doNextGuide("guideTargetDragNode")
    end
end

-- 显示交互层(弱引导)
function M:showGuideDialogEasy(control, params)
    static_rootControl.m_view:lockTouch("TAG:will dialog")
    static_rootControl:openView("guide.guide_dialog_easy", params)
    static_rootControl.m_view:unlockTouch("TAG:will dialog")
end

-- -- 通过交互节点创建交互层(弱引导)
-- function M:guideTargetNodeEasy(targetNode, maskType, speed)
--     local info = self.m_excute_info
--     local skip = info and info.skip or 0
--     local clickCallFunc = function ()
--         self:doNextGuide()
--     end
--     if targetNode then
--         local params = {
--             tempNode = targetNode,
--             -- clickCallFunc = clickCallFunc,
--             maskType = maskType,
--             skip = skip,
--             guide = self,
--             speed = speed,
--         }
--         self:showGuideDialogEasy(self.m_control, params);
--     else
--         clickCallFunc()
--     end
-- end

function M:guideStop()
    
end

function M:goBackMainPage()
    static_rootControl:enterMainPage()
end

---------------------------------
-- 收到消息
---------------------------------
--- 如果子类有此方法，则会监听之
-- function M:onHandle(msg, data)
-- end

-- 替代方法
function M:onHandle1(msg, data)
    if self:checkListenerTrigger(msg, data) then
        self.m_listener = nil
        self.m_control:closeView("Guide.GuideDialog")
        self.m_control:closeView("Guide.GuideMoveDialog")
        self.m_control.m_view:unlockTouch("TAG:valid msg")
        self:doNextGuide()
    else
        Logger.logWarning("checkListenerTrigger error")       
    end
end

function M:checkListenerTrigger(msg, data)
    if self.m_listener then
        if self.m_listener.key == msg then
            if type(self.m_listener.check) == "function" then
                return self.m_listener.check(data)
            else
                return true         -- 引导成功，进行下一步引导
            end
        end
    end
end

--- 添加子引导
function M:addSubGuide(guide)
    if self.m_subGuide then
        table.insert(self.m_subGuide, guide)
    else
        self.m_subGuide = {guide}
    end
end

function M:removeSubGuide(guide)
    for i,v in ipairs(self.m_subGuide or {}) do
        if v == guide then
            table.remove(self.m_subGuide, i)
            break
        end
    end
end

--- 清理引导
function M:destroy()
    if self.m_update_key ~= nil then
        EventDispatcher:unRegisterEvent(self.m_update_key)
        self.m_update_key = nil
    end
    if self.m_isMain then
        if self.m_subGuide then
            for i,v in ipairs(self.m_subGuide) do
                v:destroy()
            end
            self.m_subGuide = nil
        end
        UserDataManager.guide_data:removeMain(self)
    else
        local main = UserDataManager.guide_data:getMain(self.__cname)
        if main then
            main:removeSubGuide(self)
        end
    end
end

function M:updateMsg(msg, data, flag, alias)
    if flag == nil or (self.m_control.m_model and flag == self.m_control.m_model:getName()) then   -- 自身响应msg
        if self.m_listener then
            if not self.m_listener.sign then                        -- 防止锁定多次
                if self:checkListenerTrigger(msg, data) then
                    self.m_control.m_view:lockTouch("TAG:valid msg")   -- 得到想要的数据，锁定触摸
                    self.m_listener.sign = true
                end
            end
        end
    end
    if msg == 99999 then
        self.m_control:closeView("Guide.GuideDialog")
    end
end

function M:getCurExcuteGuideInfo()
    return self.m_excute_info
end

return M