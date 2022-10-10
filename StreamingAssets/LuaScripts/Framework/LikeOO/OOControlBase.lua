local M = class("OOControlBase", nil)

-- message data list
M.m_msg = nil
-- run loop with message data
M.m_update_key = nil
-- map with chiled controller
M.m_chilrenList = nil
-- model for this control
M.m_model = nil
-- view with self
M.m_view = nil
-- mind perant control
M.m_parent = nil
-- need save data for goBack
M.m_needBack = true
-- timer list
M.m_timerList = nil
M.m_timer_remove = nil

M.m_open_sound_effect = nil

M.m_close_sound_effect = nil

-- player guide control
M.m_guide = nil

M.m_closing = nil

-- static var with root control
static_rootControl = nil
-- static var that with histroy page list
static_pageList = LikeOO.OOStack:new()
-- home name
static_homeName = ""

-- static root node
static_root_node = nil
-- static front pop layer
static_topLayer = nil
-- static front layer
static_frontLayer = nil
-- static normal layer
static_normalLayer = nil
-- ghost pop
static_ghostChildren = nil

static_ui_camera = nil

-- 
function M:create()
    self.m_msg = LikeOO.OOMsgList:new()
    self.m_chilrenList = {}
    self.m_timerList = {}
    self.m_timer_remove = {}
    self.m_closing = false
    self:onCreate()

    local tempname = "UI." .. self.m_model:getName() .. ".View"
    local tempCls
    if GameVersionConfig.LUA_RELOAD_DEBUG then
        tempCls = LuaReload(tempname)
    else
        tempCls = require(tempname)
    end

    self.m_view = tempCls.new()
    self.m_view.m_control = self
    self.m_view.m_model = self.m_model
    self:createView()
end

function M:createGuide()
    if self.m_guide_file_name then
        local __guide = require(self.m_guide_file_name)
        self.m_guide = __guide.new(self)
        self.m_guide:preset()
    end
end

function M:startGuide()
    if self.m_guide then
        self.m_guide:start()
    end
end

function M:onDestroy()
end

function M:destroy()
    local name = self.m_model and self.m_model:getName()
    name = tostring(name)
    Logger.log("--------- destroy control --------" .. name)
    self:onDestroy()
    if self.m_guide then
        self.m_guide:destroy()
    end
    if self.m_update_key then
        GameMain.removeUpdate(self.m_update_key)
    end
    -- message data list
    if (self.m_msg) then
        self.m_msg:cleanAll()
    end
    self.m_msg = nil
    -- run loop with message data
    self.m_update_key = nil
    -- map with chiled controller
    for k, v in pairs(self.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for k, v in pairs(v) do
                v:closeView()
            end
        else
            v:closeView()
        end
    end
    if (self.m_view) then
        self.m_view:destroy()
    end

    if (self.m_model) then
        self.m_model:destroy()
    end

    -- mind perant control
    if (self.m_parent ~= nil) then
        local tempChiled = self.m_parent.m_chilrenList[self.m_model:getName()]
        if tempChiled and (not isClassOrObject(tempChiled)) then
            self.m_parent.m_chilrenList[self.m_model:getName()][self.m_model:getAlias()] = nil
            if (table.nums(self.m_parent.m_chilrenList[self.m_model:getName()]) <= 0) then
                self.m_parent.m_chilrenList[self.m_model:getName()] = nil
            end
        else
            self.m_parent.m_chilrenList[self.m_model:getName()] = nil
        end
        self.m_parent = nil
    end
    -- model for this control
    self.m_model = nil
    -- view with self
    self.m_view = nil
    self.m_closing = nil
    for k, v in pairs(self.m_timerList) do
        self.m_timerList[k] = nil
    end
    if static_ghostChildren and name and static_ghostChildren[name] then
        static_ghostChildren[name] = nil
    end
    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, { name = name })
end

