----------- GlobalConfig
local M = {
	GET = "GET",
	POST = "POST",
	EVENT_KEYS = {
		EQUIP_UPDATE_EVENT = "equip_update_event",
		DATA_UPDATE_EVENT = "data_update_event",
		NET_DATA_UPDATE_EVENT = "net_data_update_event",
		CLOSE_VIEW = "close_view",
        OPEN_VIEW = "open_view",
        CHAT_INIT = 'chat_init!!', -- 连接到聊天服务器TCP
        CHAT_REFRESH = 'chat_refresh!!',
        CHAT_ADD_CHANNEL = 'chat_add_channel!!',
        IDLE_UPDATE = 'idle_update',
        MOT_MONEY = "not_money",
        UNPACKING_EVENT = "later_download",
        CHARGE = "charge",
    },
    UI_TOP_OFFSET_Y = -60,
    UI_BOTTOM_OFFSET_Y = 60,
    UI_LEFT_OFFSET_X = 60,
    UI_RIGHT_OFFSET_X = -60,
    UI_DESIGN_WIDTH = 720,
    UI_DESIGN_HEIGHT = 1280,
    CONFIG_PATH = "LuaScripts/DataCenter/Config/", -- 配置路径
    ASSIST_SUMMARIES_LIMIT_NUM = 3, -- 好友的外援英雄限定数量
    MUSIC_VOLUME = 0.5, -- 音乐的声音大小
    SOUND_VOLUME = 0.5, -- 音效的声音
    SENSITIVE_WORDS_CODE = "5005",
    GOLD = {},
}

--[[
    frame_name 装备&物品 方形品质底
    frame_name_2 方形品质
    frame_name_3 大长方形品
    frame_name_4 大长方形品质框
    frame_name_5 大套装品质框
    card_frame_name 英雄 方形边框
    card_frame_name2 英雄卡牌（长方形）
    is_add-是否有附加精英边框
    icon 品质图标
]]
M.QUALITY_COMMON_SETTING = {
    {name = "new_str_0335", hero_show_name = "new_str_0457", hero_half_bg = "a_ui_lan_di", frame_name = "ui_wp_wt2", frame_name_2 = "ui_wp_wt3", frame_name_3 = "ui_wp_daka_wt3", frame_name_4 = "ui_wp_daka_wt", frame_name_5 = "ui_wp_dakataozhuang_wt", card_frame_name = "ui_YX_lv", card_frame_name2 = "a_zd_lv", card_frame_name3 = "a_ui_lv_s", gacha_item_frame = "ui_ck_danwp_wt", is_add = false, icon = "icon_hui", item_effect = nil, outline = Color.New(102/255, 128/255, 202/255, 78/255), HC = "A6A6A6", hero_3d_base = "fx_formation_grey_01" }, --1 灰色
    {name = "new_str_0334", hero_show_name = "new_str_0457",hero_half_bg = "a_ui_lv2", frame_name = "ui_wp_gn2", frame_name_2 = "ui_wp_gn3", frame_name_3 = "ui_wp_daka_gn3", frame_name_4 = "ui_wp_daka_gn", frame_name_5 = "ui_wp_dakataozhuang_gn", card_frame_name = "ui_YX_lv", card_frame_name2 = "a_zd_lv", card_frame_name3 = "a_ui_lv_s", gacha_item_frame = "ui_ck_danwp_gn", is_add = false, icon = "icon_lv", item_effect = nil, outline = Color.New(56/255, 126/255, 58/255, 78/255) , HC = "9ACF81", hero_3d_base = "fx_formation_grey_01" }, --2 绿色
    {name = "new_str_0333", hero_show_name = "new_str_0457",hero_half_bg = "a_ui_lan_di", frame_name = "ui_wp_bu2", frame_name_2 = "ui_wp_bu3", frame_name_3 = "ui_wp_daka_bu3", frame_name_4 = "ui_wp_daka_bu", frame_name_5 = "ui_wp_dakataozhuang_bu", card_frame_name = "a_zd_lan", card_frame_name2 = "a_zd_lan", card_frame_name3 = "a_ui_lan_s", gacha_item_frame = "ui_ck_danwp_bu", is_add = false, icon = "icon_lan", item_effect = nil, outline = Color.New(102/255, 128/255, 202/255,78/255) , HC = "6DC4F4", hero_3d_base = "fx_formation_blue_01" }, --3 蓝色
    {name = "new_str_0332", hero_show_name = "new_str_0457",hero_half_bg = "a_ui_lan_di", frame_name = "ui_wp_pl2", frame_name_2 = "ui_wp_pl3", frame_name_3 = "ui_wp_daka_pl3", frame_name_4 = "ui_wp_daka_pl", frame_name_5 = "ui_wp_dakataozhuang_pl", card_frame_name = "a_zd_lan", card_frame_name2 = "a_zd_lan", card_frame_name3 = "a_ui_lan_s", gacha_item_frame = "ui_ck_danwp_pl", is_add = true, icon = "icon_lan+", item_effect = nil, outline = Color.New(231/255, 103/255, 143/255,78/255) , HC = "6DC4F4", hero_3d_base = "fx_formation_blue_02" }, --4 蓝+ 有外框
    {name = "new_str_0331", hero_show_name = "new_str_0458",hero_half_bg = "a_ui_zi_di", frame_name = "ui_wp_yl2", frame_name_2 = "ui_wp_yl3", frame_name_3 = "ui_wp_daka_yl3", frame_name_4 = "ui_wp_daka_yl", frame_name_5 = "ui_wp_dakataozhuang_yl", card_frame_name = "ui_YX_zi", card_frame_name2 = "a_zd_zi", card_frame_name3 = "a_ui_zi_s", gacha_item_frame = "ui_ck_danwp_yl", is_add = false, icon = "icon_zi", item_effect = "fx_ItemNode_01", outline = Color.New(175/255, 114/255, 60/255,78/255) , HC = "F087FA", hero_3d_base = "fx_formation_purple_01" }, --5 紫色
}



