local M = class("LoginModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	math.randomseed(os.time())
	local login_cfg = ConfigManager:getCfgByName("login")
	local id = math.random(1, #login_cfg)
	self.m_login_cfg = login_cfg[id]
	self.m_user_name = U3DUtil:PlayerPrefs_GetString("username")
	self.m_user_password = U3DUtil:PlayerPrefs_GetString("password")
	self.auto_register = false
	--if self.m_user_name == nil or self.m_user_name == "" then
	--	self.m_user_name = "acc" .. math.random(100,9999999)
	--	self.m_user_password = 1
	--	self.auto_register = true
	--end
	self.m_sdk_login_state = 0
	self.m_sdk_init_success = false
end

function M:setSdkAccount(params)
	U3DUtil:PlayerPrefs_SetInt("account_type", params.type)
	self.m_sdk_login = true
	self.m_uid = params.uid
	self.m_token = params.token
	self.m_cpUid = params.cpUid
	self.m_appId = params.appId
	self.m_channel = params.channel
	self.m_channelId = params.channelId
	self.m_showName = params.showName
	self.m_certification = params.certification
	self.m_type = params.type
	self.m_isRelated = params.isRelated
end

return M
