local M = class("OOMsgList",nil)

M.m_handle = nil
M.m_last = nil

function M:addMsg( data )
	-- body
	if(data == nil)then
		return
	end
	if(self.m_handle == nil)then
		self.m_handle = { d = data ,
						  n = nil  }
		self.m_last = self.m_handle
	else
		local temp = { d = data ,
					   n = nil }
		self.m_last.n = temp
		self.m_last = self.m_last.n 
	end

end

function M:pop(  )
	-- body
	if(self.m_handle == nil)then
		return nil
	end
	local data = self.m_handle.d
	self.m_handle = self.m_handle.n
	return data
end

function M:hasData(  )
	-- body
	if( self.m_handle == nil )then
		return false
	else
		return true
	end
end

function M:cleanAll(  )
	-- body
	self.m_handle = nil 
	self.m_last = nil 
end

return M