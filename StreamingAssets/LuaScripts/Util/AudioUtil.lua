

local M = {}
M.music_volume = GlobalConfig.MUSIC_VOLUME
M.effect_volume = GlobalConfig.SOUND_VOLUME

local __AudioHelper = CS.wt.framework.AudioHelper.Instance

function M:init()
	--self.music_volume = U3DUtil:PlayerPrefs_GetFloat("music_volume", self.music_volume)
	--self.effect_volume = U3DUtil:PlayerPrefs_GetFloat("effect_volume", self.effect_volume)
	--self:SetBusVol("Bgm",self.music_volume)
	--self:SetBusVol("CV",self.effect_volume)
	--self:SetBusVol("Skills",self.effect_volume)
    --self:SetBusVol("UI",self.effect_volume)
    self.m_skill_pause = false
    self.m_music_pause = false
end

function M:LoadBank(bank_name)
    __AudioHelper:LoadBank(bank_name)
end

function M:SendEvtSkill(event_name,bank_name)
    return __AudioHelper:PostEvtSkill(event_name,bank_name)
end 

function M:SendEvtUI(event_name)
    return __AudioHelper:PostEvtUI(event_name)
end 

function M:SendEvtGo(event_name,go)
    __AudioHelper:PostEvtGo(event_name)
end 

function M:SendEvtBGM(event_name,focus)
    focus = focus or false
    __AudioHelper:PostEvtBGM(event_name,focus)
end 

function M:StopAllSkills()
    __AudioHelper:StopAllSkills()
end

function M:SendEvtCV(event_name,role_name)
    return __AudioHelper:PostEvtCV(event_name,role_name)
end 

function M:SetBusVol(bus,vol)
    __AudioHelper:SetBusVol(bus,vol)
end

function M:PauseSkillsBusVol()
    if self.m_skill_pause == false then
        self:SetBusVol("Skills",0.0)
        self.m_skill_pause = true
    end
end

function M:ResumeSkillsBusVol()
    if self.m_skill_pause == true then
        self:SetBusVol("Skills",self.effect_volume)
        self.m_skill_pause = false
    end
end

function M:PauseMusicBusVol()
    if self.m_music_pause == false then
        self:SetBusVol("Bgm",0.0)
        self.m_music_pause = true
    end
end

function M:ResumeMusicBusVol()
    if self.m_music_pause == true then
        self:SetBusVol("Bgm",self.music_volume)
        self.m_music_pause = false
    end
end

function M:PlayFmodSound(soundName,bankName)
    local sound = __AudioHelper:PlayFmodSound(soundName,bankName)
    return sound
end


return M