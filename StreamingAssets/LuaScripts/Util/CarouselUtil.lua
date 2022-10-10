------------------- CarouselUtil

local M = class("CarouselUtil")

--[[
    self.m_carousel = CarouselUtil.new() 
    self.m_carousel:create(self.m_control, self:findGameObject("carousel"))
    self.m_carousel:moveToIndex(3) --移动到指定位置
]]
function M:create(control, carouse)
	self.m_control = control
	self.carouse = carouse
	self.m_carouse = carouse:GetComponent("Carousel")
end

function M:AddChild(trans)
	self.m_carouse:AddChild(trans)
end

function M:setDrag(isDrag)
	self.m_carouse.mDrag = isDrag
end

-- 获取当前索引，CShap从0开始，lua是1
function M:currentIndex()
	return self.m_carouse.CurrentIndex + 1
end
--[[
	移动到指定索引 CShap从0开始，lua是1
]]
function M:moveToIndex(num)
	self.m_carouse:MoveToIndex(num - 1)
end

function M:addDragHandler(funCall)
	self.m_carouse:setLuaDragCallback(funCall)
end

function M:addOnIndexChange(funCall)
	self.m_carouse:AddOnIndexChange(funCall)
end

return M