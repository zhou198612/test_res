--- 剧情对话
local M = class("GuideDramaView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideDrama"
M.m_size_type = 2
local __WORD_ARR = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

function M:onEnter()
    self:setTextByLanKey("skip_btn_text", "new_str_0346")
    self:setTextByLanKey("drama_name_text", "")
    self.m_drama_text = self:setTextByLanKey("drama_text", "")
    self.left_hero_img = self:findImage("left_hero_img")
    self.centre_hero_img  = self:findImage("centre_hero_img")
    self.right_hero_img = self:findImage("right_hero_img")
    self.m_name_node = self:findGameObject("name_node")
    self.m_bg_image = self:findImage("bg_image")
    self.bg_image_2 = self:findImage("bg_image_2")
    self:setObjectVisible("select_drama_node", false)
    self:refreshUI()
end

function M:refreshUI()
    self:showDramaInfo()
end

function M:stopAllVoice()

end

function M:showDramaInfo()
    self:stopAllVoice()   -- 停止音效
    local talk_data = self.m_model:getCurDialog()
    if talk_data then
        local dialogue_cfg = talk_data.dialogue_cfg
        self:setName(dialogue_cfg)
        self:setSpine(dialogue_cfg)
        self.m_word = Language:getTextByKey(dialogue_cfg.words)
        self.m_word_len  = string.len(self.m_word)
        self.m_left = self.m_word_len
        self.m_model:setTalking(true)
        self:doDramaWord()
    end
end

function M:setDramaText()
    if self.m_model:getTalking() then
        self:killAnim()
        self:setTextByLanKey("drama_text", self.m_word)
        self.m_model:setTalking(false)
    end
end

function M:setName(dialogue_cfg)
    local role_name = dialogue_cfg.role_name or ""
    if role_name ~= "" then
        self:setTextByLanKey("drama_name_text", tostring(dialogue_cfg.role_name))
        self.m_name_node:SetActive(true)
    else
        self.m_name_node:SetActive(false)
    end
    local name_pos = dialogue_cfg.name_pos
    -- 1右 2左 3中
    if name_pos == 1 then
        UIUtil.setLocalPosition(self.m_name_node, 390)
    elseif name_pos == 2 then
        UIUtil.setLocalPosition(self.m_name_node, -390)
    else
        UIUtil.setLocalPosition(self.m_name_node, 0)
    end
end

function M:setSpine(dialogue_cfg)
    local role_left = dialogue_cfg.role_left	
    local role_right = dialogue_cfg.role_right	
    local role_center = dialogue_cfg.role_center

    if self.m_role_left ~= role_left and role_left ~= "" then
        --GameUtil:setHeroSpineBySG(role_left, self.m_left_hero_spine)
        GameUtil:updateResourcesImg(self.left_hero_img, PathUtil:GetFigurePath(role_left))
        self.m_role_left = role_left
    end
    if self.m_role_center ~= role_center  and role_center ~= "" then
        GameUtil:updateResourcesImg(self.centre_hero_img, PathUtil:GetFigurePath(role_center))
        self.m_role_center = role_center
    end
    if self.m_role_right ~= role_right and role_right ~= "" then
        GameUtil:updateResourcesImg(self.right_hero_img, PathUtil:GetFigurePath(role_right))
        self.m_role_right = role_right
    end

    local left_up_sel = dialogue_cfg.left_up == 1
    local center_up_sel = dialogue_cfg.center_up == 1
    local right_up_sel = dialogue_cfg.right_up  == 1

    self.left_hero_img.color = left_up_sel and Color.white or Color.gray
    self.centre_hero_img.color = center_up_sel and Color.white or Color.gray
    self.right_hero_img.color = right_up_sel and Color.white or Color.gray
    self.left_hero_img.gameObject.transform.localScale = Vector3.one*(left_up_sel and 1.2 or 1)
    self.centre_hero_img.gameObject.transform.localScale = Vector3.one*(center_up_sel and 1.2 or 1)
    self.right_hero_img.gameObject.transform.localScale = Vector3.one*(right_up_sel and 1.2 or 1)

    if not center_up_sel then
        self.centre_hero_img.gameObject.transform:SetAsFirstSibling()
    end
    if not right_up_sel then
        self.right_hero_img.gameObject.transform:SetAsFirstSibling()
    end
    if not left_up_sel then
        self.left_hero_img.gameObject.transform:SetAsFirstSibling() --- 是设置成第一个，显示在最后面
    end
    
    if center_up_sel then
        self.centre_hero_img.gameObject.transform:SetAsLastSibling() 
    end
    if right_up_sel then
        self.right_hero_img.gameObject.transform:SetAsLastSibling()
    end
    if left_up_sel then
        self.left_hero_img.gameObject.transform:SetAsLastSibling() 
    end

    self.left_hero_img.gameObject:SetActive(role_left ~= "")
    self.centre_hero_img.gameObject:SetActive(role_center ~= "")
    self.right_hero_img.gameObject:SetActive(role_right ~= "")
    local transparent = dialogue_cfg.transparent or 155
    local color = self.m_bg_image.color
    color.a = transparent/255
    self.m_bg_image.color = color
    local dialog_kind = dialogue_cfg.dialog_kind or 1
    self:setObjectVisible("drama_text_bg_img", dialog_kind ~= 0)
    if dialogue_cfg.bgpic and dialogue_cfg.bgpic ~= "" then
        local color = self.bg_image_2.color
        color.a = 1
        self.bg_image_2.color = color
        --self:setImg(dialogue_cfg.bgpic, dialogue_cfg.bgpic, "bg_image_2")
        local bg_img = self:findImage("bg_image_2")
        GameUtil:updateResourcesImg(bg_img, PathUtil:GetBgPath(dialogue_cfg.bgpic))
    else
        local color = self.bg_image_2.color
        color.a = 0
        self.bg_image_2.color = color
    end
end

function M:updateDramaWord()
    if self.m_model:getTalking() then
        if self.m_left == 0 then
            self.m_model:setTalking(false)
        else
            local tmp = string.byte(self.m_word, - self.m_left)
            local i = #__WORD_ARR
            while __WORD_ARR[i] do
                if tmp >= __WORD_ARR[i] then
                    self.m_left = self.m_left - i
                    break
                end
                i = i - 1
            end
            self:setTextByLanKey("drama_text", string.sub(self.m_word, 0, self.m_word_len - self.m_left))
        end
    end
end

function M:doDramaWord()
    if self.m_model:getTalking() then
        self:killAnim()
        local sequence = Tweening.DOTween.Sequence()
        self.m_drama_text.text = ""
        sequence:Append(DOTweenModuleUI.DOText(self.m_drama_text, self.m_word, 1))
        sequence:OnComplete(function()
            self.m_sequence = nil
            self.m_model:setTalking(false)
        end)
        self.m_sequence = sequence
    end
end

function M:killAnim()
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
end

--[[
	创建列表
]]
function M:updateSelectDramaLoopScroll()
    self:setObjectVisible("select_drama_node", true)
	local data = self.m_model:getSelectDramaData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "select_des_text", tostring(cell_data.des))
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_drama_Item", {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:destroy()
    self:killAnim()
    M.super.destroy(self)
end

return M
