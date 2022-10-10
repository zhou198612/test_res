------------- GameVersionConfig

local M = {
	-- 游戏版本
	CLIENT_VERSION = "1.0.05",

	-- 游戏资源版本
	GAME_RESOURCES_VERION = "t1.0.065",

	-- uid登录
	SHOW_UID_LOGIN_BTN = false,
	UID_LOGIN_FRONTWINDOW = "5e3b4530b293b5c1f4eeca4638ab4dc1",

	-- 开发入口服务器   
	--SERVER_LIST_URL_NET = "http://49.233.43.174/fashion_girl_dev",
	--SERVER_LIST_URL_CN = "http://49.233.43.174/fashion_girl_dev",

	-- czg
	--SERVER_LIST_URL_NET = "http://10.89.130.20:80/fashion_girl_dev",
	--SERVER_LIST_URL_CN = "http://10.89.130.20:80/fashion_girl_dev",

	--SERVER_LIST_URL_NET = "http://10.89.130.20:80/fashion_girl_dev",
	--SERVER_LIST_URL_CN = "http://10.89.130.20:80/fashion_girl_dev",


	-- 正式服入口服务器   
	-- SERVER_LIST_URL_NET = "http://120.53.222.46/fashion_girl_release",
	-- SERVER_LIST_URL_CN = "http://120.53.222.46/fashion_girl_release",

	-- 版署服务器
	-- SERVER_LIST_URL_NET = "http://49.233.46.162/fashion_girl_edition",
	-- SERVER_LIST_URL_CN = "http://49.233.46.162/fashion_girl_edition",
	
	
	SERVER_CHAT_URL = "49.233.43.174",
	SERVER_CHAT_PORT = 9050,
	LUA_ROOT_PATH = "D:\\WorkSpace\\Project_new\\zmhx\\ResProject\\Assets\\StreamingAssets\\";
	Debug = true,
	LUA_RELOAD_DEBUG = true,
	SERVICE_URL = nil, -- 需要用户选服时设置
	OPEN_BATTLE_LOG = false,
	IS_SERVER = false,
	IS_TENCENT_TEST = false,
	DOWN_LATER_ZIP = false, --false:没有拆分后期资源  true:有后期资源下载
	PAY_TEST = true, -- 模拟支付
	vcd=1,

	--dev
	 PORTAL_SERVER_ADDRESS_NET = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_dev.json",
	 PORTAL_SERVER_ADDRESS_CN = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_dev.json",

	--正式服
	--PORTAL_SERVER_ADDRESS_NET = "http://ssnw-cdn.kingsoft.com/entrance/android.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://ssnw-cdn.kingsoft.com/entrance/android.json",

	--czg
	--PORTAL_SERVER_ADDRESS_NET = "http://ssnw-cdn.kingsoft.com/entrance/czg.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://ssnw-cdn.kingsoft.com/entrance/czg.json",

	--审核服
	--PORTAL_SERVER_ADDRESS_NET = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_edition.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_edition.json",

	--dev2
	--PORTAL_SERVER_ADDRESS_NET = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_cehua.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://ssnw-cdn.kingsoft.com/entrance/fashion_girl_cehua.json",
}

-- 入口地址
--M.MASTER_URL = M.SERVER_LIST_URL_NET
M.PORTAL_SERVER_ADDRESS_URL = M.PORTAL_SERVER_ADDRESS_NET

return M

