local M = class( "OODataBase" , nil )

M.m_name = nil					-- the frame name
M.m_alias = nil				-- the frame alias
M.m_data = nil					-- nomorl data with net or native
M.m_params = nil				-- the frame's params that control function openViews second param
-- 1 is a first data
-- 2 is a histroy data for back to
M.m_type = 1
M.m_destroy_flag = nil

--[[
异／同步方法，获得getData获得的数据
data : type is lua table
]]
function M:callBack( data )
	self.m_data = data
	local tempControl = nil
	local tempname = "UI." .. self.m_name .. ".Control"
 	if GameVersionConfig.LUA_RELOAD_DEBUG then
		tempControl = LuaReload(tempname):new()
	else
		tempControl = require(tempname):new()
	end
	tempControl.m_model = self
	self:onEnter()
	tempControl:create()
end


--[[
根据key得到数据，
key ＝ "http://"开头时，是网络数据,否则为本地数据
params 为网络请求参数，可以没有
]]
function M:getData( key , params, loadingFlag, requestMethod, ext)	
	if( self.m_data~=nil )then
		self:callBack( self.m_data )
		return
	end
	local url = NetUrl.getUrlForKey(key)
	if(url~=nil and string.find(url , "http://"))then
		local function responseMethod(data, tag)
			if(data == nil )then
				if ext and ext.forceBack then   -- 强制返回
					self:getData(key , params, loadingFlag, requestMethod, ext)
				else
					if(self.m_type == 2)then
						static_pageList:addData( self )
					end
				end
			else
            	self:callBack( data )
            end
        end
        requestMethod = requestMethod or GlobalConfig.POST
        url = url .. "&__ts=" .. tostring(os.time())    -- 请求添加时间参数
		NetWork:httpRequest( responseMethod , url , requestMethod , params , key , loadingFlag or 1 , true)
	else
		self:callBack(nil)
	end
end

-- 获取网络数据，有回调
function M:getNetData( key , params , callfunc , loadingFlag, returnFlag, requestMethod, ext)
	local url = NetUrl.getUrlForKey(key)
	local function responseMethod(data, tag, status_code)
		if(data ~= nil)then
			self:netData(data, tag)
        	if callfunc and self.m_destroy_flag == false then
       			callfunc(data, tag, status_code)
       		end
       		EventDispatcher:dipatchEvent(self:getName() .. "NetRefresh",{tag = key})
       	else
       		if ext and ext.forceBack then   -- 强制返回
       			self:getNetData(url , params , callfunc , loadingFlag, returnFlag, requestMethod, ext)
       		else
	       		if callfunc and self.m_destroy_flag == false then
	    			callfunc(nil, tag, status_code)
	        	end
       		end
        end
    end
    requestMethod = requestMethod or GlobalConfig.POST
	local newkey = url .. "&__ts=" .. tostring(os.time())    -- 请求添加时间参数
	NetWork:httpRequest( responseMethod , newkey , requestMethod , params , key, loadingFlag or 1, returnFlag)
end

--- 网络数据回调，需要复写
function M:netData(data, tag)

end

-- 获得当前view框架名字
function M:getName(  )
	return self.m_name
end

-- 获得当前view框架别名
function M:getAlias(  )
	return self.m_alias
end

--[[
M默认启动接口
]]
function M:create( name , params , alias )
	self.m_name = name
	self.m_params = params or {}
	self.m_alias = alias
	self.m_destroy_flag = false
	self:onCreate()
end

--[[
默认销毁接口
]]
function M:destroy(  )
	-- Logger.log("----------- destroy model " .. self:getName())
	self.m_destroy_flag = true
end

-- ============================================ a little cut of line ================================

function M:onCreate(  )
	-- Logger.log("------------------ model onCreate " .. self.m_name)
end

function M:onEnter(  )
	-- Logger.log("------------------ model onEnter " .. self.m_name)
end

return M