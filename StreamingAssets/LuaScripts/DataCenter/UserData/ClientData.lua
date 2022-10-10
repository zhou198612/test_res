------------ ClientData

local M = {
	user_token = nil,
	app_id = nil,
	pt = nil,
	lan = nil,
	user_account = nil,
	device_mark = nil,
	is_iphonex = false,
	is_new_user = false,
	nosdk = true,
	sk = nil,
	crypto_switch = false,
	crypto_key = "z+m-h/x*",
	login_crypto_key = "z4+lm7oh2g/xi*0n",
	all_crypto_key = nil,
	close_ad = false,
}

if GameVersionConfig.IS_SERVER == false then
	local screen_width = U3DUtil:Screen_Width()
	local screen_height = U3DUtil:Screen_Height()
	if screen_height == 2436 and screen_width == 1125 then
		M.is_iphonex = true
	else
		-- TODO  通过不同的机型返回是否需要处理刘海
	end
	M.device_mark = U3DUtil:Get_SystemInfo_Indentifier()
end


function M:setSk(value)
	self.sk = value
	self.all_crypto_key = tostring(self.crypto_key) .. tostring(self.sk)
end

function M:getAllCryptoKey()
	return tostring(self.all_crypto_key)
end

function M:setCryptoSwitch(value)
	self.crypto_switch = value
end

function M:getCryptoSwitch()
	return self.crypto_switch
end

local __LuaZipHelper = CS.wt.framework.LuaZipHelper
local __gzip_flag = GameVersionConfig.vcd == 1
local __XXTEA = CS.Xxtea.XXTEA

function M:encryptToBase64String(data_str)
	local key = self:getAllCryptoKey()
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipCompressAndEncrypt(data_str, key)
	else
		temp_data = self:ToBase64String(data_str)
	end
	return temp_data
end

function M:ToBase64String(params_str)
	local temp_data = __XXTEA.ToBase64String(params_str)
	return temp_data
end

function M:FromBase64String(params_str)
	local temp_data = __XXTEA.FromBase64String(params_str)
	return temp_data
end

function M:decryptBase64StringToString(data_str)
	local key = self:getAllCryptoKey()
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipDecompressAndDecrypt(data_str, key)
	else
		temp_data = self:FromBase64String(data_str)
	end
	return temp_data
end

function M:loginEncryptToBase64String(data_str)
	local key = self.login_crypto_key
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipCompressAndEncrypt(data_str, key)
	else
		temp_data = self:ToBase64String(data_str)
	end
	return temp_data
end

function M:loginDecryptBase64StringToString(data_str)
	local key = self.login_crypto_key
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipDecompressAndDecrypt(data_str, key)
	else
		temp_data = self:FromBase64String(data_str)
	end
	return temp_data
end


return M