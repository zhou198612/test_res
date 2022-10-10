local M = class("LoginServerControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.on_cancel_call then
			self.m_model.on_cancel_call()
		end
        self:closeView()
    elseif msg == "select_server" then
    	local server_list = self.m_model:getServerData()
    	UserDataManager.server_data:setServerData(server_list[data])
    	self:updateMsg("select_server", nil, "parent")
    	self:closeView()
    end
end

return M;