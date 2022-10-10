local M = class("UpdateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.down_num = 0
	self.url_index = 1
	self.res_response = {}
	self.config_response = {}
	self.m_configOldTable = {}
	self.m_downloadCfgTab = {}
    self.m_downloadCfgMD5 = {}
end

-- 设置热更资源和配置信息
function M:setResponse(data)
	self.res_response = data.resource
	self.res_response.count = #data.resource.files
	self.config_response = data.config
	self.config_response.count = #data.config.game_config_version
	local res_url = UserDataManager.server_data:getResourceUrl()
	if #res_url > 0 then
		self.res_response.url = res_url
	end
	local cfg_url = UserDataManager.server_data:getConfigUrl()
	if #cfg_url > 0 then
		self.config_response.url = cfg_url
	end
end

function M:downloadNumber()
	self.down_num = self.down_num + 1
end

-- 下载失败更换地址
function M:downResUrlChanged()
	self.url_index = self.url_index + 1
	if self.url_index > #self.res_response.url then
		self.url_index = 1
	end
end

-- 获取最新资源的版本号
function M:getResversion()
	return self.res_response.version
end

-- 获取下载资源地址
function M:getResUrl()
	local url = self.res_response.url[self.url_index]
	local file = self.res_response.files[self.down_num + 1][1]
	return file, url .. file
end

-- 获取资源的MD5
function M:getResMd5()
	return self.res_response.files[self.down_num + 1][2]
end

-----------------------------------------------------------------------------
------------------ 下面是配置 -------------------------------------------------
-----------------------------------------------------------------------------

-- 获取最新配置总文件MD5
function M:getAllConfgMd5()
	return self.config_response.all_config_version
end

-- 获取单个配置文件md5列表
function M:getConfigMd5Table()
	return self.config_response.game_config_version
end

-- 获取下载配置地址
function M:getConfigUrl()
	local url = self.config_response.url[self.url_index]
	local file = self.m_downloadCfgTab[self.down_num + 1]
	local md5 = self.m_downloadCfgMD5[self.down_num + 1]
	if url then
		return file, md5, url .. file .. "." .. md5 .. ".lua"
	else
		return file, md5, ""
	end
	
end

-- 下载失败更换地址
function M:downConfigUrlChanged()
	self.url_index = self.url_index + 1
	if self.url_index > #self.config_response.url then
		self.url_index = 1
	end
end

return M
