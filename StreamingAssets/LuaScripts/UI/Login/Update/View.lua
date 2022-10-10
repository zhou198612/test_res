local M = class("UpdateView",LikeOO.OOPopBase)

M.m_uiName = "Login/Update"
M.m_size_type = 2

function M:onEnter()
	self.progress_text = self:findText("progress_text")
	self.progress_slider = self:findSlider("progress_slider")
	self.progress_anim_bar = self:findGameObject("progress_anim_bar")
	self.m_spine_player = self:findGameObject("spine_1")
	self.m_spine_biao = self:findGameObject("spine_3")
	self:refreshUI()

	self.m_Hotupdate = self.m_ui_obj:AddComponent(typeof(CS.wt.framework.HotUpdate))
	self.m_Uncompress = self.m_ui_obj:AddComponent(typeof(CS.wt.framework.Uncompress))
end

function M:refreshUI()

end

function M:downloadRes(fileName, url, md5)
	self.m_spine_biao:SetActive(true)
	local function httpStatus(msg, data)
		self.m_control:responseCode(msg, data, fileName)
	end
	local function slider(cur, total)
		self.progress_slider.value = cur/total
		-- local s = self:convertBytes(cur)

		local text = Language:getTextByKey("update_str_0001") .. self:convertBytes(cur) .. "/" .. self:convertBytes(total)
		self.progress_text.text = text
		self:setAnimation()
	end
	self.m_Hotupdate:DownLoadFile(fileName, url, md5, httpStatus, slider)
end

function M:convertBytes(bytes)
	local bytesList = {"B", "KB", "MB", "GB"}
	if bytes > 0 then
		-- Logger.log(math.log(bytes, 1024))
		local index = math.floor(math.log(bytes, 1024))
		-- Logger.log("----------> index = " .. index)
		if index > #bytesList then index = #bytesList end
		-- Logger.log(1024^index)
		return tostring(string.format("%.1f",bytes/(1024^index))) .. bytesList[index+1]
	else
		return "0B"
	end
end

function M:decompressFile()
	self.m_spine_biao:SetActive(true)
	local function decompressStatus(msg, data)
		self.m_control:responseCode(msg, data)
	end
	local function slider(cur, total)
		self.progress_slider.value = cur/total

		local text = Language:getTextByKey("update_str_0003") .. string.format("%.1f", cur/total * 100) .. "%"
		self.progress_text.text = text
		self:setAnimation()
	end
	self.m_Uncompress:Decompress(decompressStatus, slider)
end

function M:downloadConfig(cur, total)
	self.progress_slider.value = cur/total
	local text = Language:getTextByKey("update_str_0004") .. cur .. "/" .. total
	self.progress_text.text = text
end

function M:loadConfig(cur, total)
	self.progress_slider.value = cur/total
	local text = Language:getTextByKey("update_str_0006") .. cur .. "/" .. total
	self.progress_text.text = text
end

function M:setAnimation()
	-- if self.progress_slider.value >= 1 then
	-- 	local m_p = self.m_spine_player:GetComponent("SkeletonGraphic")
	-- 	self.m_spine_biao:SetActive(false)
	-- 	if m_p then
	-- 		m_p.AnimationState:AddAnimation(0,"animation2",false,0)
	-- 	end
	-- end
end

function M:noDownloadAnimation()
	local value = 0
	local function tickCall()
		value = value + 3
		self.progress_slider.value = value/100
		if value >= 100 then
			self:setAnimation()
			self.m_control:removeTimer(self.timer)
			self.m_control:setOnceTimer(0.7, function()
	            self:updateMsg(99999)
	        end)
		end
	end	
	self.timer = self.m_control:setTimer(0.01,tickCall)
end

return M