------------------- GameUtil
local __math_modf = math.modf
local __math_floor = math.floor
local __math_max = math.max

-- local __AudioHelper = CS.wt.framework.AudioHelper.Instance
local M = {}

local __ITEM_TITLE_SHOW = { [4] = 1, [5] = 1, [6] = 1, [7] = 1 }

-- 获取平台类型
function M:getpPlatform()
    if U3DUtil:Is_Platform("OSXEditor") or U3DUtil:Is_Platform("WindowsEditor") then
        return "Editor"
    elseif U3DUtil:Is_Platform("WindowsPlayer") then
        return "Windows"
    elseif U3DUtil:Is_Platform("Android") then
        return "Android"
    elseif U3DUtil:Is_Platform("IPhonePlayer") then
        return "Ios"
    else
        return "Other"
    end
end

-- 获取网络类型
function M:getNetworkReachability()
    return U3DUtil:Get_NetWorkMode()
end

-- 通用道具元素创建
function M:createItemElement(dataTable, isShowNum, isShowDetail, callback, frame_effect)
    local item = ResourceUtil:LoadUIGameObject("Common/ItemNode", Vector3.zero, nil)
    local ui_element = self:updateItemElement(item, dataTable, isShowNum, isShowDetail, callback, frame_effect)
    return item, ui_element
end

function M:updateItemElement(object, dataTable, isShowNum, isShowDetail, callback, frame_effect)
    if object == nil or type(dataTable) ~= "table" then
        Logger.log("GameUtil fun updateItemElement parameter error！！！")
        return
    end

    local data = RewardUtil:getProcessRewardData(dataTable)
    local ui_element = self:updateItemElementByData(object, data, isShowNum, isShowDetail, callback, frame_effect)
    return ui_element
end

--多道具创建
function M:createRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    scale = scale or 1
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = self:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)
        item.transform:SetParent(reward_node, false)
        UIUtil.setScale(item.transform, scale)
    end
end

-- 通用道具元素创建
function M:createItemElementByData(data, isShowNum, isShowDetail, callback, parent, frame_effect)
    local item = self:createPrefab("Common/ItemNode", parent)
    local ui_element = self:updateItemElementByData(item, data, isShowNum, isShowDetail, callback, frame_effect)
    return item, ui_element
end

function M:updateItemElementByData(object, data, isShowNum, isShowDetail, callback, frame_effect)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    luaBehaviour:InjectionFunc()
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name or "item_icon")
    ui_element.item_img = item_img
    local num = data.data_num
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.GOLD  then
        local value, unit = self:formatValue({data.data_id, data.data_num})
        num = value .. GlobalConfig.GOLD[unit]
    end
    local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", num)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_name", data.name)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local piece_img = luaBehaviour:FindGameObject("piece_img")
    local start_panel = luaBehaviour:FindGameObject("start_panel")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local fx_obj = luaBehaviour:FindGameObject("fx_obj")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_1", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_2", false)
    ui_element.red_point_img = red_point_img
    ui_element.luaBehaviour = luaBehaviour
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    piece_img:SetActive(false)
    no_panel:SetActive(false)
    lock_image:SetActive(false)
    start_panel:SetActive(false)
    lv_bg_img:SetActive(false)
    if fx_obj then
        fx_obj:SetActive(false)
    end
    count_text_bg_img:SetActive(isShowNum and data.data_num >= 1)
    count_text.gameObject:SetActive(isShowNum and data.data_num >= 1)
    -- count_text_bg_img:SetActive(false)
    if isShowNum == true then
        count_text.gameObject:SetActive(true)
    else
        count_text.gameObject:SetActive(false)
    end
    local frame_name = nil
    local quality_img = nil
    local quality_item = nil
    local function setStar()
        start_panel:SetActive(true)
        for i = 1, 5 do
            if i <= data.item_cfg.star then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, false)
            end
        end
    end
    quality_item = GlobalConfig.QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
    quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", quality_item.frame_name, "item_icon")
    quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality2_img", quality_item.frame_name_2, ResourceUtil:getLanAtlas())
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.CLOTHES then
        count_text_bg_img:SetActive(false)
        count_text.gameObject:SetActive(false)
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")
        for k, v in pairs(data.item_cfg.tag) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"txt_tag_" .. k, tag_cfg.name)
                local tag_text = luaBehaviour:FindGameObject("txt_tag_" .. k)
                tag_text:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            else
                Logger.logError("不存在tag --------- " .. v[1])
            end
        end
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.SUIT then
        count_text_bg_img:SetActive(false)
        count_text.gameObject:SetActive(false)
        local tag = UserDataManager.clothes_data:getSuitTag(data.data_id)
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")
        for k, v in pairs(tag or {}) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"txt_tag_" .. k, tag_cfg.name)
                local tag_text = luaBehaviour:FindGameObject("txt_tag_" .. k)
                tag_text:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            else
                Logger.logError("不存在tag --------- " .. v[1])
            end
        end
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.GIFT_SORT_BACKGROUND then
        count_text_bg_img:SetActive(false)
        count_text.gameObject:SetActive(false)
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")
        for k, v in pairs(data.item_cfg.tag or {}) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"txt_tag_" .. k, tag_cfg.name)
                local tag_text = luaBehaviour:FindGameObject("txt_tag_" .. k)
                tag_text:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            else
                Logger.logError("不存在tag --------- " .. v[1])
            end
        end
    else
        
    end
    ui_element.quality_img = quality_img
    piece_img:SetActive(data.is_piece)

    if frame_effect and quality_item and quality_item.item_effect then
        Logger.log(quality_item.item_effect, "quality_item.item_effect ==")
        local effect_obj = ResourceUtil:LoadCommonEffect(quality_item.item_effect, nil)
        UIUtil.setScale(effect_obj.transform, 1.3)
        effect_obj.transform.position = Vector3.zero
        effect_obj.transform:SetParent(add_panel.transform, false)
    end

    local function clickCallback()
        if isShowDetail then
            if data.data_type == RewardUtil.REWARD_TYPE_KEYS.CLOTHES then
                static_rootControl:openView("Pops.CommonItemTipsPop", { data = data })
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.SUIT then
                static_rootControl:openView("Pops.CommonSuitPop", { data = data })
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.GIFT_SORT_BACKGROUND then
                static_rootControl:openView("Pops.CommonBackgroundPop", { data = data })
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                static_rootControl:openView("Pops.CommonItemTipsPop", { data = data, target_obj = item_img.gameObject })
            else
                static_rootControl:openView("Pops.CommonItemTipsPop", { data = data, target_obj = item_img.gameObject })
            end
        end
        if type(callback) == "function" then
            callback(object, data)
        end
    end
    UIUtil.setButtonClick(object, clickCallback)
    return ui_element
end

