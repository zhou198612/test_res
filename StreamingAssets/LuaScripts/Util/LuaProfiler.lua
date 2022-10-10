--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-06-08 14:39:04
]]

---@type LuaProfiler
local LuaProfiler = class("LuaProfiler")

local isEnabled = Constants.DebugExecTime
function LuaProfiler:ctor(name)
	if not isEnabled then return end
	self.name = name
	self.totalTimeRecorder = {}
	self.timestamp = 0
end

function LuaProfiler:RecordBegin(funcName)
	if not isEnabled then return end	
	self.funcName = funcName

	local record = self.totalTimeRecorder[funcName]
	if record == nil then
		self.totalTimeRecorder[funcName] = {call=0,totaltime=0,max=0,min=9999,records={}}
		record = self.totalTimeRecorder[funcName]
	end
	record.timestamp = Time.realtimeSinceStartup
end

function LuaProfiler:RecordEnd(funcName,recordToList)
	if not isEnabled then return end
	
	if not funcName then 
		if not self.funcName then return end
		funcName = self.funcName 
		self.funcName = nil	
	end

	local record = self.totalTimeRecorder[funcName]
	if not record then return end

	record.timestamp = (Time.realtimeSinceStartup-record.timestamp)*1000				
	record.call = record.call + 1
	record.totaltime = record.totaltime + record.timestamp				
	if record.max < record.timestamp then record.max = record.timestamp end
    if record.min > record.timestamp then record.min = record.timestamp end
    if recordToList then table.insert(record.records, record.timestamp) end
    return record.timestamp
end

function LuaProfiler:AddStaticMoniter(clz, funcName, recordAll)
	if clz[funcName] then
		local func = clz[funcName]
		local s = clz.__cname.."."..funcName
		clz[funcName] = function (...)
			self:RecordBegin(s)
			func(...)
			self:RecordEnd(s, recordAll)			
		end
	end
end

function LuaProfiler:AddMonitor(clzInstance, funcName, recordAll)

	local clz = clzInstance.class or clzInstance
	if type(funcName) == "string" then
		local func = clz[funcName]
		local s = clz.__cname.."."..funcName
		local f = function(...)
			self:RecordBegin(s)
			local ret = {func(...)}
			self:RecordEnd(s, recordAll)		
			return table.unpack(ret)
		end

		if clz.class then
			clz.class[funcName] = f
		else
			clz[funcName] = f
		end
	else		
		for k,v in pairs(clz) do
			if type(v) == "function" then
				local s = clz.__cname.."."..k
				local func = function(...)
					self:RecordBegin(s)
					local ret = {v(...)}
					self:RecordEnd(s, recordAll)		
					return table.unpack(ret)
				end
				if clz.class then
					clz.class[k] = func
				else
					clz[k] = func
				end
			end
		end
	end
end

function LuaProfiler:SaveProfile()
	if not isEnabled then return end
	for k,v in pairs(self.totalTimeRecorder) do
	    v.average = v.totaltime / v.call
	    v.func = k
	end
	local tobesort = table.values(self.totalTimeRecorder)
	table.sort(tobesort, function(a,b)
	    return a.average > b.average
	end)
	if not CS.System.IO.Directory.Exists(Application.persistentDataPath.."/profilers/") then
		CS.System.IO.Directory.CreateDirectory(Application.persistentDataPath.."/profilers/")
	end
	local logger = CS.LogFileRecorder(Application.persistentDataPath.."/profilers/"..self.name..".csv")
	logger:WriteLine("Function,Average Time(ms),Max Time(ms),Min Time(ms),Total Time(ms),Call Times,Records...")
	for i,v in ipairs(tobesort) do
	    logger:WriteLine(string.format("%s,%.03f,%.03f,%.03f,%.03f,%d,%s",v.func,v.average,v.max,v.min,v.totaltime,v.call,string.join(v.records,",")))
	end
	logger:Close()
end

local recorders = {}
function LuaProfiler.Get(key)
	if not recorders[key] then 
		recorders[key] = LuaProfiler.new(key)
	end

	return recorders[key] 
end

function LuaProfiler.SaveAll()
	for k,v in pairs(recorders) do
		v:SaveProfile()
	end
end

function LuaProfiler.SaveToFile(txtContent,fileName)
	local logger = CS.LogFileRecorder(Application.persistentDataPath.."/"..fileName..".txt")
	logger:WriteLine(txtContent)
	logger:Close()
end

return LuaProfiler