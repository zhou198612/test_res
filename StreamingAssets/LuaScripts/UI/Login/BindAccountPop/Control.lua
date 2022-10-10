local M = class("CommonPopControl",LikeOO.OOControlBase)

function M:onEnter()
	if SceneManager ~= nil and SceneManager.curScene ~= nil then
		
		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(80)
		end
	end
	audio:SendEvtUI('12.chenggong')
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "btn_ok" then
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
	elseif msg == "cancle_btn" then
	    self:closeView()
    end
end


function M:destroy()
	M.super.destroy(self)
	if SceneManager ~= nil and SceneManager.curScene ~= nil then

		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(120)
		end
	end
end

return M;
