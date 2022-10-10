----------------- UIUtil

local M = {}

local Text = U3DUtil:Get_Text()
local Image = U3DUtil:Get_Image()
local Button = U3DUtil:Get_Button()
local InputField = U3DUtil:Get_InputField()
local Slider = U3DUtil:Get_Slider()
local ScrollRect = U3DUtil:Get_ScrollRect()
local RectTransform = U3DUtil:Get_RectTransform()
local Toggle = U3DUtil:Get_Toggle()
local Outline = U3DUtil:Get_Outline()
local OutlineEx = U3DUtil:Get_OutlineEx()
local CanvasGroup = U3DUtil:Get_CanvasGroup()
local LuaBehaviour = U3DUtil:Get_LuaBehaviour()
local VerticalLayoutGroup = U3DUtil:Get_VerticalLayoutGroup()
local ContentSizeFitter = U3DUtil:Get_ContentSizeFitter()

function M.getChild(trans, index)
    return trans:GetChild(index)
end

-- 注意：根节点不能是隐藏状态，否则路径将找不到
function M.findComponent(trans, ctype, path)
    assert(trans ~= nil)
    assert(ctype ~= nil)

    local targetTrans = trans
    if path ~= nil and type(path) == "string" and #path > 0 then
        targetTrans = trans:Find(path)
    end
    if targetTrans == nil then
        return nil
    end
    local cmp = targetTrans:GetComponent(ctype)
    if cmp ~= nil then
        return cmp
    end
    return targetTrans:GetComponentInChildren(ctype)
end

function M.findTrans(trans, path)
    if path == nil then
        return trans
    end
    return trans:Find(path)
end

function M.findText(trans, path)
    return M.findComponent(trans, typeof(Text), path)
end

function M.findImage(trans, path)
    return M.findComponent(trans, typeof(Image), path)
end

function M.findButton(trans, path)
    return M.findComponent(trans, typeof(Button), path)
end

function M.findInput(trans, path)
    return M.findComponent(trans, typeof(InputField), path)
end

function M.findLuaBehaviour(trans, path)
    return M.findComponent(trans, typeof(LuaBehaviour), path)
end

function M.findSlider(trans, path, func)
    local slider = M.findComponent(trans, typeof(Slider), path)
    if func then
        slider.onValueChanged:RemoveAllListeners()
        slider.onValueChanged:AddListener(func)
    end
    return slider
end

function M.findToggle(trans, path)
    return M.findComponent(trans, typeof(Toggle), path)
end

function M.findScrollRect(trans, path)
    return M.findComponent(trans, typeof(ScrollRect), path)
end

function M.findRectTransform(trans, path)
    return M.findComponent(trans, typeof(RectTransform), path)
end

function M.findContentSizeFitter(trans, path)
    return M.findComponent(trans, typeof(ContentSizeFitter), path)
end

function M.setLocalPosition(trans, x, y, z)
    local rtrans = M.findComponent(trans, typeof(RectTransform))
    local lpos = rtrans.localPosition
    if x then
        lpos.x = x
    end
    if y then
        lpos.y = y
    end
    if z then
        lpos.z = z
    end
    rtrans.localPosition = lpos
    return rtrans
end

function M.setLocalScale(trans, x, y, z)
    local rtrans = M.findComponent(trans, typeof(RectTransform))
    local lscale = rtrans.localScale
    if x then
        lscale.x = x
    end
    if y then
        lscale.y = y
    end
    if z then
        lscale.z = z
    end
    rtrans.localScale = lscale
    return rtrans
end

function M:setLocalDelta(trans, width, height)
    local rect = M.findComponent(trans, typeof(RectTransform))
    if rect then
        rect.sizeDelta = Vector2.New(width, height)
    end
end

function M.setButtonClick(trans, func, params, path, ui_name)
    local btn = M.findButton(trans, path)
    if btn then
        btn.onClick:RemoveAllListeners()
        if params then
            btn.onClick:AddListener(
                function()
                    func(trans, params)
                    ui_name = ui_name or ""
                    GameUtil:playBtnSound(ui_name .. "/" .. btn.name)
                end
            )
        else
            btn.onClick:AddListener(func)
        end
    end
    return btn
