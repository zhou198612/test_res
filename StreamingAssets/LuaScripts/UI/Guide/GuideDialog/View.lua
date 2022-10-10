local M = class("GuideDialogView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideDialog"
M.m_size_type = 2

function M:onEnter()
	local order = self.m_model.m_guide.m_view.m_sortOrder + 99
	self.m_canvas.sortingOrder = order
	self:setTextByLanKey("skip_btn_text", "new_str_0032")
	self.m_highlight_node = self:findGameObject("highlight_node")
	self.mask_clip_img = self:findImage("mask_clip_img")
	self.mask_img = self:findImage("mask_img")
	if self.m_model.m_target_pos == nil then
		local target_trans = self.m_model.m_target_trans
		local pos = target_trans.parent:TransformPoint(target_trans.localPosition) --世界坐标
		pos = self.m_highlight_node.transform.parent:InverseTransformPoint(pos) -- 相对坐标
		self.m_highlight_node.transform.localPosition = pos
		self.mask_clip_img.transform.localPosition = pos
		self.m_pos_timer = self.m_control:setTimer(0.03,function()
			local pos = target_trans.parent:TransformPoint(target_trans.localPosition)
			pos = self.m_highlight_node.transform.parent:InverseTransformPoint(pos)
			if pos.x ~= self.m_highlight_node.transform.localPosition.x or pos.y ~= self.m_highlight_node.transform.localPosition.y then
				self.m_highlight_node.transform.localPosition = pos
				self.mask_clip_img.transform.localPosition = pos
			end
		end)
		
		self.m_guide_node = self:findGameObject("guide_node")
		self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
		local rt = target_trans.gameObject:GetComponent("RectTransform")
		self.m_hollowOutMask:SetTarget(rt)
		local max = math.max(rt.rect.width, rt.rect.height)
		self.mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
	else
		local template_img = self:findGameObject("template_img")
		self.m_highlight_node.transform.position = self.m_model.m_target_pos
		self.mask_clip_img.transform.position = self.m_model.m_target_pos
		self.m_guide_node = self:findGameObject("guide_node")
		self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
		local rt = template_img:GetComponent("RectTransform")
		self.m_hollowOutMask:SetTarget(rt)
		local max = math.max(rt.rect.width, rt.rect.height)
		self.mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
	end
	self.m_highlight_node.transform.rotation = Quaternion.Euler(self.m_model.m_finger_rotation.x, self.m_model.m_finger_rotation.y, self.m_model.m_finger_rotation.z)
	self.m_hollowOutMask:SetTargetSwitch(true)
	self:refreshUI()
end

function M:refreshUI()
	local guide_info = self.m_model.m_guide:getCurExcuteGuideInfo()
	if guide_info then
		local des = guide_info.des
		local hero_id = guide_info.hero_id
		self:setTextByLanKey("guide_text", tostring(des))
		self:setObjectVisible("guide_text_node", des~="")


		--local hero_cfg =  UserDataManager.hero_data:getHeroConfigByCid(guide_info.hero_id)
		--local hero_spine = self:findGameObject("hero_spine")
		--if hero_cfg then
		--	self:setImg("a_xs_head_" .. guide_info.hero_id, "guide_ui", "head_img")
		--	self:setTextByLanKey("hero_name_text", hero_cfg.name)
		--	 local sg = hero_spine:GetComponent("SkeletonGraphic")
		--	 local skeleton_data = ResourceUtil:GetSk(hero_cfg.hero_spine, "rolespine_"..string.lower( hero_cfg.hero_spine ) )
		--	 sg.skeletonDataAsset = skeleton_data
		--	 sg:Initialize(true)
		--else
		--	hero_spine:SetActive(false)
		--end

		local des_pos = guide_info.des_pos
		if des_pos and next(des_pos) then
			local name_bg_img = self:findGameObject("name_bg_img")
			local guide_text_node = self:findGameObject("guide_text_node")
			-- if des_pos[1] == 2 then
			-- 	UIUtil.setLocalPosition(hero_spine, 176)
			-- 	UIUtil.setLocalPosition(name_bg_img, 174)
			-- else
			-- 	UIUtil.setLocalPosition(hero_spine, -176)
			-- 	UIUtil.setLocalPosition(name_bg_img, -174)
			-- end

			local offsetx = des_pos[1] or 0
			local offsety = des_pos[2] or 0
			UIUtil.setLocalPosition(guide_text_node, offsetx, offsety)
		end
	else
		self:setObjectVisible("guide_text_node", false)
	end
	if self.m_model.m_guideIsForce then
		self.m_hollowOutMask.enabled = true
		self:setObjectVisible("guide_node", self.m_model.m_maskType == 1)
		if guide_info.mask_alpha then
			self.mask_img.color = Color(0,0,0,guide_info.mask_alpha/100)
		end
		if self.m_model.m_maskType == 1 then
			self:setObjectVisible("guide_node", true)
		elseif self.m_model.m_maskType == 2 then
			self:setObjectVisible("guide_node", false)
		elseif self.m_model.m_maskType == 3 then
			self:setObjectVisible("guide_node", true)
			self.mask_img.color = Color(0,0,0,0)
		end
	else
		self.m_hollowOutMask.enabled = false
		self:setObjectVisible("guide_node", true)
	end
	

	if self.m_model.m_eventType == 2 then
		self.m_hollowOutMask:SetTargetSwitch(false)
		self:setObjectVisible("close_btn", true)
		self:setObjectVisible("figer_sp", false)
	end

	Logger.log(self.m_model.m_left_skip, "self.m_model.m_left_skip ====")
	if self.m_model.m_left_skip then
		local skip_btn_bg = self:findGameObject("skip_btn_bg")
		UIUtil.setLocalPosition(skip_btn_bg.transform, 126-self.m_rt.rect.width*0.5)
		UIUtil.setLocalScale(skip_btn_bg.transform, -1)
		local skip_btn = self:findGameObject("skip_btn")
		UIUtil.setLocalPosition(skip_btn.transform, 76-self.m_rt.rect.width*0.5)
	end
end

return M