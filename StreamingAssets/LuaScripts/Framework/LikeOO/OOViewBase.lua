local M = class("OOViewBase")

M.m_control = nil
M.m_model = nil
M.m_type = 1
M.m_rootView = nil
M.m_maskView = nil
M.m_lockNum = 0
M.m_visibleRefCount = 0
M.m_uiName = nil
M.m_luaBehaviour = nil
M.m_sortOrder = 0
M.m_iphoneXAdapter = false
M.m_sortOrderChange = true
M.m_sortOrderChange = true
M.m_initLockTime = 0.5
M.m_view_width = 720
M.m_view_height = 1280

local viewSortOrder = 0
local __VIEW_SORT_ORDER_STEP = 100
local __UI_DESIGN_WIDTH = 720
local __UI_DESIGN_HEIGHT = 1280

--[[
	此方法重载后用来做view的创建

]]
function M:create()
	local view_obj = U3DUtil:GameObject(self.__cname)
	if static_root_node then
		view_obj.transform:SetParent(static_root_node.transform, false)
	end
	if self.m_uiName then
		self.m_ui_obj = ResourceUtil:GetUIItem(self.m_uiName, view_obj, "ui_prefabs")
		self.m_luaBehaviour = self.m_ui_obj:GetComponent("LuaBehaviour")
		if self.m_model.m_mask then --添加过度效果
			local canvas_group = self.m_ui_obj.gameObject:AddComponent(typeof(CS.UnityEngine.CanvasGroup))
			--canvas_group.alpha = 0
			local animation = self.m_ui_obj.gameObject:AddComponent(typeof(CS.UnityEngine.Animation))
			local anim_com_into = ResourceUtil:LoadAnim("Anims/com_into", "anims")
			--animation:AddClip(anim_com_into)
		end
		self.m_canvas = self.m_ui_obj:GetComponent("Canvas")
		local max_sort_order = self.m_control:getMaxViewSortOrder()
		self.m_sortOrder = math.max(self.m_sortOrder, max_sort_order) + viewSortOrder
		self.m_canvas.sortingOrder = self.m_sortOrder
		self.m_canvas.worldCamera = static_ui_camera
		self.m_luaBehaviour:RegistButtonClick(handler(self, self.onButtonClick))
		self.m_luaBehaviour:RegistLanguageChanged(handler(self, self.onLanguageChanged))
		self.m_luaBehaviour:InjectionFunc()
		-- scale bg
		self.m_rt = self.m_ui_obj:GetComponent("RectTransform")
		local rect = self.m_rt.rect
		--self.m_bg_scale = math.max(rect.height/__UI_DESIGN_HEIGHT , rect.width/__UI_DESIGN_WIDTH)
		-- local bg_img = self:findGameObject("bg_img")
		-- if bg_img then
		-- 	local rt = bg_img:GetComponent("RectTransform")
		-- 	rt.localScale = Vector3(self.m_bg_scale, self.m_bg_scale, 1)
		-- end
		local content_node = self:findGameObject("content_node")
		self.content_node = content_node
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
		
		self.m_maskView = GameUtil:createPrefab("Guide/GuideTouchMask", self.m_ui_obj.transform)
		local canvas = self.m_maskView:GetComponent("Canvas")
		canvas.sortingOrder = self.m_sortOrder + __VIEW_SORT_ORDER_STEP - 1
		self.m_touch_key =  "guide_guide_touch_mask_hide_" .. tostring(self.m_ui_obj)
		self:lockTouch("create")
        EventDispatcher:registerTimeEvent(self.m_touch_key, function()
            self:unlockTouch("create")
        end, self.m_initLockTime, self.m_initLockTime)
	end
	self.m_rootView = view_obj
	self.m_visibleRefCount = 0
	self:onCreate()
	return self.m_rootView
end

function M:resetSortOrder(sort_order)
	viewSortOrder = sort_order or (self.m_sortOrder + __VIEW_SORT_ORDER_STEP)
	Logger.log(viewSortOrder, "<color=green>OOViewBase resetSortOrder </color> : " .. tostring(self.m_uiName))
end

function M:addSortOrder()
	if self.m_sortOrderChange then
		viewSortOrder = viewSortOrder + __VIEW_SORT_ORDER_STEP
		Logger.log(viewSortOrder, "<color=green>OOViewBase addSortOrder </color> : " .. tostring(self.m_uiName))
	end
end

function M:subSortOrder()
	if self.m_sortOrderChange then
		viewSortOrder = viewSortOrder - __VIEW_SORT_ORDER_STEP
		Logger.log(viewSortOrder, "<color=green>OOViewBase subSortOrder </color> : " .. tostring(self.m_uiName))
	end
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