function M:updateItemEquipInfo(object, data, reward_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local stars = luaBehaviour:FindGameObject("stars")
    if data then
        -- 显示升级等级
        local lv = data.lv or 0
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
        stars:SetActive(false)
    end
    local race = 0
    if reward_data then
        race = reward_data.race
    end
    camp_bg:SetActive(race > 0)
    camp_img:SetActive(race > 0)
    local race_data = GlobalConfig.TYPE_HERO_RACE[race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", race_data.race_icon, "common_icon")
    end
end

function M:updateHeroLvByData(object, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local lv_text = luaBehaviour:FindText("lv_text")
    lv_bg_img:SetActive(true)
    local hero_data = data
    if hero_data.clv and hero_data.clv > 0 then
        lv_text.text = string.format(Language:getTextByKey("new_str_0075"), hero_data.clv)
        --lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_6
    else
        lv_text.text = string.format(Language:getTextByKey("new_str_0075"), hero_data.lv)
        --lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
    end
end

function M:updateArtifactInfo(object, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local stars = luaBehaviour:FindGameObject("stars")
    if data then
        if data.lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= data.lv)
                end
            end
        end
    end
end

--更新服装Icon属性
function M:updateClothesNode(object, sort, id, cell_data, callback)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local money_bg_img = luaBehaviour:FindGameObject("money_bg_img")
    local lv_bg = luaBehaviour:FindGameObject("lv_bg")
    local star_bg = luaBehaviour:FindGameObject("star_bg")
    local tag_bg = luaBehaviour:FindGameObject("tag_bg")
    money_bg_img:SetActive(false)
    lv_bg:SetActive(false)
    star_bg:SetActive(false)
    tag_bg:SetActive(false)
    if luaBehaviour then
        local quality = 1
        if sort == 11 then
            local cfg = self:getBackGroundById(id)
            --lv_bg:SetActive(true)
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", tostring(cfg.icon), "bg_icon")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
            local name = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", cfg.lv)
            if cfg.quality then
                quality = cfg.quality
            end
        elseif sort == 10 then
            if cell_data.quality then
                quality = cell_data.quality
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.name)
            local name = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", true)
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", tostring(cell_data.icon), "clothes_icon")
        elseif sort == 12 then
            if cell_data.quality then
                quality = cell_data.quality
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.name)
            local name = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", true)
            if cell_data.icon then
                LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", tostring(cell_data.icon), "clothes_icon")
            else
                LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "icon_diy_makeup", "make_up_ui")
            end
        else
            local data, cfg = UserDataManager.clothes_data:getClothesDataById(id)
            if data and cfg then
                LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", tostring(cfg.icon), "clothes_icon")
                local money = RewardUtil:getProcessRewardData(cfg.price[1])
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
                local name = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "money_icon", money.icon_name, "item_icon")
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_bg_img", data == 0)
                --LuaBehaviourUtil.setText(luaBehaviour, "money_num", money.data_num)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_bg_img", false)
                if cfg.quality then
                    quality = cfg.quality
                end
            end
        end
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[quality]
        local frame_name = quality_item.frame_name
        local tag_quality = quality_item.frame_name_2
        LuaBehaviourUtil.setImg(luaBehaviour, "back_img", frame_name, "item_icon")
        LuaBehaviourUtil.setImg(luaBehaviour, "tag_quality", tag_quality, ResourceUtil:getLanAtlas())
    end
end

--更新负责星级
function M:updateClothesStar(object, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local star_bg = luaBehaviour:FindGameObject("star_bg")
    if luaBehaviour then
        star_bg:SetActive(true)
        local data, cfg = UserDataManager.clothes_data:getClothesDataById(id)
        if cfg then
            for i = 1, 5 do
                if i <= cfg.star then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, true)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, false)
                end
            end
        end
    end
end

function M:updateClothesTag(object, id, need_tag, tag)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local tag_bg = luaBehaviour:FindGameObject("tag_bg")
    tag_bg:SetActive(true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_1", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_2", false)
    local data, cfg = UserDataManager.clothes_data:getClothesDataById(id)
    local temp = tag or cfg.tag
    for k, v in pairs(temp) do
        if need_tag then
            for m, n in pairs(need_tag) do
                if v[1] == n then
                    local clothes_tag = ConfigManager:getCfgByName("clothes_tag")[n]
                    if v[2] and v[2] > 0 then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                        LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, clothes_tag.icon, "stageinfo_ui")
                        LuaBehaviourUtil.setText(luaBehaviour, "txt_tag_" .. k, v[2])
                        local txt_tag = luaBehaviour:FindGameObject("txt_tag_" .. k)
                        local com_outline = txt_tag:GetComponent("OutlineEx")
                        com_outline.OutlineColor = Color.New(clothes_tag.txt_line_color[1] / 255, clothes_tag.txt_line_color[2] / 255, clothes_tag.txt_line_color[3] / 255)
                    end
                end
            end
        else
            local clothes_tag = ConfigManager:getCfgByName("clothes_tag")[v[1]]
            if v[2] and v[2] > 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, clothes_tag.icon, "stageinfo_ui")
                LuaBehaviourUtil.setText(luaBehaviour, "txt_tag_" .. k, v[2])
                local txt_tag = luaBehaviour:FindGameObject("txt_tag_" .. k)
                local com_outline = txt_tag:GetComponent("OutlineEx")
                com_outline.OutlineColor = Color.New(clothes_tag.txt_line_color[1] / 255, clothes_tag.txt_line_color[2] / 255, clothes_tag.txt_line_color[3] / 255)
            end
        end
    end
end

function M:updateSuitTag(object, suit_id, tag)
    if tag == nil then
        tag = UserDataManager.clothes_data:getSuitTag(suit_id)
    end

    local clothes_tag = ConfigManager:getCfgByName("clothes_tag")[tag[1][1]]
    UIUtil.setImg(object.transform, clothes_tag.icon, "stageinfo_ui")
    UIUtil.setTextByLanKey(object.transform,"txt_name", clothes_tag.name)
    local txt_tag = UIUtil:FindObj(object.transform, "txt_name")
    local com_outline = txt_tag:GetComponent("OutlineEx")
    com_outline.OutlineColor = Color.New(clothes_tag.txt_line_color[1] / 255, clothes_tag.txt_line_color[2] / 255, clothes_tag.txt_line_color[3] / 255)
end

function M:getBackGroundById(id)
    local back_tab = ConfigManager:getCfgByName("home_background")
    return back_tab[id]
end

function M:updateHeroInfo(object, data)
    if data then
        local luaBehaviour = UIUtil.findLuaBehaviour(object)
        local stars = luaBehaviour:FindGameObject("stars")
        -- 显示升级等级
        local lv = data.quality - 11 or 0
        if lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
        end
    end
end

function M:updateMysticInfo(object, data)
    if data then
        local luaBehaviour = UIUtil.findLuaBehaviour(object)
        local stars = luaBehaviour:FindGameObject("stars")
        -- 显示升级等级
        local lv = data.quality - 5 or 0
        if lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
        end
    end
end

-- 刷新空的道具格子
function M:updateItemElementNoData(object, itemType, data, callback)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local stars = luaBehaviour:FindGameObject("stars")
    have_panel:SetActive(false)
    no_panel:SetActive(true)
    lock_image:SetActive(false)
    red_point_img:SetActive(false)
    stars:SetActive(false)
    ui_element.add_img = add_img

    if itemType == RewardUtil.REWARD_TYPE_KEYS.HEROS then
        LuaBehaviourUtil.setImg(luaBehaviour, "no_quality_img", "xs_tianjiatouxiang", "equip_icon")
    else

    end

    local function clickCallback()
        if type(callback) == "function" then
            callback(object, data)
        end
    end
    UIUtil.setButtonClick(object, clickCallback)
    return ui_element
