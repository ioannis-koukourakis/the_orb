local ImageTrailEffect = {}
ImageTrailEffect.__index = ImageTrailEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(ImageTrailEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function ImageTrailEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, ImageTrailEffect)
    
    -- Target intensity
    effect.m_target_intensity = 0.0
    
    return effect
end

------------------------------------------------

function ImageTrailEffect:init(t_id, t_intensity, t_fade_in, t_duration, t_fade_out)
    -- Initialize image trail effect properties
    self.m_id = t_id

    -- Clamp intensity to max 0.95 to prevent screen freeze.
    local clamped_intensity = math.min(t_intensity, 0.95)
    
    -- Set the intensity values
    self.m_amount = clamped_intensity
    self.m_max_amount = clamped_intensity
    self.m_target_intensity = clamped_intensity
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

function ImageTrailEffect:late_process(t_delta_time)
    BaseEffect.process_fade(self, t_delta_time)
end

------------------------------------------------

function ImageTrailEffect:get_intensity()
    return self.m_amount * self.m_multiplier
end

------------------------------------------------

function ImageTrailEffect:set_intensity(t_intensity)
    -- Clamp intensity to max 0.95 to prevent screen freeze.
    local clamped_intensity = math.min(t_intensity, 0.95)
    self.m_amount = clamped_intensity
    self.m_target_intensity = clamped_intensity
end

------------------------------------------------

return ImageTrailEffect
