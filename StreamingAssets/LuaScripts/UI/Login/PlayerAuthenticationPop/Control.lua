local M = class("PlayerAuthenticationPopControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "ok_btn" then -- 提交认证
		self:submitAuthenticationInfo()
	elseif msg == "btn_close" then
		self:closeView()
	end
end

function M:submitAuthenticationInfo()
	local user_account = UserDataManager.client_data.user_account
	if user_account == nil or user_account == "" then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0257"), delay_close = 2})
		self:closeView()
		return
	end
	local name, card_id_num = self.m_view:getNameAndCardIdNum()
	if name ~= "" and card_id_num ~= "" then
		local params = {card_name=tostring(name), card_num=tostring(card_id_num), account = UserDataManager.client_data.user_account}
	    local netCallback = function(response)
			UserDataManager.certification = 1
	    	GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0256"), delay_close = 2})
			self:updateMsg("refresh_anti", {flag = false}, "parent")
			if self.m_model.callback then
				--self.m_model.callback()
			end
			self:closeView()
	    end
		local uid = UserDataManager.user_data:getUid()
		Logger.logError(uid)
	    self.m_model:getNetData("doing_certification", params, netCallback)
	else
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0255"), delay_close = 2})
	end
end

return M
	