end

-- 创建预制体
function M:createPrefab(prefab_name, parent)
    local prefab = ResourceUtil:LoadUIGameObject(prefab_name, Vector3.zero, nil)
    if parent then
        prefab.transform:SetParent(parent, false)
    end
    return prefab
end

--[[
    计算时间样式
]]
function M:getTimeLayoutBySecond(second)
    local n = __math_max(0, second)
    local day = __math_modf(n / 86400)
    n = n % 86400
    local hour = __math_modf(n / 3600)
    n = n % 3600
    local min = __math_modf(n / 60)
    local sec = __math_floor(n % 60 + 0.5)
    return day, hour, min, sec
end

--[[
    格式化时间格式
]]
function M:formatTimeBySecond(second, format)
    local day, hour, min, sec = self:getTimeLayoutBySecond(second)
    format = format or 0
    if day > 0 then
        return string.format(Language:getTextByKey("new_str_0505"), day, hour, min, sec)
    else
        if hour > 0 then
            return string.format("%02d:%02d:%02d", hour, min, sec)
        else
            if format == 1 then
                if min > 0 then
                    return string.format("%02d:%02d", min, sec)
                else
                    return string.format("%d", sec)
                end
            else
                return string.format("%02d:%02d", min, sec)
            end
        end
    end

end

function M:formatTimeBySecond2(second)
    local day, hour, min, sec = self:getTimeLayoutBySecond(second)
    if day > 0 then
        return string.format(Language:getTextByKey("new_str_0547"), day) .. string.format(Language:getTextByKey("new_str_0546"), hour)
    elseif hour > 0 then
        return string.format(Language:getTextByKey("new_str_0546"), hour) .. string.format(Language:getTextByKey("new_str_0545"), min)
    elseif min > 0 then
        return string.format(Language:getTextByKey("new_str_0545"), min) .. string.format(Language:getTextByKey("new_str_0544"), sec)
    else
        return string.format(Language:getTextByKey("new_str_0544"), sec)
    end
end

function M:formatTimeBySecond3(second)
    local day, hour, min, sec = self:getTimeLayoutBySecond(second)
    if day > 0 then
        return string.format(Language:getTextByKey("new_str_0547"), day) 
    elseif hour > 0 then
        return string.format(Language:getTextByKey("new_str_0546"), hour)
    elseif min > 0 then
        return string.format(Language:getTextByKey("new_str_0545"), min)
    else
        return string.format(Language:getTextByKey("new_str_0544"), sec)
    end
end

function M:formatValue(list)
    local str = 0
    local len = table.nums(list)
    local unit = tonumber(list[len - 1])
    local value = tonumber(list[len])
    while( value >= 1000 )
    do
        if value >= (1000 ^ 4) then
            unit = unit + 1
            value = value / 1000
        elseif value >= (1000 ^ 3) then
            unit = unit + 1
            value = value / 1000
        elseif value >= (1000 ^ 2) then
            unit = unit + 1
            value = value / 1000
        elseif value >= (1000 ^ 1) then
            unit = unit + 1
            value = value / 1000
        end
    end
    if unit > 1 and value < 1 then
        unit = unit - 1
        value = value * 1000
    end
    if math.floor(value) < value and unit ~= 1 and unit ~= 0 then
        str = string.format("%.1f", value)
    else
        str = math.floor(value)
    end
    unit = math.max(unit, 1)
    if unit > table.nums(GlobalConfig.GOLD) then
        unit = table.nums(GlobalConfig.GOLD)
        value = 999
    end
    return str, unit
end

function M:formatValueToString(value, comb_flag, about)
    local tmp = math.modf(tonumber(value)  or 0)
    local str = 0
    if tmp < 10000 then
        str = tostring(tmp)
    elseif tmp < 1000000 then
        str = string.format("%.1f", tmp/1000) .. "K"
    elseif tmp < 1000000000 then
        str = string.format("%.1f", tmp/1000000) .. "M"
    elseif tmp < 1000000000000 then
        str = string.format("%.1f", tmp/1000000000) .. "B"
    elseif tmp < 1000000000000000 then
        str = string.format("%.1f", tmp/1000000000000) .. "T"
    elseif tmp < 1000000000000000000 then
        str = string.format("%.1f", tmp/1000000000000000) .. "aa"
    elseif tmp < 1000000000000000000000 then
        str = string.format("%.1f", tmp/1000000000000000000) .. "ab"
    end
    return str
end

--[[--
    格式化数字
]]
function M:formatValueToStringOld(value, comb_flag, about)
    comb_flag = comb_flag == nil and true or comb_flag
    local temp_value = "0"
    local unit = ""
    about = about or "%d"
    if type(value) == "string" then
        value = tonumber(value)
    end
    if value == nil or type(value) ~= "number" then
        return temp_value, unit
    end
    if value > 0 and value < 100000 then
        temp_value = tostring(value)
    elseif value >= 100000 and value < 100000000 then
        local v1 = __math_floor(value % 1000 / 100)
        if v1 > 0 then
            about = "%.2f"
        else
            local v2 = __math_floor(value % 10000 / 1000)
            if v2 > 0 then
                about = "%.1f"
            else
                about = "%d"
            end
        end
        if value < 10000000 then
            temp_value, unit = string.format(about, __math_floor(value * 0.01) / 100), Language:getTextByKey("new_str_0040")
        else
            temp_value, unit = string.format(about, __math_floor(value * 0.01) / 100), Language:getTextByKey("new_str_0040")
        end
    elseif value >= 100000000 then
        local v1 = __math_floor(value % 10000000 / 1000000)
        if v1 > 0 then
            about = "%.2f"
        else
            local v2 = __math_floor(value % 100000000 / 10000000)
            if v2 > 0 then
                about = "%.1f"
            else
                about = "%d"
            end
        end
        temp_value, unit = string.format(about, __math_floor(value * 0.000001) / 100), Language:getTextByKey("new_str_0039")
    end
    if comb_flag then
        temp_value = temp_value .. unit
        unit = ""
    end
    return temp_value, unit
end

local cur_look_info_tips = nil

function M:lookInfoTips(control, params)
    self:destroyLookInfoTips()
    local LookInfoTips = CustomRequire("UI.Common.LookInfoTips")
    cur_look_info_tips = LookInfoTips.new(control, params)
end

function M:resetLookInfoTips()
    cur_look_info_tips = nil
end

function M:destroyLookInfoTips()
    if cur_look_info_tips then
        cur_look_info_tips:destroy()
    end
    cur_look_info_tips = nil
end

function M:commonAttrNode(control, params)
    local CommonAttrNode = CustomRequire("UI.Common.CommonAttrNode")
    return CommonAttrNode.new(control, params)
end

function M:instanceObject(obj, parent)
    local inst = U3DUtil:Instantiate(obj)
    if parent then
        inst.transform:SetParent(parent.transform, false)
    end
    return inst
end

function M:setLanImgText(trans, img_name, path)
    local language = Language.m_cur_language
    local lan_atlas = "language_" .. language
    return UIUtil.setImg(trans, img_name, lan_atlas, path)
end

