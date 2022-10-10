local M = class("GuideMoveDialogControl", LikeOO.OOControlBase)

function M:onEnter()
	self:setTimer(1/60, self.updateTimer)
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
		self:closeView()
    elseif msg == "skip_btn" then
        local params = {
            on_ok_call = function(msg)
                UserDataManager.guide_data:skipCurGuide()
                self:closeView()
           end,
           no_close_btn = false,
           tow_close_btn = true,
           text = Language:getTextByKey("new_str_0465")
       }
       static_rootControl:openView("Pops.CommonPop", params)
    end
end

function M:updateTimer()
	self:mouseDown()
	self:mouseMove()
	self:mouseUp()
end

function M:mouseDown()
	if U3DUtil:Input_GetMouseButtonDown(0) then
		if self.m_model.m_move_call then
			self.m_is_down = self.m_model.m_move_call("touchBegin")
		else
			self.m_begin_pos = nil
			self.m_move_flag = false
			if U3DUtil:Input_GetMouseButtonDown(0) then
				self.m_is_down = true
				self.m_begin_pos = U3DUtil:GetMousePosition()
			end
		end
		--self.m_view:doTweenMove()
	end
end

function M:mouseMove()
	if self.m_is_down then
		if self.m_model.m_move_call then
			self.m_model.m_move_call("touchMove")
		else
			local move_pos = U3DUtil:GetMousePosition()
			local dis = Vector3.Distance(self.m_begin_pos, move_pos) 
			if dis > 30 then
				self.m_move_flag = true
			end
		end
	end
end

function M:mouseUp()
	if U3DUtil:Input_GetMouseButtonUp(0) then
		if self.m_model.m_move_call then
			self.m_model.m_move_call("touchEnd")
		end
		self.m_is_down = false
	end
end

return M;