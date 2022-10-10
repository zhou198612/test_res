local M = {

    chat = [[
        syntax = "proto3";

        package chat;
        
        
        // common
        message ChatResult {
            int32 code = 1;
            string msg = 2;
        }
        
        message Empty {}
        
        
        // request
        message ChatRequestPack {
            ChatResult result = 1;
            ChatLoginRequest req1 = 100;
            ChatMessageRequest req2 = 101;
            ChatJoinChannelRequest req3 = 102;
            ChatQuitChannelRequest req4 = 103;
            ChatHeartbeatRequest req5 = 104;
        }
        
        // response
        message ChatResponsePack {
            ChatResult result = 1;
            ChatLoginResponse res1 = 100;
            ChatMessageResponse res2 = 101;
            ChatJoinChannelResponse res3 = 102;
            ChatQuitChannelResponse res4 = 103;
            Empty req5 = 104;
        }
        
        
        // 登录请求
        message ChatLoginRequest {
            int64 uid = 1;
            int64 sid = 2;
            int64 platform = 3;     // 平台 0: android 1: ios
            string device_id = 4;   // IMEI on android
            string mac = 5;         // mac地址
            string model = 6;       // 机型
            string language = 7;    // 语言
            string server_id = 8;   // 游戏服务器ID
            string guild_id = 9;    // 公会id
        }
        
        
        // 登录响应
        message ChatLoginResponse {
            string sid = 1;
            repeated ChatMessageResponse msgs = 2;
        }
        
        
        // 消息请求
        message ChatMessageRequest {
            int64 uid = 1;          // 用户id
            string name = 2;        // 用户名
            string avatar = 3;      // 用户头像
            string frame = 4;       // 用户头像框
            string msg = 5;         // 消息
            string channel_type = 6;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 7;      // 频道id 1-本地 2-世界 3-工会 4-私聊
            string target_name = 8;      // 目标名字
        }
        
        
        // 消息响应
        message ChatMessageResponse {
            int64 uid = 1;          // 用户id
            string name = 2;        // 用户名
            string avatar = 3;      // 用户头像
            string frame = 4;       // 用户头像框
            string msg = 5;         // 消息
            string channel_type = 6;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 7;      // 频道id 私聊id
            string time = 8;        // 时间搓
            string msg_id = 9;      // 消息id
            string target_name = 10;      // 目标名字
        }
        
        
        // 消息请求 - 102
        message ChatJoinChannelRequest {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }
        
        
        // 消息响应 - 102
        message ChatJoinChannelResponse {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }
        
        
        // 消息请求 - 103
        message ChatQuitChannelRequest {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }
        
        
        // 消息响应
        message ChatQuitChannelResponse {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }
        
        // 心跳消息请求 - 104
        message ChatHeartbeatRequest {
            int64 uid = 1;
        }
        
    ]]
}
return M