M.HEIRLOOM_LIBRARY_QUALITY = {
    [3] = {bg = "gm_yiwuzhizhang_lan", icon = "gm_yiwupingzhi_lan"},
    [5] = {bg = "gm_yiwuzhizhang_zi", icon = "gm_yiwupingzhi_zi"},
    [7] = {bg = "gm_yiwuzhizhang_huang", icon = "gm_yiwupingzhi_jin"},
}

M.QUALITY_MYSTIC_SETTING = {
    {name = "new_str_0333", frame_name = "ui_lan", card_frame_name = "ui_YX_lan", card_frame_name2 = "ui_zd_card_lan", is_add = false, icon = "icon_lan", RGBA = Color.New(109/255, 196/255, 244/255) , HC = "6DC4F4", hero_3d_base = "fx_formation_blue_01" }, --3 蓝色
    {name = "new_str_0331", frame_name = "ui_zi", card_frame_name = "ui_YX_zi", card_frame_name2 = "ui_zd_card_zi", is_add = false, icon = "icon_zi", RGBA = Color.New(240/255, 135/255, 250/255) , HC = "F087FA", hero_3d_base = "fx_formation_purple_01" }, --5 紫色
    {name = "new_str_0329", frame_name = "ui_jin", card_frame_name = "ui_YX_jin", card_frame_name2 = "ui_zd_card_huang", is_add = false, icon = "icon_jin", RGBA = Color.New(255/255, 227/255, 70/255) , HC = "FFE346", hero_3d_base = "fx_formation_yellow_01" }, --7 金
    {name = "new_str_0327", frame_name = "ui_hong", card_frame_name = "ui_YX_hong", card_frame_name2 = "ui_zd_card_bai", is_add = false, icon = "icon_hong", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_red_01" }, --9 红
    {name = "new_str_0325", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --11 彩
    {name = "new_str_0324", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai1", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --12 彩1星
    {name = "new_str_0323", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai2", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --13 彩2星
    {name = "new_str_0322", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai3", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --14 3星
    {name = "new_str_0321", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai4", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --15 4星
    {name = "new_str_0320", frame_name = "ui_cai", card_frame_name = "ui_YX_cai", card_frame_name2 = "ui_zd_card_cai", is_add = false, icon = "icon_cai5", RGBA = Color.New(251/255, 115/255, 113/255) , HC = "FB7371", hero_3d_base = "fx_formation_white_01" }, --16 5星
}

M.QUALITY_CLOTHES_SORT = {
    [1] = {name = "ste_colth_0001", armoire = 1, img = "hair_img", bg_img = "hair_bg", up_img = "hair_up"}, --头发
    [2] = {name = "ste_colth_0002", armoire = 3, img = "top_img_1", bg_img = "top_bg", up_img = "top_up"  }, --上衣
    [3] = {name = "ste_colth_0003", armoire = 5, img = "coat_img", bg_img = "coat_bg", up_img = "coat_up"  }, --外套
    [4] = {name = "ste_colth_0004", armoire = 4, img = "bottom_img_1", bg_img = "bottom_bg_1"  }, --下衣
    [5] = {name = "ste_colth_0005", armoire = 6, img = "socks_img"}, --袜子
    [6] = {name = "ste_colth_0006", armoire = 7, img = "shoe_img", bg_img = "shoes_bg"}, --鞋子
    [7] = {name = "ste_colth_0007", armoire = 8, img = "headwear_img", bg_img = "headwear_bg"  }, --头饰
    [8] = {name = "ste_colth_0008", armoire = 8, img = "ear_img", path = "Texture/Clothes/", ab_path = "texture_clothes/" }, --耳饰
    [9] = {name = "ste_colth_0009", armoire = 8, img = "necklace_img", up_img = "necklace_up" }, --项链
    [10] = {name = "ste_colth_0010", armoire = 8, img = "arm_accessories_img", up_img = "arm_accessories_up_1" }, --手饰
    [11] = {name = "ste_colth_0011", armoire = 2, img = "skirt_img", bg_img = "skirt_bg", up_img = "skirt_up"  }, --裙子
    [12] = {name = "ste_colth_0012", armoire = 13, img = "eyeshadow_img", up_img = "eyeshadow_up"}, --眼妆
    [13] = {name = "ste_colth_0013", armoire = 13, img = "eyes_img"}, --美瞳
    [14] = {name = "ste_colth_0014", armoire = 13, img = "blush_img"}, --腮红
    [15] = {name = "ste_colth_0015", armoire = 13, img = "mouth_img"}, --唇色
    [16] = {name = "ste_colth_0016", armoire = 13, img = "flower_img"}, --花钿
    [17] = {name = "ste_colth_0017", armoire = 13, img = "face_img"}, --脸饰
    [18] = {name = "ste_colth_0018", armoire = 8, img = "hand_img_1", bg_img = "hand_bg", up_img = "hand_up"}, --手杖
}

--关卡服装顺序
M.STAGE_CLOTHES_TYPE = {
    {armoire = 2, str = "ste_colth_0002"}, --上装
    {armoire = 3, str = "ste_colth_0004"}, --下装
    {armoire = 3, str = "ste_colth_0006"}, --鞋子
    {armoire = 1, str = "ste_colth_0013"}, --发型
    {armoire = 5, str = "ste_colth_0014"}, --饰品
}

--[[
    属性id表 {"atk", "hp", "def", "dodge", "critrate", "hr", "res", "atd", "resi", "sunder"}
    与common表的战力参数对应
]]
M.ATTRS_TAB = {
    [1] = "atk", 
    [2] = "hp", 
    [3] = "def", 
    [4] = "dodge", 
    [5] = "critrate", 
    [6] = "hr", 
    [7] = "res", 
    [8] = "atd", 
    [9] =  "resi", 
    [10] = "sunder", 
    [12] =  "magicdamage",
    [13] =  "physicaldamage",
    [14] =  "cdup",
}

-- 常用颜色
M.COMMON_COLLOR = {
    COMMON_1 = Color( 239/255, 234/255, 222/255),
    COMMON_2 = Color( 255/255, 222/255, 0/255),
    COMMON_3 = Color( 0/255, 0/255, 0/255),
    COMMON_4 = Color( 102/255, 244/255, 112/255),
    COMMON_5 = Color( 245/255, 209/255, 129/255),
    COMMON_6 = Color( 57/255, 40/255, 18/255),
    COMMON_7 = Color( 130/255, 173/255, 237/255),
    COMMON_8 = Color( 252/255, 87/255, 209/255),
    COMMON_9 = Color( 233/255, 64/255, 41/255),
    COMMON_10 = Color( 199/255, 76/255, 38/255),
    COMMON_11 = Color( 1/255, 131/255, 74/255),
    COMMON_12 = Color( 197/255, 193/255, 160/255),
    COMMON_13 = Color( 68/255, 84/255, 59/255),
    COMMON_14 = Color( 102/255, 244/255, 112/255),
    COMMON_15 = Color( 157/255, 226/255, 255/255),
    COMMON_16 = Color( 153/255, 153/255, 153/255),
    COMMON_17 = Color( 184/255, 219/255, 197/255),
    COMMON_18 = Color( 228/255, 237/255, 196/255),
}

-- 描边常用颜色
M.COMMON_COLLOR_OUTLINE = {
    COMMON_1 = Color( 239/255, 234/255, 222/255, 100/255),
    COMMON_2 = Color( 255/255, 222/255, 0/255, 100/255),
    COMMON_3 = Color( 0/255, 0/255, 0/255, 100/255),
    COMMON_4 = Color( 102/255, 244/255, 112/255, 100/255),
    COMMON_5 = Color( 245/255, 209/255, 129/255, 100/255),
    COMMON_6 = Color( 57/255, 40/255, 18/255, 100/255),
    COMMON_7 = Color( 130/255, 173/255, 237/255, 100/255),
    COMMON_8 = Color( 252/255, 87/255, 209/255, 100/255),
    COMMON_9 = Color( 233/255, 64/255, 41/255, 100/255),
    COMMON_10 = Color( 199/255, 76/255, 38/255, 100/255),
    COMMON_11 = Color( 1/255, 131/255, 74/255, 100/255),
    COMMON_12 = Color( 197/255, 193/255, 160/255, 100/255),
    COMMON_13 = Color( 68/255, 84/255, 59/255, 100/255),
    COMMON_14 = Color( 102/255, 244/255, 112/255, 100/255),
    COMMON_15 = Color( 157/255, 226/255, 255/255, 100/255),
    COMMON_16 = Color( 153/255, 153/255, 153/255, 100/255),
    COMMON_17 = Color( 184/255, 219/255, 197/255, 100/255),
    COMMON_18 = Color( 228/255, 237/255, 196/255, 100/255),
}

--
M.BOUNTY_RANK = {
    { name = "new_str_0102", RGBA = Color.New(153/255, 255/255, 43/255) }, --绿
    { name = "new_str_0103", RGBA = Color.New(128/255, 215/255, 255/255) }, --蓝
    { name = "new_str_0104", RGBA = Color.New(250/255, 165/255, 244/255)  }, --紫
    { name = "new_str_0105", RGBA = Color.New(255/255, 232/255, 90/255) }, --橙
    { name = "new_str_0106", RGBA = Color.New(255/255, 0/255, 0/255) }, --红
    { name = "new_str_0101", RGBA = Color.New(1, 1, 1) }, --白
}

M.RANK_TOP_THREE_IMG = {
    [1] = {rank = "a_ui_phb_1", atlas = "common_ui"},
    [2] = {rank = "a_ui_phb_2", atlas = "common_ui"},
    [3] = {rank = "a_ui_phb_3", atlas = "common_ui"},
}

-- 0: 女  1: 男  -1: 未设置
M.GENDER_CFG = {
    [0] = {icon = "tjl_nvxing", atlas = "common_ui", name = "new_str_0213"},
    [1] = {icon = "tjl_nanxing", atlas = "common_ui", name = "new_str_0212"},
}

-- 联盟职位
M.UNION_POS = {
    PRESIDENT = 1, -- 会长
    PRESIDENT_VICE = 2, -- 副会长
    COMMON = 3, -- 普通
}

-- 对成员的操作
M.UNION_HANDLE_ID = {
    PROMOTE_ELDER = 1, -- 提升到副会长
    CHANGE_ELITE = 2, -- 提升到无谓之手
    DEMOTE = 3, -- 撤销副会长
    DELETE = 4,  -- 提出公会
    BLACK = 5, -- 加入黑名单
}

-- 联盟职位操作
M.UNION_POS_HANDLE = {
    [M.UNION_POS.PRESIDENT] = {
        [M.UNION_POS.PRESIDENT] = {M.UNION_HANDLE_ID.CHANGE_ELITE},
        [M.UNION_POS.PRESIDENT_VICE] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DEMOTE, M.UNION_HANDLE_ID.DELETE},
        [M.UNION_POS.COMMON] = {M.UNION_HANDLE_ID.PROMOTE_ELDER, M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DELETE},
    },
    [M.UNION_POS.PRESIDENT_VICE] = {
        [M.UNION_POS.PRESIDENT] = {M.UNION_HANDLE_ID.CHANGE_ELITE},
        [M.UNION_POS.PRESIDENT_VICE] = {M.UNION_HANDLE_ID.CHANGE_ELITE},
        [M.UNION_POS.COMMON] = {M.UNION_HANDLE_ID.CHANGE_ELITE, M.UNION_HANDLE_ID.DELETE},
    },
}

M.MYSTIC_TYPE = {
    EXTERNAL = 1,
    INTERNAL = 2,
    STEPS = 3,
    MASTER = 4,
}

-- 高阶竞技场段位颜色
M.ARENA_SEGMENT_COLLOR = {
    [1] = Color( 255/255, 216/255, 111/255),
    [2] = Color( 209/255, 231/255, 255/255),
    [3] = Color( 231/255, 236/255, 244/255),
    [4] = Color( 230/255, 242/255, 243/255),
    [5] = Color( 255/255, 226/255, 137/255),
    [6] = Color( 240/255, 255/255, 252/255),
    [7] = Color( 210/255, 250/255, 241/255),
    [8] = Color( 252/255, 255/255, 255/255),
}

M.PACKAGE_POP_TYPE = {
    OPEN_POS = 1,
    SELL = 2,
}

--计算计分步骤
M.SETTLEMENT_STEP = {
	{clothes_sort = {1}, index = 1, name = "ste_colth_0001", pos = Vector2(13, -580)}, --发型
	{clothes_sort = {7}, index = 2, name = "ste_colth_0007", pos = Vector2(13, -550)}, --头饰
    {clothes_sort = {12,13,14,15,16,17}, index = 3, name = "ste_colth_0019", pos = Vector2(13, -550)}, --妆容
	{clothes_sort = {8}, index = 4, name = "ste_colth_0008", pos = Vector2(13, -550)}, --耳饰
	{clothes_sort = {9}, index = 5, name = "ste_colth_0009", pos = Vector2(13, -530)}, --项链
	{clothes_sort = {3}, index = 6, name = "ste_colth_0003", pos = Vector2(13, -500)}, --外套
	{clothes_sort = {11}, index = 7, name = "ste_colth_0011", pos = Vector2(13, -250)}, --连衣裙
	{clothes_sort = {2}, index = 8, name = "ste_colth_0002", pos = Vector2(13, -400)}, --上衣
	{clothes_sort = {4}, index = 9, name = "ste_colth_0004", pos = Vector2(13, 180)}, --下衣
    {clothes_sort = {10}, index = 10, name = "ste_colth_0020", pos = Vector2(13, -150)}, --手饰
    {clothes_sort = {18}, index = 11, name = "ste_colth_0018", pos = Vector2(13, -150)}, --手持物
	{clothes_sort = {5}, index = 12, name = "ste_colth_0005", pos = Vector2(13, 320)}, --袜子
    {clothes_sort = {6}, index = 13, name = "ste_colth_0006", pos = Vector2(13, 400)}, --鞋子
    {clothes_sort = {}, index = 14, name = "ste_colth_0039", pos = Vector2(13, -100), scale = Vector2(1.25, 1.25)}, --背景
}

M.COLOR = {
    {img = "icon_mfsl_yts_1", color = Color(1, 0.854902, 0.2705882,1)},
    {img = "icon_mfsl_yts_2", color = Color(0.9176471, 0.427451, 0.4117647,1)},
    {img = "icon_mfsl_yts_3", color = Color(0.9529412, 0.8588235, 0.509804,1)},
    {img = "icon_mfsl_yts_4", color = Color(0.3411765, 0.8705882, 0.6,1)},
    {img = "icon_mfsl_yts_5", color = Color(0.4078431, 0.7176471, 0.8901961,1)},
    {img = "icon_mfsl_yts_6", color = Color(0.654902, 0.3372549, 0.8784314,1)},
}

M.LANGUAGE_TYPE = {
    [1] = "ChineseSimplified",
    [2] = "ChineseTraditional",
}

M.TYPE_MONEY = {
    {name = "CNY", sign_name = "¥",},
    {name = "USD", sign_name = "$",},
    {name = "GBP", sign_name = "£",},
    {name = "EUR", sign_name = "€",},
    {name = "KRW", sign_name = "₩",},
    {name = "RUB", sign_name = "₽",},
    {name = "INR", sign_name = "₹",},
    {name = "THB", sign_name = "฿",},
    {name = "VND", sign_name = "₫",},
    {name = "HKD", sign_name = "HK$",},
    {name = "TWD", sign_name = "NT$",},
    {name = "SGD", sign_name = "S$",},
    {name = "MYR", sign_name = "RM",},
    {name = "MOP", sign_name = "MOP$",},
    {name = "JPY", sign_name = "¥",},
    {name = "PHP", sign_name = "₱",},
    {name = "CAD", sign_name = "C$",},
}

M.CLOTHES_LIST_TYPE = {
    [1] = "Stage",
    [2] = "TShow",
    [3] = "Appointment",
}

M.CHINESE_NUM_LAN = {"num_str_0000", "num_str_0001", "num_str_0002", "num_str_0003", "num_str_0004", "num_str_0005", "num_str_0006", "num_str_0007", "num_str_0008", "num_str_0009"}
M.CHINESE_UNIT_LAN = {"", "unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0004", "unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0005","unit_num_str_0001", "unit_num_str_0002", "unit_num_str_0003", "unit_num_str_0004"}

return M