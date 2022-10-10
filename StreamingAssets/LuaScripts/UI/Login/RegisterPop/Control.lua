local M = class("RegisterPopControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "sign_up_btn" then	-- 注册
		if self.m_model.is_agree then
			self:register()
		else
			GameUtil:lookInfoTips(static_rootControl, {msg = "请同意协议政策", delay_close = 2})
		end
	elseif msg == "cancle_btn" then -- 取消
		self:closeView()
	elseif msg == "btn_agree" then -- 同意条款
		self.m_model.is_agree = not self.m_model.is_agree
		self.m_view:refreshAgree()
	elseif msg == "btn_service" then --打开条款
		self.m_view:ServerActive(true)
	elseif msg == "btn_close_service" then --关闭条款
		self.m_view:ServerActive(false)
	end
end

function M:register()
	local account, password1, password2 = self.m_view:getNameAndPassword()

	if account ~= "" and password1 ~= "" and password2 ~= "" then
		if password1 == password2 then
			local params = { device_mark = UserDataManager.client_data.device_mark,
				passwd=tostring(password1), account=tostring(account)}
			SDKUtil:appendPlatformParam(params)
			local netCallback = function(response)
				StatisticsUtil:doPoint("loginSuccess")
				StatisticsUtil:sendLoginPointLog("loginSuccess")
				StatisticsUtil:doAppsFlyerPoint("RegistrationComplete","fb_mobile_complete_registration")
				Logger.logError("loginSuccess")
				U3DUtil:PlayerPrefs_SetString("username", account)
				U3DUtil:PlayerPrefs_SetString("password", password1)

        		UserDataManager.client_data.user_account = tostring(account)
        		Logger.log(account,"account =========")
       			--注册完之后直接进游戏
				UserDataManager.client_data:setSk(response.sk)
				UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
				UserDataManager.server_data:setServerData(response.current_server)
				UserDataManager.server_data:setUserSid(response.sid)
				UserDataManager.client_data.is_new_user = true
				UserDataManager.certification = response.certification
				self:closeView()
				if response.certification == 0 then -- 需要认证
					--self:openView("Login.PlayerAuthenticationPop")
					self:updateMsg("start_btn", nil, "parent")
				else
					self:updateMsg("start_btn", nil, "parent")
				end
		    end
		    self.m_model:getNetData("register", params, netCallback)
		else
			Logger.log("请确认你的密码是否一致")
		end
	else
		Logger.log("缺少用户名或密码")
	end
end

return M
	