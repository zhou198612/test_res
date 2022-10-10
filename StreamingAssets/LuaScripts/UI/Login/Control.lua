local M = class("LoginControl", LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false
M.m_notice_pop = false

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    --CS.wt.framework.AudioHelper.Instance:InitCommonBank()
    --GameMain.initSound()
    GameVersionConfig.preload_res = false
    self.m_model.m_init_url_count = 0
    self:initUrl()
end

function M:initUrl()
    GameVersionConfig.PORTAL_SERVER_ADDRESS_URL =
    self.m_model.m_init_url_count % 2 == 0 and GameVersionConfig.PORTAL_SERVER_ADDRESS_NET or
            GameVersionConfig.PORTAL_SERVER_ADDRESS_CN
    self.m_model.m_init_url_count = self.m_model.m_init_url_count + 1
    local function responseMethod(response)
        if response then
            local data = Json.decode(response)
            UserDataManager.server_data:setPortalServerAddressData(data)
            self:updateMsg("open_vedio")
        else
            self:initUrl()
        end
    end
    local url = GameVersionConfig.PORTAL_SERVER_ADDRESS_URL
    --NetWork:httpRequest(responseMethod, url, GlobalConfig.GET, {}, "portal_server_address_url", 0, true, 2, true)
end

function M:noSDkLogin()
    --if self.m_model.m_user_name == nil or self.m_model.m_user_name == "" then
    --	self:openView("Login.RegisterPop")
    --else
    --	if self.m_model.auto_register == true then
    --		self:autoRegister()
    --	else
    StatisticsUtil:doPoint("startLogin")
    Logger.log("startLogin")
    self:login()
    --  	end
    --end

    --self:openView("Login.LoginPop")
end

function M:OnSdkInit()
    if SDKUtil.isHaveSDK == true then
        StatisticsUtil:doPoint("onInitSDK")
        Logger.log("onInitSDK")
        self.m_view:sdkVisible(false)
        local function eventBack()
            self.m_view:switchNotice(false)
        end
        self:setOnceTimer(3.0, eventBack)
        self:sdkCheckLogin()
    else
        self.m_view:sdkVisible(true)
        self.m_view:startBtnVisible(true)
        local function eventBack()
            self.m_view:switchNotice(false)
        end
        self:setOnceTimer(3.0, eventBack)
        self:noSDkLogin()
    end
end

function M:sdkCheckLogin()
    SDKUtil:isLogined(
            function(params)
                Logger.log(params, "sdkCheckLogin isLogined ====")
                if params.result == true and self.m_model.m_sdk_login then
                    self.m_view:startBtnVisible(true)
                    self:platformAccess()
                else
                    StatisticsUtil:doPoint("startLogin")
                    Logger.log("startLogin")
                    SDKUtil:logIn(handler(self, self.sdkLoginCall))
                end
            end
    )
end

function M:sdkLoginCall(params)
    self.m_view:startBtnVisible(true)
    if params.result == true then
        StatisticsUtil:doPoint("loginSuccess")
        StatisticsUtil:sendLoginPointLog("loginSuccess")
        StatisticsUtil:doAppsFlyerPoint("RegistrationComplete","fb_mobile_complete_registration")
        Logger.log("loginSuccess")
        self.m_model:setSdkAccount(params)
        self:platformAccess()
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0448"), delay_close = 2})
    end
end

function M:platformAccess()
    local function accessCallback(response)
        UserDataManager.certification = response.certification
        UserDataManager.client_data.user_account = response.account
        UserDataManager.client_data.openid = response.openid
        UserDataManager.client_data.sk = response.sk
        UserDataManager.client_data.nosdk = false
        UserDataManager.client_data:setSk(response.sk)
        UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
        UserDataManager.server_data:setServerData(response.current_server)
        UserDataManager.server_data:setUserSid(response.sid)
        local current_server = response.current_server or {}
        local uid = current_server.uid or ""
        UserDataManager.client_data.is_new_user = uid == ""
        --self:openView("Login.Update")
        --self:updateMsg("start_btn")
        self.m_view:refreshUI()
    end
    local params = {  device_mark = UserDataManager.client_data.device_mark }
    params.channel = self.m_model.m_channel
    params.channel_id = self.m_model.m_channelId
    params.app_id = self.m_model.m_appId
    params.token = self.m_model.m_token
    params.uid = self.m_model.m_uid
    params.cpUid = self.m_model.m_cpUid
    params.openid = self.m_model.m_cpUid
    params.showName = self.m_model.m_showName
    params.certification = self.m_model.m_certification
    params.type = self.m_model.m_type
    params.isRelated = self.m_model.m_isRelated
    SDKUtil:appendPlatformParam(params)
    self.m_model:getNetData("platform_access", params, accessCallback, nil, true) -- a
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:closeView()
    elseif msg == "start_btn" then
        self:startGame()
   
    elseif msg == "select_server_btn" then
        self:getServerList()
    elseif msg == "account_btn" then
        self:openView("Login.LoginPop")
    elseif msg == "sdk_account_btn" then
        self:openView("Login.LoginSwitch", {sdkLoginCall = handler(self, self.sdkLoginCall)})
    elseif msg == "select_server" then
        self.m_view:refreshUI()
    elseif msg == "open_vedio" then
        -- end
        -- if U3DUtil:PlayerPrefs_GetInt("player_vedio", 0) == 0 then
        -- 	self:openView("Pops.VedioPlayerPop", {callback = function()
        -- 		self:vedioEndCall()
        -- 	end})
        -- 	U3DUtil:PlayerPrefs_SetInt("player_vedio", 1)
        -- else
        self:vedioEndCall()
    elseif msg == "vedio_btn" then
        self:openView("Pops.VedioPlayerPop")
    elseif msg == "btn_notice" then
        self:openView("Notice")
    elseif msg == "open_notice" then
        --else
        --	self.m_notice_pop = true
        --end
        --if self.m_notice_pop then
        self:openView("Notice")
    elseif msg == "btn_des" then
        self.m_view:setObjectVisible("des_node", true)
        self.m_view:setObjectVisible("btn_close", true)
    elseif msg == "btn_age" then
        self.m_view:setObjectVisible("age_node", true)
        self.m_view:setObjectVisible("btn_close", true)
    elseif msg == "btn_service" then
        self.m_view:setObjectVisible("service_node", true)
        self.m_view:setObjectVisible("btn_close", true)
    elseif msg == "btn_privacy" then
        self.m_view:setObjectVisible("privacy_node", true)
        self.m_view:setObjectVisible("btn_close", true)
    elseif msg == "btn_close" then
        self.m_view:setObjectVisible("des_node", false)
        self.m_view:setObjectVisible("btn_close", false)
        self.m_view:setObjectVisible("age_node", false)
        self.m_view:setObjectVisible("service_node", false)
        self.m_view:setObjectVisible("privacy_node", false)
    end
end

function M:vedioEndCall()
    audio:SendEvtBGM("9inspiring_award")
    self.m_view:releaseVisibleView()
    self:OnSdkInit()
end

function M:autoRegister()
    local account = self.m_model.m_user_name
    local password = self.m_model.m_user_password

    local params = {device_mark = UserDataManager.client_data.device_mark,
                    passwd = tostring(password), account = tostring(account)}
    SDKUtil:appendPlatformParam(params)
    local netCallback = function(response)
        U3DUtil:PlayerPrefs_SetString("username", account)
        U3DUtil:PlayerPrefs_SetString("password", password)

        UserDataManager.client_data.user_account = tostring(account)
        Logger.log(account, "account =========")
        --注册完之后直接进游戏
        UserDataManager.client_data:setSk(response.sk)
        UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
        UserDataManager.server_data:setServerData(response.current_server)
        UserDataManager.server_data:setUserSid(response.sid)
        UserDataManager.client_data.is_new_user = true
        self:updateMsg("start_btn")
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("register", params, netCallback) -- a
end

-- 有本地账号默认自动登录
function M:login()
    local account = self.m_model.m_user_name
    local password = self.m_model.m_user_password
    if account ~= "" and password ~= "" then
        local params = {  device_mark = UserDataManager.client_data.device_mark,
                          passwd = tostring(password), account = tostring(account)}
        SDKUtil:appendPlatformParam(params)
        local function netCallback(response, tag)
            if response then
                StatisticsUtil:doPoint("loginSuccess")
                StatisticsUtil:sendLoginPointLog("loginSuccess")
                StatisticsUtil:doAppsFlyerPoint("RegistrationComplete","fb_mobile_complete_registration")
                Logger.log("loginSuccess")
                UserDataManager.certification = response.certification
                U3DUtil:PlayerPrefs_SetString("username", account)
                U3DUtil:PlayerPrefs_SetString("password", password)
                UserDataManager.client_data.user_account = tostring(account)
                UserDataManager.client_data:setSk(response.sk)
                UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
                UserDataManager.server_data:setServerData(response.current_server)
                UserDataManager.server_data:setUserSid(response.sid)
                local current_server = response.current_server or {}
                local uid = current_server.uid or ""
                UserDataManager.client_data.is_new_user = uid == ""
                self.m_view:refreshUI()
            else
            end
        end
        self.m_model:getNetData("login", params, netCallback, nil, true) -- a
    end
end

-- 开始游戏
function M:startGame()
    local account = UserDataManager.client_data.user_account
    local server = UserDataManager.server_data:getServerId()

    if account and server then
        StatisticsUtil:doPoint("clickStartGame")
        StatisticsUtil:doAppsFlyerPoint("af_start_triale","SubmitApplicationn")
        Logger.log("clickStartGame")
        local params = { device_mark = UserDataManager.client_data.device_mark,
                         account = tostring(account), server = tostring(server)}
        SDKUtil:appendPlatformParam(params)
        local function netCallback(response)
            if response then
                UserDataManager.server_data:setServerData(response.current_server)
                NetWork:resetServerRequestCount()
                --self:userGameInfo()
                --ChatUtil:connectChatServer()
                self:openView("Login.Update")
            else
                self:startGame()
            end
        end
        self.m_model:getNetData("login_server", params, netCallback, nil, true) -- a
    else
        if SDKUtil.isHaveSDK == false then
            self:openView("Login.RegisterPop")
        else
            self:sdkCheckLogin()
        end
    end
end

-- 请求玩家本地存储数据
function M:userGameInfo()
    local function netCallback(response)
        if response then
            UserDataManager:updateUserGameInfo(response)

            local function __cbfunc()
                if response.is_first_name == 0 then
                    --self:openView("CreateName")
                    --self:userMain()
                    local finish_click1 = function()
                        local finish_click2 = function()
                            StatisticsUtil:doPoint("changeName")
                            Logger.log("changeName")
                            self:openView("CreateName")
                        end
                        local story_id = ConfigManager:getCommonValueById(15)
                        if story_id ~= 0 and story_id[2] then
                            self:openView("Story", {id = story_id, finish_click = finish_click2})
                        else
                            finish_click2()
                        end
                    end
                    local story_id = ConfigManager:getCommonValueById(15)
                    if story_id ~= 0 and story_id[1] then
                        StatisticsUtil:doPoint("startTitleStory")
                        Logger.log("startTitleStory")
                        self:openView("Story", {id = story_id, finish_click = finish_click1})
                    else
                        finish_click1()
                    end
                else
                    local stage_id = ConfigManager:getCommonValueById(107,0)
                    if next(response.prepare_stage_stars) or stage_id == 0 then
                        self:userMain()
                    else
                        StatisticsUtil:doPoint("firstStagePreStory")
                        Logger.log("firstStagePreStory")
                        QuickOpenFuncUtil:openFunc(10, {stage_id = stage_id, is_temp_stage = true, mask = 2})
                    end
                end
            end

            self:openView("Loading.Preloading", {callback = __cbfunc})
            --临时测试数据
            StatisticsUtil:doPoint("clickEnterGameButton")
        else
            self:userGameInfo()
        end
    end
    self.m_model:getNetData("user_game_info", nil, netCallback, nil, true)
end

-- 请求主场景数据
function M:userMain()
    self:goMainScene()
end

-- 测试获取服务器列表，正常流程不会用到
function M:getServerList()
    local account = UserDataManager.client_data.user_account

    if account then
        local params = {account = tostring(account)}
        local netCallback = function(response)
            Logger.log("-------- server_list -------")
            self:openView("Login.LoginServer", response.servers)
        end
        self.m_model:getNetData("server_list", params, netCallback)
    end
end

-- 进入主场景
function M:goMainScene()
    --local function cbfunc()
    --    self:openView("Main")
    --end
    --
    --self:openView("Loading.Preloading", {callback = cbfunc})
    self:openView("Main")
end

function M:openViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Login.Update" then
        self.m_view:setObjectVisible("info_node", false)
    end
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Login.Update" then
        self.m_view:setObjectVisible("info_node", true)
        if self.m_notice_pop then
            --self:openView("Notice")
        else
            self.m_notice_pop = true
        end
        if GameMain.download_game_resources ~= true then
            self:userGameInfo()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    M.super.destroy(self)
end

return M
