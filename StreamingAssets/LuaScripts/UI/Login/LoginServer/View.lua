local M = class("LoginServerView",LikeOO.OOPopBase)

M.m_uiName = "Login/LoginServer"
M.m_size_type = 2

function M:onEnter()
    self:createLoopScroll()
end

--
function M:createLoopScroll()
    self.m_loopScroll = LoopScrollUtil.new() 
    self.m_loopScroll:createLoop(self.m_control,self:findGameObject("LoopScroll"))
    self.m_loopScroll:creatCell("Login/loopCell1",#self.m_model:getServerData(),true,5,1,handler(self, self.setCellHander))
end

--Scroll内cell的回调
function M:setCellHander(handertype, id, obj)
   if handertype == 1 then
	    local cell_count = obj.transform:Find("loopCell_Text"):GetComponent("Text")
    	local server_data = self.m_model:getServerData()
    	cell_count.text = server_data[id].server_name
	    local function btnss()
            self:updateMsg("select_server", id)
	    end 
        UIUtil.setButtonClick(obj.transform, btnss)
    elseif handertype == 2 then
  --   	self.m_model:addServerData()
		-- self.m_loopScroll:pullDownRefresh(#self.m_model:getServerData())
    end 

end

return M