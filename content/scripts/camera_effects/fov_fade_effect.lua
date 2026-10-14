local FovFadeEffect = {}
FovFadeEffect.__index = FovFadeEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")

setmetatable(FovFadeEffect, { __index = BaseEffect })

------------------------------------------------

function FovFadeEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, FovFadeEffect)
    
    -- FOV multiplier
    effect.m_fov_multiplier = 1.0
    return effect
end

------------------------------------------------

function FovFadeEffect:init(t_id, t_fov_multiplier, t_fade_in, t_duration, t_fade_out)
    -- Initialize fov fade effect properties
    self.m_id = t_id
    self.m_amount = t_fov_multiplier
    self.m_max_amount = t_fov_multiplier
    self.m_fade_in_time = 0.0
    self.m_duration = t_duration
    self.m_fade_out_time = 0.0
    self.m_max_fade_in_time = t_fade_in
    self.m_max_fade_out_time = t_fade_out
    self.m_time_elapsed = 0.0
    self.m_multiplier = 0.0
    self.m_state = BaseEffect.STATE_FADE_IN
end

------------------------------------------------

function FovFadeEffect:late_process(t_delta_time)
    -- Process fade. 
    -- Use late process to ensure fov multiplier is updated after fade. 
    BaseEffect.process_fade(self, t_delta_time)
    
    -- Lerp the fov multiplier.
    self.m_fov_multiplier = math_lerp(1.0, self.m_amount, self.m_multiplier)
end

------------------------------------------------

function FovFadeEffect:get_fov_multiplier()
    return self.m_fov_multiplier
end

------------------------------------------------

function FovFadeEffect:set_fov_multiplier(t_multiplier)
    self.m_amount = t_multiplier
end

------------------------------------------------

return FovFadeEffect
