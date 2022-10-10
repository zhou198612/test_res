GameMain = {}

-- 重加载白名单
local __ResourcesHelper = CS.wt.framework.ResourcesHelper
local __SpriteAtlasHelper = CS.wt.framework.SpriteAtlasHelper
local __PoolManager = CS.wt.framework.PoolManager
local LuaFileHelper = CS.wt.framework.LuaFileHelper.Inst
local _reload_white_map = {
    _G = true,
    coroutine = true,
    io = true,
    table = true,
    string = true,
    debug = true,
    utf8 = true,
    math = true,
    package = true,
    os = true,
}
local _updateFunctionTab = {}
GameMain.download_game_resources = false

function GameMain.start()
    GameMain.download_game_resources = false
    GameVersionConfig = require("Start.GameVersionConfig")
    U3DUtil = require("Util.U3DUtil")
    U3DUtil:init()
    local client_verion = U3DUtil:PlayerPrefs_GetString("client_verion")
    if client_verion ~= tostring(GameVersionConfig.CLIENT_VERSION) then--覆盖更新,删除老版本下载的资源
        -- TODO : 删除热更目录下的资源
        print("删除热更目录下的资源")
        if U3DUtil:Is_Platform("OSXEditor") == false and U3DUtil:Is_Platform("WindowsEditor") == false then
            LuaFileHelper:DeleteDir("Bundles", true)
            LuaFileHelper:DeleteDir("LuaScripts", true)
            LuaFileHelper:DeleteDir("unpacking", true)
        end
        U3DUtil:PlayerPrefs_SetString("game_resources_verion",tostring(GameVersionConfig.GAME_RESOURCES_VERION))
        U3DUtil:PlayerPrefs_SetString("client_verion",tostring(GameVersionConfig.CLIENT_VERSION))
    end
    GameVersionConfig.GAME_RESOURCES_VERION = U3DUtil:PlayerPrefs_GetString("game_resources_verion",GameVersionConfig.GAME_RESOURCES_VERION) or GameVersionConfig.GAME_RESOURCES_VERION
    -- __ResourcesHelper.moveConfigVersionFile()
    GameMain.init()
    -- audio:SendEvtBGM('play_city_bgm')
    Logger.log(LuaFileHelper:GetReadAndWritePath(), "LuaFileHelper:GetReadAndWritePath()-->")
    if GameVersionConfig.OPEN_SR_DEBUG then
        CS.LuaGameLaunch.Instance:OpenSRDebug()
    end
end

function GameMain.init()
    require("Start.Init")
    GameMain.initFont()
    _updateFunctionTab = {}

    ResourceUtil:PreloadAtlas("login_ui")
    ResourceUtil:PreloadAtlas("mail_ui")
    ResourceUtil:PreloadAtlas("language_ZH_CN")
    ResourceUtil:PreloadAtlas("language_ZH_TC")
    ResourceUtil:PreloadAtlas("common_ui")
    SDKUtil:getPlatform(function()
        LikeOO.OOControlBase:openView("Login")
        --local screen_effect = require("UI.Common.ScreenClickEffect")
        --GameMain.screen_effect = screen_effect.new(nil, {parent = static_root_node})
    end)
end

-- 初始化字体
function GameMain.initFont()
    U3DUtil:Set_Font();
end

-- 初始化声音
function GameMain.initSound()
    audio:init()
end

-- 初始化游戏画质,1底画质 2高画质
function GameMain.initPictureQuality()
    local flag = U3DUtil:PlayerPrefs_GetInt("picture_quality", 2)
    GameMain.setPictureQuality(flag)
end

-- 设置画质品质高低
function GameMain.setPictureQuality(flag)
    CS.zmhx.PhoneHelper.SetUnAutoPhoneLevel(flag);
end

function GameMain.reStart()
    if static_rootControl then
        static_rootControl:closeAllViewPop()
        static_rootControl:openView("Splash.RestartSplash")
    else
        LikeOO.OOControlBase:openView("Splash.RestartSplash")
    end
end

function GameMain.update(dt, unsdt)
	for k,v in pairs(_updateFunctionTab) do
        if v.available then
            v.func(dt, unsdt)
        end
	end
    for k,v in pairs(_updateFunctionTab) do
        if not v.available then
            _updateFunctionTab[k] = nil
        end
    end

    if SceneManager ~= nil then
        SceneManager:update(dt, unsdt)
    end
end

function GameMain.fixedUpdate(fdt)
    if SceneManager ~= nil then
        --Logger.log(" fdt -------- >>>> [ "..fdt.." ]");
        SceneManager:fixedUpdate(fdt);
    end
end

function GameMain.lateUpdate(dt, unsdt)
    if SceneManager ~= nil then
        SceneManager:lateUpdate(dt, unsdt);
    end
end

function GameMain.onDestroy()
    
end

function GameMain.addUpdate(key, updateFunction)
    if not _updateFunctionTab[key] then
        _updateFunctionTab[key] = {name = key, func = updateFunction, available = true}
    else
        _updateFunctionTab[key].available = true;
        _updateFunctionTab[key].func = updateFunction
    end
end

function GameMain.removeUpdate(key)
    if _updateFunctionTab[key] then
        _updateFunctionTab[key].available = false
    end
end

function GameMain.removeAllUpdate()
    _updateFunctionTab = {}
end

function GameMain.hasUpdate(key)
    return _updateFunctionTab[key] ~= nil
end

function GameMain.onApplicationQuit()
    Logger.log("OnApplicationQuit")
end

local enter_background_time = os.time()

function GameMain.onApplicationFocus(focus)
    Logger.log("OnApplicationFocus : " .. tostring(focus))
    EventDispatcher:dipatchEvent("onApplication", focus);
    if SceneManager ~= nil then
        if focus == true then
            local diff_time = os.time() - enter_background_time
            if EventDispatcher then
                EventDispatcher:addjustTimer(diff_time)
                EventDispatcher:dipatchEvent("background_time", {event = "background_time"});
            end
        else
            enter_background_time = os.time()
        end
    end
end

function GameMain.luaExceptionError(mssage, stack_trace)
    if GameUtil then
        GameUtil:sendLuaError(mssage, stack_trace)
    end
end

return GameMain