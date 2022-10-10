------------------- NetUrl
--[[--
    游戏逻辑接口，访问的是各个应用服务器，没有固定域名和ip
]]
local game_url = {
    -- config_version = "/config/?method=config_version",--获取配置版本号  
    check_version = "/config/?method=check_version", -- 热更资源和配置信息
    -- all_config = "/config/?method=all_config",--获取具体配置    &config_name=hero_basis
    
    user_game_info = "/api/?method=user.game_info",--获取用户信息 &user_token=gtt11234567
    user_main = "/api/?method=user.main",--主界面
    user_set_desc = "/api/?method=user.set_desc",--设置签名  desc: ""  签名
    user_set_avatar = "/api/?method=user.set_avatar",--设置玩家头像  avatar: ""
    user_set_title = "/api/?method=user.set_title",--设置称号
    user_see_title = "/api/?method=user.see_title",-- 查看称号
    user_recv_idle_offline_reward = "/api/?method=user.recv_idle_offline_reward",--领取离线挂机奖励
    user_heartbeat = "/api/?method=user.heartbeat",--心跳
    user_guide = "/api?method=user.guide",  -- 新手引导 sort 引导组 guide_id 引导id skip 0 1 是否跳过
    user_skip_guide = "/api?method=user.skip_guide", -- 跳过指定新手引导 skip_data:{sort:guide_id}
    user_set_name = "/api?method=user.set_name", -- 设置玩家姓名 name: ""  名字
    user_user_detail_info = "/api?method=user.user_detail_info", -- 用户详情 target_uid: 0     查询用户的uid
    --user_promote = "/api?method=user.promote", -- 提升途径提示小弹窗弹出次数
    user_switch_lang = "/api?method=user.switch_lang", --切换语言
    
    item_use_item = "/api?method=item.use_item", -- 使用道具item_id: 道具id item_num: 道具数量 item_index: 玩家自选道具
    
    battle_array_data ="/api?method=battle.array_data" , --布阵界面数据
    battle_start ="/api?method=stage.battle_start" , --战斗前获取 
    battle_end ="/api?method=stage.battle_end" , --战斗结果获取 
    battle_replay = "/api?method=battle.replay", -- 战斗回放 battle_id: 0  战斗id
    chapter_unlock ="/api?method=stage.chapter_unlock" , --解锁新章节
    
    chat_send = '/api?method=chat.send_msg', -- 短链接临时聊天发送
    chat_get = '/api?method=chat.get_msg', -- 短链接临时聊天获取

    code_use_code = "/api?method=code.use_code", -- 兑换码. code: afk666

    question_start = "/api?method=question.start", -- 开始问卷
    question_do = "/api?method=question.do_question", --做题

    sign_week_index = "/api?method=sign_week.index", --七天签到
    sign_week_receive = "/api?method=sign_week.receive", --七天签到领取
    sign_week_patch = "/api?method=sign_week.patch", --七天签到补领

    stage_action = "/api?method=stage.action", --闯关
    stage_prepare_action = "/api?method=stage.prepare_action", --创新角色体验关
    stage_chapter = "/api?method=stage.chapter", --章节
    stage_point = "/api?method=stage.point", --领取章节奖励
    stage_finish = "/api?method=stage.finish", --领取章节最终奖励
    clothes_buy = "/api?method=closet.buy_clothes", --衣柜--购买衣服
    clothes_change = "/api?method=closet.change_clothes", --衣柜--换装
    closet_get_suit_award = "/api?method=closet_suit.get_suit_award", -- 领取套装收集奖励
    
    set_background = "/api?method=user.set_background", --衣柜背景--换

    boyfriend_index = "/api?method=boyfriend.index", --男友首页
    boyfriend_see = "/api?method=boyfriend.see", --男友清楚新标记
    boyfriend_give = "/api?method=boyfriend.give", --男友送礼 
    boyfriend_read_story = "/api?method=boyfriend.read_story", -- 已阅读标记
    boyfriend_see_story = "/api?method=boyfriend.see_story", -- 新故事查看标记
    boyfriend_award_story = "/api?method=boyfriend.award_story", -- 领取已读奖励
    boyfriend_touch = "/api?method=boyfriend.touch", -- 互动点击事件
    boyfriend_interact = "/api?method=boyfriend.interact", -- 互动结束
    boyfriend_see_information = "/api?method=boyfriend.see_information", -- 查看男友资料标记
    receive_love_reward = "/api?method=boyfriend.receive_love_reward", --男友--领取好感度奖励
    boyfriend_reward_gift = "/api?method=boyfriend.reward_gift", -- 领取男友互动奖励
    boyfriend_reward_letter = "/api?method=boyfriend.reward_letter", -- 领取男友信件奖励
    boyfriend_partner = "/api?method=boyfriend.partner", -- 男友陪伴
    boyfriend_action = "/api?method=boyfriend.action", --约会
    boyfriend_buy_times = "/api?method=boyfriend.buy_times", --购买约会

    gacha_gacha_index = "/api?method=gacha.gacha_index", --抽卡入口
    gacha_get_gacha = "/api?method=gacha.get_gacha", --抽卡  弃用
    gacha_get_gacha_adv_ten = "/api?method=gacha.get_gacha_adv_ten", --广告抽卡  弃用
    gacha_get_gacha_adv_diff_ten = "/api?method=gacha.get_gacha_adv_diff_ten", --广告补齐抽卡 弃用
    gacha_get_gacha_free = "/api?method=gacha.get_gacha_free", --广告抽卡
    gacha_get_gacha_ticket = "/api?method=gacha.get_gacha_ticket", --抽卡卷抽卡
    gacha_get_gacha_diamond = "/api?method=gacha.get_gacha_diamond", --钻石抽卡
    
    set_attr_random = "/api?method=user.set_attr_random",  --设置玩家随机属性
    make_clothes = "/api?method=closet_suit.make_clothes", --制作衣服
    shop_index = "/api?method=shop.index", --商店
    shop_buy = "/api?method=shop.buy", --购买
    shop_refresh = "/api?method=shop.refresh", --刷新商店
    finish_story = "/api?method=story.finish", --完成剧情
    award_story = "/api?method=story.award", --领取剧情奖励
    
    avg_choose = "/api?method=avg.choose", --剧情奖励

    user_unlock_title = "/api/?method=user.unlock_title", --解锁称号

    package_Add = "/api?method=bag.adv_closet", --背包内购买
    package_buy = "/api?method=bag.buy", --背包内购买
    package_merge = "/api?method=bag.merge", --背包内合成
    package_drag = "/api?method=bag.drag", --背包内移动
    package_add_slot = "/api?method=bag.add_clot", --背包内解锁格子
    package_sell = "/api?method=bag.sell", --背包内出售
    package_libao = "/api?method=bag.libao", --生成礼包
    package_openlibao = "/api?method=bag.openlibao", --打开礼包
    package_luck_bubble = "/api?method=user.luck_bubble", --随机礼包

    jewelry_Add = "/api?method=jewelry.adv_closet", --背包内购买
    jewelry_buy = "/api?method=jewelry.buy", --背包内购买
    jewelry_merge = "/api?method=jewelry.merge", --背包内合成
    jewelry_drag = "/api?method=jewelry.drag", --背包内移动
    jewelry_add_slot = "/api?method=jewelry.add_clot", --背包内解锁格子
    jewelry_sell = "/api?method=jewelry.sell", --背包内出售
    jewelry_libao = "/api?method=jewelry.libao", --生成礼包
    jewelry_openlibao = "/api?method=jewelry.openlibao", --打开礼包
    jewelry_luck_bubble = "/api?method=user.luck_bubble", --随机礼包

    package_task = "/api?method=package_task.task",

    adv_begin = "/api?method=user.adv_begin", --开始看视频
    adv_speed_up = "/api?method=user.adv_speed_up", --挂机加速
    adv_diamond = "/api?method=user.adv_diamond", --看广告领钻石
    adv_coin = "/api?method=user.adv_coin", --看广告领金币
    quest_index = "/api?method=quest.index", --任务
    recv_main_reward = "/api?method=quest.recv_main_reward", --领取任务奖励
    recv_bundles_reward = "/api?method=user.bundles_reward", --下载后期资源包奖励
    index_charge = "/api?method=payment.index",  --获取充值数据
    buy_charge = "/api?method=user_payment.charge",  --虚拟充值
    charge_check = "/api?method=user_payment.charge_check", --充值检查
    payment_pay_order = "/api?method=payment.pay_order",  --获取订单号
    payment = "/api?method=user.payment", --支付接口 - 做统计使用
    first_payment_index = "/api?method=user_payment.first_payment_index", -- 首充
    receive_first_payment = "/api?method=user_payment.receive_first_payment", -- 领取首充
    gift_new_index = "/api?method=user_payment.gift_new_index", -- 新手礼包

    sign_month_index = "/api?method=sign_month.index", -- 月签入口
    sign_month_receive = "/api?method=sign_month.receive", -- 月签到
    sign_month_point = "/api?method=sign_month.point", -- 领宝箱

    level_gift_index = "/api?method=level_gift.index", -- 等级礼包
    level_gift_award = "/api?method=level_gift.award", -- 领取等级礼包

    roulette_roulette_index = "/api?method=roulette.roulette_index", --转盘
    roulette_refresh = "/api?method=roulette.refresh", --转盘刷新
    roulette_treasure = "/api?method=roulette.treasure", --转转盘
    roulette_treasure_free = "/api?method=roulette.treasure_adv_free", --广告转转盘
    roulette_free = "/api?method=roulette.treasure_free", --免费转转盘
    roulette_point = "/api?method=roulette.point", --星光值奖励

    salon_salon_index = "/api?method=salon.salon_index", --美发沙龙
    salon_treasure = "/api?method=salon.treasure", --理发
    salon_free_treasure = "/api?method=salon.free_treasure", --免费理发
    salon_select = "/api?method=salon.select", --理发选择发型
    salon_set_color = "/api?method=salon.set_color", --染发
    salon_join = "/api?method=salon.join", --沙龍vip

    adv_index = "/api?method=adv.index", --每日广告活动
    adv_award = "/api?method=adv.award", --领取每日广告活动奖励

    arena_index = "/api?method=arena.index",  --T台展示入口
    arena_challenge = "/api?method=arena.challenge",  --T台挑战
    arena_buy_times = "/api?method=arena.buy_times",  --T台购买次数
    arena_select_rank_list = "/api?method=arena.select_rank_list",  --T台排行榜
    arena_select_arena_logs = "/api?method=arena.select_arena_logs",  --T台挑战记录
    arena_get_section_award = "/api?method=arena.get_rank_up_rewards",  --T台领取段位奖励

    recruit_index = "/api?method=recruit.index",  --七日旅程
    recruit_buy = "/api?method=recruit.buy",  --旅程购买
    recruit_recv_main_reward = "/api?method=recruit.recv_main_reward", -- 领取旅程任务
    recruit_point = "/api?method=recruit.point", -- 领取旅程积分奖励

    festival_index = "/api?method=festival.index",  --新年活动
    festival_buy = "/api?method=festival.buy",  --新年活动购买
    festival_recv_main_reward = "/api?method=festival.recv_main_reward", -- 领取新年活动任务
    festival_point = "/api?method=festival.point", -- 领取新年活动积分奖励

    makeup_index = "/api?method=makeup.index", --化妆
    makeup_save = "/api?method=makeup.save", --妆容保存
    makeup_buy = "/api?method=makeup.buy", --妆容购买
    makeup_change = "/api?method=makeup.change", --妆容改名
    makeup_expand = "/api?method=makeup.expand", --妆容扩展
    makeup_award = "/api?method=makeup.award", --领购买妆容次数奖励

    active_total_charge_index = "/api?method=active.total_charge_index", -- 累计充值入口
    active_total_charge_award = "/api?method=active.total_charge_award", -- 累计充值领奖

    mall_index = "/api?method=mall.index", --商城入口
    mall_zone = "/api?method=mall.zone", --商城专区
    mall_buy = "/api?method=mall.buy", --商城游戏内货币购买
    mall_charge = "/api?method=mall.charge", --商城支付现金购买
    mall_month_card = "/api?method=mall.month_card", --商城月卡状态
    mall_exchange = "/api?method=mall.exchange", --兑换商品
    mall_exchange_refresh = "/api?method=mall.exchange_refresh", --兑换刷新
    mall_rebate = "/api?method=mall.rebate", --返利兑换
    mall_rebate_award = "/api?method=mall.rebate_award", --返利奖励领取

    mail_index = "/api?method=mail.index", -- 邮箱主页 mail_ids: [], 查看邮件的id列表,首次进入邮件主页是为空
    mail_read = "/api?method=mail.read", -- 阅读邮件 mail_id: 邮件id
    mail_receive = "/api?method=mail.receive", -- 领取邮件 mail_id: 邮件id
    mail_receive_all = "/api?method=mail.receive_all", -- 领取全部邮件
    mail_delete_mail = "/api?method=mail.delete_mail", -- 删除邮件 mail_id: 邮件id
    mail_delete_all = "/api?method=mail.delete_all", -- 删除所有邮件

    --问卷
    question_start = "/api?method=question.start", -- 开始问卷
    question_do = "/api?method=question.do_question", --做题
    
}

