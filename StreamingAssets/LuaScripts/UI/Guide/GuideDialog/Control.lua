local M = class("GuideDialogControl", LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_eventType == 2 then -- 做提示用
        	self.m_model.m_guide:doNextGuide()
        end
        self:closeView()
    elseif msg == "skip_btn" then
        local params = {
            on_ok_call = function(msg)
                UserDataManager.guide_data:skipCurGuide()
                self:closeView()
           end,
           no_close_btn = false,
           text = Language:getTextByKey("new_str_0034")
       }
       static_rootControl:openView("Pops.CommonPop", params);
    end
end

function M:onDestroy()
    if self.m_model.m_endCallFunc then
        self.m_model.m_endCallFunc()
    end
end

return M;