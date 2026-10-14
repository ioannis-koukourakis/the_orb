-- @NOTE: Custom post-process effect (pass 1, vignette.frag.glsl). Applied by camera_effects_module.

local VignetteEffect = {}
VignetteEffect.__index = VignetteEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(VignetteEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function VignetteEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, VignetteEffect)
    
    -- Target intensity and color
    effect.m_target_intensity = 0.0
    effect.m_color = vec3(0.0, 0.0, 0.0)
    
    return effect
end

------------------------------------------------

function VignetteEffect:init(t_id, t_intensity, t_color, t_fade_in, t_duration, t_fade_out)
    -- Initialize vignette effect properties
    self.m_id = t_id
    self.m_amount = t_intensity
    self.m_max_amount = t_intensity
    self.m_target_intensity = t_intensity
    self.m_color = t_color
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

function VignetteEffect:late_process(t_delta_time)
    BaseEffect.process_fade(self, t_delta_time)
end

------------------------------------------------

function VignetteEffect:get_intensity()
    return self.m_amount * self.m_multiplier
end

------------------------------------------------

function VignetteEffect:get_color()
    return self.m_color
end

------------------------------------------------

function VignetteEffect:set_intensity(t_intensity)
    self.m_amount = t_intensity
    self.m_target_intensity = t_intensity
end

------------------------------------------------

function VignetteEffect:set_color(t_color)
    self.m_color = t_color
end

------------------------------------------------

return VignetteEffect