function M:onInjectionFunc(obj, name)
	if self[name] == nil then
		self[name] = obj
	else
		Logger.logWarning("name is exist : " .. tostring(name))
	end
end

--- 创建UI公共方法
function M:createUI(name)

end

--[[
	使用方法，与参数性质同controlBase
]]
function M:updateMsg(msg, data, flag, alias)
	-- body
	self.m_control:updateMsg( msg,data,flag,alias )
end

function M:destroy()
	EventDispatcher:unRegisterEvent(self.m_model:getName() .. "NetRefresh", {self, self.netRefreshEvent})
	-- body
	if self.m_rootView then
		EventDispatcher:unRegisterEvent(self.m_touch_key)
		if self.m_cache_ui_flag then
			if not IsNull(self.m_ui_obj) then
				ResourceUtil:ReturnItem(self.m_ui_obj)
				self.m_ui_obj = nil
			end
			if not IsNull(self.m_maskView) then
				ResourceUtil:ReturnItem(self.m_maskView)
				self.m_maskView = nil
			end
			U3DUtil:GameObjectDestroy(self.m_rootView)
		else
			U3DUtil:DestroyAndBundle(self.m_rootView, self.m_uiName)
		end
		self.m_rootView = nil
		self.m_luaBehaviour = nil
	end
	-- Logger.log("-------- destroy view " .. self.m_model:getName())
	self.m_maskView = nil
	self.m_model = nil
	self.m_control = nil
end

function M:getType(  )
	-- body
	return self.m_type
end

function M:getRootView(  )
	-- body
	return self.m_rootView
end

--[[
	页面调用create时调用
]]
function M:onCreate(  )
	-- body
	-- Logger.log("-------------- view onCreate " .. self.m_model:getName())
end

--[[
	页面进入后
]]
function M:onEnter(  )
	-- body
	-- Logger.log("-------------- view onEnter " .. self.m_model:getName())
	EventDispatcher:registerEvent(self.m_model:getName() .. "NetRefresh", {self, self.netRefreshEvent})
end

--- 网络数据回来的ui刷新，需要复写
function M:netRefreshEvent(event, data)

end

--[[
	锁定所有的点击事件
]]
function M:lockTouch(tag)
	self.m_lockNum = self.m_lockNum + 1
	self:enableMaskLayer()
end

--[[
	解锁所有的点击事件
]]
function M:unlockTouch(tag)
	self.m_lockNum = self.m_lockNum - 1
	if self.m_lockNum < 0 then
		self.m_lockNum = 0
		assert(self.m_lockNum >= 0, "lock number can not < 0 " .. self.__cname)
	end
	if self.m_lockNum == 0 then
		self:disableMaskLayer()
	end
end

function M:enableMaskLayer()
	if self.m_rootView ~= nil then
		if self.m_maskView ~= nil then
			self.m_maskView:SetActive(true)
		end
	end
end

function M:disableMaskLayer()
	if self.m_rootView ~= nil then
		if self.m_maskView ~= nil then
			self.m_maskView:SetActive(false)
		end
	end
end

--[[
	锁定所有的点击事件, 锁定时间触摸添加回调
]]
function M:lockTouchFinitude( callFunc, interval )
	-- interval = interval or 0
	-- local time = os.time()
	-- if(self.m_rootView ~= nil)then
	-- 	if(self.m_fmaskView ~= nil)then
	-- 		return
	-- 	end
end

--[[
	解锁所有的点击事件
]]
function M:unlockTouchFinitude(  )
	-- if(self.m_fmaskView == nil)then
	-- 	return
	-- else
	-- 	self.m_fmaskView:removeFromParent(true)
	-- 	self.m_fmaskView = nil
	-- end
end

--- 统一使用的黑色背景遮罩
function M:showBlackBg(opacity)
	-- TODO :
end

-- 隐藏界面计数++
function M:retainVisibleView()
	self.m_visibleRefCount = self.m_visibleRefCount + 1
	self.m_rootView:SetActive(self.m_visibleRefCount <= 0)
	if not (self.m_visibleRefCount <= 0) then
		Logger.log("hide view name ->" .. self.__cname)
	end
end

-- 隐藏界面计数--
function M:releaseVisibleView()
	self.m_visibleRefCount = self.m_visibleRefCount - 1
	self.m_rootView:SetActive(self.m_visibleRefCount <= 0)
	if self.m_visibleRefCount <= 0 then
		Logger.log("show view name ->" .. self.__cname)
		if self.m_dirty then
			EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event= self.__cname .. "_refresh"} )
			self.m_dirty = false
		end
	end
