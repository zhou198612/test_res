-- if you want create a scene , 
local M = class( "OOSceneBase" , LikeOO.OOViewBase)

M.m_type = 1

function M:create()
	self:resetSortOrder(0)
	M.super.create(self)
	return self.m_rootView
end

function M:destroy()
	M.super.destroy(self)
end

function M:consumeTouch(con)
	
end

return M