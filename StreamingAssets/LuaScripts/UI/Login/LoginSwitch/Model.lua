local M = class("LoginSwitchModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.sdkLoginCall = self.m_params.sdkLoginCall
end

return M
