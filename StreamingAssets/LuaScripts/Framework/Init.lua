Mathf		= require("Framework.UnityEngine.Mathf")
Vector2		= require("Framework.UnityEngine.Vector2")
Vector3 	= require("Framework.UnityEngine.Vector3")
Vector4		= require("Framework.UnityEngine.Vector4")
Quaternion	= require("Framework.UnityEngine.Quaternion")
Color		= require("Framework.UnityEngine.Color")
ColorHexHelper		= require("Framework.UnityEngine.ColorHexHelper")
Ray			= require("Framework.UnityEngine.Ray")
Bounds		= require("Framework.UnityEngine.Bounds")
RaycastHit	= require("Framework.UnityEngine.RaycastHit")
Touch		= require("Framework.UnityEngine.Touch")
LayerMask	= require("Framework.UnityEngine.LayerMask")
Plane		= require("Framework.UnityEngine.Plane")
Time		= require("Framework.UnityEngine.Time")
if GameVersionConfig.IS_SERVER == false then
	LuaCSharpArr = require("Framework.LuaCSharpArr")
end
require("Framework.UnityEngine.Object")

require("Framework.Commom.Functions")
require("Framework.Commom.IoUtil")
require("Framework.Commom.StringUtil")
require("Framework.Commom.TableUtil")
Utf8 = require("Framework.Commom.Utf8")
Logger = require("Framework.Commom.Logger")
TimeUtil = require("Framework.Commom.TimeUtil")
Json = require("Framework.Commom.Json")

EventDispatcher = require("Framework.Commom.EventDispatcher")
if GameVersionConfig.IS_SERVER == false then
	UIUtil = require("Framework.Commom.UIUtil")
	LuaBehaviourUtil = require("Framework.Commom.LuaBehaviourUtil")
	LikeOO = {}
	LikeOO.OOMsgList = require("Framework.LikeOO.OOMsgList")
	LikeOO.OOStack = require("Framework.LikeOO.OOStack")
	LikeOO.OOControlBase = require("Framework.LikeOO.OOControlBase")
	LikeOO.OODataBase = require("Framework.LikeOO.OODataBase")
	LikeOO.OOViewBase = require("Framework.LikeOO.OOViewBase")
	LikeOO.OOPopBase = require("Framework.LikeOO.OOPopBase")
	LikeOO.OOSceneBase = require("Framework.LikeOO.OOSceneBase")
	LikeOO.OOUIbase = require("Framework.LikeOO.OOUIbase")
	LikeOO.OOGuideBase = require("Framework.LikeOO.OOGuideBase")
end

--加载场景管理

--表池类
TablePoolUtil = require("Util.TablePoolUtil")
TablePoolUtil:init();

function LuaReload( moduleName )
    package.loaded[moduleName] = nil
    return require(moduleName)
end

function CustomRequire( moduleName )
	if GameVersionConfig.LUA_RELOAD_DEBUG then
		return LuaReload(moduleName)
	else
		return require(moduleName)
	end
end