function M:setUserAvatar(obj, user, show_lv)
    if obj == nil then
        return
    end
    local transform = obj.transform
    if user == nil then
        UIUtil.setImg(transform, "item_icon_wenhao", "item_icon", "tx_mask/tx_img")
        UIUtil.setObjectVisible(transform, false, "lv_bg")
    else
        local avatar = user.avatar or "0"
        local tab = ConfigManager:getCfgByName("player_face")
        local id = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        if tab[id] then
            UIUtil.setImg(transform, tab[id].icon, "player_head", "head_img")
        else
            UIUtil.setImg(transform, "face1", "player_head", "head_img")
        end
    end
end

function M:setHeroSpineAnim(hero_spine_obj, id)
    local sg = hero_spine_obj:GetComponent("SkeletonGraphic")
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    local skeletonData = ResourceUtil:GetSk(cfg.hero_spine, "rolespine_" .. string.lower(cfg.hero_spine))
    sg.skeletonDataAsset = skeletonData
    sg:Initialize(true)
end

function M:setHeroRace(transform, id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    if cfg then
        local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].race_icon --英雄种族icon
        UIUtil.setImg(transform, race, "common_icon")
    end
end

function M:getRefreshCost(refresh_count, renovate_type)
    local refresh_count = refresh_count or 0
    local renovate = ConfigManager:getCfgByName("renovate")
    local cur_renovate = renovate[renovate_type] or {}
    local count_list = cur_renovate.count_list or {}
    local cost = cur_renovate.cost or {}
    local cur_cost = nil
    for i, v in ipairs(count_list) do
        if refresh_count < v then
            cur_cost = cost[i]
            break
        end
    end
    return cur_cost or cost[#cost]
end

function M:getHeroById(id)
    local hero_info, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    return hero_info, hero_cfg
end

function M:addTips(attrs, gain, parent, order)
    if next(attrs) == nil then
        return
    end
    local tips = ResourceUtil:LoadUIGameObject("Common/Tips", Vector3.zero, parent)
    if tips then
        local m_canvas = tips:GetComponent("Canvas")
        m_canvas.sortingOrder = order + 2
        local luaBehaviour = UIUtil.findLuaBehaviour(tips)
        local add_attrs = luaBehaviour:FindGameObject("add_attr")
        local sub_attrs = luaBehaviour:FindGameObject("sub_attr")
        add_attrs:SetActive(false)
        sub_attrs:SetActive(false)
        function endCallFunc()
            if tips ~= nil then
                U3DUtil:Destroy(tips)
            end
        end
        if gain == true then
            add_attrs:SetActive(true)
            for k, v in pairs(attrs) do
                local atr_obj_name = "attr" .. k
                local attr_obj = UIUtil.findTrans(add_attrs.transform, atr_obj_name)
                UIUtil.setTextByLanKey(attr_obj.transform, "name_text", v.name)
                if v.num > 0 then
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", "+" .. v.num)
                else
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", v.num)
                end
                UIUtil.setObjectVisible(add_attrs.transform, true, atr_obj_name)
            end
        else
            sub_attrs:SetActive(true)
            for k, v in pairs(attrs) do
                local atr_obj_name = "attr" .. k
                local attr_obj = UIUtil.findTrans(sub_attrs.transform, atr_obj_name)
                UIUtil.setTextByLanKey(attr_obj.transform, "name_text", v.name)
                if v.num > 0 then
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", "+" .. v.num)
                else
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", v.num)
                end
                UIUtil.setObjectVisible(sub_attrs.transform, true, atr_obj_name)
            end
        end
        luaBehaviour:RunAnim("Tips_Show", endCallFunc, 1)
    end
end

--缩放动效
function M:ZoomObj(obj)
    obj.transform.localScale = Vector3(0.8, 0.8, 0.8)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(obj.transform:DOScale(1.2, 0.15))
    sequence:Append(obj.transform:DOScale(1.0, 0.15))
    sequence:SetAutoKill(true)
end

function M:playBtnSound(full_btn_name)
    local sound_name = BtnSoundConfig[full_btn_name]
    if sound_name and sound_name ~= "" then
        audio:SendEvtUI(sound_name)
    end
end

function M:getCanEquipHeroIds(equip_c_id)
    local crystal_heros_id = {}
    local open_flag, _ = BtnOpenUtil:isBtnOpen(29)
    if open_flag then
        crystal_heros_id = UserDataManager.hero_data:getCrystalAllHerosId()
    end
    local sel_equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(equip_c_id)
    if sel_equip_cfg == nil then
        Logger.logError(equip_c_id, "equip_c_id not found : ")
        return {}
    end
    local equip_type = sel_equip_cfg.type
    local pos = sel_equip_cfg.pos
    local quality = sel_equip_cfg.quality
    local function filterFunc(data, cfg)
        local flag = false
        if (data.lv > 1 or crystal_heros_id[data.oid] ~= nil) and cfg.type == equip_type then
            local equips = data.equips or {}
            local equip_data = equips[tostring(pos)] or {}
            if _G.next(equip_data) then
                local equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(equip_data.id)
                if equip_cfg then
                    flag = quality > equip_cfg.quality
                end
            else
                flag = true
            end
        end
        return flag
    end
    local hero_ids = UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
    return hero_ids
end

-- 倒计时
function M:remainingTimeUpdate(control, time_key, time_text, end_time, end_time_event, format)
    local end_time = end_time or (UserDataManager:getServerTime() + 86400 * 9)
    local diff_time = end_time - UserDataManager:getServerTime()
    local ft = GameUtil:formatTimeBySecond(diff_time, format)
    time_text.text = ft
    local function tick(event, dt, remaining_time)
        local diff_time = end_time - UserDataManager:getServerTime()
        local ft = GameUtil:formatTimeBySecond(diff_time, format)
        time_text.text = ft
        if remaining_time <= 0 then
            control:updateMsg(end_time_event or "time_end_refresh")
        end
    end
    EventDispatcher:registerTimeEvent(time_key, tick, 1, diff_time)
end

function M:getHeirloomNum(heirlooms)
    local show_data = {}
    local heirlooms = heirlooms or {}
    local heirloom = ConfigManager:getCfgByName("heirloom")
    for k, v in pairs(heirlooms) do
        local cfg = heirloom[v]
        if cfg then
            local quality = cfg.quality or 0
            local atkrating_ratio = cfg.atkrating_ratio or 0
            if show_data[quality] == nil then
                show_data[quality] = { num = 1, atkrating_ratio = atkrating_ratio }
            else
                show_data[quality].num = show_data[quality].num + 1
                show_data[quality].atkrating_ratio = show_data[quality].atkrating_ratio + atkrating_ratio
            end
        end
    end
    return show_data
end

function M:setUserGender(luaBehaviour, gender, gender_img_key, gender_text_key)
    gender = gender or -1
    local gender_cfg_item = GlobalConfig.GENDER_CFG[gender]
    if gender_cfg_item then
        if gender_text_key then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, gender_text_key, gender_cfg_item.name)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_text_key, true)
        end
        if gender_img_key then
            LuaBehaviourUtil.setImg(luaBehaviour, gender_img_key, gender_cfg_item.icon, gender_cfg_item.atlas)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_img_key, true)
        end
    else
        if gender_text_key then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_text_key, false)
        end
        if gender_img_key then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_img_key, false)
        end
    end
