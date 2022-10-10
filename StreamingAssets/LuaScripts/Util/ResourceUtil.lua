------------------- ResourceUtil

local M = {}

local __PoolManager = CS.wt.framework.PoolManager.Inst
local __SpriteAtlasHelper = CS.wt.framework.SpriteAtlasHelper
local __ResourcesHelper = CS.wt.framework.ResourcesHelper
local __AssetLoaderHelper = CS.wt.framework.AssetLoaderHelper.Inst
local __AssetBundleHelper = nil;
local useAssetBundle = __ResourcesHelper.useAssetBundle
if useAssetBundle then
    __AssetBundleHelper = CS.wt.framework.AssetBundleHelper.Inst
end
function M:GetUIItem(name, parent, ab_name)
    if useAssetBundle then
        return __PoolManager:GetItem(name, parent, string.lower(ab_name))
    else
        return __PoolManager:GetItemFromRes("UI/" .. name, parent, string.lower(ab_name))
    end
end

-- pool_type 池的类型
-- common 通用的
-- hero   专门的英雄池
-- enemy  专门的敌人池 
function M:GetItem(name, parent, ab_name)
    if useAssetBundle then
        return __PoolManager:GetItem(name, parent, string.lower(ab_name))
    else
        return __PoolManager:GetItemFromRes(name, parent, string.lower(ab_name))
    end
end

-- 异步加载池中物体
function M:GetItemAsync(name, parent, ab_name, pool_type, loadFinish)
    if useAssetBundle then
        __PoolManager:GetItemAsync(name, parent, string.lower(ab_name),pool_type, loadFinish);
    else
        __PoolManager:GetItemFromResAsync(name, parent, string.lower(ab_name),pool_type, loadFinish);
    end
end

--清除掉整个bundle中的预制体
function M:UnLoadBundlePrefab( bundleName )
    __AssetLoaderHelper:UnLoadBundlePrefab(bundleName);
end


-- 卸载bundle
function M:UnLoadBundle(name, isForce)
    if useAssetBundle then
        __AssetBundleHelper:Unload(name, isForce);
    end
end

function M:clearHeroItem( hero_name )
    if useAssetBundle then
        __PoolManager:ClearHeroItems(hero_name);
    end
end


function M:ReturnItem(obj, pool_type)
    if pool_type == nil then
        pool_type = "common";
    end
    return __PoolManager:ReturnItem(obj, pool_type)
end


function M:DestroyInstance( inst, bundleName )
    __AssetLoaderHelper:DestoryInstance(inst, bundleName)
end


function M:ClearItem()
    __PoolManager:ClearItem()
end

function M:LoadFont(name, ab_name)
    return __ResourcesHelper.LoadFont(name, string.lower(ab_name))
end

function M:LoadAnim(name, ab_name)
    return __ResourcesHelper.LoadAnim(name, string.lower(ab_name))
end

function M:LoadUIGameObject(name, pos, parent)
    if useAssetBundle then
        return __ResourcesHelper.LoadUIGameObject(name, pos, parent)
    else
        return __ResourcesHelper.LoadFromRes("UI/" .. name, pos, parent)
    end
end

--tip:这个方法是异步的
--evt:加载结束时调用的方法 会返回 scene_name,flag
--flag: 自定义回调标记
function M:LoadScene(scene_name, evt, flag)
    if useAssetBundle then
        __ResourcesHelper.LoadScene(scene_name, evt, flag)
    else
        __ResourcesHelper.LoadSceneResource(scene_name, evt, flag)
    end
end

function M:LoadGameObjectAsync(prefabName, evt, flag)
    if useAssetBundle then
        __ResourcesHelper.LoadGameObjectAsync(prefabName, evt, flag)
    else
        __ResourcesHelper.LoadGameObjectResAsync(prefabName, evt, flag)
    end
end


function M:HasGameObject(name, ab_name)
    if useAssetBundle then
        return __ResourcesHelper.hasGameObject(name, string.lower(ab_name))
    else
        return __ResourcesHelper.hasGameObjectFromRes(name, string.lower(ab_name))
    end
end

function M:PreloadAtlas(atlas_name)
    if useAssetBundle then
        return __SpriteAtlasHelper.Preload( atlas_name)
    else
        return __SpriteAtlasHelper.Preload( "Atlas/"..atlas_name)
    end
end
--[[
    atlas_name 和 ab 一致
]]
function M:GetSprite(name, atlas_name)
    if useAssetBundle then
        return __SpriteAtlasHelper.GetSprite(name, atlas_name, useAssetBundle)
    else
        return __SpriteAtlasHelper.GetSprite(name, "Atlas/"..atlas_name, useAssetBundle)
    end
end

function M:GetSk(name, ab_name)
    return __ResourcesHelper.GetSk("GirlSpine/" .. name, string.lower(ab_name))
end

function M:LoadSprite(name, ab_name)
    return __ResourcesHelper.LoadSprite(name, string.lower(ab_name))
end

function  M:LoadAllSprite(name, child)
    local sprite = __ResourcesHelper.LoadMultipleSpriteFromRes(name, child)
    return sprite
end

function M:LoadRole3d(prefab_name, parent)
    local name_path = string.split(prefab_name,"/")
    local name = name_path[2]
    local obj = self:GetItem( "Role3d/".. name .. "/" .. name, parent, "role3d_" .. string.lower(name))
    return obj
end

