local CameraLookAtEffect = {}
CameraLookAtEffect.__index = CameraLookAtEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local BaseEffect = dofile("../content/scripts/camera_effects/base_effect.lua")
setmetatable(CameraLookAtEffect, { __index = BaseEffect })
local MathHelpers = dofile("../content/scripts/shared/math_helpers.lua")

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function CameraLookAtEffect:new(t_params)
    t_params = t_params or {}
    local self = setmetatable(BaseEffect:new(t_params), CameraLookAtEffect)

    self.m_id = tonumber(t_params.id) or -1

    self.m_fade_in_time = 0.0
    self.m_duration = tonumber(t_params.duration) or -1.0
    self.m_fade_out_time = 0.0
    self.m_max_fade_in_time = tonumber(t_params.fade_in) or 0.0
    self.m_max_fade_out_time = tonumber(t_params.fade_out) or 0.0
    self.m_time_elapsed = 0.0
    self.m_multiplier = 0.0
    self.m_state = BaseEffect.STATE_FADE_IN

    self.m_target_entity_id = tonumber(t_params.target_entity_id) or 0
    self.m_target_position = t_params.target_position

    self.m_speed_mul = tonumber(t_params.speed_mul) or 2.0
    self.m_max_speed = tonumber(t_params.max_speed) or 2.0
    self.m_acceleration = tonumber(t_params.acceleration) or 10.0

    self.m_immediate_pull_fraction = 0.0
    self.m_immediate_pull_cap_fraction = 0.0

    self.m_current_yaw_speed = 0.0
    self.m_current_pitch_speed = 0.0

    return self
end

------------------------------------------------

function CameraLookAtEffect:set_pull_strength(t_speed_mul, t_max_speed, t_acceleration, t_immediate_pull_fraction, t_immediate_pull_cap_fraction)
    self.m_speed_mul = t_speed_mul
    self.m_max_speed = t_max_speed
    self.m_acceleration = t_acceleration
    self.m_immediate_pull_fraction = t_immediate_pull_fraction or 0.0
    self.m_immediate_pull_cap_fraction = t_immediate_pull_cap_fraction or 0.0
end

------------------------------------------------

function CameraLookAtEffect:stop(t_fade_out_time)
    self.m_current_yaw_speed = 0.0
    self.m_current_pitch_speed = 0.0
    BaseEffect.stop(self, t_fade_out_time)
end

------------------------------------------------

function CameraLookAtEffect:set_target_entity(t_entity_id)
    self.m_target_entity_id = t_entity_id
    self.m_target_position = nil
end

------------------------------------------------

function CameraLookAtEffect:get_angle_to_target(t_camera_pos, t_target_pos)
    local dx = t_target_pos.x - t_camera_pos.x
    local dy = t_target_pos.y - t_camera_pos.y
    local dz = t_target_pos.z - t_camera_pos.z
    local horizontal_distance = math_sqrt((dx * dx) + (dz * dz))
    -- Yaw 0 looks down engine forward, which is -Z.
    local yaw = math_atan2(-dx, -dz)
    local pitch = math_atan2(dy, horizontal_distance)
    return pitch, yaw
end

------------------------------------------------

function CameraLookAtEffect:process(t_delta_time, t_camera_entity_id, t_current_pitch, t_current_yaw)
    self:process_fade(t_delta_time)

    if self.m_state == BaseEffect.STATE_ENDED then
        return 0.0, 0.0
    end

    local target_pos = nil
    if self.m_target_entity_id > 0 and entity_get_is_valid(self.m_target_entity_id) then
        target_pos = transform_get_world_position(self.m_target_entity_id)
    elseif self.m_target_position ~= nil then
        target_pos = self.m_target_position
    else
        return 0.0, 0.0
    end

    local camera_pos = transform_get_world_position(t_camera_entity_id)
    local target_pitch, target_yaw = self:get_angle_to_target(camera_pos, target_pos)

    local yaw_error = MathHelpers.get_shortest_angle_distance_rad(t_current_yaw, target_yaw)
    local pitch_error = MathHelpers.get_shortest_angle_distance_rad(t_current_pitch, target_pitch)

    local wanted_yaw_speed = math.min(math.abs(yaw_error) * self.m_speed_mul, self.m_max_speed)
    local wanted_pitch_speed = math.min(math.abs(pitch_error) * self.m_speed_mul, self.m_max_speed)
    if yaw_error < 0.0 then
        wanted_yaw_speed = -wanted_yaw_speed
    end
    if pitch_error < 0.0 then
        wanted_pitch_speed = -wanted_pitch_speed
    end

    self.m_current_yaw_speed = self.m_current_yaw_speed + (wanted_yaw_speed - self.m_current_yaw_speed) * t_delta_time * self.m_acceleration
    self.m_current_pitch_speed = self.m_current_pitch_speed + (wanted_pitch_speed - self.m_current_pitch_speed) * t_delta_time * self.m_acceleration

    local pitch_delta = self.m_current_pitch_speed * t_delta_time * self.m_multiplier
    local yaw_delta = self.m_current_yaw_speed * t_delta_time * self.m_multiplier

    if self.m_immediate_pull_cap_fraction > 0.0 then
        pitch_delta = pitch_delta + (pitch_error * self.m_immediate_pull_fraction)
        yaw_delta = yaw_delta + (yaw_error * self.m_immediate_pull_fraction)
        local max_pitch_delta = pitch_error * self.m_immediate_pull_cap_fraction
        local max_yaw_delta = yaw_error * self.m_immediate_pull_cap_fraction
        if pitch_error >= 0.0 and pitch_delta > max_pitch_delta then
            pitch_delta = max_pitch_delta
        elseif pitch_error < 0.0 and pitch_delta < max_pitch_delta then
            pitch_delta = max_pitch_delta
        end
        if yaw_error >= 0.0 and yaw_delta > max_yaw_delta then
            yaw_delta = max_yaw_delta
        elseif yaw_error < 0.0 and yaw_delta < max_yaw_delta then
            yaw_delta = max_yaw_delta
        end
    end

    return pitch_delta, yaw_delta
end

------------------------------------------------

return CameraLookAtEffect
