------------------- StatisticsUtil
CS.StatisticsHelper.Init()
StatisticsHelper = CS.StatisticsHelper

local M = {
    -- 打点数据。
    m_point_data = {
        enterGame = {action_id = 1, name = "enterGame"},  --点击icon
        startPage = {action_id = 2, name = "startPage"},  --启动页
        openLogin = {action_id = 3, name = "openLogin"},  --加载登录界面
        enterLogin = {action_id = 5, name = "enterLogin"},  --进入登录界面
        onInitSDK = {action_id = 6, name = "onInitSDK"},     -- SDK初始化完成
        healthyNotice = {action_id = 4, name = "healthyNotice"},  --健康公告
        startLogin = {action_id = 7, name = "startLogin"},     -- 开始登录
        loginSuccess = {action_id = 8, name = "loginSuccess"},     -- 登录成功
        clickStartGame = {action_id = 9, name = "clickStartGame"},     -- 点击开始游戏
        startDownloadHotUpdate = {action_id = 10, name = "startDownloadHotUpdate"},     -- 开始热更时
        startDownloadConfig = {action_id = 11, name = "startDownloadConfig"},     -- 开始下载配置时
        startTitleStory = {action_id = 12, name = "startTitleStory"},     -- 开始片头剧情
        changeName = {action_id = 13, name = "changeName"},  --起名
        firstStagePreStory = {action_id = 14, name = "firstStagePreStory"},  --首战前置剧情
        firstStage = {action_id = 15, name = "firstStage"},  --首战关卡
        startNewGuide = {action_id = 16, name = "startNewGuide"},     -- 新手引导开始时
        firstStageSettlement = {action_id = 17, name = "firstStageSettlement"},  --首战结算
        firstStagePostStory = {action_id = 18, name = "firstStagePostStory"},  --首战后置剧情
        firstStageReward = {action_id = 19, name = "firstStageReward"},  --首战奖励
        enterMain = {action_id = 20, name = "enterMain"},  --进入主界面
    },
    m_bundles_point_data = {
        DownloadBundles = {action_id = 1000, name = "DownloadBundles"},
        DownloadFile = {action_id = 1001, name = "DownloadFile"},
        ReStartBundles = {action_id = 1002, name = "ReStartBundles"},
    },
    m_resource_point_data = {
        startDownloadHotUpdate = {action_id = 1, name = "startDownloadHotUpdate"},  --开始热更资源包
        endDownloadHotUpdate = {action_id = 2, name = "endDownloadHotUpdate"},  --完成热更资源包
    },
    m_config_point_data = {
        startDownloadConfig = {action_id = 1, name = "startDownloadConfig"},  --开始热更配置
        endDownloadConfig = {action_id = 2, name = "endDownloadConfig"},  --完成热更配置
    },
    m_login_point_data = {
        enterGame = {action_id = 1, name = "enterGame"},  --点击icon
        loginSuccess = {action_id = 2, name = "loginSuccess"},  --登陆成功
        enterMain = {action_id = 3, name = "enterMain"},  --进入游戏
    },
}

-- 发送打点数据  
function M:sendPointLog(data,eventName,fb_eventName)
	--if GameVersionConfig and not GameVersionConfig.Debug then
	--	data = data or {}
    --    SDKUtil:appendPlatformParam(data)
	--    local strinfo = "&"
	--    for k,v in pairs(data) do
	--    	strinfo = strinfo .. tostring(k) ..  "=" .. tostring(v) .. "&"
	--    end
    --    local url = NetUrl.getUrlForKey("device_action")
	--    url = tostring(url) .. "&" .. strinfo .. NetUrl.getExtUrlParam()
	--    NetWork:httpRequest(function ()
    --        if data.name == "startNewGuide" then
    --            self:finishDoPoint()
    --        end
    --    end, url, GlobalConfig.GET, nil, "device_action", 0)
	--end
    data = data or {}
    SDKUtil:appendPlatformParam(data)
    local url = NetUrl.getUrlForKey("device_action")
    NetWork:httpRequest(function ()
        if data.name == "enterMain" then
            --self:finishDoPoint()
        end
    end, url, GlobalConfig.POST, data, "device_action", 0)
    self:logToBIByEvent(eventName,data,fb_eventName)
end

