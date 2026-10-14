local ScreenFadeEffect = {}
ScreenFadeEffect.__index = ScreenFadeEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(ScreenFadeEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function ScreenFadeEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, ScreenFadeEffect)
    
    -- Target intensity and color
    effect.m_target_intensity = 0.0
    effect.m_color = vec3(0.0, 0.0, 0.0)
    
    return effect
end

------------------------------------------------

function ScreenFadeEffect:init(t_id, t_intensity, t_color, t_fade_in, t_duration, t_fade_out)
    -- Initialize screen fade effect properties
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

function ScreenFadeEffect:late_process(t_delta_time)
    BaseEffect.process_fade(self, t_delta_time)
end

------------------------------------------------

function ScreenFadeEffect:get_intensity()
    return self.m_amount * self.m_multiplier
end

------------------------------------------------

function ScreenFadeEffect:get_color()
    return self.m_color
end

------------------------------------------------

function ScreenFadeEffect:set_intensity(t_intensity)
    self.m_amount = t_intensity
    self.m_target_intensity = t_intensity
end

------------------------------------------------

function ScreenFadeEffect:set_color(t_color)
    self.m_color = t_color
end

------------------------------------------------

function ScreenFadeEffect:set_fade_in_from_normalized_intensity(t_normalized_current, t_fade_in)
    local normalized_current = math_clamp(t_normalized_current, 0.0, 1.0)

    -- Set the multiplier and fade in time.
    self.m_multiplier = normalized_current
    self.m_fade_in_time = normalized_current * t_fade_in
    self.m_state = BaseEffect.STATE_FADE_IN
end

------------------------------------------------

function ScreenFadeEffect:set_fade_out_from_normalized_intensity(t_normalized_current)
    local normalized_current = math_clamp(t_normalized_current, 0.0, 1.0)

    -- Set the multiplier and fade out time.
    self.m_multiplier = normalized_current
    self.m_fade_out_start_multiplier = normalized_current
    self.m_state = BaseEffect.STATE_FADE_OUT
    self.m_fade_out_time = 0.0
    self.m_fade_in_time = self.m_max_fade_in_time
end

------------------------------------------------

return ScreenFadeEffect
