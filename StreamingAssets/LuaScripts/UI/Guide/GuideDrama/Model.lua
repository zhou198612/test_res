local M = class("GuideDramaModel", LikeOO.OODataBase)

function M:onCreate()
	self:getData()
end

function M:onEnter()
	local ids = self.m_params.dialogs
	local is_guide = self.m_params.guide or false
	self.m_bgm = ""
	if not ids then
		local dialog_id = self.m_params.dialog_id or 101
		local dialogue_event_team = {}
		if is_guide then
			dialogue_event_team = ConfigManager:getCfgByName("dialogue_guide_team")
		else
			dialogue_event_team = ConfigManager:getCfgByName("dialogue_event_team")
		end
		local dialogue_event_team_item = dialogue_event_team[dialog_id] or {}
		ids = dialogue_event_team_item.dialogue_id or {}
		self.m_bgm = dialogue_event_team_item.bgm or ""
	end
	local dialogue_event = {}
	if is_guide then
		dialogue_event = ConfigManager:getCfgByName("dialogue_guide")
	else
		dialogue_event = ConfigManager:getCfgByName("dialogue_event")
	end
	local dialogs = {}
	for i, id in ipairs(ids) do
		local cfg = dialogue_event[id]
		if cfg then
			table.insert(dialogs, {dialogue_cfg = cfg})
		end
	end
	self.m_dialogs = dialogs
	self.m_dialog_index = 1
	self.m_talking = false
	local choise = self.m_params.choise or {}
	local choise_id = self.m_params.choise_id or {}
	self.m_select_drama_data = {}
	for i, v in ipairs(choise) do
		table.insert(self.m_select_drama_data, {des = v, id = choise_id[i]})
	end
end

function M:getDialogs()
	return self.m_dialogs
end

function M:getCurDialog()
	return self.m_dialogs[self.m_dialog_index]
end

function M:nextDialog()
	self.m_dialog_index = self.m_dialog_index + 1
	return self:getCurDialog() ~= nil
end

function M:setTalking(flag)
    self.m_talking = flag
end

function M:getTalking()
    return self.m_talking
end

function M:getSelectDramaData()
	return self.m_select_drama_data or {}
end

return M