end

function M:createTeamHeros(team_node, rewards, is_show_num, is_show_detail, callback, scale, update_func)
    scale = scale or 1
    local rewards = rewards or {}
    UIUtil.destroyAllChild(team_node)
    for k, v in ipairs(rewards) do
        local item = nil
        if _G.next(v) then
            item = self:createItemElementByData(v, is_show_num, is_show_detail, callback)
            if update_func then
                update_func(item, v)
            end
        else
            item = self:createPrefab("Common/ItemNode")
            local ui_element = GameUtil:updateItemElementNoData(item)
            ui_element.add_img:SetActive(false)
        end
        UIUtil.setScale(item.transform, scale, scale)
        item.transform:SetParent(team_node, false)
    end
end

function M:getFormatTeamData(team, other_heros, has_null)
    local show_data = {}
    local high_arena_defense = self.mult_main_teams
    team = team or {}
    other_heros = other_heros or {}
    local team_heros_data = {}
    for index = 1, 5 do
        local hero_id = team[index] or ""
        local hero_data = other_heros[hero_id] or UserDataManager.hero_data:getHeroDataById(hero_id)
        local data = nil
        if hero_data then
            data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0 })
            data.quality = hero_data.evo
            data.card_id = hero_id
            data.hero_data = hero_data
        end
        if has_null == nil or has_null == true then
            table.insert(team_heros_data, data or {})
        else
            if data then
                table.insert(team_heros_data, data)
            end
        end
    end
    return team_heros_data
end

--格式化小数点后的0
function M:formatNum(count)
    local num = tonumber(count)
    if num == nil then
        return 0
    end
    
    if num <= 0 then
        return 0
    else
        local t1, t2 = __math_modf(num)
        if t2 > 0 then
            return num
        else
            return t1
        end
    end
end

function M:setHeroSpineBySG(hero_cid, spine)
    hero_cid = hero_cid or 0
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_cid)
    if hero_cfg then
        spine.gameObject:SetActive(true)
        local hero_spine = hero_cfg.hero_spine
        local sk_data = ResourceUtil:GetSk(hero_spine, "rolespine_" .. string.lower(hero_spine))
        spine.skeletonDataAsset = sk_data
        spine:Initialize(true)
    else
        spine.gameObject:SetActive(false)
    end
end

function M:setHeroSpineByObj(hero_cid, spine_obj)
    local spine = spine_obj:GetComponent("SkeletonGraphic")
    self:setHeroSpineBySG(hero_cid, spine_obj)
end

function M:getCurStageCfg()
    local level = UserDataManager:getCurStage()
    local stage = ConfigManager:getCfgByName("stage")
    return stage[level] or {}
end

function M:getBattleStageCfg()
    local stage_id = UserDataManager:getBattleStage()
    local stage_cfg = ConfigManager:getCfgByName("stage")
    return stage_cfg[stage_id] or {}
end

function M:getCurStageIdleData()
    local stage = self:getCurStageCfg();
    local staget_idle = stage.idle_id
    local stage = ConfigManager:getCfgByName("stage_idle")
    local curIdle = stage[staget_idle];
    local battle_id = curIdle.battle_id;
    local stage_battle = ConfigManager:getCfgByName("stage_battle")
    local battle_data = stage_battle[battle_id]
    return battle_data;
end

-- 英雄背包是否已满
function M:heroBagIsFull()
    local max_cell = 100 + UserDataManager.extra_hero_grid
    local heros = UserDataManager.hero_data:getHerosId()
    return #heros >= max_cell
end

function M:formatTextString(text, params, time_format)
    local enum_cfg = ConfigManager:getCfgByName("text_enum")
    local function getString(s)
        s = string.sub(s, 2, -2)
        local str_tab = string.split(s, '_')
        local id = tonumber(str_tab[1])
        local value_type = ""
        for i = 2, #str_tab do
            value_type = value_type .. str_tab[i]
            if i < #str_tab then
                value_type = value_type .. "_"
            end
        end
        if value_type == "value" then
            return params[id] or "error"
        elseif value_type == "time" then
            time_format = time_format or "%m-%d %H:%M"
            local time = params[id]
            if time then
                return os.date(time_format, time)
            else
                return "error"
            end
        elseif value_type == "language" then
            local key = params[id]
            return Language:getTextByKey(key or "error")
        else
            local cfg = enum_cfg[value_type]
            if cfg then
                local key = params[id]
                if key then
                    return Language:getTextByKey(cfg[key] or "error")
                end
            end
            return "error"
        end
    end

    return string.gsub(text, "{[%w_]*}", getString)
end

-- 上报lua错误信息
local device_error_logs = {}
function M:sendLuaError(error_msg, error_detail)
    if GameVersionConfig and GameVersionConfig.SERVICE_URL and GameUtil:getpPlatform() ~= "Editor" then
        local send_time = device_error_logs[error_msg]
        if send_time ~= nil then
            return
        end
        device_error_logs[error_msg] = os.time()
        local errorMessage = error_msg .. "\n" .. tostring(error_detail)
        --errorMessage = string.sub(errorMessage, 1, 600)
        local own_uid = UserDataManager.user_data:getUid()
        errorMessage = GameVersionConfig.SERVICE_URL .. "\n" .. tostring(own_uid) .. "\n" .. "c_ver=" .. tostring(GameVersionConfig.CLIENT_VERSION) .. ",r_ver=" .. tostring(GameVersionConfig.GAME_RESOURCES_VERION) .. "\n" .. table.concat(Logger.history, "\n") .. "\n\n".. errorMessage
        -- errorMessage = string.urlencode(errorMessage)
        local md5_str = ""
        if CS.wt.framework.LuaFileHelper.Inst.MD5EncryptString then
            md5_str = CS.wt.framework.LuaFileHelper.Inst:MD5EncryptString(error_msg)
        end
        local url = GameVersionConfig.SERVICE_URL .. "/front_err/?err_id=" .. md5_str .. "&" .. NetUrl.getExtUrlParam()
        local params = { msg_type = "text",
                         content = { text = errorMessage}
        }
        NetWork:errorHttpRequest(function()
        end, url, GlobalConfig.POST, params, "front_err", 0)
    end
end

function M:getBattleUploadData(base_data)
    local result = base_data.result
    local win_count = 0
    local upload_rounds = {}
    local battle = base_data.battle_data.battle or {}
    local rounds = battle.output.rounds or {}
    for k, v in ipairs(rounds) do
        local attacker_stats = v.attacker_stats or {}
        local attacker_team = v.attacker_team or {}
        local attacker_dyns = self:getHerosDyns(attacker_stats, attacker_team)
        local defender_stats = v.defender_stats or {}
        local defender_team = v.defender_team or {}
        local defender_dyns = self:getHerosDyns(defender_stats, defender_team)
        upload_rounds[k] = { round = v.round, result = v.result, operations = v.operations, defender_dyns = defender_dyns, attacker_dyns = attacker_dyns, attacker_stats = attacker_stats, defender_stats = defender_stats }
        if v.result == 1 then
            win_count = win_count + 1
        end
    end
    if #rounds > 1 then
        result = win_count > math.floor(win_count / 2) and 1 or 0
    end
    local data = { result = result, cli_ver = "v1.0.1", rounds = upload_rounds }
    return data
