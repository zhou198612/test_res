--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-06-02 21:03:08
]]

local M = class("TablePoolUtil")

--0 默认 {}
--1 FixVector3
function M:init()
   --实际的表池
   self.table_pool = {}
   --临时的表池
   self.table_pool_temp = {}
   self.table_pop_log = {}
   self.table_push_log = {}
   self.table_len_max = {};
   self:register(1,0);
--    self:register(2,20);
   self.registerFinish = 1;
end


--一开始注册对象
function M:register( key, count )
    for i=1,count do
        self:addItem( key )
    end
    self.table_len_max[key] = count;
end


--向表中加入一个对象
function M:addItem( key )
    if self.table_pool[key] == nil then
        self.table_pool[key] = {}
    end
    local item = self:getItem(key)
    table.insert(self.table_pool[key], item)
end


--根据key 获取一个对象
function M:getItem( key )
    local item = nil
    if key == 1 then
        item = FixVector3.New(0,0,0);
    elseif key == 2 then
        item = FixQuaternion.New(0,0,0,0);
    else
        item = {}
    end
    return item
end


--从池中弹出一个物体
function M:pop( key )
    local table_key = self.table_pool[key]
    if table_key ~= nil then
        local len = #table_key
	    if len > 0 then
		    local item = table_key[len]
            table.remove(table_key, len)
            if self.table_len_max[key] < #table_key then
                self.table_len_max[key] = #table_key
            end
            -- Logger.log("pop 池中的剩余长度 "..#table_key );
            return item
        else
            local item = self:getItem(key)
            return item;
        end
    else
        local item = self:getItem(key)
        return item;
    end
end

--将item推入临时表中
function M:push_temp( key, item )
    if self.table_pool_temp[key] == nil then
        self.table_pool_temp[key] = {}
    end

    if item ~= nil then
        table.insert(self.table_pool_temp[key], item)
    end

    if self.table_len_max[key] < #self.table_pool_temp[key] then
        self.table_len_max[key] = #self.table_pool_temp[key]
    end
end

--将所有的item 推入到池中
function M:push_all()
    for k1,v1 in pairs(self.table_pool_temp) do
        if self.table_pool[k1] == nil then
            self.table_pool[k1] = {}
        end
        for k2,v2 in ipairs(v1) do
            table.insert(self.table_pool[k1], v2)
        end
        if self.table_pool_temp[k1] ~= nil then
            self.table_pool_temp[k1] = nil
        end
    end
end


--将一个对象 返回到池中
function M:push( key, item )
    
    if self.table_pool[key] == nil then
        self.table_pool[key] = {}
    end

    if item ~= nil then
        table.insert(self.table_pool[key], item)
    end
    
    if self.table_len_max[key] < #self.table_pool[key] then
        self.table_len_max[key] = #self.table_pool[key]
    end
end

return M;