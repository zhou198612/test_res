local M = class("CommonUIUtil")

function M:createHeroElement(data, is_big, parent)
    local item  = nil
    if is_big then
        item = GameUtil:createPrefab("Common/HeroNode2", parent)   
    else
        item = GameUtil:createPrefab("Common/HeroNode", parent)    
    end

    local ui_element = self:updateHeroElement(item, data, is_big)
    return item, ui_element
end

function M:createHeroElementByData(data, is_big, parent)
    local item  = nil
    if is_big then
        item = GameUtil:createPrefab("Common/HeroNode2", parent)   
    else
        item = GameUtil:createPrefab("Common/HeroNode", parent)    
    end
    local ui_element = self:updateHeroElementByData(item, data, nil, is_big)
    return item, ui_element
end

function M:updateHeroElement(object, dataTable, is_big)
    if object == nil or type(dataTable) ~= "table" then 
        Logger.log("CommonUIUtil fun updateItemElement parameter error！！！")
        return 
    end
    
    local data = RewardUtil:getProcessRewardData(dataTable)
    local ui_element = self:updateHeroElementByData(object, data, nil, is_big)
    return ui_element
end

function M:updateHeroElementByData(object, data, callback, is_big)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    -- luaBehaviour:InjectionFunc()
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.item_cfg.s_battle_icon, data.atlas_name or "item_icon")
    -- TODO : 等出图后修改
    -- local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", "a_TX_bagua", data.atlas_name or "item_icon")
    ui_element.item_img = item_img
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local mask_img = luaBehaviour:FindGameObject("mask_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local type_bg = luaBehaviour:FindGameObject("type_bg")
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local lv_text = luaBehaviour:FindText("lv_text")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local item_img = luaBehaviour:FindGameObject("item_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local assist_img = luaBehaviour:FindGameObject("assist_img")
    local master_img = luaBehaviour:FindGameObject("master_img")
    ui_element.red_point_img = red_point_img
    ui_element.duigou_img = duigou_img
    ui_element.luaBehaviour = luaBehaviour
    item_img:SetActive(true)
    red_point_img:SetActive(false)
    lock_img:SetActive(false)
    duigou_img:SetActive(false)
    stars:SetActive(false)
    camp_bg:SetActive(false)
    mask_img:SetActive(false)
    add_img:SetActive(false)
    apostle_applay_img:SetActive(false)
    add_panel:SetActive(false)
    up_image:SetActive(false)
    assist_img:SetActive(false)
    master_img:SetActive(false)
    local frame_name = nil
    local quality_img = nil
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
        camp_bg:SetActive(true)
        type_bg:SetActive(true)
        local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
        local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
        if race_data then
            LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon, "common_icon")
        end
        if type_data then
            LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "common_icon")
        end
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        if is_big then
            frame_name = quality_item.card_frame_name3
        else
            frame_name = quality_item.card_frame_name3.."1"
        end
        quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
        quality_up_img:SetActive(quality_item.is_add)
        if data.oid then
            local hero_data,hero_cfg = UserDataManager.hero_data:getHeroDataById(data.oid)
            if hero_data then
                self:updateHeroLvByData(object, hero_data)
            end
        end
        if data.quality and data.quality > 11 then --白色之后加星
            GameUtil:updateHeroInfo(object,data)
        end
    end
    ui_element.quality_img = quality_img
    if callback then
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
            callback(click_object, click_name, idx, data)
        end)
    end
    return ui_element
end

function M:updateHeroHpSlider(object, hp_value, qi_value)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    if luaBehaviour then
        local hp_img = luaBehaviour:FindImage("hpValue")
        local qi_img = luaBehaviour:FindImage("lanValue")
        hp_img.fillAmount = hp_value
        qi_img.fillAmount = qi_value
    end
end

