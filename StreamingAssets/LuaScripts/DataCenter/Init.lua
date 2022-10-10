GlobalConfig = require("DataCenter.GlobalConfig")
ConfigManager = require("DataCenter.ConfigManager")
ConfigManager:init()
if GameVersionConfig.IS_SERVER == false then
    Language = require("DataCenter.Language")
    Language:init()
end
UserDataManager = require("DataCenter.UserDataManager")
UserDataManager:init()
BtnSoundConfig = require("DataCenter.BtnSoundConfig")