-- 构造view用
function M:createView()
    local callback = function()
        local tempVT = self.m_view:getType()
        if (tempVT == 1) then
            local name = self.m_model and self.m_model:getName()
            -- changed scene
            if (static_rootControl) then
                if (self.m_model.m_type == 1) then
                    -- if data type is a first flag
                    if (static_rootControl.m_needBack) then
                        static_rootControl.m_model.m_type = 2
                        static_pageList:addData(static_rootControl.m_model)
                    end
                elseif (self.m_model.m_type == 2) then
                    -- if data type is a histroy flag
                    static_rootControl.m_model:destroy()
                end
                static_rootControl:destroy()
            else
                self:init_oo()
            end
            self.m_parent = nil
            self.m_view:create()
            static_rootControl = self
        elseif (tempVT == 2) then
            self.m_view:create()
            -- add pop in the control
            local normalFlag = self.m_view.m_normal
            if (not normalFlag) then
                self.m_parent = nil
                if (not static_ghostChildren) then
                    static_ghostChildren = {}
                end
                local tempName = self.m_model:getName()
                if (static_ghostChildren[tempName] ~= nil) then
                    static_ghostChildren[tempName]:closeView()
                end
                static_ghostChildren[tempName] = self
            else
                if (static_rootControl) then
                    self.m_parent = static_rootControl
                    if (static_rootControl.m_chilrenList[self.m_model:getName()] ~= nil) then
                        local tempName = self.m_model:getName()
                        local tempAlias = self.m_model:getAlias()
                        local tempC = static_rootControl.m_chilrenList[tempName]
                        if (not isClassOrObject(tempC)) then
                            if (tempAlias == nil) then
                                local tempAl = #tempC + 1
                                tempC[tempAl] = self
                                self.m_model.m_alias = tempAl
                            else
                                tempC[tempAlias] = self
                            end
                        else
                            static_rootControl.m_chilrenList[tempName] = {}
                            local alias = tempC.m_model:getAlias()

                            if (alias == nil) then
                                static_rootControl.m_chilrenList[tempName][1] = tempC
                                tempC.m_model.m_alias = 1
                            else
                                static_rootControl.m_chilrenList[tempName][alias] = tempC
                            end

                            local tempCR = static_rootControl.m_chilrenList[tempName]
                            if (tempAlias == nil) then
                                local tempAl = #tempCR + 1
                                tempCR[tempAl] = self
                                self.m_model.m_alias = tempAl
                            else
                                tempCR[tempAlias] = self
                            end
                        end
                    else
                        if self.m_model:getName() ~= "Loading.CommonMask" and self.m_model:getName() ~= "Loading.CommonMask2" then
                            static_rootControl.m_chilrenList[self.m_model:getName()] = self
                        end
                    end
                end
            end
        end
        self:addControlUpdate()
        --self:onUpdate()
        self.m_view:onEnter()
        -- 音效
        if self.m_open_sound_effect then
            -- pop开启音效
            game_sound:playEffect(self.m_open_sound_effect)
        end
        self:onEnter()
        self:createGuide()
        if self.m_view then
            self.m_view:openTransition(function()
                self:retainVisibleView()
                self:startGuide()
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, { name = self.m_model:getName() })
            end)
        end
    end
    if self.m_view and self.m_model.m_mask == 1 then
        self:openView("Loading.CommonMask", { callback = callback })
    elseif self.m_view and self.m_model.m_mask == 2 then
        self:openView("Loading.CommonMask2", { callback = callback })
    else
        callback()
    end

    if (self.m_model:getName() == static_homeName) then
        static_pageList:cleanAll()
    end
end

function M:addControlUpdate()
    local function tick(dt)
        for tk, tv in pairs(self.m_timerList) do
            tv.time = tv.time + dt
            if (tv.inter <= 0) then
                tv.callFunc(self, tv.time)
                tv.time = 0
            elseif (tv.time >= tv.inter) then
                tv.callFunc(self, tv.inter)
                tv.time = tv.time - tv.inter
            end
        end

        for k, v in pairs(self.m_timer_remove) do
            self.m_timerList[k] = nil
            self.m_timer_remove[k] = nil
        end
        local tempMsg = self.m_msg and self.m_msg:pop()
        if (tempMsg ~= nil) then
            if (tempMsg.m_msg == "oo_update") then
                if (static_rootControl ~= nil) then
                    static_rootControl:onUpdate()
                    for k, v in pairs(static_rootControl.m_chilrenList) do
                        if (not isClassOrObject(v)) then
                            for kc, vc in pairs(v) do
                                vc:onUpdate()
                            end
                        else
                            v:onUpdate()
                        end
                    end
                end
            else
                self:onHandle(tempMsg.m_msg, tempMsg.m_model)
            end
        end
    end
    self.m_update_key = self.m_model:getName() .. "_control_update_" .. tostring(tick)
    GameMain.addUpdate(self.m_update_key, tick)
end

