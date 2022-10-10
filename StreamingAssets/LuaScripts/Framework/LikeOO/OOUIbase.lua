-------- OOUIbase 单独ui的创建

local M = class("OOUIbase")

local viewSortOrder = 0
local __VIEW_SORT_ORDER_STEP = 1
M.m_iphoneXAdapter = false

function M:ctor(control, params)
	self.m_control = control or static_rootControl
	self.m_params = params or {}
	self.m_model = self.m_control.m_model
	self:create()
	self:onEnter()
end

function M:create()
	viewSortOrder = viewSortOrder + __VIEW_SORT_ORDER_STEP
	if self.m_uiName then
		self.m_rootView = ResourceUtil:GetUIItem(self.m_uiName, self.m_control.m_view.m_rootView, "ui_prefabs")
		self.m_luaBehaviour = self.m_rootView:GetComponent("LuaBehaviour")
		local canvas = self.m_rootView:GetComponent("Canvas")
		self.m_sortOrder = self.m_sortOrder or self.m_control.m_view.m_sortOrder + viewSortOrder
		if not IsNull(canvas) then
			canvas.sortingOrder = self.m_sortOrder
			canvas.worldCamera = static_ui_camera
		end
		self.m_luaBehaviour:RegistButtonClick(handler(self, self.onButtonClick))
		self.m_luaBehaviour:RegistLanguageChanged(handler(self, self.onLanguageChanged))
		self.m_luaBehaviour:InjectionFunc(handler(self, self.onInjectionFunc))
		local content_node = self:findGameObject("content_node")

		self.m_rt = self.m_rootView:GetComponent("RectTransform")
		self.m_rt.localPosition = Vector3.zero
		local rect = self.m_rt.rect
		self.m_view_width = rect.width
		self.m_view_height = rect.height
		self.m_bg_scale_w = self.m_view_width/GlobalConfig.UI_DESIGN_WIDTH
		self.m_bg_scale_h = self.m_view_height/GlobalConfig.UI_DESIGN_HEIGHT
		self.m_bg_scale = math.max(self.m_bg_scale_w , self.m_bg_scale_h)
		local aspect_ratio = self.m_view_height/self.m_view_width

		local is_iphonex = UserDataManager.client_data.is_iphonex
		self.m_iphonex_offset_y = 0
		-- 1280 - 1380
		if self.m_iphoneXAdapter then
			if is_iphonex then
				self.m_iphonex_offset_y = GlobalConfig.UI_BOTTOM_OFFSET_Y
			else
				local diff_aspect_ratio = aspect_ratio - 1380/GlobalConfig.UI_DESIGN_WIDTH
				if diff_aspect_ratio > 0 then
					self.m_iphonex_offset_y = GlobalConfig.UI_BOTTOM_OFFSET_Y
				end
			end
		end
		if self.m_iphonex_offset_y > 0 then
			if content_node then
				local rt = content_node:GetComponent("RectTransform")
				rt.offsetMin = Vector2(rt.offsetMin.x, self.m_iphonex_offset_y)
				rt.offsetMax = Vector2(rt.offsetMax.x, -self.m_iphonex_offset_y)
			end
			local CommonFullBg = self:findGameObject("CommonFullBg2")
			if CommonFullBg then
				local rt = CommonFullBg:GetComponent("RectTransform")
				rt.offsetMin = Vector2(rt.offsetMin.x, self.m_iphonex_offset_y)
				rt.offsetMax = Vector2(rt.offsetMax.x, -self.m_iphonex_offset_y)
			end
		end
		
		self:setParent(self.m_params.parent)
	else
		Logger.logError(self.__cname .. " ui not found ")
	end
	Logger.log(viewSortOrder, "<color=green>OOUIbase create viewSortOrder</color> : " .. tostring(self.m_uiName))
	self:onCreate()
	return self.m_rootView
end

function M:onButtonClick(obj, name)
	if name == "close_btn" or name == "big_close_btn" then
		self:updateMsg(99999)
		audio:SendEvtUI("btn_close")	--没有音效暂时屏蔽
	else
		self:updateMsg(name)
		local full_btn_name = self.m_uiName .. "/" .. name
		GameUtil:playBtnSound(full_btn_name)
	end
end

function M:onLanguageChanged(mode)
	
end

