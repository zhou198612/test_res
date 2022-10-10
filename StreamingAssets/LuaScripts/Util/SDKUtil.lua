------------------- SDKUtil

local M = {}

M.callbackMap = {}
M.sdk_params = {
	app = 1,
	platform = "editor",
	device = "",
	sysversion = "",
	notch = false,
	notchheight = 0,
}

M.isHaveSDK = false

local __SystemInfo = CS.UnityEngine.SystemInfo
local __Application = CS.UnityEngine.Application
local __SRFileUtil = CS.SRFileUtil

local __tag_callback__ = "__callback__"
function M:init()
	local GameCenter = U3DUtil:GameObject_Find("GameCenter")
	local sdk_component = GameCenter:GetComponent("SdkComponent")
	self.m_sdk_helper = sdk_component.sdk_helper
	self.isHaveSDK = self.m_sdk_helper:checkHaveSDK()
	local function callbackAction(params)
		if params then
			local t_p = Json.decode(params)
			if t_p.func and self.callbackMap[t_p.func] then
				self.callbackMap[t_p.func](t_p)
			end
		end
	end
	self.m_sdk_helper:init(callbackAction)
	--UserDataManager.client_data.is_iphonex = self.sdk_params.notch
	if GameUtil:getpPlatform() == "Ios" then
		self.sdk_params.app = 2
	end
end

function M:sdkInit(callback)
	if GameUtil:getpPlatform() == "Editor" then
		callback({result = true, noplatform = true})
	else
		self.callbackMap["OnsdkInit"] = callback
		self.m_sdk_helper:sdkInit()
	end
end

function M:isLogined(callback)
	self.callbackMap["OnisLogined"] = callback
	self.m_sdk_helper:isLogined()
end

function M:logIn(callback)
	self.callbackMap["OnLoginSuccess"] = callback
	local account_type = U3DUtil:PlayerPrefs_GetInt("account_type", 1)
	self.m_sdk_helper:logIn(account_type)
end

function M:SwitchAccount(callback)
	self.callbackMap["OnSwitchAccount"] = callback
	self.m_sdk_helper:SwitchAccount()
end

function M:BindAccount(callback)
	self.callbackMap["OnBindAccount"] = callback
	self.m_sdk_helper:BindAccount()
end

function M:logOut(callback)
	self.callbackMap["OnlogOut"] = callback
	self.m_sdk_helper:logOut()
end

function M:exitGame()
	self.m_sdk_helper:exitGame()
end

function M:getPlatform(platform_callback)
	self.callbackMap["OngetPlatform"] = function(data)
		if data and data ~= "" then
			for k,v in pairs(data) do
				M.sdk_params[k] = v
			end
		end
		if self.sdk_params.notch then
			UserDataManager.client_data.is_iphonex = self.sdk_params.notch
		end
		Logger.log(M.sdk_params,"platform ====")
		if platform_callback then
			platform_callback()
		end
	end

	self.m_sdk_helper:getPlatform()
	self.sdk_params.device = __SystemInfo.deviceName
	self.sdk_params.device_mark = UserDataManager.client_data.device_mark
	self.sdk_params.operatingSystem = __SystemInfo.operatingSystem
	self.sdk_params.cpuType = __SystemInfo.processorType
	self.sdk_params.processorCount = __SystemInfo.processorCount -- cup核心数
	self.sdk_params.GLRender = __SystemInfo.graphicsDeviceName
	self.sdk_params.GLVersion = __SystemInfo.graphicsDeviceVersion
	self.sdk_params.applicationVersion = __Application.version
	self.sdk_params.sysLanguage = __Application.systemLanguage:ToString()
	self.sdk_params.memory = __SystemInfo.systemMemorySize -- 内存
	self.sdk_params.graphicsMemory = __SystemInfo.graphicsMemorySize -- 显存
	self.sdk_params.screenWidth = U3DUtil:Screen_Width()
	self.sdk_params.screenHight = U3DUtil:Screen_Height()
	self.sdk_params.network = U3DUtil:Get_NetWorkMode()
	-- self.sdk_params.mac = CS.PlatformUtil.GetMacAddress()
end

function M:appendPlatformParam(params)
	for k,v in pairs(self.sdk_params) do
		--params[k] = string.urlencode(tostring(v))
		params[k] = tostring(v)
	end
end

function M:sendInfoToPlatform(callback, params)
	self.callbackMap["sendInfoToPlatform"] = callback
	self.m_sdk_helper:sendInfoToPlatform(params)
end

function M:isNotch()
	return self.m_sdk_helper:isNotch()
end

function M:pay(callback, goodsInfo)
	local params = Json.encode(goodsInfo)
	self.callbackMap["OnPay"] = callback
	self.m_sdk_helper:Pay(params)
	--local userInfo = SDKUtil:GetUserInfo()
	--Logger.log("是否关联" .. tostring(userInfo.isRelated))
	--if userInfo.isRelated then
	--	local params = Json.encode(goodsInfo)
	--	self.callbackMap["OnPay"] = callback
	--	self.m_sdk_helper:Pay(params)
	--else
	--	local params =
	--	{
	--		on_ok_call = function()
	--			SDKUtil:BindAccount(handler(self, self.BindAccountCall))
	--		end,
	--		no_close_btn = true,
	--		ok_text = Language:getTextByKey("login_str_0005"),
	--		text = Language:getTextByKey("5875"),
	--	}
	--	static_rootControl:openView("Login.BindAccountPop", params)
	--end
end

function M:openUrl(url)
	self.m_sdk_helper:openUrl(url)
end

function M:showAd(callback)
	self.callbackMap["OnshowAd"] = callback
	self.m_sdk_helper:showAd()
end

function M:Share(callback, img_path)
	self.callbackMap["OnShare"] = callback
	self.m_sdk_helper:Share("system", "IMAGE", "", "", "", "LOCAL", img_path)
end

function M:GetUserInfo()
	local userInfo = self.m_sdk_helper:GetUserInfo() or ""
	return Json.decode(userInfo)
end

function M:BindAccountCall()
	local params =
	{
		on_ok_call = function()
		end,
		no_close_btn = true,
		ok_text = Language:getTextByKey("login_str_0007"),
		text = Language:getTextByKey("5876")
	}
	static_rootControl:openView("Login.BindAccountPop", params)
end

return M