end

function M.setText(trans, text_msg, path)
    local text = M.findText(trans, path)
    if text and text_msg then
        text.text = text_msg
    end
    return text
end

function M.setTextColor(trans, color, path)
    local text = M.findText(trans, path)
    if text then
        text.color = color
    end
    return text
end

function M.setTextByLanKey(trans, path, lan_key, arg1, ...)
    return M.setText(trans, Language:getTextByKey(lan_key, arg1, ...), path)
end

--img_msg:图片名字 img_atlas：隶属于图集的名字
function M.setImg(trans, img_msg, img_atlas, path)
    local img = M.findImage(trans, path)
    if img then
        img.sprite = ResourceUtil:GetSprite(img_msg, img_atlas)
    end
    return img
end

function M.setScale(trans, scale1, scale2)
    scale1 = scale1 or 1
    if scale2 then
        trans.localScale = Vector3.New(scale1, scale2, 1)
    else
        trans.localScale = Vector3.New(scale1, scale1, 1)
    end
end

function M.setObjectVisible(trans, visible, path)
    local obj = M.findTrans(trans, path)
    if obj then
        obj.gameObject:SetActive(visible)
    end
    return obj
end

-- 设置透明度0~1
function M.setOpacity(trans, opacity)
    local canvas_group = M.findComponent(trans, typeof(CanvasGroup))
    if canvas_group then
        canvas_group.alpha = opacity or 1
    end
end

function M.setToggleIsOn(trans, visible)
    local togBtn = M.findComponent(trans, typeof(Toggle))
    togBtn.isOn = visible
    return togBtn
end

function M.addToggleListener(toggle_btn, func, params, ui_name)
    toggle_btn.onValueChanged:RemoveAllListeners()
    toggle_btn.onValueChanged:AddListener(
        function(check)
            func(check, params)
            if check then
                ui_name = ui_name or ""
                GameUtil:playBtnSound(ui_name .. "/" .. toggle_btn.gameObject.name)
            end
        end
    )
end

function M.destroyObject(obj)
    U3DUtil:Destroy(obj)
end

function M.destroyAllChild(trans)
    local count = trans.childCount
    if count > 0 then
        for i = count - 1, 0, -1 do
            U3DUtil:Destroy(trans:GetChild(i).gameObject)
        end
    end
end

function M.loadGameObject(prefabs, parent)
    local gameObjiec = ResourceUtil:LoadUIGameObject(prefabs, Vector3.zero, nil)
    gameObjiec.transform:SetParent(parent.transform, false)
    return gameObjiec
end

function M.addInputFieldListener(trans, func)
    local input = M.findComponent(trans, typeof(InputField))
    input.onValueChanged:RemoveAllListeners()
    input.onValueChanged:AddListener(func)
    return input
end

function M.worldToScreenPoint(pos)
    return static_ui_camera:WorldToScreenPoint(pos)
end

function M.UITo3D(uipos)
    local screenPos = static_ui_camera:WorldToScreenPoint(uipos)
    screenPos.z = 15
    --SceneManager.curScene.cameraController.Camera_3D.transform.position.z;
    local pos_3d = SceneManager.curScene.cameraController.Camera_3D:ScreenToWorldPoint(screenPos)
    return pos_3d
end

function M.screenToWorldPoint(pos)
    return static_ui_camera:ScreenToWorldPoint(pos)
end

function M.worldToViewportPoint(pos)
    return static_ui_camera:WorldToViewportPoint(pos)
end

function M.findOutline(trans, path)
    return M.findComponent(trans, typeof(Outline), path)
end

function M.setOutlineEffectColor(trans, path, color)
    local outline = M.findComponent(trans, typeof(Outline), path)
    if outline then
        outline.effectColor = color
    end
    return outline
end

function M.findOutlineExt(trans, path)
    return M.findComponent(trans, typeof(OutlineEx), path)
end

function M.setOutlineExEffectColor(trans, path, color, width)
    local outline = M.findComponent(trans, typeof(OutlineEx), path)
    if outline then
        outline.OutlineColor = color
        if width then
            outline.OutlineWidth = width
        end
    end
    return outline
