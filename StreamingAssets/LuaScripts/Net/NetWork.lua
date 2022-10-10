------------------- NetWork

local M = {
    m_requestMap = {},
    m_request_count = 0,
    m_server_request_count = 1024,
    m_request_list = {},
    m_cur_request = nil,
}

local HttpRequest = CS.wt.framework.HttpRequest.Inst
local __RETRY_COUNT = 2
local __RETRY_TIME = 2     -- 多长时间后重试, 单位秒
local __DEFAULT_TIMEOUT = 5
G_GUIDE_FORCE_NET_COMPLETE = false -- 标记开始新手引导，在此期间，需要等到数据恢复后再继续 


function M:resetServerRequestCount()
    self.m_server_request_count = 1024
end

function M:closeLoading(request)
    local loadingFlag = request and request.loadingFlag
    if loadingFlag ~= 0 then
        static_rootControl:closeView("Loading.SmallLoading")
        static_rootControl:closeView("Loading.BigLoading")
    end
end

function M:handleCallback(request, status_code)
    if request.returnFlag and type(request.callback) == "function" then
        request.callback(nil, request.tag, tostring(status_code or ""))
    end
end

function M:handleNullData(data, request)
    if not request.showTips then
        self:handleCallback(request)
    else
        self:showRequestFailedTip(function()
            self:handleCallback(request)
        end, Language:getTextByKey("new_str_0009"))
    end
end

function M:handleDownloadGame(data, request)
    local updateUrl = data.url
    if updateUrl == nil then return end
    local params =
    {
        on_ok_call = function(msg)
            -- TODO : 打开下载链接 暂时重新登录
            GameMain.reStart()
        end,   
        no_close_btn = true,
        text = data.msg or Language:getTextByKey("new_str_0008"),
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

--- 更新配置提示
function M:showConfigChangeTip(data, request)
    local tips = data.config_refresh_text or Language:getTextByKey("new_str_0479")
    local params =
    {
        on_ok_call = function(msg)
            GameMain.reStart()
        end,
        no_close_btn = true,
        text = tips,
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

-- 添加配置更新的处理
function M:handleConfigChange(data, request)
    local all_config_version = data.all_config_version or ""
    local data = data.data
    if data.config_refresh and tonumber(data.config_refresh) == 1 then -- 需要更新配置
        local str = U3DUtil:PlayerPrefs_GetString("all_config_version", "")
        if str ~= nil and str ~= all_config_version then
            self:showConfigChangeTip(data, request)
        end
    end
end

function M:handleStatusError(data, request)
    if not request.showTips then
        self:handleCallback(request, data.status)
    else
        local error_msg = data.msg
        self:showNetErrorTip(function()
            self:handleCallback(request, data.status)
        end, error_msg)
    end
end



function M:showNetErrorTip(callback, error_msg)
    local params =
    {
        on_ok_call = function(msg)
            if type(callback) == "function" then
                callback()
            end
        end,
        no_close_btn = true,
        text = error_msg or Language:getTextByKey("new_str_0011")
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:handleServerNotOpen(data, request)
    local params =
    {
        on_ok_call = function(msg)
            GameMain.reStart()
        end,
        no_close_btn = true,
        text = data.msg or Language:getTextByKey("new_str_0010")
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:rewardTips(data)
    if type(data) == "table" then
        local delay_open = 0
        for k,v in pairs(data) do
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(v), delay_open = delay_open, delay_close = 2})
            delay_open = delay_open + 1
        end
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(data), delay_close = 2})
    end
end

function M:handleNetWorkFailed(net_data, request)
    local function doRetry()
        if request.retry then request.retry = (request.retry or 0) + 1 end        -- 记录重试次数
        self:httpRequestBase(request)
    end
    if request.retry_count > 0 then   -- 有重试次数等待响应
        request.retry_count = request.retry_count - 1
        EventDispatcher:registerTimeEvent("tryAgain", doRetry, __RETRY_TIME, __RETRY_TIME)
    elseif G_GUIDE_FORCE_NET_COMPLETE and request.showTips then   -- 有新手引导，必须获取数据
        request.retry_count = RETRY_COUNT or 2
        self:showRequestFailedTip(doRetry)
    else
        self:closeLoading(request)
        self:cleanRequestByTag(request.tag_sign_key)
        local showTips = request.showTips
        if not showTips then -- 不需要弹框提示
            self:handleCallback(request)
        else
            self:showRequestFailedTip(function()
                self:handleCallback(request)
            end, net_data)
        end
    end
end

function M:showRequestFailedTip(callback, error_msg)
    local error_msg = error_msg or Language:getTextByKey("new_str_0004")
    local code = 0
    local msg = string.format("[%s(%s)]", tostring(error_msg), tostring(code))
    local params = {
        text = msg,
        on_ok_call = callback,   
        on_cancel_call = callback,
    }
    static_rootControl:openView("Pops.CommonPop", params, "netFailed")
