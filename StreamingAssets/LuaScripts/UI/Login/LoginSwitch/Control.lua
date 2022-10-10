local M = class("LoginSwitchControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "btn_bind" then	-- 绑定账号
		SDKUtil:BindAccount()
		self:closeView()
    elseif msg == "btn_switch" then -- 切换账号
		SDKUtil:SwitchAccount(self.m_model.sdkLoginCall)
		self:closeView()
    end
end

return M
	