
--[[
    1.0
    目的:通用消息处理类，时间事件和普通事件
        此类为全局类

    使用说明: registerTimeEvent 和 registerEvent   负责事件的注册
             dipatchEvent                         触发某个事件

    特别说明: 1 由于依赖cocos2d的scheduler， 所以在设备进入后台后，scheduler停止运转，导致时间不消耗(解决方案:监听前后台事件，以获取系统时间为准。）
             2 当invoke对象释放时，请务必调用unRegisterAllEvent 或者 unRegisterEvent取消监听
              否则可能造成不可预知的行为
]]
local EventDispatcher = {}
EventDispatcher.msgList = {}          --消息队列,用于缓存消息
EventDispatcher.timeList = {}         --时间事件监听队列
EventDispatcher.eventList = {}        --事件监听队列
EventDispatcher.allTimeMsgList = {}       --存储所有时间事件的消息，按照传入消息的类型存储 allMsgList["type"][1],allMsgList["type"][2]
EventDispatcher.allEventMsgList = {}       --存储所有事件监听队列的消息，按照传入消息的类型存储 allMsgList["type"][1],allMsgList["type"][2]
--[[
    说明:  监听时间事件
          eventname  事件名称
          interval   事件间隔
          listener   invoke对象(可以是自定义的方法)
          duration   持续多长时间 可以不传
          eventType  事件的分类，可以不传
]]
function EventDispatcher:registerTimeEvent(eventName, listener, interval, duration, eventType)
    if listener == nil then
        return
    end

    local time = {}
    time.eclips = 0
    time.interval = interval or 1
    time.listener = listener
    time.duration = duration or 210000000

    self.timeList[eventName] = time

    if eventType then
        if not(self.allTimeMsgList[eventType]) then 
            self.allTimeMsgList[eventType] = {}
        end
        table.insert(self.allTimeMsgList[eventType], time)
    end
    self:startUp()
end

--- 设置某个事件的当前时间
function EventDispatcher:setTimeDuration(eventName, duration)
    local time = self.timeList[eventName]
    if time then
        time.duration = duration
    end
end

--- 取回某个事件的当前时间
function EventDispatcher:getTimeDuration(eventName)
    local time = self.timeList[eventName]
    if time then
        return time.duration
    end
    return 0
end


--[[
    说明:  监听事件
          eventname  事件名称
          listener   invoke对象.(可以是自定义的方法) 或者是 {target, target.function}
          eventType  事件的分类，可以不传
          
]]
function EventDispatcher:registerEvent(eventName, listener, eventType)
    if listener == nil then
        return
    end

    local temp = self.eventList[eventName]
    if temp == nil then
        self.eventList[eventName] = {} 
        temp = self.eventList[eventName]
    end

    local exit = false
    for i = 1, #temp do
        exit = self:isEqual(listener, temp[i])
        if exit then
            break
        end
    end

    --- 没有找到, 那么加入到队列中
    if not exit then
        table.insert(temp, listener)
        if eventType then
            if not(self.allEventMsgList[eventType]) then 
                self.allEventMsgList[eventType] = {}
            end
            table.insert(self.allEventMsgList[eventType], listener)
        end
    end
end

--[[--
    说明: 注销监听所有事件
    listener invoke对象 
]]
function EventDispatcher:unRegisterAllEvent(listener)
    --删除时间事件
    for k, v in pairs(self.timeList) do
        if self:isEqual(v.listener, listener) then
            v.listener = nil
            v.duration = -1
        end
    end

    --删除事件
    for k, v in pairs(self.eventList) do
        for i = 1, #v do
            if self:isEqual(listener, v[i]) then
                table.remove(v, i)
                break
            end
        end
    end
end

function EventDispatcher:unRegisterAllEventByType(eventType)
    if self.allTimeMsgList[eventType] then
        for k,timer in pairs(self.allTimeMsgList[eventType]) do
            timer.listener = nil 
            timer.duration = -1
        end
    end
    if self.allEventMsgList[eventType] then
        for index,listener in pairs(self.allEventMsgList[eventType]) do
            for k, v in pairs(self.eventList) do
                for i = 1, #v do
                    if self:isEqual(listener, v[i]) then
                        table.remove(v, i)
                        break
                    end
                end
            end
        end

    end
end

--[[
    说明: 注销监听
    enventname   事件名称
    listener     invoke对象 
]]
function EventDispatcher:unRegisterEvent(enventname, listener)
    local timer = self.timeList[enventname]
    if timer then
        timer.listener = nil 
        timer.duration = -1
    end

    local temp = self.eventList[enventname]
    if temp == nil then return end 
    for i,v in pairs(temp) do
        if self:isEqual(listener, temp[i]) then
            temp[i] = nil
            break
        end
    end
end

--[[
    说明:  触发消息, 会在每帧中消化
          eventname  事件名称
          data       扩展数据
]]
function EventDispatcher:dipatchEvent(eventName, data)
    if eventName == nil then return end
    local listeners = self.eventList[eventName] or {}
    for k, v in pairs(listeners) do
        self:_notify(v, eventName, data)
    end
end

--- 通知事件监听主体, 内部方法
function EventDispatcher:_notify(listener, event, data, leftTime)
    if listener == nil then return end
    local listenerType = type(listener) 
    if listenerType == "function" then
        listener(event, data, leftTime)
    elseif listenerType == "table" then
        if listener and listener[2] and listener[1] then
            listener[2](listener[1], event, data)
        end
    end
end

--[[
    说明: 启动事件循环队列
          先处理普通事件
          再处理时间事件 (一般行为上，时间事件为低精度事件)
]]
function EventDispatcher:startUp()
    if GameMain.hasUpdate("event_dispatcher_update") then return end

    local invalidTimer = {}
    -- 时间方法
    local tick = function(delta, unsdt)
        for k, v in pairs(self.timeList) do 
            v.duration = v.duration - unsdt
            v.eclips = v.eclips + unsdt
            if v.eclips >= v.interval then
                v.eclips = v.eclips - v.interval
                self:_notify(v.listener, k, unsdt, v.duration)
            end

            if v.duration <= 0 then
                v.listener = nil
                invalidTimer[#invalidTimer + 1] = k
            end
        end

        for i = 1, #invalidTimer do
            self.timeList[ invalidTimer[i] ] = nil
            invalidTimer[i] = nil;
        end
    end
    GameMain.addUpdate("event_dispatcher_update", tick)
end

----------------------------------------------------------------------------------
--- 矫正时间差,主要是前后台的时间差
function EventDispatcher:addjustTimer(offset)
    offset = offset or 0
    for k, v in pairs(self.timeList) do 
        v.duration = v.duration - offset
        v.eclips = v.eclips + offset
        if v.eclips > v.interval then
            v.eclips = v.interval
        end
    end
end

--- 是否是同一个监听者
function EventDispatcher:isEqual(data, data1)
    if data == nil or data1 == nil then return false end

    local tmp = type(data)
    local tmp1 = type(data1)
    if tmp == tmp1 then
        if tmp == "function" then  -- 如果是方法
            return data == data1
        else
            return data[1] == data1[1]
        end
    else
        return false
    end
end

--[[
    说明: 停止事件循环队列
]]
function EventDispatcher:stop()
    GameMain.removeUpdate("event_dispatcher_update")
end

---给不同的tickcall添加名字来区别
--tickname ，注册的tickname每个模块需要有自己的前缀
--tickcount， 每帧处理的对象个数。todo//可以根据差值校验动态添加，这里默认是等长时间处理
--data，必须是一个数组。
--tickcall,每帧调用的方法，会把当前的数据传过去。
--fianlcall,最后执行完调用的方法。如果被替换是否执行finalcall则可以在增加参数
EventDispatcher.tickDiction = {}
function EventDispatcher:initTickCall(tickname,tickcount,data,tickCall,finalCall)
    self:unRegisterEvent(tickname)
    local t = {}
    t.tickname = tickname
    t.tickcount = tickcount
    t.data = data
    t.tickCall = tickCall
    t.finalCall = finalCall
    t.totalcount = 0
    self.tickDiction[tickname] = t
end

function EventDispatcher:startTickCall(tickname)
    local t = self.tickDiction[tickname]
    if t == nil then return end
    t.totalcount = t.totalcount + 1
    local tick = function (eventName, offset, duration)
        --如果执行结束则销毁。
        if t.totalcount >= #t.data then
            self:unRegisterEvent(t.tickname)
            if t.finalCall then
                t.finalCall()
            end
            self.tickDiction[t.tickname] = nil
        end
        local s = t.totalcount
        local e = t.totalcount + t.tickcount
        for i = s , e do
            if i > #t.data then break end
            local dt = t.data[i]
            if(dt and t.tickCall) then
                t.tickCall(dt,eventName,offset,duration)
            end
            t.totalcount = t.totalcount + 1
        end
    end
    self:registerTimeEvent(tickname, tick, 0)
end

function EventDispatcher:reset()
    self.msgList = {}          --消息队列
    self.timeList = {}         --时间事件监听队列
    self.eventList = {}        --事件监听队列
    self.tickDiction = {}
    self:stop()
end

return EventDispatcher