end

function M:cleanRequestByTag(tag)
    self.m_requestMap[tag] = nil
end

-- 网络回调处理
function M:httpResponseHander(success, net_data, tag_sign_key)
    local request = self.m_requestMap[tag_sign_key]
    if success then -- 成功
        local tag = request.tag
        self:closeLoading(request)
        self:cleanRequestByTag(tag_sign_key)
        if request.ingnoreState then
            request.callback(net_data, tag)
            return
        end
        local tag_tab = string.split(tag_sign_key, "##")
        local first_value = tag_tab[1]
        if request.method == GlobalConfig.POST then
            local crypto_url_value = NetUrl.getCryptoUrlValue(first_value)
            local temp_data = nil
            if crypto_url_value == 1 then
                temp_data = UserDataManager.client_data:loginDecryptBase64StringToString(net_data)
            elseif crypto_url_value == 2 then
                -- 不做解密处理
                temp_data = net_data
            else
                temp_data = UserDataManager.client_data:decryptBase64StringToString(net_data)
            end
            if temp_data == nil then

                UserDataManager.__heartStop = true

                local params =
                {
                    on_ok_call = function(msg)
                        UserDataManager.__heartStop = nil
                        GameMain.reStart()
                    end,   
                    no_close_btn = true,
                    text = Language:getTextByKey("sys_login_other")
                }
                static_rootControl:openView("Pops.CommonPop", params, nil, true)
                return

            end
            net_data = temp_data
        end

        local data = Json.decode(net_data)
        if not data then
            self:handleNullData(data, request)
            return
        end
        -- 客户端升级提示
        local client_upgrade = data.data and data.data.client_upgrade
        if client_upgrade then  -- 客户端升级
            self:handleDownloadGame(client_upgrade, request)
            return
        end
        local status = tostring(data.status)
        if status == "0" or status == "ok" then  --数据正常
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_back",data = data, tag = tag})
            -- 响应callback
            if type(request.callback) == "function" then
                request.callback(data.data, tag)
            else
                Logger.log("not callback func => " .. tostring(tag))
            end
            self:handleConfigChange(data, request)
            if data.data.reward and data.data.reward.reward_full_tips then
                self:rewardTips(data.data.reward.reward_full_tips)
            end

        elseif status == "error_1024" then -- 服务器尚未开启
            self:handleServerNotOpen(data, request)
        --elseif status == "15003"  then --打公会boss期间被踢出公会
        --    SceneManager:changeScene(1)
        --    static_rootControl:closeAllViewPop()
        --    self:showNetErrorTip(nil, data.msg)
        elseif status == "1849" then
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.MOT_MONEY, {event="not_diamond"})
        elseif status == "1851" then
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.MOT_MONEY, {event="not_coin"})
        elseif status == "14204" then
                --背包和服务器数据不一致时需要更新
                local data_sync = data.data_sync
                if data_sync then
                    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_sync",data = data_sync, tag = tag})
                end 
        elseif status == "42" then
            --被服务器踢下线
            local error_msg = data.msg
            self:showNetErrorTip(function()
                GameMain.reStart()
            end, error_msg)
        else

            -- 发生的情况是和服务器数据不一致时需要更新
            local data_sync = data.data_sync
            if data_sync then
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_sync",data = data_sync, tag = tag})
            end
            self:handleStatusError(data, request)

        end
    else -- 网络请求失败
        self:handleNetWorkFailed(net_data, request)
    end
end

function M:errorHttpResponseHander(success, net_data, tag_sign_key)
    local request = self.m_requestMap[tag_sign_key]
    if success then -- 成功
        local temp_data = UserDataManager.client_data:FromBase64String(net_data)

        local data = Json.decode(temp_data)
        if not data then
            self:handleNullData(data, request)
            return
        end
    else -- 网络请求失败
        self:handleNetWorkFailed(net_data, request)
    end
end

--[[--
    发送http请求
]]


function M:httpRequestBase(request)
    local params_str = request.params_str or ""
    local method = string.upper(tostring(request.method))
    local url = request.url
    if method == GlobalConfig.GET and params_str ~= "" then
        url = url .. "&" .. params_str
    end
    if request.retry and request.retry > 0 then
        if request.ingnoreState then
            url = url .. "?retry=" .. tostring(request.retry)
        else
            url = url .. "&retry=" .. tostring(request.retry)
        end
    end
    Logger.log("<color=yellow>" .. url .. "</color>")
    local time_out = __DEFAULT_TIMEOUT
    if request.ingnoreState then
        time_out = 15
    end
    HttpRequest:SendMsg(url, request.tag_sign_key, params_str,method, time_out, handler(self, self.httpResponseHander))
end