end

function M:getHerosDyns(common_stats, common_team)
    local dyns = {}
    common_stats = common_stats or {}
    common_team = common_team or {}
    local heros = common_team.heros or {}
    for k, v in pairs(common_stats) do
        local cur_hp = v.hp or 0
        local cur_rage = v.rage or 0
        local hero_data = heros[k] or {}
        local attrs = hero_data.attrs or {}
        local hp = attrs.hp or 0
        local rage = 1000 -- 默认怒气 1000
        local hp_pct = hp > 0 and math.ceil(cur_hp / hp * 10000) or 10000
        local mp_pct = rage > 0 and math.ceil(cur_rage / rage * 10000) or 10000
        dyns[k] = { hp_pct = math.max(0, hp_pct), mp_pct = math.max(0, mp_pct) }
    end
    return dyns
end

--[[
    存储数据到本地
]]
function M:saveTableDataWithName(data, file_name)
    data = { type = tostring(type(data)), data = data }
    local str = Json.encode(data) or ""
    local ret = io.writefile(file_name, str)
    return ret
end

function M:getTableDataByName(file_name)
    local exist_flag = io.exists(file_name)
    if exist_flag then
        local read_data = io.readfile(file_name)
        if read_data then
            local data = Json.decode(read_data)
            if data then
                return data.data
            end
        end
    end
    return {}
end

--function M:playAd(ad_obj, reward_func, ios_slot_id, android_slot_id, reward_name, reward_amount, user_id, media_extra)
--    local ad_be = ad_obj:GetComponent("AdBehaviour")
--    ad_be:AddAdCallFunc(function(ad_msg, ad_code)
--        if ad_code == 0 then
--            if ad_msg == "ad_is_downloaded" then
--                ad_be:ShowRewardAd()
--            elseif ad_msg == "ad_reward_verify_success" then
--                -- 请求后端接口获得奖励
--                if reward_func then
--                    reward_func()
--                end
--            end
--        else
--            Logger.logError(ad_msg .. " ; ad_code = " .. ad_code, "ad_msg")
--        end
--    end)
--    ad_be:LoadRewardAd(ios_slot_id, android_slot_id, reward_name, reward_amount, user_id, media_extra)
--
--end
--
---- 挂机激励广告
--function M:playHangUpAd(ad_obj, reward_func)
--    local slot_id = "945388118"
--    local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
--    self:playAd(ad_obj, reward_func, slot_id, slot_id, "", 1, uid, "")
--end

-- 签到激励广告
--function M:playSignInAd(ad_obj, reward_func)
--    local slot_id = "945387658"
--    local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
--    self:playAd(ad_obj, reward_func,slot_id, slot_id, "", 1, uid, "" )
--end

-- 离线奖励广告
--function M:playOfflineInAd(ad_obj, reward_func)
--    local slot_id = "945462932"
--    local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
--    self:playAd(ad_obj, reward_func,slot_id, slot_id, "", 1, uid, "" )
--end

function M:playRewardAd(reward_func)
    self.reward_func = reward_func
    --数据回调,只有编辑器平台才运行
    if UserDataManager.client_data.nosdk then
        self:onShowRewardAdCallBack()
    else
        audio:SetBusVol("Bgm", 0)
        SDKUtil:showAd(handler(self, self.onShowRewardAdCallBack))
        static_rootControl.m_model:getNetData("adv_begin", nil, nil)
    end
end

function M:onShowRewardAdCallBack()
    Logger.log( "onShowRewardAdCallBack")
    self.music_volume = U3DUtil:PlayerPrefs_GetFloat("music_volume", 0)
    audio:SetBusVol("Bgm", self.music_volume)
    self.reward_func()
end

--根据衣柜获取对应服装类型
function M:getSortByArmoire(a_id)
    local clothes = ConfigManager:getCfgByName("clothes_sort")
    local sort_list = {}
    for k, v in pairs(clothes) do
        if v.armoire_id == a_id then
            table.insert(sort_list, k)
        end
    end
    return sort_list
end

--根据路劲设置图片
function M:updateResourcesImg(img, img_path, default)
    local texture_bg = img.gameObject:GetComponent("TextureLoadSet")
    if texture_bg then
        local ab_name = string.gsub(img_path, "/", "_")
        texture_bg:SetSprite(img_path, string.lower(ab_name), true, default)
    end
    return img
end

function M:updateResourcesRawImg(tex, img_path)
    local texture_bg = tex.gameObject:GetComponent("RawImageLoadSet")
    if texture_bg then
        local ab_name = string.gsub(img_path, "/", "_")
        texture_bg:SetTexture(img_path, string.lower(ab_name), false)
    end
    return tex
end

function M:updatPlayerAvatar(img)

end

function M:updateSpineLoadSet(obj, spineName, animName, trackIndex, isLoop)
    if not IsNull(obj) then
        local spineLoadSet = obj.gameObject:GetComponent("SpineLoadSet")
        if spineLoadSet then
            local ab_name = string.gsub(spineName, "/", "_")
            spineLoadSet:SetSpine(spineName, string.lower(ab_name), animName, trackIndex, isLoop)
        end
    end
    return obj
end

function M:ReceiveCoin(adCallback, num)
    if num then
        local params =
        {
            on_ok_call = function(msg)
                GameUtil:playRewardAd(adCallback)
            end,
            --on_cancel_call = function()
            --end,
            text = "new_str_0036",
            data = { RewardUtil.REWARD_TYPE_KEYS.GOLD, num[1], num[2] }
        }
        static_rootControl:openView("Pops.CommonMoneyPop", params, nil, true)
    else
        self:ReceiveDiamond(adCallback)
    end
end

function M:ReceiveDiamond(adCallback)
    local params =
    {
        on_ok_call = function(msg)
            GameUtil:playRewardAd(adCallback)
        end,
        --on_cancel_call = function()
        --end,
        text = "new_str_0037",
        data = { RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0 }
    }
    static_rootControl:openView("Pops.CommonMoneyPop", params, nil, true)
end

function M:ShowOneGachaItem(data, item, close_fx)
    if data then
        self:updateOneGachaItem(item, data[1], close_fx)
    end
end

function M:ShowOneSuitGachaItem(data, item)
    if data then
        self:updateOneSuitGachaItem(item, data[1])
    end
end

function M:ShowGachaItem(data, item)
    if data then
        self:updateGachaItem(item, data[1])
    end
end

