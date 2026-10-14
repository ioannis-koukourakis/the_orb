local VertigoEffect = {}
VertigoEffect.__index = VertigoEffect

------------------------------------------------
-- VERTIGO EFFECT
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
local Easing = dofile("../content/scripts/shared/easing.lua")
setmetatable(VertigoEffect, { __index = BaseEffect })

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function VertigoEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, VertigoEffect)
    
    -- Target intensity and current values
    effect.m_intensity_target = 1.0
    effect.m_current_fov_multiplier = 0.0
    effect.m_current_camera_offset = 0.0
    
    return effect
end

------------------------------------------------

function VertigoEffect:init(t_id, t_intensity, t_fade_in, t_duration, t_fade_out)
    -- Initialize vertigo effect properties
    self.m_id = t_id
    self.m_amount = t_intensity
    self.m_max_amount = t_intensity
    self.m_intensity_target = t_intensity
    self.m_fade_in_time = 0.0
    self.m_duration = t_duration
    self.m_fade_out_time = 0.0
    self.m_max_fade_in_time = t_fade_in
    self.m_max_fade_out_time = t_fade_out
    self.m_time_elapsed = 0.0
    self.m_multiplier = 0.0
    self.m_state = BaseEffect.STATE_FADE_IN

    -- Easing
    self:set_ease_in(Easing.out_cubic)
    self:set_ease_out(Easing.in_sine)
end

------------------------------------------------

function VertigoEffect:process(t_delta_time)
    BaseEffect.process_fade(self, t_delta_time)

    -- Clamped quadratic fade weight.
    local fade_weight = math_clamp(self.m_multiplier, 0.0, 1.0)
    local quadratic_weight = fade_weight * fade_weight
    local effect_strength = self.m_intensity_target * quadratic_weight

    -- Update the current FOV multiplier and camera offset.
    self.m_current_fov_multiplier = 1.0 + effect_strength
    self.m_current_camera_offset = effect_strength * 5.0
end

------------------------------------------------

function VertigoEffect:set_intensity(t_intensity)
    -- Set the target intensity.
    self.m_intensity_target = t_intensity 
    --self.m_amount = t_intensity
    --self.m_max_amount = t_intensity
end

------------------------------------------------

function VertigoEffect:get_fov_multiplier()
    return self.m_current_fov_multiplier
end

------------------------------------------------

function VertigoEffect:get_camera_offset()
    return self.m_current_camera_offset
end

------------------------------------------------

function VertigoEffect:get_world_offset(t_camera_entity_id)
    local camera_forward = transform_get_world_forward(t_camera_entity_id)
    
    -- Calculate world-space offset along camera forward direction.
    return vec3_mul(camera_forward, self.m_current_camera_offset)
end

------------------------------------------------

return VertigoEffect
