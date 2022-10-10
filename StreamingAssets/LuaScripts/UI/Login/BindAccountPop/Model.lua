local M = class("CommonPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_ok_text = self.m_params.ok_text or Language:getTextByKey("new_str_0006")
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_text = self.m_params.text or ""
	self.m_on_ok_call = self.m_params.on_ok_call
end

return M
