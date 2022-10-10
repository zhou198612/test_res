-- if you want create a pop window,you mast inheritance the oo_viewBase
local M = class( "OOPopBase" , LikeOO.OOViewBase)

M.m_type = 2
M.m_selfClose = false   -- 触摸可关闭pop选项
M.m_close_tag = 99999
M.m_priority = 0
M.m_normal = true
M.m_size_type = 1 -- 1隐藏下层ui，2不隐藏

function M:create()
	M.super.create( self )
	-- -- 触摸可关闭pop更多选线
	self.m_avoid_close = {}  		-- 点击到此区域不会关闭
	self.m_closeSign = false  		-- 触摸began时标记是否在触摸结束时可以关闭pop
	return self.m_rootView
end

function M:canClose( can ,tag)
	self.m_selfClose = can
	self.m_close_tag = tag or self.m_close_tag
end

function M:addAvoidCloseNode( node )
	if node then
		self.m_avoid_close[node] = true
	end
end

function M:removeAvoidCloseNode( node )
	if self.m_avoid_close then
		self.m_avoid_close[node] = nil
	end
end

function M:clearAvoidCloseNode( )
	self.m_avoid_close = {}
end

function M:consumeTouch( con )
	
end

-- 设置优先级
function M:setPriority( priority )
	self.m_priority = priority
	-- TODO : set order
end

-- 得到当前优先级别
function M:getPriority()
	return self.m_priority
end

function M:destroy()	
	M.super.destroy(self)
end

---------------------------------
-- 触摸是否在
---------------------------------
-- 触摸点是否在放置关闭区域内部
function M:pointInAvoid( worldPos)
	for k,v in pairs( self.m_avoid_close ) do
		local pos = k:getParent():convertToNodeSpace( worldPos )
		if cc.rectContainsPoint(k:boundingBox(), pos) then
			return true
		end
	end
end

-- 添加模糊截图背景
function M:addScreenShootBlur()
	-- TODO : create blur bg
end

return M