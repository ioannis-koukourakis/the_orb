local FovShakeEffect = {}
FovShakeEffect.__index = FovShakeEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
local MathHelpers = dofile("../content/scripts/shared/math_helpers.lua")

setmetatable(FovShakeEffect, { __index = BaseEffect })

------------------------------------------------
-- SETTINGS
------------------------------------------------

local SHAKE_FORCE_MULTIPLIER = 8.0

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function FovShakeEffect:new()
    -- Create a new base effect.
    local effect = BaseEffect:new()
    setmetatable(effect, FovShakeEffect)
    
    -- Shake values
    effect.m_shake = 0.0
    effect.m_last_shake = 0.0
    effect.m_rate = 0.0
    effect.m_noise_time = 0.0
    effect.m_seed = math.random() * 1000.0
    
    return effect
end

------------------------------------------------

function FovShakeEffect:init(t_id, t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    -- Initialize fov shake effect properties
    self.m_id = t_id
    self.m_amount = t_force
    self.m_max_amount = t_force
    self.m_rate = math.max(0.0, t_rate)
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

function FovShakeEffect:late_process(t_delta_time)
    -- Process fade and shake. 
    -- Use late process to ensure shake is processed after fade. 
    BaseEffect.process_fade(self, t_delta_time)
    self:process_shake(t_delta_time)
end

------------------------------------------------

function FovShakeEffect:process_shake(t_delta_time)
    -- Update noise time
    self.m_noise_time = self.m_noise_time + t_delta_time
    
    -- Calculate noise values.
    local time = self.m_noise_time * self.m_rate
    local amplitude = (self.m_amount * self.m_multiplier) * SHAKE_FORCE_MULTIPLIER
    
    -- Generate noise value
    local shake_value = MathHelpers.get_hash_noise(self.m_seed, time) * amplitude
    
    -- Smoothing factor for smoother transitions
    local smoothing = math_clamp(self.m_rate * 0.1, 0.0, 1.0)
    
    -- Apply smoothing to the shake value.
    self.m_shake = self.m_last_shake + (shake_value - self.m_last_shake) * smoothing
    self.m_last_shake = self.m_shake
end

------------------------------------------------

function FovShakeEffect:get_shake()
    return self.m_shake
end

------------------------------------------------

function FovShakeEffect:set_force(t_force)
    self.m_amount = t_force
end

------------------------------------------------

return FovShakeEffect
