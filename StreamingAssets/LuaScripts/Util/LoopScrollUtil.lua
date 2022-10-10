------------------- LoopScrollUtil

local M = class("LoopScrollUtil")

M.m_loop_scroll_rect = nil

function M:createLoop(control, loop_scroll)
	self.m_control = control
	self.m_loop_scroll = loop_scroll
	self.m_loop_scroll_rect = loop_scroll:GetComponent("LoopScrollRect")
end

--[[
	创建ScrollRect的子物体
	name--子预制的名字
	num--需要创建的数量
	isVer true为纵向  false为横向
	interval-- 间距
	cloumNum-- 每一行的数量
	callback-- 返回cell的回调
]]
function M:creatCell(name,num,isVer,interval,cloumNum,callback)
	self.m_loop_scroll_rect:Init(name,num,isVer,interval,cloumNum,callback)
end

--[[
	向unity发送下拉后的更新数据
]]
function M:pullDownRefresh(num)
	self.m_loop_scroll_rect:PullDownRefresh(num)
end

--[[
	向unity发送后的更新数据
]]
function M:refresh(num)
	self.m_loop_scroll_rect:Refresh(num)
end

function M:AddDragHandler(funCall)
	self.m_loop_scroll_rect:setLuaDragCallback(funCall)
end

function M:SrollToCell(index, speed)
	self.m_loop_scroll_rect:SrollToCell(index-1,speed)
end

--[[
    @desc:清理 
]]
function M:clearCell()
	self.m_loop_scroll_rect:ClearCells()
end

return M
