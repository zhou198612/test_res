------------ ServerData
local M = {
	server_data = nil,
	sid = nil,
	portal_server_address_data = nil,
	select_server_info = nil,
	server_list_index = 1,
}

-- 设置服务器数据
function M:setServerData(serverdata)
	if type(serverdata) ~= "table" then return end
	self.server_data = serverdata
	--GameVersionConfig.SERVICE_URL = self.server_data.domain
end

-- 获取服务器数据
function M:getServerData()
	return self.server_data
end

--获取开服时间(时间戳)
function M:getServerOpenTimeStamp()
	return self.server_data.open_time or 0;
end


--获取开服时间
function M:getServerOpenTime()
	local time = self.server_data.open_time or 0;
	return TimeUtil.gmTime(time)
end

function M:setUserSid(sid)
	self.sid = sid
end

-- 获取玩家sid
function M:getUserSid()
	if self.sid then
		return self.sid
	else
		return ""
	end
end

-- 获取当前服务器id
function M:getServerId()
	if self.server_data then
		return self.server_data.server
	else
		return ""
	end
end

-- 所有服务器数据
function M:setPortalServerAddressData(data)
	if data == nil then return end
	self.portal_server_address_data = data
	local server_info = data.server_info or {}
	-- czg如果有审核地址，审核完后此地址会删除
	local tmp = data[tostring(GameVersionConfig.CLIENT_VERSION)]
	if tmp then
		server_info = tmp
	end

	if #server_info > 0 then
		local index = math.random(1, #server_info)
		self:setSelectServerInfo(server_info[index])
	end
end

--  设置选择的服务器信息
function M:setSelectServerInfo(data)
	if data == nil then return end
	Logger.logWarning(data.name)
	self.select_server_info = data
	local server_list = data.server_list or {}
	if #server_list > 0 then
		self.server_list_index = math.random(1, #server_list)
		GameVersionConfig.SERVICE_URL = server_list[self.server_list_index]
	end
end

--  获取下载配置的url
function M:getConfigUrl()
	if self.select_server_info then
		return self.select_server_info.configurl or {}
	end
	return {}
end

--  获取下载配置的url
function M:getResourceUrl()
	if self.select_server_info then
		return self.select_server_info.resourceurl or {}
	end
	return {}
end

-- 公告地址
function M:getNoticeUrl()
	if self.portal_server_address_data then
		local cur_lan = Language:getCurLanguage()
		return self.portal_server_address_data.noticeurl[cur_lan]
	end
end

return M