--异步加载人物
function M:LoadRole3dAsync(prefab_name, parent, pool_type, loadFinish)
    local name_path = string.split(prefab_name,"/")
    local name = name_path[2]
    self:GetItemAsync( "Role3d/".. name .. "/" .. name, parent, "role3d_" .. string.lower(name), pool_type, loadFinish)
end


function M:LoadRole3dShow(prefab_name, parent)
    local name_path = string.split(prefab_name,"/")
    local name = name_path[2]
    if name == nil then
        name = prefab_name;
    end
    local obj = self:GetItem( "Role3d/".. name .. "/" .. name.."Show", parent, "role3d_" .. string.lower(name))
    return obj
end


function M:LoadRole3dEffect(player_name,prefab_name, parent)
    local effect = self:LoadCommonEffect(prefab_name, parent)
    if effect == nil then
        effect = self:GetItem("Role3d/"..player_name.."/VFX/"..prefab_name, parent, "role3d_"..string.lower(player_name) )
    end
    return effect
end

function M:LoadRole3dBullet(player_name,prefab_name, parent)
    local effect = self:LoadCommon(prefab_name, parent)
    if effect == nil then
        effect = self:GetItem("Role3d/"..player_name.."/Bullet/"..prefab_name, parent, "role3d_"..string.lower(player_name) )
    end
    return effect
end

function M:LoadRole3dBulletAsync(player_name, prefab_name, parent, pool_type, loadFinish)
    local prefabName = "Role3d/".. player_name .. "/Bullet/"..prefab_name;
    local ab_name = "role3d_" .. string.lower(player_name);
    self:GetItemAsync( prefabName, parent, ab_name, pool_type, loadFinish)
end

function M:LoadCommonEffectAsync(prefab_name, parent,loadFinish)
    if self:HasGameObject("CommonEffect/"..prefab_name,"commoneffect") then
        self:GetItemAsync("CommonEffect/"..prefab_name, parent, "commoneffect","common",loadFinish )
    end
end


function M:LoadCommonEffect(prefab_name, parent)
    local effect = nil
    if self:HasGameObject("CommonEffect/"..prefab_name,"commoneffect") then
        effect = self:GetItem("CommonEffect/"..prefab_name, parent, "commoneffect" )
    end
    return effect
end

function M:LoadCommon(prefab_name, parent)
    local effect = nil
    if self:HasGameObject("Common/"..prefab_name,"common") then
        effect = self:GetItem("Common/"..prefab_name, parent, "common" )
    end
    return effect
end

function M:LoadRoleSound(name)

    if useAssetBundle then
        __ResourcesHelper.LoadRoleSound(name)
    else
        __ResourcesHelper.LoadRoleSoundRes(name)
    end
end

function M:UnLoadRoleSound(name)
    if useAssetBundle then
        __ResourcesHelper.UnLoadRoleSound(name)
    else
        __ResourcesHelper.UnLoadRoleSoundRes(name)
    end
end

function M:LoadCurves(name)
    if useAssetBundle then
        return __ResourcesHelper.LoadShakeCurve("role3d_"..string.lower(name))
    else
       return __ResourcesHelper.LoadShakeCurveRes(name)
    end
end

function M:LoadRoleCV(name)

    if useAssetBundle then
        __ResourcesHelper.LoadRoleCV(name)
    else
        __ResourcesHelper.LoadRoleCVRes(name)
    end
end

function M:UnLoadRoleCV(name)
    if useAssetBundle then
        __ResourcesHelper.UnLoadRoleCV(name)
    else
        __ResourcesHelper.UnLoadRoleCVRes(name)
    end
end

function M:createMaterial(name)
    return __ResourcesHelper.CreateMaterial(name)
end

function M:spriteAtlasRealClear()
    local print_log = GameVersionConfig and GameVersionConfig.Debug
    __SpriteAtlasHelper.RealClear(print_log)
end

function M:LoadAssetAllAsync(bundleName, callBack, loadProgress )
    if useAssetBundle then
        __AssetLoaderHelper:LoadAssetAllAsync(string.lower(bundleName), callBack, loadProgress)
    else
        callBack()
    end
end

function M:LoadAssetResAsync(bundleName, callBack)
    if useAssetBundle then
        __SpriteAtlasHelper.LoadSpriteAtlasAnsyc(string.lower(bundleName), true, callBack)
    else
        callBack()
    end
end

function M:UnLoadMemeroy()
    __ResourcesHelper.UnLoadMemeroy()
end

function M:luaGCStop()
    collectgarbage("stop")
end

function M:luaGCRestart()
    collectgarbage("restart")
end

function M:luaGCStep(n)
    local ret_step = collectgarbage("step", n)
    Logger.log(ret_step, "lua step return value : ")
end

function M:printLuaTotalMem()
    local count = collectgarbage("count") -- 以 KB 为单位
    local men_str = string.format("%0.2fMB", count/1024)
    Logger.log(men_str, "lua total memory : ")
end

function M:printMonoTotalMem()
    if __ResourcesHelper.GetMonoUsedSize then
        local count = __ResourcesHelper.GetMonoUsedSize() -- 以 Bytes 为单位
        local men_str = string.format("%0.2fMB", count/1048576)
        Logger.log(men_str, "mono total memory : ")
    end
end

function M:getLanAtlas()
    local cur_lan = Language:getCurLanguage()
    self.m_lan_atlas = "language_" .. cur_lan
    return self.m_lan_atlas
end

return M
