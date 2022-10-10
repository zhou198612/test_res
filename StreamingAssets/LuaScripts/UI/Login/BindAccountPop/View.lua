local M = class("CommonPopView",LikeOO.OOPopBase)

M.m_uiName = "Login/BindAccountPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("msg_text", self.m_model.m_text)
	self:setText("txt_ok", self.m_model.m_ok_text)
	self:setText("common_title_text", self.m_model.m_title)
	self:setObjectVisible("close_btn", false)
	self:refreshUI()
end

function M:refreshUI()

end


return M