end

--- 界面是否显示
function M:isVisible()
	if self.m_rootView then
		return self.m_rootView.activeSelf
	end
	return false
end

--- 打开ui动画
function M:runOpenAnim( anim_node, callBackFunc )
	local transfer = self.m_model.m_transfer
	if anim_node and transfer then
		self:lockTouch("TAG:runOpenAnim")
		local function endCallFunc()
			self:unlockTouch("TAG:runOpenAnim")
			callBackFunc()
		end
		--增加pop框的弹出效果
		local transform = anim_node.transform
		if transfer == "scale" then
			transform.localScale = Vector3(0.8,0.8,0.8)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOScale(1.2, 0.15))
			sequence:Append(transform:DOScale(1.0, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "up_to_down" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x, pos.y + __UI_DESIGN_HEIGHT, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveY(pos.y - 10, 0.25))
			sequence:Append(transform:DOLocalMoveY(pos.y, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "right_to_left" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x + __UI_DESIGN_WIDTH, pos.y, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x - 10, 0.35))
			sequence:Append(transform:DOLocalMoveX(pos.x, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "left_to_right" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x - __UI_DESIGN_WIDTH, pos.y, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x + 10, 0.35))
			sequence:Append(transform:DOLocalMoveX(pos.x, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "scale_and_up_to_down" then
			transform.localScale = Vector3.zero
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x - __UI_DESIGN_WIDTH, pos.y + __UI_DESIGN_WIDTH, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMove(pos, 0.25))
			sequence:Join(transform:DOScale(1, 0.25))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "animation" then
			if self.m_luaBehaviour and self.m_model.m_anim_name then
				self.m_luaBehaviour:RunAnim(self.m_model.m_anim_name, endCallFunc, 1)
			else
				endCallFunc()
			end
	    else
	    	endCallFunc()
		end
	else
		callBackFunc()
	end
end

--- 关闭ui动画
function M:runCloseAnim( anim_node, callBackFunc)
	local transfer = self.m_model.m_transfer
	if anim_node and transfer then
		self:lockTouch("TAG:runCloseAnim")
		local function endCallFunc()
			self:unlockTouch("TAG:runCloseAnim")
			callBackFunc()
		end
		local transform = anim_node.transform
		if transfer == "scale" then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOScale(0, 0.2))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "up_to_down" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveY(pos.y + __UI_DESIGN_HEIGHT, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "right_to_left" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x - __UI_DESIGN_WIDTH, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "left_to_right" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x + __UI_DESIGN_WIDTH, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		else
			endCallFunc()
		end
	else
		callBackFunc()
	end
end

--- view 打开过渡
-- @param callBackFunc
function M:openTransition( callBackFunc )
	self:addSortOrder()
	self:runOpenAnim(self.content_node, callBackFunc)
end

--- view 关闭过渡
-- @param callBackFunc
function M:closeTransition( callBackFunc )
	self:subSortOrder()
	self:runCloseAnim(self.content_node, callBackFunc)
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

function M:setTextColor(key, color)
	local text = self:findText(key)
	if text then
		text.color = color
	end
	return text
end

function M:setObjectVisible(key, visible)
	local obj = self:findGameObject(key)
	if obj then
		obj:SetActive(visible)
	end
	return obj
end

function M:setImg(img_msg, img_atlas, key)
	local sprite = nil
	local img = self:findImage(key)
	if img then
		sprite = ResourceUtil:GetSprite(img_msg,img_atlas)
		img.sprite = sprite
	end
	return img, sprite
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

function M:findAnimation(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindAnimation(name)
	end
end

function M:findAnimationState(name,state_name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindAnimationState(name,state_name)
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

function M:findSkeletonGraphic(name)
	local obj = self:findGameObject(name)
	if obj then
		local sg = obj:GetComponent("SkeletonGraphic")
		return sg
	end
end

--[[
    @desc: 长按事件 
	--@action1:按下
	--@action2:抬起
]]
function M:addTrigger(name,action1,action2)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerDown") ,action1)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerUp"),action2)
	end
end

--设置按钮进入事件
function M:addTriggerEnter(name)
	if self.m_luaBehaviour then
		function callback_enter()
			self:updateMsg("com_enter", name)
		end
		function callback_exit()
			self:updateMsg("com_exit", name)
		end
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerEnter") ,callback_enter)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerExit"),callback_exit)
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

function M:runAnim(anim_name, end_call_func)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:RunAnim(anim_name, end_call_func, 1)
	end
end

return M