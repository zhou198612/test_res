local M = class("LoginServerModel", LikeOO.OODataBase)

M.testTable = {}

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.server_data = self.m_params
end

function M:getServerData()
	return self.server_data
end

return M