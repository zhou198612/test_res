local M = class("PlayerAuthenticationPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.callback = self.m_params.callback
end

return M
