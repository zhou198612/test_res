local M = class("MaskSlider")
--前排图片
M.front = nil
--跟随图片
M.follow = nil
--目标的x
M.set_x = 0
--目标的y
M.set_y = 0
--最大值
M.max = 0
--当前值
M.cur = 0

M.time = 5

M.moveTime = 0.5

M.followTime = 0

M.cur_x = 0
   
M.cur_y = 0

M.target_x = 0

M.target_y = 0
--直接修改数值
M._fixValue = 0
--solider的值
M._value=0

function M:creat(obj)

    self.time = 5
    self.follow= UIUtil.findImage(obj.transform,"douQiValue (1)")
    self.front= UIUtil.findImage(obj.transform,"douQiValue")
    Logger.log(self.follow.name ..self.front.name)

    self.pingPangMotion = PingPangMotion.new()
    self.pingPangMotion:creat(self.front)

    self.set_x = 230
    self.set_y = 70 
    self.max = self.set_x + self.set_y
    self.cur = 0
end

function M:update(dt)
    --遮罩带的动画
    if self.pingPangMotion ~= nil then
        self.pingPangMotion:update(dt)
    end

    if self.time > 0 then     
        self.time = self.time - dt
        local value_pos = self.front.transform.localPosition
        value_pos.x = Mathf.Lerp(self.cur_x, self.target_x, (self.moveTime - self.time) / self.moveTime)
        value_pos.y = Mathf.Lerp(self.cur_y, self.target_y, (self.moveTime - self.time) / self.moveTime)
        self.front.transform.localPosition = value_pos  
    end
    if self.followTime > 0 then    
        self.followTime = dt - self.followTime
        local value_pos = self.follow.transform.localPosition
        value_pos.x = Mathf.Lerp(self.cur_x, self.target_x, (self.moveTime - self.followTime) / self.moveTime)
        value_pos.y = Mathf.Lerp(self.cur_y, self.target_y, (self.moveTime - self.followTime) / self.moveTime)
        self.follow.transform.localPosition = value_pos 
    end
end


function M:get_FixValue()
    return self._fixValue
end

function M:set_FixValue(value)
    local value_pos = self.front.transform.localPosition;
    self.cur = self._fixValue
    self._fixValue = value

    local data = self.set_y / self.max
    --目标x
    local x_move_rate = self._fixValue - data

    x_move_rate = self:Estimate(x_move_rate,0) --> 0 ? x_move_rate : 0
    self.target_x = -x_move_rate * self.max

    local data1 = self.set_y / self.max
    --目标y
    local y_move_rate = self:Estimate(self._fixValue,data1)
    self.target_y = -y_move_rate * self.max

    --设定目标
    local value_pos = self.front.transform.localPosition
    value_pos.x = self.target_x
    value_pos.y = self.target_y
    self.front.transform.localPosition = value_pos
end

function  M:get_Value()
    return self._value
end

function  M:set_Value(value)
    self.cur = self._value
    self._value = value

    local x_move_rate = self._value - (self.set_y / self.max)
     x_move_rate =self:Estimate(x_move_rate,0)
     self.target_x = -x_move_rate * self.max

    --目标y
    local y_move_rate = self:Estimate(self._value,(self.set_y /self.max)) 
    self.target_y = -y_move_rate * self.max

    --当前的x
    self.cur_x = self.front.transform.localPosition.x
    --当前的y
    self.cur_y = self.front.transform.localPosition.y
    --移动时间
    self.time = self.moveTime

    self.followTime = self.moveTime * 1.5
end

function  M:Estimate( value1,value2)
    if value1 >= value2 then 
        return value2
    else
        return value1
    end
end

return M