-- 打点
function M:doPoint(id)
    --local point_data_finish = UserDataManager.local_data:getLocalDataByKey("point_data_finish", "")
    --if point_data_finish ~= "over" then 
    --    local point_data = self.m_point_data[id]
    --    if point_data then
    --    	self:sendPointLog(point_data)
    --	end
    --end
end

-- appsflyer打点 RegistrationComplete(完成注册)、af_start_trial(创建角色)、af_tutorial_completion(完成新手)、af_purchase(充值)
-- facebook 打点 fb_mobile_complete_registration(完成注册)、SubmitApplication(创建角色)、fb_mobile_tutorial_completion(完成新手)、Purchase(充值)
function M:doAppsFlyerPoint(eventName,fb_eventName, eventData)
    local data_list = {}
    local params = {}
    params["af_registration_method"] = data_list ~= nil and data_list["af_registration_method"] or 0
    params["af_success"] = data_list ~= nil and data_list["af_success"] or 0
    params["af_currency"] = data_list ~= nil and data_list["af_currency"] or 0
    params["af_revenue"] = data_list ~= nil and data_list["af_revenue"] or 0
    params["af_quantity"] = data_list ~= nil and data_list["af_quantity"] or 0
    local data = {}


    SDKUtil:appendPlatformParam(data)
    
    if eventData then
        
        data["af_revenue"] = eventData.price
        data["af_quantity"] = 1
        data["af_content_id"] = eventData.goods_id
        data["af_currency"] = eventData.currency
        data["pay_info_price"] = eventData.payInfoPrice
        
    end

    self:logToBIByEvent(eventName,data,fb_eventName)
end

-- 标志打点完成。
function M:finishDoPoint()
    --UserDataManager.local_data:setLocalDataByKey("point_data_finish", "over")
end

-- bundles下载后期资源打点
function M:sendBundlesPointLog(id)
    local params = self.m_bundles_point_data[id]
    SDKUtil:appendPlatformParam(params)
    local url = NetUrl.getUrlForKey("device_bundles_action")
    NetWork:httpRequest(function () end, url, GlobalConfig.POST, params, "device_bundles_action", 0)
end

-- 资源包统计打点
function M:sendResourcePointLog(id, fileName)
    local params = self.m_resource_point_data[id]
    params.resource_name = fileName
    SDKUtil:appendPlatformParam(params)
    local url = NetUrl.getUrlForKey("device_resource_action")
    NetWork:httpRequest(function () end, url, GlobalConfig.POST, params, "device_resource_action", 0)
end

-- 配置统计打点
function M:sendConfigPointLog(id)
    local params = self.m_config_point_data[id]
    SDKUtil:appendPlatformParam(params)
    local url = NetUrl.getUrlForKey("device_config_action")
    NetWork:httpRequest(function () end, url, GlobalConfig.POST, params, "device_config_action", 0)
end

-- 登录统计打点
function M:sendLoginPointLog(id)
    local params = self.m_login_point_data[id]
    SDKUtil:appendPlatformParam(params)
    local url = NetUrl.getUrlForKey("device_login_action")
    NetWork:httpRequest(function () end, url, GlobalConfig.POST, params, "device_login_action", 0)
end

function M:statusBiParams(params)
    params = params or {}
    if UserDataManager.user_data and UserDataManager.user_data.user_status then
        params.uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
        params.name = UserDataManager.user_data:getUserStatusDataByKey("name")
        params.level = UserDataManager.user_data:getUserStatusDataByKey("level")
    end
    if UserDataManager.client_data then
        params.user_unique_id = UserDataManager.client_data.openid --"(必填)用户OPENID号"
    else
        params.user_unique_id = ""
    end
    if UserDataManager.server_data then
        local serverData = UserDataManager.server_data:getServerData()
        if serverData then
            params.server_id = serverData.server
            --params.server_name = serverData.server_name
            params.reg_time = serverData.reg_time
        end
    else
        params.server_id = ""
        params.reg_time = ""
    end
    params.time = UserDataManager:getServerTime() --"游戏事件的时间"
    Logger.log(params,"statusBiParams ======")
end

function M:logToBIByEvent(eventName, params,fb_eventName)
    if SDKUtil.isHaveSDK then
        params = params or {}
        self:statusBiParams(params)
       
    end

    StatisticsHelper.logToBIByEvent(eventName, Json.encode(params),fb_eventName)
end

return M
