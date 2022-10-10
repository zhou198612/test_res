local M = class("UpdateControl",LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false
M.m_isRestart = false
M.m_network_tips = true
M.m_link_count = 0
M.m_url_change_count = 0

function M:onEnter()
  	self:getHotUpateData()
	self.later_name = ""
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

function M:responseCode(msg, data, fileName)
	if msg == "isDone" then -- 资源下载完成
		Logger.log(data, "isDone  ==== ")
		self.m_link_count = 0
		if data == 0 then -- 下载完成 去解压
			StatisticsUtil:sendResourcePointLog("endDownloadHotUpdate", fileName)
			Logger.log("endDownloadHotUpdate")
			self.m_url_change_count = 0
			self.m_view:decompressFile()
		elseif data == 1 then -- MD5校验失败 从新下载
			if self:downResUrlChanged() then
				self:downloadRes()
			end
		end
	elseif msg == "code" then
		Logger.log(data, "Update http code ==== ")
		if data ~= 200 and data ~= 302 then
			if self.m_link_count > 3 then
				self.m_link_count = 0
				if self:downResUrlChanged() == false then
					return
				end
			else
				self.m_link_count = self.m_link_count + 1
			end
			self:downloadRes()
		end
	elseif msg == "UncompressCode" then
		if data == 0 then -- 解压完成
			self.m_model:downloadNumber()
			local later_name = U3DUtil:PlayerPrefs_GetString("later_name", "9e379c564dc915e0f5fd2dd393db26c3")
			if self.later_name == later_name then
				U3DUtil:PlayerPrefs_SetString("later_md5", later_name)
				StatisticsUtil:sendBundlesPointLog("DownloadFile")
				U3DUtil:PlayerPrefs_Save()
			end
			self:downloadRes()
		else

		end
	end
end

-- 变更资源备用地址
function M:downResUrlChanged()
	self.m_url_change_count = self.m_url_change_count + 1
	if self.m_url_change_count >= #self.m_model.res_response.url then
		-- Logger.log(self.m_url_change_count,"url all changed === ")
		return false
	end
	self.m_model:downResUrlChanged()
	return true
end

-- 请求热更信息
function M:getHotUpateData()
	-- app 默认是 Android = 1，ios = 2
	--local later_md5 = UserDataManager.local_data:getLocalDataByKey("later_md5", "")
	local later_zip_flag = GameVersionConfig.DOWN_LATER_ZIP
	local later_md5 = U3DUtil:PlayerPrefs_GetString("later_md5", "")
	if later_zip_flag == false then
		U3DUtil:PlayerPrefs_SetString("later_md5", "9e379c564dc915e0f5fd2dd393db26c3")
	end
	local params = { c_ver = GameVersionConfig.CLIENT_VERSION, r_ver = GameVersionConfig.GAME_RESOURCES_VERION,
		app = SDKUtil.sdk_params.app or 1, later_md5 = later_md5}
	local function netCallback(response)
		if response then
			local function downRes()
				self:downloadConfigMd5File(response)
			end
			local bundles_list = response.resource.bundles
			if bundles_list and #bundles_list > 0 then
				Unpacking.fileName = response.resource.bundles[1]
				Unpacking.md5 = response.resource.bundles[3]
				Unpacking.fileSize = tonumber(response.resource.bundles[2])
				U3DUtil:PlayerPrefs_SetString("later_name", response.resource.bundles[3])
				if later_zip_flag == false then
					downRes()
                else
					Unpacking.networkStatusReachable(downRes)
                end
			else
				downRes()
			end
		else
			self:getHotUpateData()
		end
	end
	self.m_model:getNetData("check_version", params, netCallback, nil, true)
end

-- 检测网络环境，是否是WiFi
function M:networkStatusReachable(callback)
	if self.m_network_tips == false then
		callback()
		return
	end

	self.m_network_tips = false
	local netType = GameUtil:getNetworkReachability()
	-- netType = "wifi"
	if netType == "wifi" then
		-- self:downloadRes()
		callback()
	elseif netType == "4G" then
		local params =
	    {
	        on_ok_call = function(msg)
	            -- self:downloadRes()
	            callback()
	        end,
	        on_cancel_call = function (msg)
	        	GameMain.reStart()
	        end,
	        no_close_btn = true,
	        text = Language:getTextByKey("update_str_0002")
	    }
	    static_rootControl:openView("Pops.CommonPop", params)
	else
		local params =
	    {
	        on_ok_call = function(msg)
	            
	        end,
	        on_cancel_call = function (msg)
	        	GameMain.reStart()
	        end,
	        no_close_btn = false,
	        text = Language:getTextByKey("update_str_0005")
	    }
	    static_rootControl:openView("Pops.CommonPop", params)
	end
end

-- 下载热更资源
function M:downloadRes()
	if GameUtil:getpPlatform() == "Editor" then -- 开发环境跳过下载资源
		Logger.log("---------------- jump download res go config --------------")
		self:checkDownloadConfig()
	else
		if self.m_model.down_num < self.m_model.res_response.count then
			local function checkWifiBack()
				self.m_isRestart = true
				local fileName, url = self.m_model:getResUrl()
				local md5 = self.m_model:getResMd5()
				self.later_name = md5
				StatisticsUtil:doPoint("startDownloadHotUpdate")
				StatisticsUtil:sendResourcePointLog("startDownloadHotUpdate", fileName)
				Logger.log("startDownloadHotUpdate")
				self.m_view:downloadRes(fileName, url, md5)
			end
			self:networkStatusReachable(checkWifiBack)
		else
			self:downLoadResEnd()
		end
	end
end

function M:downLoadResEnd()
	-- body
	Logger.log("----------- downLoadResEnd -------------")
	local res_version = self.m_model:getResversion()
	U3DUtil:PlayerPrefs_SetString("game_resources_verion",res_version)
	self:checkDownloadConfig()
end

----------------------------------------------------------------------------------------
---------------------------- 美丽的风景线 ------------------------------------------------
----------------------------------------------------------------------------------------
-- 检查是否下载热更配置
function M:checkDownloadConfig()
	local localAllCfgMd5 = U3DUtil:PlayerPrefs_GetString("all_config_version")
	local netCfgMd5 = self.m_model:getAllConfgMd5()
	-- if localAllCfgMd5 ~= netCfgMd5 then
	self:analysisNeedDownConfig()
	self:downloadConfig()
	-- else
	-- 	self:downloadConfigEnd()
	-- end
end

--- 分析需要下载哪些配置
function M:analysisNeedDownConfig()
    local cfgVersionData = self.m_model:getConfigMd5Table()

    local config_path = GlobalConfig.CONFIG_PATH

    local readData = io.readfile(config_path .. "game_config_version.txt")
    if readData then		
		self.m_model.m_configOldTable = Json.decode(readData) or {};
		for k, v in pairs(self.m_model.m_configOldTable) do
			if cfgVersionData[k] == nil then
				self.m_model.m_configOldTable[k] = nil
			end
		end
    else
        self.m_model.m_configOldTable = {}
    end

    --当前配置文件
    self.m_model.m_downloadCfgTab = {}
    self.m_model.m_downloadCfgMD5 = {}

    -- 过滤不需要多语言配置
    local index = 1
    local addOneDownConfig = function (configName, configVer)
        self.m_model.m_downloadCfgTab[index] = configName
        self.m_model.m_downloadCfgMD5[index] = configVer
        index = index + 1
    end

    local verValue = nil;  -- 记录原版本号
    for configName, configVer in pairs(cfgVersionData) do
    	if configVer and configVer ~= "" then
	        verValue = self.m_model.m_configOldTable[configName]
	        if verValue == nil then
	            addOneDownConfig(configName, configVer)   -- 如果没有记录，则不使用忽略规则
	        else
	            local fileFullPath = config_path .. configName .. ".lua";
	            if configVer ~= verValue or (not io.exists(fileFullPath)) then           -- 本地版本号与远程版本不匹配或者本地文件未找到
	                addOneDownConfig(configName, configVer)
	            end
	        end
	    end
    end
end

-- 下载热更配置
function M:downloadConfig()
	self.m_link_count = 0
	self.m_url_change_count = 0
	self.m_model.down_num = 0
	self.m_model.url_index = 1
	self.m_config_total = #self.m_model.m_downloadCfgTab
	if self.m_config_total > 0 then
		StatisticsUtil:doPoint("startDownloadConfig")
		StatisticsUtil:sendConfigPointLog("startDownloadConfig")
		Logger.log("startDownloadConfig")
	end
	self:downloadNextConfig()
end

-- 变更资源备用地址
function M:downConfigUrlChanged()
	self.m_url_change_count = self.m_url_change_count + 1
	if self.m_url_change_count >= #self.m_model.config_response.url then
		-- Logger.log(self.m_url_change_count,"config url all changed === ")
		return false
	end
	self.m_model:downConfigUrlChanged()
	return true
end

-- 下载配置
function M:downloadNextConfig()
	self.m_view:downloadConfig(self.m_model.down_num, self.m_config_total)
    if self.m_model.down_num >= #self.m_model.m_downloadCfgTab then
    	local netCfgMd5 = self.m_model:getAllConfgMd5()
    	U3DUtil:PlayerPrefs_SetString("all_config_version", netCfgMd5)

    	local function delayCall()
    		self:downloadConfigEnd()
    	end
        self:setOnceTimer(0.1, delayCall)
    else
    	local function checkWifiBack()
			-- self.m_isRestart = true
        	self:downloadConfigCDNData()
		end
		self:networkStatusReachable(checkWifiBack)
    end
end

--- 尝试从CDN下载配置下载
function M:downloadConfigCDNData()
	local configName, md5, url = self.m_model:getConfigUrl()
    if url == nil or url == "" then  -- 没有cdn地址
        return 
    end
    local function responseMethod(gameData, event)
        if gameData == nil then
    		if self:downConfigUrlChanged() == false then
				-- self.m_model:downloadNumber()
				self.m_url_change_count = 0
				self.m_model.url_index = 1
				local params =
			    {
			        on_ok_call = function(msg)
			            self:downloadNextConfig()
			        end,
			        no_close_btn = true,
			        text = Language:getTextByKey("update_str_0007")
			    }
			    static_rootControl:openView("Pops.CommonPop", params)
			else
				self:downloadNextConfig()
			end
        else
        	self:downOneConfigSuccess(configName, gameData, md5)
			self.m_url_change_count = 0
			self.m_model.url_index = 1
	        self:downloadNextConfig()
        end
    end
    Logger.log(url, "donw load config -------  ")
    NetWork:httpRequest( responseMethod , url, GlobalConfig.GET , "", "config_cdn" , 0, true, true, true)
end

--- 下载一个配置成功
function M:downOneConfigSuccess(configName, configData, md5)
	local config_path = GlobalConfig.CONFIG_PATH

    if not io.exists(config_path) then  -- 如果写入配置目录不存在，创建目录
        io.mkdir(config_path)
    end

    local fullpath = config_path .. tostring(configName) .. ".lua"
    -- Logger.log(fullpath,"fullpath ========")
    io.writefile(fullpath, configData)  -- 写入文件

    if md5 then
        self.m_model.m_configOldTable[configName] = md5
        local fullpath = config_path .. "game_config_version.txt"
        io.writefile(fullpath, Json.encode(self.m_model.m_configOldTable))  -- 把版本号写入game_config_version.txt文件，用来和下次做对比
    end

    self.m_model:downloadNumber()
end

-- 配置下载完成
function M:downloadConfigEnd()
	if self.m_model.down_num > 0 then
		StatisticsUtil:sendConfigPointLog("endDownloadConfig")
		Logger.log("endDownloadConfig")
	end
	Logger.log("----------- downLoadRConfigEnd -------------")
	if self.m_isRestart then
		GameMain.download_game_resources = true
		GameMain.reStart()
	else
		ConfigManager:resetCfg()
		Language:init()
		local preload_cfg = ConfigManager:analysisPreloadCfg()
		local index = 1
		local function tick()
			if preload_cfg[index] then
				ConfigManager:loadCfg(preload_cfg[index][1], preload_cfg[index][2])
				index = index + 1
				self.m_view:loadConfig(index, #preload_cfg)
			else
				-- if CS.wt.framework.ResourcesHelper.useAssetBundle then
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("commoneffect")
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_cangyun2")
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_liushan9")
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_robberleader20")
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_gaibang12")
				-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_mingjiao1")
				-- end
				self:removeTimer(self.preload_cfg_timer)
				self:updateMsg(99999)
			end
		end
		self.preload_cfg_timer = self:setTimer(0.02, tick)
  		self.m_view:loadConfig(0, #preload_cfg)
	end
end

--- 从CDN下载配置下载 config.md5.lua
function M:downloadConfigMd5File(param)
	local cfg_url = UserDataManager.server_data:getConfigUrl()
	local url = cfg_url[self.m_model.url_index]
	local md5 = param.config.all_config_version
	self.m_model.url_index = self.m_model.url_index + 1
	if self.m_model.url_index > #cfg_url then
		self.m_model.url_index = 1
	end

	local function responseMethod(response)
		if response then
			local fun = load(response)
			local data = fun()
			data.all_config_version = md5
			self.m_model:setResponse({ config = data, resource = param.resource })
			self:downloadRes()
		else
			self:downloadConfigMd5File(param)
		end
	end

	local filename = url .. "config." .. md5 .. ".lua"
	Logger.log(url, "donw load config md5 file -------  ")
	NetWork:httpRequest(responseMethod ,filename ,GlobalConfig.GET ,"", "config_cdn" , 0, true, true, true)
end

return M
