local M = class("PingPangMotion")
M.time = 1

M.playOnAwake = false

local curTime = 0

M.img = nil

local delayTime = 0

local playing = false

function M:creat( obj )
    self.curTime = self.time
    self.playing = self.playOnAwake
    self.img = obj:GetComponent('Image')
end

function  M:Play()
	self.playing = true
end

function  M:Stop()
	
end

function  M:update(dt)
	if self.playing == true then
		if self.curTime >= self.time then
			self.delayTime = self.delayTime - dt
		end
		if self.curTime <= 0 then
			self.delayTime = dt
		end

		self.curTime = self.curTime + dt
		self.Color_img = self.img.color
		self.Color_img.a = Mathf.Lerp(0,1,self.curTime / self.time)
		self.img.color = self.Color_img
	end
end

return M