------------ LocalData 本地数据
---
local __local_file_name = "local_data.txt"

local M = {
	userData = nil,   	-- 用户数据
	localData = nil, 	-- 本地数据,用户无关数据
	cur_uid = nil,
}

function M:init()
	self.localData = GameUtil:getTableDataByName(__local_file_name) or {}
end

function M:getLocalDataByKey(key, default)
	if self.localData[key] then
		return self.localData[key]
	else
		return default
	end
end

function M:setLocalDataByKey(key, data)
	self.localData[key] = data
	self:flushLocalData()
end

function M:flushLocalData()
	GameUtil:saveTableDataWithName(self.localData or {}, __local_file_name)
end

-- 需要有uid后初始化
function M:initUserData(uid)
	self.userData = GameUtil:getTableDataByName(tostring(uid)) or {}
	self.cur_uid = uid
end

function M:getUserDataByKey(key, default)
	if self.userData and self.userData[key] ~= nil then
		return self.userData[key]
	else
		return default
	end
end

function M:setUserDataByKey(key, data)
	local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	if uid and uid ~= "" then
		if self.userData == nil or self.cur_uid ~= uid then
			self:initUserData(uid)
		end
		self.userData[key] = data
		self:flushUserData()
	else
		Logger.logError("setUserDataByKey player uid not exist !")
	end
end

function M:flushUserData()
	local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	if uid and uid ~= "" then
		GameUtil:saveTableDataWithName(self.m_userData or {}, uid)
	else
		Logger.logError("flushUserData player uid not exist !")
	end
end

function M:delete()

end

return M