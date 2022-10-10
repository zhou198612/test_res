local M = class("LoginPopView",LikeOO.OOPopBase)

M.m_uiName = "Login/LoginPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0013")
	self:setTextByLanKey("sign_up_btn_text", "new_str_0014")
	self:setTextByLanKey("login_btn_text", "new_str_0013")
	self:setTextByLanKey("name_input_label_text", "new_str_0015")
	self:setTextByLanKey("password_input_label_text", "new_str_0016")
	self.name_input = self:findInputField("name_input")
	self.password_input = self:findInputField("password_input")
	self:refreshUI()
end

function M:refreshUI()
	self.name_input.text = self.m_control.m_model.m_user_name
	self.password_input.text = self.m_control.m_model.m_user_password
end

function M:getUserNameAndPassword()
	return self.name_input.text, self.password_input.text
end

return M