end

function M.setVerticalLayoutGroupSpacing(trans, num)
    local obj = M.findComponent(trans, typeof(VerticalLayoutGroup))
    if obj then
        obj.spacing = num
    end
end

function M.setContentSizeFitterLayoutVertical(trans, path)
    local csf = M.findContentSizeFitter(trans, path)
    if csf then
        csf:SetLayoutVertical()
    end
end

function M.setContentSizeFitterLayoutHorizontal(trans, path)
    local csf = M.findContentSizeFitter(trans, path)
    if csf then
        csf:SetLayoutHorizontal()
    end
end

function M:registerDragEvent(obj, start_func, drag_func, end_func)
    local dragEventHelper = obj:GetComponent("DragEventHelper")
    local begin_pos = nil
    if dragEventHelper then
        local function OnBeginDrag(eventData)
            begin_pos = eventData.position
            start_func(eventData)
        end

        local function OnDrag(eventData)
            drag_func(eventData)
        end

        local function OnEndDrag(eventData)
            if begin_pos then
                end_func(eventData)
            end
            begin_pos = nil
        end
        dragEventHelper.mOnBeginDragHandler = OnBeginDrag
        dragEventHelper.mOnDragHandler = OnDrag
        dragEventHelper.mOnEndDragHandler = OnEndDrag
    end
end

function M:bindUIDragEvent(obj, start_func, drag_func, end_func)
    local dragEventHelper = obj:GetComponent("UI_Input_ADP")
    if dragEventHelper then
        local function OnBeginDrag(eventData)
            start_func(eventData)
        end

        local function OnDrag(eventData)
            drag_func(eventData)
        end

        local function OnEndDrag(eventData)
            end_func(eventData)
        end
        dragEventHelper.Drag_Begin_Handler = start_func
        dragEventHelper.Drag_Move_Handler = drag_func
        dragEventHelper.Drag_End_Handler = end_func
    end
end

function M:AnimEvent_Bind(obj, in_func)
    local luaADP = obj:GetComponent("UI_Anim_ADP")
    if luaADP then
        -- animEventHolder.Void_Handler =
        -- function ()
        -- 	if in_func ~= nil then
        -- 		Logger.log("nil nil nil nil")
        -- 		-- in_func(nil)
        -- 	end
        -- end
        luaADP.Void_Handler = in_func
        luaADP.Int_Handler = in_func
        luaADP.Float_Handler = in_func
        luaADP.String_Handler = in_func
    end
end

function M:Anim_SetBool(obj, valName, val)
    local luaADP = obj:GetComponent("UI_Anim_ADP")
    if luaADP then
        luaADP:Anim_SetBool(valName, val)
    end
end

function M:Anim_SetFloat(obj, valName, val)
    local luaADP = obj:GetComponent("UI_Anim_ADP")
    if luaADP then
        luaADP:Anim_SetFloat(valName, val)
    end
end

function M:Anim_BindFloatCurve(obj, paraName, curveName, dstVal, time)
    local luaADP = obj:GetComponent("UI_Anim_ADP")
    if luaADP then
        luaADP:Anim_BindValue(paraName, curveName, dstVal, time)
    end
end

function M:FInterp(curVal, dstVal, delVal)
    local rst = curVal
    delVal = math.abs(delVal)

    local interpVal = dstVal - curVal
    if dstVal > curVal then
        if interpVal > delVal then
            rst = curVal + delVal
        else
            rst = dstVal
        end
    else
        if interpVal < -delVal then
            rst = curVal - delVal
        else
            rst = dstVal
        end
    end

    return rst
end

function M:FindTrans(rootTrans, withName)
    if (rootTrans.gameObject.name == withName) then
        return rootTrans
    end

    for idx = 0, rootTrans.childCount - 1 do
        local rst = M:FindTrans(rootTrans:GetChild(idx), withName)
        if rst ~= nil then
            return rst
        end
    end
    return nil
end

function M:FindObj(rootObj, withName)

	local rstTrans = M:FindTrans(rootObj.transform, withName)

	if rstTrans then
		return rstTrans.gameObject
	else
		return nil
	end

end


return M