--[[--
    用于登录的服务器，域名和ip基本不变（不保证
    sdk的登录和付费都放在login_url_config表中
]]
local login_url_config = {  -- 走master服务器的配置
    register = "/login/?method=register",--账号注册   &account=kongliang&passwd=123456
    login = "/login/?method=login",--账号登录  &account=kongliang&passwd=123456
    platform_access = "/login/?method=platform_access",--验证 &pre_pf=test&channel=test&openid=1234567
    new_account = "/login/?method=new_account", -- 如果用户没有账户，给他一个临时的
    server_list = "/login/?method=server_list",--前端通过保存的account，获得用户的server_list数据
    login_server = "/login/?method=login_server", -- 登录服
    new_user = "/login/?method=new_user",     --  增加name 和is_new
    notice = "/login/?method=notice", -- 公告
    device_action = "/login/?method=device_action", -- 统计接口
    device_bundles_action = "/login/?method=device_bundles_action", -- bundles下载资源统计接口
    device_resource_action = "/login/?method=device_resource_action", -- 资源包热更统计接口
    device_config_action = "/login/?method=device_config_action", -- 配置热更统计接口
    device_login_action = "/login/?method=device_login_action", -- 登录统计接口
    doing_certification = "/login/?method=doing_certification", -- 实名认证 account=acc6575003&card_num=1000&card_name=啊啊啊啊
}

