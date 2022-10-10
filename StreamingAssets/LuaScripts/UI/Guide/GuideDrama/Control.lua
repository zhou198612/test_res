local M = class("GuideDramaControl", LikeOO.OOControlBase)

function M:onEnter()
	if not self.m_model:getCurDialog() then
		self:updateMsg(99999)
	else
		-- self:setTimer(0.1,self.talkUpdate)
	end
end

function M:onHandle(msg, data)
	if msg == 99999 then
		self:closeView()
	elseif msg == "skip_btn" then
		self:checkSelectDrama()
	elseif msg == "speak_end" then
		self.m_model:setTalking(false)
	elseif msg == "next_btn" then
		if not self.m_model:getTalking() then
			if self.m_model:nextDialog() then
				self.m_view:refreshUI()
			else
				self:checkSelectDrama()
			end
		else
			self.m_view:setDramaText()
		end
	elseif msg == "select_drama_Item" then
		self.m_select_choise_data = {id = data.cell_data.id, index = data.index}
		self:closeView()
	end
end

function M:talkUpdate()
	self.m_view:updateDramaWord()
end

function M:checkSelectDrama()
	if #self.m_model:getSelectDramaData() > 0 then -- 是否有选择剧情对话
		self.m_view:updateSelectDramaLoopScroll()
	else
		self:closeView()
	end
end

function M:closeView(...)
	self.m_view:stopAllVoice()
	local callback = self.m_model.m_params.callback
	if type(callback) == "function" then
		callback(self.m_select_choise_data)
	end
	M.super.closeView(self, ...)
end

return M;