local M = class("PlayerAuthenticationPopView",LikeOO.OOPopBase)

M.m_uiName = "Login/PlayerAuthenticationPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("ok_btn_text", "new_str_0254")
	self:setTextByLanKey("name_input_placeholder", "new_str_0253")
	self:setTextByLanKey("card_id_num_input_placeholder", "new_str_0252")
	self:setTextByLanKey("title_text", "new_str_0251")
	self:setTextByLanKey("tips_text", "new_str_0250")
	self.name_input = self:findInputField("name_input")
	self.card_id_num_input = self:findInputField("card_id_num_input")
	self:refreshUI()
end

function M:refreshUI()

end

function M:getNameAndCardIdNum()
	return self.name_input.text, self.card_id_num_input.text
end

return M