function M:updateOneGachaItem(obj, data, close_fx)
    if data then
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")
        local clothes_type = ConfigManager:getCfgByName("clothes_type")
        
        local reward_data = RewardUtil:getProcessRewardData(data)
        local is_has = UserDataManager.clothes_data:CheckIsHave(reward_data.data_id)
        local is_new = UserDataManager.clothes_data:clothesIsNew(reward_data.data_id)
        UserDataManager.clothes_data:RemoveAllClothesNewData(reward_data.data_id)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[reward_data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        local frame_name_3 = quality_item.frame_name_4
        local frame_name_4 = quality_item.frame_name_3
        local item_img = luaBehaviour:FindImage("item_img")
        local item_bg = luaBehaviour:FindImage("item_bg")
        local item_frame = luaBehaviour:FindImage("item_frame")
        local default = self:GetDefaultTexture(2, reward_data.icon_name)
        if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.CLOTHES then
            self:updateResourcesImg(item_img, PathUtil:GetBigClothesIconPath(reward_data.item_cfg.big_icon), PathUtil:GetBigClothesIconPath(default))
        elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.GIFT_SORT_BACKGROUND then
            self:updateResourcesImg(item_img, PathUtil:GetBgPath(reward_data.item_cfg.bg))
        end
        self:updateResourcesImg(item_bg, PathUtil:GetBgPath(frame_name_3))
        LuaBehaviourUtil.setImg(luaBehaviour, "item_frame", frame_name_4, ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setText(luaBehaviour, "txt_name", reward_data.name)
        luaBehaviour:FindGameObject("txt_name"):GetComponent("OutlineEx").OutlineColor = quality_item.outline
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", data[1] == 9 )
        --LuaBehaviourUtil.setText(luaBehaviour, "lv_text", reward_data.item_cfg.lv .. "级")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "main_tag", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_new", is_new)
        LuaBehaviourUtil.setImg(luaBehaviour, "has_img", "ui_gq_list_yiyongyou_l", ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "has_img", not is_new and is_has)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_2", false)
        Logger.log(reward_data.item_cfg.tag,"reward_data.item_cfg.tag =====")

        for k,v in pairs(reward_data.item_cfg.tag or {}) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_name_" .. k, tag_cfg.name)
                LuaBehaviourUtil.setText(luaBehaviour,"tag_value_" .. k, v[2])
                local tag_name = luaBehaviour:FindGameObject("tag_name_" .. k)
                local tag_value = luaBehaviour:FindGameObject("tag_value_" .. k)
                tag_name:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
                tag_value:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            end
        end
        
        for i=1, 3 do
            if reward_data.item_cfg.type then
                if clothes_type[reward_data.item_cfg.type[i]] then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_" ..  i, true)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_type_" .. i, clothes_type[reward_data.item_cfg.type[i]].name)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_" ..  i, false)
                end
            end
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Fx_Star", close_fx == false)
    end
end

function M:updateOneSuitGachaItem(obj, data)
    if data then
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")
        local clothes_type = ConfigManager:getCfgByName("clothes_type")

        local reward_data = RewardUtil:getProcessRewardData(data)
        local is_has = UserDataManager.clothes_data:CheckIsHave(reward_data.data_id)
        local is_new = UserDataManager.clothes_data:clothesIsNew(reward_data.data_id)
        UserDataManager.clothes_data:RemoveAllClothesNewData(reward_data.data_id)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local suit_cfg = ConfigManager:getCfgByName("clothes_suit")[reward_data.item_cfg.suit]
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[suit_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        local frame_name_5 = quality_item.frame_name_5
        local frame_name_4 = quality_item.frame_name_3
        local item_img = luaBehaviour:FindImage("item_img")
        local item_bg = luaBehaviour:FindImage("item_bg")
        local item_frame = luaBehaviour:FindImage("item_frame")
        
        self:updateResourcesImg(item_bg, PathUtil:GetBgPath(frame_name_5))
        LuaBehaviourUtil.setImg(luaBehaviour, "item_frame", frame_name_4, ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setText(luaBehaviour, "txt_name", reward_data.name)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", data[1] == 9 )
        --LuaBehaviourUtil.setText(luaBehaviour, "lv_text", reward_data.item_cfg.lv .. "级")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "main_tag", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_new", is_new)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "has_img", not is_new and is_has)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_2", false)
        
        for k,v in pairs(reward_data.item_cfg.tag or {}) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_name_" .. k, tag_cfg.name)
                LuaBehaviourUtil.setText(luaBehaviour,"tag_value_" .. k, v[2])
                local tag_name = luaBehaviour:FindGameObject("tag_name_" .. k)
                local tag_value = luaBehaviour:FindGameObject("tag_value_" .. k)
                tag_name:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
                tag_value:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            end
        end

        local suit_params = UserDataManager.clothes_data:clothesSuitCollectById(reward_data.item_cfg.suit)
        if suit_params then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "suit_name_text", suit_params.sut_cfg.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "silder_text", "gacha_str_0011", suit_params.collect_num, suit_params.total_num)
            local silder_img = luaBehaviour:FindImage("silder_img")
            silder_img.fillAmount = (suit_params.collect_num - 1)/suit_params.total_num
            DOTweenModuleUI.DOFillAmount(silder_img,suit_params.collect_num/suit_params.total_num, 1)
            local default = self:GetDefaultTexture(2, suit_params.sut_cfg.icon)
            self:updateResourcesImg(item_img, PathUtil:GetBigClothesIconPath("big_" .. suit_params.sut_cfg.icon), PathUtil:GetBigClothesIconPath(default))
        end
    end
end

function M:updateSuitItem(obj, data)
    if data then
        local clothes_tag = ConfigManager:getCfgByName("clothes_tag")

        local reward_data = RewardUtil:getProcessRewardData(data)
        
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)

        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[reward_data.item_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        local frame_name_5 = quality_item.frame_name_5
        local frame_name_4 = quality_item.frame_name_3
        local item_img = luaBehaviour:FindImage("item_img")
        local item_bg = luaBehaviour:FindImage("item_bg")

        self:updateResourcesImg(item_bg, PathUtil:GetBgPath(frame_name_5))
        LuaBehaviourUtil.setImg(luaBehaviour, "item_frame", frame_name_4, ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suit_name_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "txt_name", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_new", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "has_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_2", false)
        local tag = UserDataManager.clothes_data:getSuitTag(reward_data.data_id)
        for k,v in pairs(tag) do
            local tag_cfg = clothes_tag[v[1]]
            if tag_cfg then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_" .. k, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_" .. k, tag_cfg.icon, "stageInfo_ui")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_name_" .. k, tag_cfg.name)
                LuaBehaviourUtil.setText(luaBehaviour,"tag_value_" .. k, v[2])
                local tag_name = luaBehaviour:FindGameObject("tag_name_" .. k)
                local tag_value = luaBehaviour:FindGameObject("tag_value_" .. k)
                tag_name:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
                tag_value:GetComponent("OutlineEx").OutlineColor = Color( tag_cfg.txt_line_color[1]/255, tag_cfg.txt_line_color[2]/255, tag_cfg.txt_line_color[3]/255, 0.3294118)
            end
        end

        local suit_params = UserDataManager.clothes_data:clothesSuitCollectById(reward_data.data_id)
        if suit_params then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "suit_name_text_2", suit_params.sut_cfg.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "silder_text", "gacha_str_0011", suit_params.collect_num, suit_params.total_num)
            local silder_img = luaBehaviour:FindImage("silder_img")
            silder_img.fillAmount = (suit_params.collect_num - 1)/suit_params.total_num
            DOTweenModuleUI.DOFillAmount(silder_img,suit_params.collect_num/suit_params.total_num, 1)
            local default = self:GetDefaultTexture(2, suit_params.sut_cfg.icon)
            self:updateResourcesImg(item_img, PathUtil:GetBigClothesIconPath("big_" .. suit_params.sut_cfg.icon), PathUtil:GetBigClothesIconPath(default))
        end
    end
end