function M:updateHeroElementAdd(object, data, show_add)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local item_img = luaBehaviour:FindGameObject("item_img")
    local mask_img = luaBehaviour:FindGameObject("mask_img")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local type_bg = luaBehaviour:FindGameObject("type_bg")
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local lv_text = luaBehaviour:FindText("lv_text")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local assist_img = luaBehaviour:FindGameObject("assist_img")
    local master_img = luaBehaviour:FindGameObject("master_img")
    local quality_img = luaBehaviour:FindGameObject("quality_img")
    assist_img:SetActive(false)
    type_bg:SetActive(false)
    master_img:SetActive(false)
    quality_img:SetActive(true)
    mask_img:SetActive(false)
    red_point_img:SetActive(false)
    lock_img:SetActive(false)
    duigou_img:SetActive(false)
    stars:SetActive(false)
    camp_bg:SetActive(false)
    item_img:SetActive(false)
    quality_up_img:SetActive(false)
    lv_text.gameObject:SetActive(false)
    add_panel:SetActive(false)
    up_image:SetActive(false)
    local quality_img = LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_tianjia 1", "hero_head_ui")
    if show_add then
        add_img:SetActive(true)
    else
        add_img:SetActive(false)
    end
    apostle_applay_img:SetActive(false)
end

function M:updateHeroLvByData(object, data, is_big)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_text", true)
    local hero_data = data
    if hero_data then
        if hero_data.clv and hero_data.clv > 0 then
            local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "new_str_0075", hero_data.clv)
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_2
        else
            local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "new_str_0075", hero_data.lv)
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
        local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
        local quality = hero_data.evo or 1
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        local frame_name =""
        if is_big then
            frame_name = quality_item.card_frame_name3
        else
            frame_name = quality_item.card_frame_name3.."1"
        end
        local quality_img = LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame_name, "hero_head_ui")
        quality_up_img:SetActive(quality_item.is_add)
        local stars = luaBehaviour:FindGameObject("stars")
        -- 显示品质等级
        local lv = quality - 11 or 0
        if lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
        end
    else
        local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "new_str_0075", 1)
        lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    end
end

function M:createTeamHerosNode(team_node, rewards, scale, show_add, is_big)
    scale = scale or 1
    local rewards = rewards or {}
    UIUtil.destroyAllChild(team_node)
    for k,v in ipairs(rewards) do
        local item = nil
        if is_big then
            item = GameUtil:createPrefab("Common/HeroNode2")
        else
            item = GameUtil:createPrefab("Common/HeroNode")
        end
		if _G.next(v) then
            self:updateHeroElementByData(item, v, nil, is_big)
            self:updateHeroLvByData(item, v.hero_data, is_big)
		else
			self:updateHeroElementAdd(item, v, show_add)
		end
		UIUtil.setScale(item.transform, scale, scale)
        item.transform:SetParent(team_node, false)
    end
end

-- 3D模型展示
function M:createPlayerModel(rol_obj, user)
    if rol_obj == nil then return end
    local transform = rol_obj.transform
    UIUtil.destroyAllChild(transform)
    if user then
        local avatar = user.avatar or "0"  
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(avatar))  
        if hero_cfg then
            local prefab_name = hero_cfg["prefab"]
            local obj = ResourceUtil:LoadRole3d(prefab_name)
            local helper = obj:GetComponent("LuaTransformHelper")
            helper:SetAnimator(true);
            obj.transform.localPosition = Vector3(0,0,0);
            obj.transform.localRotation = Quaternion.Euler(0,0,0);
            obj.transform:SetParent(rol_obj.transform, false)
            GlobalTools:CloseShadow(obj.transform)
        end
    end
end

function M:setSegmentInfo(segment_node, cfg, show_name)
    if segment_node == nil then 
        return 
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(segment_node)
	local star_num = cfg.star_num or 0
	for i = 1, 9 do
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, i <= star_num)
	end
    LuaBehaviourUtil.setImg(luaBehaviour,"segment_img",cfg.division_icon,"item_icon")
    local segment_name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "segment_name_text", tostring(cfg.division_name))
    if show_name then
        segment_name_text.gameObject:SetActive(true)
    else
        segment_name_text.gameObject:SetActive(false)
    end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "segment_rank_text", tostring(cfg.rank_min))
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"segment_rank_text",star_num == 0)
    local division = cfg.division or -1
    segment_name_text.color = GlobalConfig.ARENA_SEGMENT_COLLOR[division] or GlobalConfig.ARENA_SEGMENT_COLLOR[1]
end

return M