--[[
    统一的网络接口函数
    loadingFlag : 0        --> 不需要loading
                  1        --> 大loading
                  2        --> 小laoding

    returnFlag: 错误后是是否还回调
]]
function M:httpRequest(callback, url, method, params, tag, loadingFlag, returnFlag, delayShowLoading, ingnoreState)
    loadingFlag = loadingFlag or 1 
    if loadingFlag == 1 then
        static_rootControl:openView("Loading.SmallLoading",{delay_show = delayShowLoading or 2})
    elseif loadingFlag == 2 then
        static_rootControl:openView("Loading.BigLoading",{delay_show = delayShowLoading})
    end
    if returnFlag == nil then returnFlag = false end
    method = method or GlobalConfig.POST
    local params_str = ""
    local type_name = type(params)
    local crypto_url_value = NetUrl.getCryptoUrlValue(tag)
    if type_name == "table" or type_name == "nil" then
        params = params or {}
        if method == GlobalConfig.POST then
            params["sid"] = UserDataManager.server_data:getUserSid()
            if crypto_url_value ~= 1 then
                self.m_server_request_count = (self.m_server_request_count + 1)%100000000
                params["seq"] = self.m_server_request_count
            end
            params_str = Json.encode(params)
        else
            for k, v in pairs(params) do
                if type(v) == "table" then              -- 如果参数是表，那么再拆分一次 只支持一层
                    for kk,vv in pairs(v) do
                        params_str = params_str .. k .. "=" .. vv .. "&"
                    end
                else
                    params_str = params_str .. k .. "=" .. v .. "&"
                end
            end
        end
    elseif type_name == "string" then
        params_str = params
    end

    if method == GlobalConfig.POST then
        if crypto_url_value == 1 then
            local temp_data = UserDataManager.client_data:loginEncryptToBase64String(params_str)
            params_str = temp_data
        elseif crypto_url_value == 2 then
            -- 不做加密处理
        else
            local temp_data = UserDataManager.client_data:encryptToBase64String(params_str)
            params_str = temp_data
        end
    end

    self.m_request_count = (self.m_request_count + 1)%100000000
    local tag_sign_key = tag .. "##" .. tostring(self.m_request_count)
    local request = self.m_requestMap[tag_sign_key]
    if request == nil then
    	request = {
    		callback = callback,
    		url = url,
    		method = method,
    		params = params,
            params_str = params_str,
            tag = tag,
            retry = loadingFlag ~= 0 and 0 or nil , -- loadingFlag为0时不附加 retry=1,2,3
            tag_sign_key = tag_sign_key,
    		loadingFlag = loadingFlag,
    		returnFlag = returnFlag,
    		retry_count = __RETRY_COUNT,
    		showTips = loadingFlag ~= 0,-- 当网络失败或者是异常的时候是否需要弹提示框，此处默认是没有loading的是不弹任何提示的
    	    ingnoreState = ingnoreState
        }
        self.m_requestMap[tag_sign_key] = request
    else
        Logger.logWarning(tag_sign_key ,"net request tag exist : ")
    end
    self:httpRequestBase(request)
end

function M:errorHttpRequest(callback, url, method, params, tag, loadingFlag, returnFlag, delayShowLoading, ingnoreState)
    local params_str = Json.encode(params)
    local temp_data = UserDataManager.client_data:ToBase64String(params_str)
    params_str = temp_data
    self.m_request_count = (self.m_request_count + 1)%100000000
    local tag_sign_key = tag .. "##" .. tostring(self.m_request_count)
    local request = self.m_requestMap[tag_sign_key]
    if request == nil then
        request = {
            callback = callback,
            url = url,
            method = method,
            params = params,
            params_str = params_str,
            tag = tag,
            retry = loadingFlag ~= 0 and 0 or nil , -- loadingFlag为0时不附加 retry=1,2,3
            tag_sign_key = tag_sign_key,
            loadingFlag = loadingFlag,
            returnFlag = returnFlag,
            retry_count = __RETRY_COUNT,
            showTips = loadingFlag ~= 0,-- 当网络失败或者是异常的时候是否需要弹提示框，此处默认是没有loading的是不弹任何提示的
            ingnoreState = ingnoreState
        }
        self.m_requestMap[tag_sign_key] = request
    else
        Logger.logWarning(tag_sign_key ,"net request tag exist : ")
    end
    self:errorHttpRequestBase(request)
end

function M:errorHttpRequestBase(request)
    local params_str = request.params_str or ""
    local method = string.upper(tostring(request.method))
    local url = request.url
    if method == GlobalConfig.GET and params_str ~= "" then
        url = url .. "&" .. params_str
    end
    if request.retry then
        if request.ingnoreState then
            url = url .. "?retry=" .. tostring(request.retry)
        else
            url = url .. "&retry=" .. tostring(request.retry)
        end
    end
    Logger.log("<color=yellow>" .. url .. "</color>")
    local time_out = __DEFAULT_TIMEOUT
    if request.ingnoreState then
        time_out = 15
    end
    HttpRequest:SendMsg(url, request.tag_sign_key, params_str,method, time_out, handler(self, self.errorHttpResponseHander))
end

return M
