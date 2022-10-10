------------------- AnimUtil

local M = {}

function M:setSpine(spine_obj, spine_name, spine_ab)
    if not IsNull(spine_obj) then
        local sg = spine_obj:GetComponent("SkeletonGraphic")
        local skeletonDataAsset = ResourceUtil:GetSk(spine_name, spine_ab)
        sg.skeletonDataAsset = skeletonDataAsset
        sg:Initialize(true)
        return sg
    end
end

function M:setSpineAnimation(spine_obj, track_index, animation_name, loop)
    if not IsNull(spine_obj) then
        if loop == nil then
            loop = true
        end
        local sg = spine_obj:GetComponent("SkeletonGraphic")
        sg.AnimationState:SetAnimation(track_index or 0, animation_name or "animation", loop)
        return sg
    end
end

return M
