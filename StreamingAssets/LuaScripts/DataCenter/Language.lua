------------ Language
local M = {}

function M:init()
    local default_language = U3DUtil:PlayerPrefs_GetString("language_type")
    if (not default_language) or default_language == "" then
        self.m_system_language = U3DUtil:Get_SystemLanguage():ToString()
    else
        self.m_system_language = default_language
    end
    self:changeLanguage()
end

function M:changeLanguage()
    Logger.log("当前语言为 = " .. self.m_system_language)
    if self.m_system_language == "ChineseSimplified" or self.m_system_language == "Chinese" then
        self.m_cur_language = "ZH_CN"
        self.m_lang = require("DataCenter.Language.Language_ZH_CN")
        local lang = ConfigManager:getCfgByName("ZH_CN-1")
        for k,v in pairs(lang) do
            self.m_lang[k] = v
        end
    elseif self.m_system_language == "ChineseTraditional"then
        self.m_cur_language = "ZH_TC"
        self.m_lang = require("DataCenter.Language.Language_ZH_TC")
        local lang = ConfigManager:getCfgByName("ZH_TC-1")
        for k,v in pairs(lang) do
            self.m_lang[k] = v
        end
    else
        self.m_cur_language = "ZH_CN"
        self.m_lang = require("DataCenter.Language.Language_ZH_CN")
        local lang = ConfigManager:getCfgByName("ZH_CN-1")
        for k,v in pairs(lang) do
            self.m_lang[k] = v
        end
    end
end

function M:getTextByKey( key, arg1, ... )
    key = tostring(key)
    if arg1 then
        local format = self.m_lang[key]
        if format then
            return string.format( format, arg1, ... )
        else
            return key
        end
    else
        return self.m_lang[key] or key
    end
end

function M:getSystemLanguage()
    return self.m_system_language
end

function M:getCurLanguage()
    return self.m_cur_language
end

return M