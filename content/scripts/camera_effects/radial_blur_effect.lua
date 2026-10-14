local RadialBlurEffect = {}
RadialBlurEffect.__index = RadialBlurEffect

------------------------------------------------
-- DPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(RadialBlurEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function RadialBlurEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, RadialBlurEffect)
    
    -- Target intensity
    effect.m_target_intensity = 0.0
    
    return effect
end

------------------------------------------------

function RadialBlurEffect:init(t_id, t_intensity, t_fade_in, t_duration, t_fade_out)
    -- Initialize radial blur effect properties
    self.m_id = t_id
    self.m_amount = t_intensity
    self.m_max_amount = t_intensity
    self.m_target_intensity = t_intensity
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

function RadialBlurEffect:late_process(t_delta_time)
    BaseEffect.process_fade(self, t_delta_time)
end

------------------------------------------------

function RadialBlurEffect:get_intensity()
    return self.m_amount * self.m_multiplier
end

------------------------------------------------

function RadialBlurEffect:set_intensity(t_intensity)
    self.m_amount = t_intensity
    self.m_target_intensity = t_intensity
end

------------------------------------------------

return RadialBlurEffect
