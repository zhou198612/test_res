local M = class("LoginView",LikeOO.OOSceneBase)

M.m_uiName = "Login/Login"

function M:onEnter()
	self:setObjectVisible("img_notice", false)
	self:setText("res_version_text",Language:getTextByKey("new_str_0001") .. GameVersionConfig.GAME_RESOURCES_VERION)
	self:findText("client_version_text").text = Language:getTextByKey("new_str_0002") .. GameVersionConfig.CLIENT_VERSION
	self:findText("start_text").text = Language:getTextByKey("new_str_0003")
	self:setTextByLanKey("txt_des", "login_str_0001")
	self:setTextByLanKey("txt_sdk_account", "login_str_0002")
	self:setTextByLanKey("txt_account", "login_str_0002")
	self:setTextByLanKey("txt_notice", "notice_str_0001")
	self:setTextByLanKey("txt_privacy_btn", "login_str_0003")
	self:setTextByLanKey("txt_service_btn", "login_str_0004")
	self:setImg("age_notice", ResourceUtil:getLanAtlas(), "btn_age")
	self:setImg("ui_dl_qxsysm_txt_title", ResourceUtil:getLanAtlas(), "img_title_des")
	self:setImg("ui_dl_slts_txt_title", ResourceUtil:getLanAtlas(), "img_title_age")
	local str = string.gsub(Language:getTextByKey("tid#mustdo1"), "\\n", "\n")
	self:setText("mustdo_text", str)
	self:setTextByLanKey("notice_btn_text", "notice_str_0001")
	self:setTextByLanKey("vedio_btn_text", "new_str_0469")
	--local bg_img = self:findGameObject("bg_img")
	--GameUtil:updateResourcesImg(bg_img, PathUtil:GetBgPath(self.m_model.m_login_cfg.back))
	local girl_spine = self:findGameObject("girl_spine")
	local title_spine = self:findGameObject("title_spine")
	GameUtil:updateSpineLoadSet(girl_spine,"GirlSpine/" .. self.m_model.m_login_cfg.back .. "_SkeletonData","animation",0,true)
	local spine_name = Language:getCurLanguage() .. "_dengluye_UI_SkeletonData"
	GameUtil:updateSpineLoadSet(title_spine,"GirlSpine/" .. spine_name,"animation",0,true)
	if self.m_model.m_login_cfg.forward and self.m_model.m_login_cfg.forward ~= "" then
		self:setObjectVisible("bg_img_up", true)
		local bg_img_up = self:findGameObject("bg_img_up")
		GameUtil:updateResourcesImg(bg_img_up, PathUtil:GetBgPath(self.m_model.m_login_cfg.forward))
	else
		self:setObjectVisible("bg_img_up", false)
	end
	self:setText("dec_content_1", string.gsub(Language:getTextByKey(2619 or "???"), "\\n", "\n"))
	self:setText("dec_content_2", string.gsub(Language:getTextByKey(3138 or "???"), "\\n", "\n"))
	self:setText("dec_content_3", string.gsub(Language:getTextByKey(3139 or "???"), "\\n", "\n"))
	self:setText("dec_content_4", string.gsub(Language:getTextByKey(3140 or "???"), "\\n", "\n"))
	self:setText("age_content", string.gsub(Language:getTextByKey(2778 or "???"), "\\n", "\n"))
	self:setText("service_content", string.gsub(Language:getTextByKey(1204 or "???"), "\\n", "\n"))
	self:setText("privacy_content", string.gsub(Language:getTextByKey(5759 or "???"), "\\n", "\n"))
	self:setTextByLanKey("txt_title_service", "4983")
	self:setTextByLanKey("txt_title_privacy", "5758")
	self:findGameObject("content_dec").transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	self:findGameObject("content_age").transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	self:findGameObject("content_service").transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	self:findGameObject("privacy_content").transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
	self:setObjectVisible("des_node", false)
	self:setObjectVisible("btn_close", false)
	self:setObjectVisible("age_node", false)
	self:setObjectVisible("service_node", false)
	self:setObjectVisible("privacy_node", false)
	self:setText("txt_service", string.gsub(Language:getTextByKey(5686 or "???"), "\\n", "\n"))
	self.m_sequence = Tweening.DOTween.Sequence()
	--self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findText("start_text"), 0.2, 2))
	self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("start_img"), 0.2, 2))
	--self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findText("start_text"), 1, 2))
	self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("start_img"), 1, 2))
	self.m_sequence:SetLoops(-1)
	self:refreshUI()
	--self:retainVisibleView()
	self:startBtnVisible(false)
	self:setParticleRenderOrder(self.content_node)
	--self:updateMsg("open_vedio")
end

function M:refreshUI()
	local server_data = UserDataManager.server_data:getServerData()
	if server_data then
		self:setText("select_server_text",server_data.server_name)
	end
end

function M:sdkVisible(flag)
	flag = flag or false
	self:setObjectVisible("account_btn", flag)
end

function M:startBtnVisible(flag)
	self:setObjectVisible("start_btn", flag)
end

function M:switchNotice(flag)
	if not flag then
		local img_notice = self:findImage("img_notice")
		local img_notice_1 = self:findImage("img_notice_1")
		local img_notice_2 = self:findImage("img_notice_2")
		DOTweenModuleUI.DOFade(img_notice, 0.2, 1)
		DOTweenModuleUI.DOFade(img_notice_1, 0.2, 1)
		DOTweenModuleUI.DOFade(img_notice_2, 0.2, 1)
		self.m_control:setOnceTimer(1.0, function()
			self:setObjectVisible("img_notice", false)
			self:setObjectVisible("img_notice_1", false)
			self:setObjectVisible("img_notice_2", false)
			--self:updateMsg("account_btn")
			--self:updateMsg("open_notice")
		end)

		StatisticsUtil:doPoint("healthyNotice")
		Logger.log("healthyNotice")
	end
end

function M:destroy()
	self.m_sequence:Kill()
    M.super.destroy(self)
end

return M