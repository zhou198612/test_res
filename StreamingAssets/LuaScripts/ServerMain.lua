--
-- Created by IntelliJ IDEA.
-- User: kongliang
-- Date: 2020/1/17
-- Time: 3:33 下午
-- To change this template use File | Settings | File Templates.


package.path = "../LuaScripts/?.lua";
print(package.path)

SceneManager = require("Battle.Sce.SceneManager")
--SocketTools = require("Battle.Tool.SocketTools")
GameVersionConfig = require("Start.GameVersionConfig")
GameVersionConfig.IS_SERVER = true;
require("Framework.Init")
require("DataCenter.Init")
U3DUtil = require("Util.U3DUtil")

ConfigManager:getCfgByName("hero_detail");
ConfigManager:getCfgByName("skill_detail");
ConfigManager:getCfgByName("heirloom");
ConfigManager:getCfgByName("deployment");
ConfigManager:getCfgByName("common");
ConfigManager:getCfgByName("artifact");
ConfigManager:getCfgByName("buff");
ConfigManager:getCfgByName("buff_effect");
ConfigManager:getCfgByName("world_boss");
ConfigManager:getCfgByName("world_boss_cycle");
ConfigManager:getCfgByName("stage");
ConfigManager:getCfgByName("stage_battle");

-- local data = require("Battle.serverData")
--local data = require("Battle.serverData2")
local yyy = '{"result":0,"status":0,"svr_ver":"","defend_score":1879,"pre_score":1284,"revenge":0,"pre_rank":4108,"battle_id":258720001,"rank":4119,"battle":{"common":{"defender_troop_ids":[],"attacker_user":{"uid":1048584,"frame":"","level":32,"gender":0,"guild_name":"墨染天下","avatar":"403","name":"闲鱼"},"param":0,"attacker_heirloom":[],"defender_user":{"uid":1048598,"frame":"","level":30,"gender":0,"guild_name":"墨染天下","avatar":"109","name":"怀铁入梦"},"seed":3051,"attacker_buffs":[],"defender_heirloom":[],"attacker_troop_ids":[],"defender_buffs":[],"seed_team":1},"output":{"rounds":[{"attacker_stats":{"406-1594779114-zWN4Vg":{"atk":73099,"hp":0,"cure":0,"def":44059,"rage":456},"403-1594798642-X9ShVT":{"atk":10041,"hp":0,"cure":0,"def":57972,"rage":824},"104-1594778907-jIqLdd":{"atk":1925,"hp":0,"cure":0,"def":27712,"rage":312},"105-1594793525-DBg0Cp":{"atk":4000,"hp":0,"cure":7396,"def":51138,"rage":728},"112-1594805529-eoMeVH":{"atk":2643,"hp":0,"cure":0,"def":37687,"rage":682}},"round":1,"defender_team":{"deployment":1,"team":["105-1594870161-LKxzhd","101-1594896549-VtVGkb","301-1594801791-yHG7np","109-1594821076-rKeoZy","303-1594780157-5pjLMk"],"dyns":[],"heros":{"301-1594801791-yHG7np":{"lv":81,"clv":0,"evo_hero":[],"attrs":{"def":248.1168,"atk":1360.8106,"hp":21261.848,"critrate":5},"skill":{"1":30112,"3":30131,"2":30122,"5":30151,"4":30141},"id":301,"lock":false,"oid":"301-1594801791-yHG7np","equips":{"1":{"exp":0,"lv":0,"oid":66,"amount":1,"race":0,"id":50301},"4":{"exp":0,"lv":0,"oid":105,"amount":1,"race":0,"id":50304},"3":{"exp":0,"lv":0,"oid":104,"amount":1,"race":0,"id":50303},"2":{"exp":0,"lv":0,"oid":67,"amount":1,"race":0,"id":50302}},"combat":14404,"sig":[],"evo":5,"artifact":[]},"105-1594870161-LKxzhd":{"lv":81,"clv":0,"evo_hero":[105],"attrs":{"def":335.655,"atk":1527.204,"hp":26181.825,"critrate":5},"skill":{"1":10512,"3":10531,"2":10522,"5":10551,"4":10541},"id":105,"lock":false,"oid":"105-1594870161-LKxzhd","equips":{"1":{"exp":0,"lv":0,"oid":93,"amount":1,"race":0,"id":30101},"4":{"exp":0,"lv":0,"oid":95,"amount":1,"race":0,"id":20104},"3":{"exp":0,"lv":0,"oid":86,"amount":1,"race":0,"id":30103},"2":{"exp":0,"lv":0,"oid":108,"amount":1,"race":0,"id":40102}},"combat":13827,"sig":[],"evo":6,"artifact":[]},"101-1594896549-VtVGkb":{"lv":81,"clv":0,"evo_hero":[],"attrs":{"def":290.6469,"atk":1452.8824,"hp":19135.724,"critrate":5},"skill":{"1":10112,"3":10131,"2":10122,"5":10151,"4":10141},"id":101,"lock":false,"oid":"101-1594896549-VtVGkb","equips":{"1":{"exp":0,"lv":0,"oid":110,"amount":1,"race":5,"id":50101},"4":{"exp":0,"lv":0,"oid":48,"amount":1,"race":0,"id":30104},"3":{"exp":0,"lv":0,"oid":70,"amount":1,"race":0,"id":30103},"2":{"exp":100,"lv":0,"oid":69,"amount":1,"race":0,"id":40102}},"combat":12718,"sig":[],"evo":5,"artifact":[]},"303-1594780157-5pjLMk":{"lv":81,"clv":0,"evo_hero":[],"attrs":{"def":248.1168,"atk":1665.5328,"hp":15238.4999,"critrate":5},"skill":{"1":30312,"3":30331,"2":30322,"5":30351,"4":30341},"id":303,"lock":false,"oid":"303-1594780157-5pjLMk","equips":{"1":{"exp":0,"lv":0,"oid":103,"amount":1,"race":5,"id":50201},"4":{"exp":0,"lv":0,"oid":109,"amount":1,"race":6,"id":50204},"3":{"exp":0,"lv":0,"oid":89,"amount":1,"race":0,"id":30203},"2":{"exp":0,"lv":0,"oid":106,"amount":1,"race":0,"id":40202}},"combat":13224,"sig":[],"evo":5,"artifact":[]},"109-1594821076-rKeoZy":{"lv":118,"clv":0,"evo_hero":[109],"attrs":{"def":682.943,"atk":4821.4489,"hp":45323.8171,"critrate":5},"skill":{"1":10912,"3":10931,"2":10923,"5":10951,"4":10941},"id":109,"lock":false,"oid":"109-1594821076-rKeoZy","equips":{"1":{"exp":0,"lv":4,"oid":27,"amount":1,"race":0,"id":50101},"4":{"exp":0,"lv":0,"oid":63,"amount":1,"race":0,"id":40104},"3":{"exp":0,"lv":0,"oid":73,"amount":1,"race":0,"id":40103},"2":{"exp":330,"lv":1,"oid":74,"amount":1,"race":0,"id":50102}},"combat":33677,"sig":[],"evo":8,"artifact":[]}}},"operations":[{"frame":267,"skillId":0,"id":109,"instance":"109-1594821076-rKeoZy"},{"frame":643,"skillId":0,"id":406,"instance":"406-1594779114-zWN4Vg"},{"frame":660,"skillId":0,"id":105,"instance":"105-1594870161-LKxzhd"},{"frame":681,"skillId":0,"id":303,"instance":"303-1594780157-5pjLMk"}],"frame":864,"result":0,"defender_stats":{"109-1594821076-rKeoZy":{"atk":221964,"hp":50091.389665,"cure":0,"def":9061,"rage":1000},"105-1594870161-LKxzhd":{"atk":5922,"hp":2952.09875,"cure":32334,"def":43670,"rage":215},"101-1594896549-VtVGkb":{"atk":2338,"hp":0,"cure":0,"def":55790,"rage":395},"303-1594780157-5pjLMk":{"atk":21270,"hp":17524.274885,"cure":0,"def":11770,"rage":85},"301-1594801791-yHG7np":{"atk":7661,"hp":19477.1252,"cure":8440,"def":12004,"rage":1000}},"attacker_team":{"deployment":1,"team":["104-1594778907-jIqLdd","112-1594805529-eoMeVH","105-1594793525-DBg0Cp","406-1594779114-zWN4Vg","403-1594798642-X9ShVT"],"dyns":[],"heros":{"406-1594779114-zWN4Vg":{"lv":93,"clv":0,"evo_hero":[406],"attrs":{"hr":44.2,"atk":3163.343,"hp":30858.7719,"dodge":24.8,"def":540.9196,"critrate":7},"skill":{"1":40612,"3":40631,"2":40622,"5":40651,"4":40641},"id":406,"lock":false,"oid":"406-1594779114-zWN4Vg","equips":{"1":{"exp":10,"lv":1,"oid":55,"amount":1,"race":0,"id":40201},"4":{"exp":0,"lv":0,"oid":54,"amount":1,"race":0,"id":30204},"3":{"exp":0,"lv":0,"oid":57,"amount":1,"race":0,"id":30203},"2":{"exp":0,"lv":0,"oid":64,"amount":1,"race":0,"id":40202}},"combat":21145,"sig":[],"evo":8,"artifact":[]},"403-1594798642-X9ShVT":{"lv":89,"clv":0,"evo_hero":[403],"attrs":{"hr":31,"atk":1957.5522,"hp":30699.1178,"dodge":15,"def":496.408,"critrate":5},"skill":{"1":40312,"3":40331,"2":40322,"5":40351,"4":40341},"id":403,"lock":false,"oid":"403-1594798642-X9ShVT","equips":{"1":{"exp":0,"lv":0,"oid":26,"amount":1,"race":0,"id":50101},"4":{"exp":0,"lv":0,"oid":31,"amount":1,"race":0,"id":30104},"3":{"exp":0,"lv":0,"oid":66,"amount":1,"race":0,"id":40103},"2":{"exp":0,"lv":0,"oid":73,"amount":1,"race":0,"id":40102}},"combat":16212,"sig":[],"evo":6,"artifact":[]},"104-1594778907-jIqLdd":{"lv":91,"clv":0,"evo_hero":[104],"attrs":{"hr":42,"atk":2283.1275,"hp":23585.425,"dodge":21,"def":406.7829,"critrate":5},"skill":{"1":10412,"3":10431,"2":10422,"5":10451,"4":10441},"id":104,"lock":false,"oid":"104-1594778907-jIqLdd","equips":{"1":{"exp":0,"lv":0,"oid":62,"amount":1,"race":3,"id":40201},"4":{"exp":0,"lv":0,"oid":39,"amount":1,"race":0,"id":30204},"3":{"exp":0,"lv":0,"oid":71,"amount":1,"race":0,"id":30203},"2":{"exp":0,"lv":0,"oid":56,"amount":1,"race":0,"id":30202}},"combat":15646,"sig":[],"evo":6,"artifact":[]},"105-1594793525-DBg0Cp":{"lv":91,"clv":0,"evo_hero":[181,183],"attrs":{"hr":47,"atk":2296.5454,"hp":39604.1606,"haste":2,"dodge":15,"def":637.0402,"critrate":5},"skill":{"1":10512,"3":10531,"2":10522,"5":10551,"4":10541},"id":105,"lock":false,"oid":"105-1594793525-DBg0Cp","equips":{"1":{"exp":0,"lv":0,"oid":76,"amount":1,"race":5,"id":50101},"4":{"exp":0,"lv":0,"oid":61,"amount":1,"race":4,"id":40104},"3":{"exp":0,"lv":0,"oid":63,"amount":1,"race":0,"id":50103},"2":{"exp":0,"lv":0,"oid":65,"amount":1,"race":0,"id":50102}},"combat":19955,"sig":[],"evo":7,"artifact":[]},"112-1594805529-eoMeVH":{"lv":1,"clv":89,"evo_hero":[112],"attrs":{"def":388.261,"atk":1714.136,"hp":29162.3076,"critrate":5},"skill":{"1":11211,"5":11251},"id":112,"lock":false,"oid":"112-1594805529-eoMeVH","equips":[],"combat":14331,"sig":[],"evo":6,"artifact":[]}}}}]},"sort":5},"score":1283,"log_time":1594907723,"defend_pre_score":1878,"user_info":{"uid":1048598,"name":"怀铁入梦","is_online":1,"avatar":"109","level":30,"last_active_time":1594907716,"vip":0,"server":1,"frame":"","stage":728,"full_combat":87850,"gender":0},"create_ts":1594907723,"change_score":-1}'
local data = Json.decode(yyy)
-- local data = require("Battle.serverData1")
--local data = require("Battle.battleXXX")

SceneManager:preLoad();
--SocketTools:beginTime("serverStart")
SceneManager:serverStart(data)
--SocketTools:endTime("serverStart")