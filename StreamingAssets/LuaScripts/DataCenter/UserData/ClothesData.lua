------------ ClothesData
local M = {
	m_clothes = {},
    m_new_clothes = {},
    m_colors = {}, -- 染发
    m_face_suit = {}
}

function M:initClothesData(data)
    if data then
        self.m_clothes = data
    end
end

function M:updateFaceData(data)
    if data then
        self.m_face_suit = data
    end
end

--[[--
    更新服饰数据
]]
function M:updateMoreClothesData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        if self.m_clothes[k] == nil then
            self.m_new_clothes[k] = v
        end
        self.m_clothes[k] = v
    end
end

function M:clothesIsNew(key)
    key = tostring(key)
    if self.m_new_clothes[key] then
        return true
    end
    return false
end

function M:RemoveAllClothesNewData(key)
    key = tostring(key)
    self.m_new_clothes[key] = nil
end

--[[--
    通过id表格移出服饰数据
]]
function M:removeMoreClothesDataById(ids)
    if ids == nil then return end
    for _,v in pairs(ids) do
        self.m_clothes[tostring(v)] = nil
    end
end

--[[--
   获得服饰数据
]]
function M:getClothesData()
    return self.m_clothes
end

--[[
    获得服饰的id列表
]]
function M:getClothesId()
    local ids = {}
    local clothes_data = self:getClothesData()
    for k,_ in pairs(clothes_data) do
        table.insert(ids, k)
    end
    return ids
end

--[[
    获得服饰的id列表
]]
function M:getClothesIdByFilterFunc(filter_func)
    local clothes = ConfigManager:getCfgByName("clothes")
    local ids = {}
    local clothes_data = self:getClothesData()
    for k,v in pairs(clothes_data) do
        if filter_func(v, clothes[tonumber(k)]) then
            table.insert(ids, k)
        end
    end
    return ids
end

-- 获取某一类型服饰的id
function M:getClothesIdsBySort(sort)
    local clothes = ConfigManager:getCfgByName("clothes")
    local ids = {}
    local clothes_data = self:getClothesData()
    for k,v in pairs(clothes_data) do
        local id = tonumber(k)
        local cfg = clothes[id]
        if cfg and cfg.sort == sort then
            table.insert(ids, id)
        end
    end
    return ids
end

--[[
	获得服饰数据
]]
function M:getClothesDataById(id)
    id = tostring(id)
    local data = self.m_clothes[id] or 0
    local clothes = ConfigManager:getCfgByName("clothes")
    local cfg = clothes[tonumber(id)]
    return data, cfg
end

--判断服装是否拥有
function M:CheckIsHave(clothes_id)
    if not clothes_id then
        return false
    end
    clothes_id = tostring(clothes_id)
    local is_have = false
    if self.m_clothes[clothes_id] and self.m_clothes[clothes_id] > 0 then
        is_have = true
    end
    
    return is_have
end

-- 通过类型读取套装配置
function M:getClothesSuitCfgByGroup(group_id)
    local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
    local suit = {}
    for i,v in pairs(clothes_suit or {}) do
        if v.group == group_id and v.type == 1 then
            local cfg = table.copy(v)
            cfg.id = i
            suit[#suit + 1] = cfg
        end
    end
    return suit
end

-- 一类套装收集情况
function M:groupSuitCollect(group_id)
    local suit = self:getClothesSuitCfgByGroup(group_id)
    local collect_num = 0
    local has_reward = false -- 可领奖励
    for i,v in ipairs(suit) do
        local suit_data = self:clothesSuitCollectById(v.id)
        if suit_data.collect_num == suit_data.total_num then
            collect_num = collect_num + 1
            if not UserDataManager:getSuitAwardById(v.id) then
                has_reward = true
            end
        end
    end
    local params = {}
    params.collect_num = collect_num
    params.total_num = #suit
    params.has_reward = has_reward
    return params
end

-- 收集的套装数据
function M:clothesSuitCollectById(suit_id)
    if suit_id then
        local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
        local suit_cfg = clothes_suit[suit_id]
        local collect_num = 0
        local collect_ids = {}
        local params = {}
        if suit_cfg then
            for i,v in ipairs(suit_cfg.clothes or {}) do
                local num, cfg = self:getClothesDataById(v)
                if num and num > 0 then
                    collect_num = collect_num + 1
                    collect_ids[collect_num] = v
                end
            end
            params.total_num = #suit_cfg.clothes
        else
            params.total_num = 0
        end
        params.collect_num = collect_num
        params.collect_ids = collect_ids
        params.sut_cfg = suit_cfg
        return params
    end
end

function M:clothesSuitCfgById(suit_id)
    local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
    return clothes_suit[suit_id]
end

--获取妆容套装
function M:getFaceSuitList()
    local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
    local data = {}
    local key = 0
    for k, v in pairs(clothes_suit) do
        if v.type == 2 then
            data[k] = v
            if k > key then
                key = k
            end
        end
    end
    for m, n in pairs(self.m_face_suit) do
        key = key + 1
        data[key] = n
    end
    return data
end

--获取服饰套装
function M:getClothesSuitList()
    local clothes_suit = ConfigManager:getCfgByName("clothes_suit")
    local data = {}
    for k, v in pairs(clothes_suit) do
        if v.type == 1 then
            data[k] = v
        end
    end
    return data
end

-- 获得套装的主标签
function M:getSuitTag(suit_id)
    local suit_cfg = self:clothesSuitCfgById(suit_id)
    local tag = {}
    if suit_cfg then
        local num = 0
        for m, n in pairs(suit_cfg.clothes or {}) do
            local data, item_cfg = self:getClothesDataById(n)
            for i,v in ipairs(item_cfg.tag or {}) do
                tag[v[1]] = (tag[v[1]] or 0) + v[2]
            end
        end
    end
    
    local value = {}
    for k,v in pairs(tag) do
        table.insert(value, {k, v})
    end
    table.sort(value, function(a, b) 
        return a[1] < b[1]
    end)
    return value
end

-----------------------------------------------------------------------------
--- 染发

function M:updateColorsData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self.m_colors[k] = v
    end
end

function M:removeColorsDataById(ids)
    if ids == nil then return end
    for _,v in pairs(ids) do
        self.m_colors[tostring(v)] = nil
    end
end

function M:getColorsById(id)
    id = tostring(id)
    return self.m_colors[id]
end

return M