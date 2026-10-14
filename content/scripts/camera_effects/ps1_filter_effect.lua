-- @NOTE: Custom post-process effect (pass 2, ps1_filter.frag.glsl). Applied by camera_effects_module.

local Ps1FilterEffect = {}
Ps1FilterEffect.__index = Ps1FilterEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(Ps1FilterEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function Ps1FilterEffect:new()
    local effect = BaseEffect:new()
    setmetatable(effect, Ps1FilterEffect)

    effect.m_target_intensity = 0.0

    return effect
end

------------------------------------------------

function Ps1FilterEffect:init(t_id, t_intensity, t_fade_in, t_duration, t_fade_out)
    -- Initialize ps1 filter effect properties
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

function Ps1FilterEffect:late_process(t_delta_time)
    -- Process fade. 
    -- Use late process to ensure intensity is updated after fade. 
    BaseEffect.process_fade(self, t_delta_time)
end

------------------------------------------------

function Ps1FilterEffect:get_intensity()
    return self.m_amount * self.m_multiplier
end

------------------------------------------------

function Ps1FilterEffect:set_intensity(t_intensity)
    self.m_amount = t_intensity
    self.m_target_intensity = t_intensity
end

------------------------------------------------

return Ps1FilterEffect
