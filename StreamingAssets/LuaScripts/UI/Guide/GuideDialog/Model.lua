local M = class("GuideDialogModel", LikeOO.OODataBase)

function M:onCreate()
	self:getData()
end

function M:onEnter()
	if self.m_params ~= nil then
		local params         = self.m_params
		self.m_clickCallFunc = params.clickCallFunc
		self.m_target_trans  = params.target_trans
		self.m_skipFunc      = params.skipFunc
		self.m_guide         = params.guide
		self.m_nofinger 	 = params.nofinger
		self.m_finger_pos	 = params.finger_pos
		self.m_finger 		 = params.finger or 1
		self.m_maskOffset    = params.maskOffset
		-- self.m_finger 		 = 1 		-- 使用箭头
		-- 1，不改变节点的父节点；创建遮罩使用剪裁节点露出需点击区域。此种方式一般eventType需要使用1。透传点击，让点击点到按钮本身。
		-- 2 把引导的node的parent替换的mas上层（多用于btn，或者图片动画不固定的方式）, 3 mask不蒙黑 4 蒙黑 此种方式一般eventType使用2，不用透传点击，以为直接能点到按钮本身。
		self.m_maskType      = params.maskType or 3
		self.m_eventType     = params.eventType or 2  -- 1 通过触摸的方式将多余的触摸屏幕 2 打开close_btn,界面只用于提示用
	    self.m_finger_offset = params.finger_offset or Vector2(0, 0)    -- 对于有特殊需求的引导，手指位置的偏移量。
		self.m_finger_rotation = params.finger_rotation or Vector3(0, 0, 0)
	    self.m_guideIsForce  = params.guideIsForce
		self.m_endCallFunc = params.endCallFunc
		self.m_left_skip = params.left_skip
	    if params.target_pos then
	    	self.m_target_pos = params.target_pos
	    end
	end
end


return M