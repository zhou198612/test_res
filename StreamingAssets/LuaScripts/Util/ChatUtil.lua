
local M = {}
local __ChatClient = CS.ChatClient.Instance
local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3}

M.pb = require 'pb'
M.pbs = require 'Net.pbs'
M.pbc = require 'Net.protoc'
assert(M.pbc:load(M.pbs.chat))

function M:initData()
    self.msgs = {}
    self.player_names = {}
    self.channel_msgs = {}
    self.channel_msgs[__CHAT_CHANNEL.WORLD] = {} --世界频道
    self.channel_msgs[__CHAT_CHANNEL.LOCAL] = {} --本地频道
end

--连接聊天服务器
function M:connectChatServer()
    self:initData()
    local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id") or 0
        if guild_id ~= 0 then
            self.channel_msgs[__CHAT_CHANNEL.GUILD] = {} --工会频道
        end
    __ChatClient:RegisterLuaChatMgr(
        function (msg_data)
            local cmd_id = msg_data._cmdId
            local bytes = msg_data._bytes
            local data = assert(ChatUtil.pb.decode('chat.ChatResponsePack',bytes))
            if data.result.code == 0 then
            local res = data['res'..cmd_id]
            if cmd_id == 1 then
                self.msgs = res.msgs
                for i,msg in pairs(self.msgs) do
                    local channel = tonumber(msg.channel_type)
                    if channel > 3 then
                        local channel_id = tonumber(msg.channel_id)
                        self.channel_msgs[channel_id]  =  self.channel_msgs[channel_id] or {}
                        table.insert(self.channel_msgs[channel_id],msg)
                    else
                        self.channel_msgs[channel]  =  self.channel_msgs[channel] or {}
                        table.insert(self.channel_msgs[channel],msg)
                    end
                   
                end
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT)
            elseif cmd_id == 2 then
                local channel = tonumber(res.channel_type)
                table.insert(self.msgs,res)
                if channel > 3 then

                    local channel_id = tonumber(res.channel_id)
                    local flag = self.channel_msgs[channel_id] == nil
                    if flag then
                        self.channel_msgs[channel_id] = {}
                    end
                    table.insert(self.channel_msgs[channel_id],res)
                    if flag then 
                        print('我广播了！！！！！！！！！！！！！！！！！！！！！')
                        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_ADD_CHANNEL,channel_id)
                    end
                else   
                    self.channel_msgs[channel]  =  self.channel_msgs[channel] or {}
                    table.insert(self.channel_msgs[channel],res)
                end
                
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH)
            end
        end
    end)
    __ChatClient:Connect(UserDataManager.server_data:getServerData().chat_addr[1],UserDataManager.server_data:getServerData().chat_addr[2], handler(self, self.eventAction))
end

function M:eventAction(event_name)
    if event_name == "connect_success" then
        self:initData()
        self:login()
    elseif event_name == "reconnect_success" then
        self:initData()
        self:login()
        -- if static_rootControl then
        --     GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0423"), delay_close = 2})
        -- end
    elseif event_name == "disconnect" then
        -- if static_rootControl then
        --     GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0424"), delay_close = 2})
        -- end
    elseif event_name == "send_data_failed" then
        if static_rootControl then
            GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0425"), delay_close = 2})
        end
    end
end

function M:login()
    local data = {uid = UserDataManager.user_data:getUid(),sid ='0',Language = 'CN',server_id = tostring(UserDataManager.server_data:getServerId()),guild_id = tostring(UserDataManager.user_data:getUserStatusDataByKey("guild_id") or 0)}
    self:sendMsg(data,1)
    local bytes = assert(self.pb.encode('chat.ChatRequestPack', {['req5'] = {uid = UserDataManager.user_data:getUid()}}))
    __ChatClient:SetHeartbeatByte(bytes, 5)
end

--打开界面时绑定网络返回方法
function M:bindFunc(func)
    self.receive_func = func
end

--关闭界面时解绑
function M:unbindFunc()
    self.receive_func = nil
end

function M:closeSocket()
    __ChatClient:CloseChatSocket()
end

--向服务器发送聊天消息，可以在这里添加时间限制
function M:sendMsg(msg_data,cmd_id)
    local data = { }
    data['req'..cmd_id] = msg_data
    local bytes = assert(self.pb.encode('chat.ChatRequestPack',data))
    __ChatClient:SendMsg(bytes,cmd_id)
end

return M