--[[
	打开指定名字的窗口

]]
function M:openView(name, params, alias, ismulity)
    --todo 如果是model状态则只能打开一个。多余的会关掉。
    if ismulity == nil or ismulity == false then
        local result = self:hasChild(name, alias)
        if result == true then
            return
        end
    end

    local tempname = "UI." .. name .. ".Model"
    Logger.log("-------------- openView : " .. tempname)

    local tempCls
    if GameVersionConfig.LUA_RELOAD_DEBUG then
        tempCls = LuaReload(tempname)
    else
        tempCls = require(tempname)
    end
    local tempModel = tempCls:new()
    tempModel:create(name, params, alias)
end

function M:closeAllViewPop(not_close_tab)
    if static_rootControl == nil then
        return false
    end
    local chilrenList = static_rootControl.m_chilrenList or {}
    not_close_tab = not_close_tab or {}
    for k, v in pairs(chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                local name = vc.m_model:getName()
                if not not_close_tab[name] then
                    vc:closeView()
                end
            end
        else
            local name = v.m_model:getName()
            if not not_close_tab[name] then
                v:closeView()
            end
        end
    end
end

function M:closeView(name, alias)
    if name then
        self:realCloseView(name, alias)
    elseif self.m_view and self.m_closeAnim and self.m_view.m_ccbNode then
        game_comm_ani.showPopClosed(self.m_view.m_ccbNode, function()
            self:realCloseView(name, alias)
        end, self.m_view)
    else
        self:realCloseView(name, alias)
    end
end

function M:realCloseView(name, alias)
    -- 音效
    if self.m_close_sound_effect then
        -- pop开启音效
        game_sound:playEffect(self.m_close_sound_effect)
    end

    if (name) then
        local tempChiled = static_rootControl.m_chilrenList[name]
        if (tempChiled) then
            if (not isClassOrObject(tempChiled)) then
                if (alias) then
                    local tempAliasC = tempChiled[alias]
                    if (tempAliasC) then
                        tempAliasC:closeView()
                        static_rootControl.m_chilrenList[name][alias] = nil
                        if (table.nums(static_rootControl.m_chilrenList[name][alias]) <= 0) then
                            static_rootControl.m_chilrenList[name] = nil
                        end
                    end
                else
                    for k, v in pairs(tempChiled) do
                        v:closeView()
                    end
                    static_rootControl.m_chilrenList[name] = nil
                end
            else
                tempChiled:closeView()
                static_rootControl.m_chilrenList[name] = nil
            end
        elseif (static_ghostChildren ~= nil and static_ghostChildren[name] ~= nil) then
            static_ghostChildren[name]:closeView()
            static_ghostChildren[name] = nil
        end
    else
        if self.m_view and self.m_closing == false then
            self.m_closing = true
            self:releaseVisibleView()
            self.m_view:closeTransition(function()
                self:destroy()
            end)
        end
    end
end

--[[
更新一个消息到消息队列中
msg :消息标记
data:为消息数据
flag:为数据传递标志
	 'this'   当前control消息
	 'parent' 父control消息
	 '其他'   指定名字control消息
]]
function M:updateMsg(msg, data, flag, alias)
    local temp = { m_msg = msg, m_model = data }

    if (flag == 'this' or flag == nil) then
        if self.m_msg then
            self.m_msg:addMsg(temp)
        end
    elseif (flag == 'parent') then
        if (self.m_parent) then
            self.m_parent:updateMsg(msg, data, 'this')
        elseif (static_rootControl) then
            static_rootControl:updateMsg(msg, data, 'this')
        else
            self.m_msg:addMsg(temp)
        end
    else
        if (static_rootControl.m_chilrenList[flag] ~= nil) then
            Logger.log("---------- yock chilren " .. flag)
            local tempChilren = static_rootControl.m_chilrenList[flag]
            if (not isClassOrObject(tempChilren)) then
                if (alias) then
                    if (tempChilren[alias] ~= nil) then
                        tempChilren[alias]:updateMsg(msg, data, 'this')
                    else
                        for k, v in pairs(tempChilren) do
                            Logger.log(k)
                        end
                        Logger.log("---------- yock no chilren " .. flag .. "alias=" .. alias)
                    end
                else
                    Logger.log("----------- updateMsg all chiled " .. flag)
                    for k, v in pairs(tempChilren) do
                        v:updateMsg(msg, data, 'this')
                    end
                end
            else
                static_rootControl.m_chilrenList[flag]:updateMsg(msg, data, 'this')
            end
        elseif (static_ghostChildren ~= nil and static_ghostChildren[flag] ~= nil) then
            static_ghostChildren[flag]:updateMsg(msg, data, 'this')
        else

            for k, v in pairs(static_rootControl.m_chilrenList) do
                Logger.log(k)
            end
            Logger.log("---------- yock no chilren " .. flag)
        end
    end

end

--[[
	发出一个更新全族消息
]]
function M:updateView()
    if (static_rootControl ~= nil) then
        static_rootControl:updateMsg("oo_updata")
    end
end

--[[
	检查是否可以回退
	返回值：true   可以返回
		   false  不可以返回
]]

function M:canBack()
    if (static_pageList:hasData()) then
        return true
    else
        return false
    end
end

--[[
	返回上一个页面
	从历史数据里取得最后一个压栈数据
	还原视图
	duress: 强制重新拿数据，从onCreate开始 true
]]
function M:goBack(duress)
    if (not self:canBack()) then
        self:enterMainPage()
        return
    end
    local tempModel = static_pageList:pop()
    if (tempModel.m_name == static_homeName) then
        static_pageList:cleanAll()
    end
    if tempModel.m_name == "main_page.main_page" then
        self:enterMainPage()
    else
        local goBack = function()
            tempModel.m_type = 2
            if (duress == nil or duress == false) then
                tempModel:callBack(tempModel.m_data)
            else
                tempModel.m_data = nil
                tempModel:onCreate()
            end
        end
        goBack()
    end
end

--[[
	返回当前页面的根节点
	还原视图
	duress: 强制重新拿数据，从onCreate开始 true
]]
function M:goCurrent(duress)
    local control = self.m_parent or static_rootControl
    local model = control.m_model

    if model.m_name == "main_page.main_page" then
        self:enterMainPage()
    else
        model.m_type = 2
        if (duress == nil or duress == false) then
            model:callBack(model.m_model)
        else
            model.m_model = nil
            model:onCreate()
        end
    end
end

--[[
	设置返回重点页面
]]
function M:setHomeName(homeName)
    static_homeName = homeName
end


--[[
	获得根窗口
	根窗口为静态变量
]]
function M:getRootWin()
    local tempRC = self:getRootControl()
    if (tempRC ~= nil) then
        return tempRC.m_view:getRootView()
    else
        return nil
    end
end

--[[
	得到根控制器（control）
]]
function M:getRootControl()
    return static_rootControl
end


--[[
	注册timer回调函数
]]
function M:setTimer(interval, onTimer)
    local tempTimer = { time = 0, inter = interval, callFunc = onTimer }
    local id = #self.m_timerList + 1
    self.m_timerList[id] = tempTimer
    return id
end

--[[
	移出timer回调
]]
function M:removeTimer(id)
    if id then
        self.m_timer_remove[id] = true
    end
end

--- 创建一个只执行一次的回调函数
function M:setOnceTimer(time, onTimer)
    local id
    local func = function(...)
        self:removeTimer(id)
        if type(onTimer) == "function" then
            onTimer(...)
        end
    end
    id = self:setTimer(time, func)
end


--[[
	检查是否有指定子窗口
]]
function M:hasChild(name, alias)
    --如果是空的话则还没有常见view。所以肯定没有子窗口
    if static_rootControl == nil then
        return false
    end

    local tempChilren = static_rootControl.m_chilrenList[name]
    if (tempChilren ~= nil) then
        if (alias == nil) then
            return true
        else
            if (not isClassOrObject(tempChilren)) then
                if (tempChilren[alias] ~= nil) then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    elseif (static_ghostChildren ~= nil and static_ghostChildren[name] ~= nil) then
        return true
    end
    return false
end

--[[
	检查是否有有子窗口
]]
function M:checkHasChild()
    --如果是空的话则还没有常见view。所以肯定没有子窗口
    if static_rootControl == nil then
        return false
    end
    local chilrenList = static_rootControl.m_chilrenList or {}
    local ghostChildren = static_ghostChildren or {}
    return _G.next(chilrenList) ~= nil or _G.next(ghostChildren) ~= nil
end

--[[
	隐藏界面计数++
]]
function M:retainVisibleView()
    --如果是空的话则还没有常见view。所以肯定没有子窗口
    if static_rootControl == nil then
        return
    end
    local size_type = self.m_view.m_size_type or 1
    local tempVT = self.m_view:getType()
    if size_type ~= 1 or tempVT == 1 then
        return
    end
    --Logger.log(self.m_model:getName(), "self.m_model:getName()-----retainVisibleView---->")
    for k, v in pairs(static_rootControl.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                if vc.m_model:getName() ~= self.m_model:getName() then
                    if vc.m_view:getType() == 2 and vc.m_view.m_normal then
                        vc.m_view:retainVisibleView()
                    end
                end
            end
        else
            if v.m_model:getName() ~= self.m_model:getName() then
                if v.m_view:getType() == 2 and v.m_view.m_normal then
                    v.m_view:retainVisibleView()
                end
            end
        end
    end
    static_rootControl.m_view:retainVisibleView()
end

--[[
	隐藏界面计数--
]]
function M:releaseVisibleView()
    --如果是空的话则还没有常见view。所以肯定没有子窗口
    if static_rootControl == nil or self.m_view == nil then
        return
    end
    local size_type = self.m_view.m_size_type or 1
    local tempVT = self.m_view:getType()
    if size_type ~= 1 or tempVT == 1 then
        return
    end
    Logger.log(self.m_model:getName(), "self.m_model:getName()-----releaseVisibleView---->")
    for k, v in pairs(static_rootControl.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                if vc.m_model:getName() ~= self.m_model:getName() then
                    if vc.m_view:getType() == 2 and vc.m_view.m_normal then
                        vc.m_view:releaseVisibleView()
                    end
                end
            end
        else
            if v.m_model:getName() ~= self.m_model:getName() then
                if v.m_view:getType() == 2 and v.m_view.m_normal then
                    v.m_view:releaseVisibleView()
                end
            end
        end
    end
    static_rootControl.m_view:releaseVisibleView()
end

-- ================================= a cut of line =================================

-- 构造结束后调用

function M:onCreate()
    -- Logger.log("------------- control onCreate " .. self.m_model:getName())
end

-- 构造结束后调用
function M:onEnter()
    -- Logger.log("------------- control onEnter " .. self.m_model:getName())
end

-- 消息循环重载后使用
function M:onHandle(msg, data)

end

function M:onUpdate()

end

--[[
	释放内存
]]
function M:freeMemory()
    -- TODO :
end

function M:freeAllMemory()

end

function M:init_oo()
    local ui_root = U3DUtil:GameObject_Find("UIRoot")
    static_root_node = ui_root
    local camera_obj = U3DUtil:GameObject_Find("UIRoot/UICamera")
    if not IsNull(camera_obj) then
        static_ui_camera = UIUtil.findComponent(camera_obj.transform, typeof(U3DUtil:Get_Camera()))
    end
end

function M:enterMainPage()
    static_rootControl:openView("main")
end

--[[
	获取最大的ui层级
]]
function M:getMaxViewSortOrder()
    local sort_order = 0
    if static_rootControl == nil or self.m_view == nil then
        return sort_order
    end
    for k, v in pairs(static_rootControl.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                if vc.m_view.m_sortOrderChange then
                    sort_order = math.max(sort_order, vc.m_view.m_sortOrder)
                end
            end
        else
            if v.m_view.m_sortOrderChange then
                sort_order = math.max(sort_order, v.m_view.m_sortOrder)
            end
        end
    end
    return sort_order
end

--[[
	是否能点击3d场景
]]
function M:can3DTouchByViewName(view_name)
    local can_touch = true
    if static_rootControl == nil or self.m_view == nil then
        return can_touch
    end

    local isGuiding = UserDataManager.guide_data:isGuiding()
    if isGuiding then
        local guide_info = UserDataManager.guide_data:getCurGuideInfo()
        if guide_info and guide_info.key == "Formation" then
            if guide_info.action == 4 then
                return can_touch
            end
        end
    end

    local cur_sort_order = 999999999
    local controls = {}
    for k, v in pairs(static_rootControl.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                if vc.m_model:getName() ~= view_name then
                    table.insert(controls, vc)
                else
                    cur_sort_order = vc.m_view.m_sortOrder
                end
            end
        else
            if v.m_model:getName() ~= view_name then
                table.insert(controls, v)
            else
                cur_sort_order = v.m_view.m_sortOrder
            end
        end
    end
    for i, v in pairs(controls) do
        if v.m_view.m_sortOrder > cur_sort_order then
            can_touch = false
            break
        end
    end
    return can_touch
end

return M