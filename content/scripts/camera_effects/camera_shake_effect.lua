local CameraShakeEffect = {}
CameraShakeEffect.__index = CameraShakeEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
local MathHelpers = dofile("../content/scripts/shared/math_helpers.lua")

setmetatable(CameraShakeEffect, { __index = BaseEffect })

------------------------------------------------
-- SETTINGS
------------------------------------------------

local SHAKE_FORCE_MULTIPLIER = 1.0

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function CameraShakeEffect:new()
    local effect = BaseEffect:new()
    setmetatable(effect, CameraShakeEffect)
    
    -- Preinitialize shake effect properties
    effect.m_shake = vec3(0.0, 0.0, 0.0)
    effect.m_last_shake = vec3(0.0, 0.0, 0.0)
    effect.m_rate = 0.0
    effect.m_noise_time = 0.0
    
    -- Preinitialize noise seeds for each axis
    effect.m_seed_x = math.random() * 1000.0
    effect.m_seed_y = math.random() * 1000.0
    effect.m_seed_z = math.random() * 1000.0
    
    return effect
end

------------------------------------------------

function CameraShakeEffect:init(t_id, t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    -- Initialize shake effect properties
    self.m_id = tonumber(t_id) or -1
    self.m_amount = tonumber(t_force) or 0.0
    self.m_max_amount = tonumber(t_force) or 0.0
    self.m_rate = math.max(0.0, tonumber(t_rate) or 0.0)
    self.m_fade_in_time = 0.0
    self.m_duration = tonumber(t_duration) or -1.0
    self.m_fade_out_time = 0.0
    self.m_max_fade_in_time = tonumber(t_fade_in) or 0.0
    self.m_max_fade_out_time = tonumber(t_fade_out) or 0.0
    self.m_time_elapsed = 0.0
    self.m_multiplier = 0.0
    self.m_state = BaseEffect.STATE_FADE_IN
end

------------------------------------------------

function CameraShakeEffect:late_process(t_delta_time)
    -- Process fade and shake. 
    -- Use late process to ensure shake is processed after fade. 
    BaseEffect.process_fade(self, t_delta_time)
    self:process_shake(t_delta_time)
end

------------------------------------------------

function CameraShakeEffect:process_shake(t_delta_time)
    -- Update noise time
    self.m_noise_time = self.m_noise_time + t_delta_time
    -- Calculate amplitude based on current multiplier and force
    local time = self.m_noise_time * self.m_rate
    local amplitude = (self.m_amount * self.m_multiplier) * SHAKE_FORCE_MULTIPLIER
    
    -- Generate noise for each axis
    local shake_x = MathHelpers.get_hash_noise(self.m_seed_x, time) * amplitude
    local shake_y = MathHelpers.get_hash_noise(self.m_seed_y, time) * amplitude
    local shake_z = MathHelpers.get_hash_noise(self.m_seed_z, time) * amplitude
    
    -- Calculate smoothing factor
    local smoothing = math_clamp(self.m_rate * 0.1, 0.0, 1.0)
    
    -- Smooth the shake
    self.m_shake.x = self.m_last_shake.x + (shake_x - self.m_last_shake.x) * smoothing
    self.m_shake.y = self.m_last_shake.y + (shake_y - self.m_last_shake.y) * smoothing
    self.m_shake.z = self.m_last_shake.z + (shake_z - self.m_last_shake.z) * smoothing
    
    -- Update last shake
    self.m_last_shake.x = self.m_shake.x
    self.m_last_shake.y = self.m_shake.y
    self.m_last_shake.z = self.m_shake.z
end

------------------------------------------------

function CameraShakeEffect:get_world_offset(t_camera_yaw)
    -- Rotate local shake to world space using camera yaw
    local cos_yaw = math.cos(t_camera_yaw)
    local sin_yaw = math.sin(t_camera_yaw)
    
    return vec3(
        self.m_shake.x * cos_yaw - self.m_shake.z * sin_yaw,
        self.m_shake.y,
        self.m_shake.x * sin_yaw + self.m_shake.z * cos_yaw
    )
end

------------------------------------------------

function CameraShakeEffect:get_shake()
    return self.m_shake
end

------------------------------------------------

function CameraShakeEffect:set_force(t_force)
    self.m_amount = tonumber(t_force) or 0.0
end

------------------------------------------------

function CameraShakeEffect:set_rate(t_rate)
    self.m_rate = math.max(0.0, tonumber(t_rate) or 0.0)
end

------------------------------------------------

return CameraShakeEffect
