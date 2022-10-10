----------------Logger
local M = { history = {} }

local Debug;
local logDebug
local LogError
local LogWarning

if GameVersionConfig.IS_SERVER then
	logDebug = print
	LogError= print
    LogWarning = print
else
	logDebug = U3DUtil:Log()
	LogError= U3DUtil:LogError()
    LogWarning = U3DUtil:LogWarning()
end


local function _logDebug(var)
	logDebug(var)
	M.catch(var)
end

local function _LogError(var)
	LogError(var)
	M.catch(var)
end

local function _LogWarning(var)
	LogWarning(var)
	M.catch(var)
end

function M.catch(var)
	if GameVersionConfig.IS_SERVER then return end
	table.insert(M.history, var)
	if #M.history > 30 then
		table.remove(M.history, 1)
	end
end

function M.log(var, name)
	if GameVersionConfig.Debug then
	    name = name or "var"
	    name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	    if(var == nil)then
			_logDebug("----- var is nil : " .. name)
	        return   
	    end
	    if type(var) == "table" then
			_logDebug(name .. " = " .. table.dump(var, true, 10))
	    else
			_logDebug(name .. " = " .. tostring(var))
	    end
	end
end

function M.logError(var, name)
	if GameVersionConfig.Debug then
	    name = name or "var"
	    name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	    if(var == nil)then
			_logDebug("----- var is nil : " .. name)
	        return   
	    end
	    if type(var) == "table" then
			_LogError(name .. " = " .. table.dump(var, true, 10))
	    else
			_LogError(name .. " = " .. tostring(var))
	    end
	end
end

function M.logWarning(var, name)
	if GameVersionConfig.Debug then
	    name = name or "var"
	    name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	    if(var == nil)then
			_logDebug("----- var is nil : " .. name)
	        return   
	    end
	    if type(var) == "table" then
			_LogWarning(name .. " = " .. table.dump(var, true, 5))
	    else
			_LogWarning(name .. " = " .. tostring(var))
	    end
	end
end

return M