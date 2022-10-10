local M = class("LoginPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_user_name = U3DUtil:PlayerPrefs_GetString("username")
	self.m_user_password = U3DUtil:PlayerPrefs_GetString("password")
end

return M