function M:setParent(parent)
	if not IsNull(self.m_rootView) and not IsNull(parent) then
		self.m_rootView.transform:SetParent(parent.transform, false)
	end
end

function M:onInjectionFunc(obj, name)
	if self[name] == nil then
		self[name] = obj
	else
		Logger.logWarning("name is exist : " .. tostring(name))
	end
end

function M:onCreate()
	
end

function M:onEnter()
	
end

function M:refreshUI()
	
end

--[[
	使用方法，与参数性质同controlBase
]]
function M:updateMsg( msg , data , flag , alias)
	-- body
	self.m_control:updateMsg( msg,data,flag,alias )
end

function M:destroy()
	if self.m_rootView then
		viewSortOrder = viewSortOrder - __VIEW_SORT_ORDER_STEP
		Logger.log(viewSortOrder, "<color=green>OOUIbase destroy viewSortOrder</color> : " .. tostring(self.m_uiName))
		if self.m_cache_ui_flag then
			ResourceUtil:ReturnItem(self.m_rootView)
		else
			U3DUtil:DestroyAndBundle(self.m_rootView, self.m_uiName)
		end
		self.m_rootView = nil
		self.m_luaBehaviour = nil
	end
	self.m_model = nil
	self.m_control = nil
end

-- 设置粒子特效的order
function M:setParticleRenderOrder(obj, order)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:SetParticleSystemRendererOrder(obj, order or self.m_sortOrder + 1)
	end
end

function M:setText(key, text_msg)
	local text = self:findText(key)
	if text then
		text.text = text_msg
	end
	return text
end

function M:setTextByLanKey(key, lan_key, arg1, ...)
	return self:setText(key, Language:getTextByKey(lan_key, arg1, ...))
end

function M:setObjectVisible(key, visible)
	local obj = self:findGameObject(key)
	if obj then
		obj:SetActive(visible)
	end
	return obj
end

function M:setImg(img_msg, img_atlas, key)
	local img = self:findImage(key)
	img.sprite = ResourceUtil:GetSprite(img_msg,img_atlas)
	return img
end

function M:setTexture(key, img_msg, ab_name)
	local img = self:findImage(key)
	if img then
		img.sprite = ResourceUtil:LoadSprite(img_msg, ab_name)
	end
	return img
end

function M:findGameObject(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindGameObject(name)
	end
end

function M:findButton(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindButton(name)
	end
end

function M:findText(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindText(name)
	end
end

function M:findImage(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindImage(name)
	end
end

function M:findSlider(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindSlider(name)
	end
end

function M:addSliderListener(name, func)
	if self.m_luaBehaviour then
		local slider = self.m_luaBehaviour:FindSlider(name)
	    slider.onValueChanged:RemoveAllListeners()
		slider.onValueChanged:AddListener(func)
	end
end

function M:findRawImage(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindRawImage(name)
	end
end

function M:findToggle(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindToggle(name)
	end
end

function M:findScrollbar(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindScrollbar(name)
	end
end

function M:findDropdown(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindDropdown(name)
	end
end

function M:findInputField(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindInputField(name)
	end
end

function M:findRectTransform(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindRectTransform(name)
	end
end

function M:findParticleSystem(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindParticleSystem(name)
	end
end

function M:addSpineComplete(state,action)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:SpineCompleteEvent(state,action)
	end
end

function M:addSpineEvent(state,action)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:SpineEvent(state,action)
	end
end

--[[
	长按事件(第二版)
	action1 -- 普通点击
	action2 -- 长按
]]
function M:addActionChangAn(name,action1,action2)
	if self.m_luaBehaviour then
		local changAn_obj = self:findGameObject(name)
		local changAn_btn = changAn_obj:GetComponent("ChangAn")
		if changAn_btn then
			changAn_btn:RegistButtonClick(action1, action2)
		end
	end
end
--设置按钮进入事件
function M:addTriggerEnter(name)
	if self.m_luaBehaviour then
		function callback_enter()
			self:updateMsg("btn_enter", name)
		end
		function callback_exit()
			self:updateMsg("btn_exit", name)
		end
		function callback_down()
			self:updateMsg("btn_down", name)
		end
		function callback_up()
			self:updateMsg("btn_up", name)
		end
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerEnter") ,callback_enter)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerExit"),callback_exit)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerDown") ,callback_down)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerUp"),callback_up)
	end
end

return M