local M = class("LoginPopControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "sign_up_btn" then	-- 注册
    	self:closeView()
    	self:openView("Login.RegisterPop")
    elseif msg == "login_btn" then -- 登录
    	self:Login()
    end
end

function M:Login()
	local account, password = self.m_view:getUserNameAndPassword()
	if account ~= "" and password ~= "" then
		local params = { device_mark = UserDataManager.client_data.device_mark,
			passwd=tostring(password), account=tostring(account)}
		SDKUtil:appendPlatformParam(params)
		local netCallback = function(response)
			StatisticsUtil:doPoint("loginSuccess")
			StatisticsUtil:sendLoginPointLog("loginSuccess")
			StatisticsUtil:doAppsFlyerPoint("RegistrationComplete","fb_mobile_complete_registration")
			Logger.log("loginSuccess")
			U3DUtil:PlayerPrefs_SetString("username", account)
			U3DUtil:PlayerPrefs_SetString("password", password)

    		UserDataManager.client_data.user_account = tostring(account)
			UserDataManager.client_data:setSk(response.sk)
			UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
			UserDataManager.server_data:setServerData(response.current_server)
			UserDataManager.server_data:setUserSid(response.sid)
			UserDataManager.certification = response.certification
			if response.certification == 0 then -- 需要认证
				--self:openView("Login.PlayerAuthenticationPop")
				self:updateMsg("start_btn", nil, "parent")
			else
				self:updateMsg("start_btn", nil, "parent")
			end
			self:closeView()
	    end
	    self.m_model:getNetData("login", params, netCallback)
	end
end

return M
	