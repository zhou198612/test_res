----------------- LuaBehaviourUtil
local M = {}


function M.setText(luaBehaviour, key, text_msg)
	local text = luaBehaviour:FindText(key)
	if text and text_msg then
		text.text = text_msg
	end
	return text
end

function M.setTextByLanKey(luaBehaviour, key, lan_key, arg1, ...)
	return M.setText(luaBehaviour, key, Language:getTextByKey(lan_key, arg1, ...))
end

function M.setImg(luaBehaviour, key, img_msg, img_atlas)
	local img = luaBehaviour:FindImage(key)
	if img then
		img.sprite = ResourceUtil:GetSprite(img_msg,img_atlas)
	end
	return img
end

function M.setTexture(luaBehaviour, key, img_msg, ab_name)
	local img = luaBehaviour:FindImage(key)
	if img then
		img.sprite = ResourceUtil:LoadSprite(img_msg, ab_name)
	end
	return img
end

function M.setTextureByMultiple(luaBehaviour, key, img_msg, child)
	local img = luaBehaviour:FindImage(key)
	if img then
		img.sprite = ResourceUtil:LoadAllSprite(img_msg, child)
	end
	return img
end

function M.setObjectVisible(luaBehaviour, key, visible)
	local obj = luaBehaviour:FindGameObject(key)
	if obj then
		obj:SetActive(visible)
	end
	return obj
end

function M.addAnimEvent(luaBehaviour,event)
	luaBehaviour:AddAnimEvent(event)
end

function M.setTextColor(luaBehaviour, key, r, g, b, a)
	if not a then
		a = 255
	end
	local img = luaBehaviour:FindText(key)
	if img then
		img.color = Color(r, g, b, a)
	end
end

function M.setTextOutLineColor(luaBehaviour, key, r, g, b, a)
	if not a then
		a = 255
	end
	local outline = luaBehaviour:FindOutlineEx(key)
	if outline then
		outline.OutlineColor = Color(r, g, b, a)
	end
end

return M