local M = {}

--[[--
    获得完整的url
]]
function M.getUrlForKey(key)
    local url = nil
    if game_url[key] then
        url = GameVersionConfig.SERVICE_URL .. game_url[key]
    elseif login_url_config[key] then
        url = GameVersionConfig.SERVICE_URL .. login_url_config[key]
    end
    if url ~= nil then
        url = url .. "&" .. M.getExtUrlParam()
    end
    return url
end

function M.getExtUrlParam()
    local client_data = UserDataManager.client_data
    local params = {}
    table.insert(params, "uid=" .. UserDataManager.user_data:getUid())
    --table.insert(params, "uid=" .. 1048584)
    --table.insert(params, "frontwindow=" .. "5e3b4530b293b5c1f4eeca4638ab4dc1")
    --table.insert(params, "uid=" .. 1048584)
    if client_data.user_token then
        table.insert(params, "user_token=" .. client_data.user_token)
    end
    --table.insert(params, "c_ver=" .. GameVersionConfig.CLIENT_VERSION)
    --table.insert(params, "r_ver=" .. GameVersionConfig.GAME_RESOURCES_VERION)
    table.insert(params, "device_mark=" .. UserDataManager.client_data.device_mark)
    table.insert(params, "sid=" .. UserDataManager.server_data:getUserSid())
    table.insert(params, "vcd=" .. (GameVersionConfig.vcd or ""))
    table.insert(params, "lang=" .. Language:getCurLanguage())
    return table.concat(params, "&")
end

local __crypto_url_keys = {
    check_version = 1,
    register = 1,
    login = 1,
    platform_access = 1,
    new_account = 1,
    server_list = 1,
    login_server = 1,
    new_user = 1,
    notice = 1,
    device_action = 1,
    device_bundles_action = 1,
    device_resource_action = 1,
    device_config_action = 1,
    device_login_action = 1,
    front_err = 1,
}

function M.getCryptoUrlValue(key)
    return __crypto_url_keys[tostring(key)]
end

return M