function M:updateGachaItem(obj, data)
    if data then
        local reward_data = RewardUtil:getProcessRewardData(data)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[reward_data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        local gacha_item_frame = quality_item.gacha_item_frame
        local frame_name_3 = quality_item.frame_name_3
        local bg_img = luaBehaviour:FindImage("bg_img")

        self:updateResourcesImg(bg_img, PathUtil:GetBgPath(gacha_item_frame))
        LuaBehaviourUtil.setImg(luaBehaviour, "labels_img", frame_name_3, ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", reward_data.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", reward_data.story)
        luaBehaviour:FindGameObject("name_text"):GetComponent("OutlineEx").OutlineColor = quality_item.outline
        local num = reward_data.data_num
        if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.GOLD  then
            local value, unit = self:formatValue({reward_data.data_id, reward_data.data_num})
            num = value .. GlobalConfig.GOLD[unit]
        end
        LuaBehaviourUtil.setText(luaBehaviour, "num_text", "x" .. num)
    end
end

function M:GetDefaultTexture(type, id)
    local id = tonumber(id)
    if type == 1 then --服装资源
        local clothes_cfg = ConfigManager:getCfgByName("clothes")[id]
        if clothes_cfg.sort == 1 then
            return ConfigManager:getCommonValueById(67, 0)
        elseif clothes_cfg.sort == 2 then
            return ConfigManager:getCommonValueById(68, 0)
        elseif clothes_cfg.sort == 3 then
            return ConfigManager:getCommonValueById(69, 0)
        elseif clothes_cfg.sort == 4 then
            return ConfigManager:getCommonValueById(70, 0)
        elseif clothes_cfg.sort == 5 then
            return ConfigManager:getCommonValueById(71, 0)
        elseif clothes_cfg.sort == 6 then
            return ConfigManager:getCommonValueById(72, 0)
        elseif clothes_cfg.sort == 7 then
            return ConfigManager:getCommonValueById(73, 0)
        elseif clothes_cfg.sort == 8 then
            return ConfigManager:getCommonValueById(74, 0)
        elseif clothes_cfg.sort == 9 then
            return ConfigManager:getCommonValueById(75, 0)
        elseif clothes_cfg.sort == 10 then
            return ConfigManager:getCommonValueById(76, 0)
        elseif clothes_cfg.sort == 11 then
            return ConfigManager:getCommonValueById(77, 0)
        elseif clothes_cfg.sort == 12 then
            return ConfigManager:getCommonValueById(78, 0)
        end
    elseif type == 2 then --衣服大图标
        return ConfigManager:getCommonValueById(66, 0)
    elseif type == 3 then --背景大图标
        return ConfigManager:getCommonValueById(79, 0)
    elseif type == 4 then --背景资源
        return ConfigManager:getCommonValueById(80, 0)
    end
end

function M:CheckIsIndulgeTime()
    local flag = false
    local hours = tonumber(os.date("%H",UserDataManager:getServerTime()))
    if hours >= 8 and hours <= 21 then
        flag = true
    end
    return flag
end

function M:formatInputText(text)
    local new_text = string.gsub(tostring(text),"<quad(.*)>*","***")
    return new_text
end

function M:getMoneyTypeStr()
    local money_type = ConfigManager:getCommonValueById(105)
    local unit =  "¥"
    for k,v in pairs(GlobalConfig.TYPE_MONEY) do
        if money_type == v.name then
            unit = v.sign_name
        end
    end
    return unit
end

function M:switchMoneyType(price)
    local money_type = ConfigManager:getCommonValueById(105)
    local charge_tab = ConfigManager:getCfgByName("price_show")
    local price_data = charge_tab[price]
    if price_data == nil then
        return price
    end
    local num = price_data[money_type] or price
    return GameUtil:formatNum(num)
end

function M:getMoneyTypeNum(price, ratio)
    local money_type = ConfigManager:getCommonValueById(105)
    local unit =  "¥"
    for k,v in pairs(GlobalConfig.TYPE_MONEY) do
        if money_type == v.name then
            unit = v.sign_name
        end
    end
    local switch_num = self:switchMoneyType(price)
    if switch_num then
        if ratio and ratio ~= 1 then
            return GameUtil:formatNum(switch_num*ratio)..unit
        end
        return switch_num ..unit
    end
    return ""
end

--支付接口 - 做统计使用 1发起  2成功 3取消 4失败
function M:sendPayment(charge_id, type)
    --local url = NetUrl.getUrlForKey("payment")
    --local params = {charge_id = charge_id, action = type}
    --NetWork:httpRequest(
    --        function()
    --        end,
    --        url,
    --        GlobalConfig.POST,
    --        params,
    --        "payment",
    --        0
    --)
end

local __chinese_num = {}
local __chinese_unit = {}
-- 数字转大写
function M:numberToChineseString(num)
    if next(__chinese_num) == nil then
        for k,v in ipairs(GlobalConfig.CHINESE_NUM_LAN) do
            __chinese_num[k] = Language:getTextByKey(v)
        end
    end
    if next(__chinese_unit) == nil then
        for k,v in ipairs(GlobalConfig.CHINESE_UNIT_LAN) do
            __chinese_unit[k] = Language:getTextByKey(v)
        end
    end
    local ten_str = __chinese_num[2] .. __chinese_unit[2]
    local ten_len = string.len(ten_str)
    num = math.floor(num)
    if num == 0 then
        return __chinese_num[1]
    end
    local num_len = string.len(num)
    if num_len > 13 or num_len == 0 or num < 0 then
        return tostring(num)
    end
    local num_str = ""
    local zero_num = 0
    for i=1,num_len do
        local one_num = tonumber(string.sub(num, i,i))
        if one_num == 0 then
            zero_num = zero_num + 1
        else
            if zero_num > 0 then
                num_str = num_str .. __chinese_num[1]
            end
            num_str = num_str .. __chinese_num[one_num+1]
            zero_num = 0
        end
        if zero_num < 4 and ((num_len - i) % 4 == 0 or one_num ~= 0) then
            num_str = num_str .. __chinese_unit[num_len-i+1]
        end
    end
    local sub_str = string.sub(num_str, 1, ten_len)
    --- 开头的 "一十" 转成 "十"
    if sub_str == ten_str then
        num_str = string.sub(num_str, ten_len//2 + 1, string.len(num_str))
    end
    return num_str
end

--两个时间的天数差              --时间戳1  时间戳2  多少点开始算第二天
function M:NumberOfDaysInterval(unixTime1,unixTime2)
    if unixTime1 == 0 or unixTime2 == 0 then
        Logger.logError("获取时间差输入时间戳为0--")
        return 0
    end

    local time1 = TimeUtil.getIntTimestamp(unixTime1)
    local time2 = TimeUtil.getIntTimestamp(unixTime2)
    local sub = math.abs(time2 - time1)/(24*60*60)
    return sub
end

--将一个字符串转换为时间戳
function M:stringToTimesTamp(str)
    local date_pattern = "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)"
    local start_time = str or "1971-01-01 1:00:00"
    local _, _, _y, _m, _d, _hour, _min, _sec = string.find(start_time, date_pattern)
    local timestamp = os.time({year=_y, month = _m, day = _d, hour = _hour, min = _min, sec = _sec})
    return timestamp
end

return M
