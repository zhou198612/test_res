local M = class("LoginSwitchView",LikeOO.OOPopBase)

M.m_uiName = "Login/LoginSwitch"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0013")
	self:setTextByLanKey("txt_bind", "login_str_0005")
	self:setTextByLanKey("txt_switch", "login_str_0006")
	self:refreshUI()
end

function M:refreshUI()
end

return M