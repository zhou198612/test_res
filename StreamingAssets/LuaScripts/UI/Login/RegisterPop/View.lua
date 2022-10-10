local M = class("RegisterPopView",LikeOO.OOPopBase)

M.m_uiName = "Login/RegisterPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0014")
	self:setTextByLanKey("sign_up_btn_text", "new_str_0006")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("name_input_label_text", "new_str_0015")
	self:setTextByLanKey("password_input_label_text", "new_str_0016")
	self:setTextByLanKey("password2_input_label_text", "new_str_0016")
	self.name_input = self:findInputField("name_input")
	Logger.log(self.name_input);
	self.password_input = self:findInputField("password_input")
	self.password2_input = self:findInputField("password2_input")
	self:refreshUI()
end

function function_name( ... )
	-- body
end

function M:refreshUI()
	self:setTextByLanKey("txt_title", "4983")
	self:setText("service_content", string.gsub(Language:getTextByKey(1204 or "???"), "\\n", "\n"))
	self:findGameObject("content_service").transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	self:ServerActive(false)
	self:refreshAgree()
end

function M:getNameAndPassword( )
	return self.name_input.text, self.password_input.text, self.password2_input.text
end

function M:refreshAgree()
	self:setObjectVisible("img_agree", self.m_model.is_agree)
end

function M:ServerActive(flag)
	self:setObjectVisible("service_node", flag)
end

return M