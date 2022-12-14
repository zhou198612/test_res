---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by DELL.
--- DateTime: 2020/11/3 11:35
---

local M = {
    clothes_group_cfg = {},
    clothes_suit_cfg = {},
    clothes_cfg = {},

    clothes_suit_data = {},
    finish_suit = {}
}

function M:updateSuitClothes(data)
    self.clothes_group_cfg = ConfigManager:getCfgByName("clothes_group")
    self.clothes_suit_cfg = ConfigManager:getCfgByName("clothes_suit")
    self.clothes_cfg = ConfigManager:getCfgByName("clothes")
    for k, v in pairs(self.clothes_group_cfg) do
        self.clothes_suit_data[k] = {}
        for m, n in pairs(self.clothes_suit_cfg) do
            if tonumber(n.group) == k then
                n.id = m
                table.insert(self.clothes_suit_data[k], n)
            end
        end
        self.finish_suit[k] = {}
        for i, j in pairs(data) do
            if i == tostring(k) then
                self.finish_suit[k] = j
            end
        end
        self:Sort(self.clothes_suit_data[k])
    end
end

function M:AddSuitData(open_suit_id)
    local group = self.clothes_suit_cfg[open_suit_id].group
    table.insert(self.finish_suit[group], open_suit_id)
    for k, v in pairs(self.clothes_group_cfg) do
        self:Sort(self.clothes_suit_data[k])
    end
end

-- 排序
function M:Sort(list)
    --可制作的服饰套装>未制作的服饰套装>已制作的服饰套装
    for k, v in pairs(list) do
        if self:CheckFinish(v.id) then
            v.state = 2
        else
            if self:CheckSuitMakeById(v.id) then
                v.state = 1
            else
                v.state = 0
            end
        end
    end
    local sort1, sort2
    local sortFunc = function(a, b)
        sort1 = a.state
        sort2 = a.state
        if a.state == 2 then
            sort1 = 10000 + a.order
        elseif a.state == 1 then
            sort1 = 1000 + a.order
        elseif a.state == 0 then
            sort1 = 5000 + a.order
        end
        if b.state == 2 then
            sort2 = 10000 + b.order
        elseif b.state == 1 then
            sort2 = 1000 + b.order
        elseif b.state == 0 then
            sort2 = 5000 + b.order
        end
        return sort1 < sort2
    end
    table.sort(list, sortFunc)
end

--通过套装id检测套装是否已经完成
function M:CheckFinish(suit_id)
    if not suit_id then
        return false
    end
    local is_open = false
    for k, v in pairs(self.finish_suit) do
        for m, n in pairs(v) do
            if n == suit_id then
                is_open = true
            end
        end
    end
    return is_open
end

--通过衣服id检测是否可制作
function M:CheckClothesMake(clothes_id)
    if not clothes_id then
        return false
    end
    local is_have = UserDataManager.clothes_data:CheckIsHave(clothes_id) --已有服装不可制作
    if is_have then
        return false
    end
    local can_make = true
    local items = self.clothes_cfg[clothes_id].need_item
    for k, v in pairs(items) do
        local item_num = UserDataManager.item_data:GetNumById(v[2])
        if item_num < v[3] then
            can_make = false
            break
        end
    end
    return can_make
end

--通过套装id检测套装是否有可制作的
function M:CheckSuitMakeById(suit_id)
    local have_make = false
    local clothes = self.clothes_suit_cfg[suit_id].clothes
    if self:CheckSuitClothesMake(clothes) then
        have_make = true
    else
        have_make = false
    end
    return have_make
end

--检测当前套装是否有可制作的
function M:CheckSuitClothesMake(clothes)
    if not clothes then
        return false
    end
    local have_make = false
    for m, n in pairs(clothes) do
        if self:CheckClothesMake(n) then
            have_make = true
            break
        end
    end
    return have_make
end

--通过套装分组检测当前分组是否有可制作的
function M:CheckGroupClothesMake(group_id)
    if not group_id then
        return false
    end
    local have_make = false
    for k, v in pairs(self.clothes_suit_data[group_id]) do
        if self:CheckSuitClothesMake(v.clothes) then
            have_make = true
            break
        end
    end
    return have_make
end

function M:GetSuitDataByGroup(group_id)
    return self.clothes_suit_data[group_id]
end

function M:GetFinishSuitData()
    return self.finish_suit
end

return M