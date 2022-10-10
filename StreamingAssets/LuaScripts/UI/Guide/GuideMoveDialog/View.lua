local M = class("GuideMoveDialogView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideMoveDialog"
M.m_size_type = 2
M.m_initLockTime = 0.1

function M:onEnter()
    self:setTextByLanKey("skip_btn_text", "new_str_0346")
    self.m_highlight_node = self:findGameObject("highlight_node")

    self.m_model.m_start_pos.z = 0
    local RectTransform = self.m_ui_obj:GetComponent("RectTransform")
    self.rect = RectTransform.rect
    --self.m_model.m_start_pos.x = self.m_model.m_start_pos.x / U3DUtil:Screen_Width() * self.rect.width
    --self.m_model.m_start_pos.y = self.m_model.m_start_pos.y / U3DUtil:Screen_Height() * self.rect.height
    self.m_highlight_node.transform.localPosition = self.m_model.m_start_pos
    self.m_guide_node = self:findGameObject("guide_node")
    self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
    self:refreshUI()
    self:doTweenMove()
    
end

function M:refreshUI()
    local guide_info = self.m_model.m_guide:getCurExcuteGuideInfo()
    if guide_info then
        local des = guide_info.des
        local hero_id = guide_info.hero_id
        self:setTextByLanKey("guide_text", tostring(des))
        self:setObjectVisible("guide_text_node", des ~= "")
    else
        self:setObjectVisible("guide_text_node", false)
    end
    if self.m_model.m_guideIsForce then
        self.m_hollowOutMask.enabled = true
        self:setObjectVisible("guide_node", self.m_model.m_maskType == 1)
    else
        self.m_hollowOutMask.enabled = false
        self:setObjectVisible("guide_node", true)
    end
end

function M:doTweenMove()
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(self.m_highlight_node.transform:DOLocalMove(self.m_model.m_target_pos, 1))
    sequence:AppendInterval(0.2)
    sequence:SetLoops(-1)
    local arrow = self:findGameObject("arrow")
    local arrow_img = self:findGameObject("arrow_img")
    local pos = self.m_model.m_start_pos + self.m_model.m_target_pos
    local dis = Vector3.Distance(self.m_model.m_start_pos, self.m_model.m_target_pos)
    local size = arrow_img:GetComponent("RectTransform").sizeDelta
    arrow_img:GetComponent("RectTransform").sizeDelta = Vector2.New(math.max(dis, size.x), size.y)
	local cur_stage_pos = Vector3.New( 0 - self.m_model.m_start_pos.x, 0 - self.m_model.m_start_pos.y,0)
	local next_stage_pos = Vector3.New( 0 - self.m_model.m_target_pos.x, 0 - self.m_model.m_target_pos.y,0)
	local from = Vector3.left
    local to = next_stage_pos - cur_stage_pos
	arrow.transform.rotation = Quaternion.FromToRotation(from, to)
    arrow.transform.localPosition = Vector3.New(pos.x / 2, pos.y / 2, pos.z / 2)
end

return M
