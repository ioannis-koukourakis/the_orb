local PlayerMovement = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

local INPUT_DEADZONE = 0.01
local DIRECTION_NORMALIZE_THRESHOLD = 1.0

------------------------------------------------
-- INTERFACE
------------------------------------------------

function PlayerMovement.get_move_input(t_context)
    local input = vec3(t_context.input_move_x, 0.0, t_context.input_move_z)
    
    local direction_length = vec3_length(input)
    
    if direction_length > DIRECTION_NORMALIZE_THRESHOLD then
        input = vec3_normalize(input)
    end
    
    return input
end

------------------------------------------------

function PlayerMovement.get_wants_to_move(t_input_length)
    return t_input_length >= INPUT_DEADZONE
end

------------------------------------------------

function PlayerMovement.get_has_move_input(t_context)
    local input_direction = PlayerMovement.get_move_input(t_context)
    return PlayerMovement.get_wants_to_move(vec3_length(input_direction))
end

------------------------------------------------

function PlayerMovement.apply_ground_move(t_context, t_delta_time, t_input_direction, t_speed_multiplier)
    if not t_context or not t_context.current_velocity then
        print_error("[PlayerMovement] apply_ground_move: invalid context")
        return
    end

    -- Project camera vectors onto horizontal plane.
    local camera_forward = transform_get_world_forward(t_context.camera_entity_id)
    local camera_right = transform_get_world_right(t_context.camera_entity_id)
    local horizontal_forward = vec3_normalize(vec3(camera_forward.x, 0.0, camera_forward.z))
    local horizontal_right = vec3_normalize(vec3(camera_right.x, 0.0, camera_right.z))
    
    -- Combine forward and right components based on direction.
    local right_component = vec3_mul(horizontal_right, t_input_direction.x)
    local forward_component = vec3_mul(horizontal_forward, t_input_direction.z)
    local target_direction = vec3_sub(right_component, forward_component)

    local directional_multiplier = 1.0
    local backward_speed_multiplier = t_context.backward_speed_multiplier
    local sideways_speed_multiplier = t_context.sideways_speed_multiplier
    
    -- Moving backward
    if t_input_direction.z > INPUT_DEADZONE then
        if math.abs(t_input_direction.x) < INPUT_DEADZONE then
            -- Moving backward only.
            directional_multiplier = directional_multiplier * backward_speed_multiplier
        else
            -- Moving backward diagonally.
            directional_multiplier = directional_multiplier * sideways_speed_multiplier
        end
    -- Moving sideways only
    elseif math.abs(t_input_direction.x) > INPUT_DEADZONE and math.abs(t_input_direction.z) < INPUT_DEADZONE then
        directional_multiplier = directional_multiplier * sideways_speed_multiplier
    end

    -- Calculate the current movement speed and target velocity horizontal.
    local current_movement_speed = t_context.movement_speed * t_speed_multiplier * directional_multiplier
    local target_velocity_horizontal = vec3_mul(target_direction, current_movement_speed)

    -- Apply the smooth acceleration to the current velocity.
    local acceleration = t_context.acceleration

    -- Current horizontal velocity.
    local current_horizontal = vec3(t_context.current_velocity.x, 0.0, t_context.current_velocity.z)
    
    -- Calculate velocity change needed
    local velocity_diff = vec3_sub(target_velocity_horizontal, current_horizontal)
    local max_velocity_change = math.max(0.0, acceleration * t_delta_time)
    local velocity_change_length = vec3_length(velocity_diff)
    
    -- Clamp velocity change.
    if velocity_change_length > max_velocity_change then
        local normalized_diff = vec3_normalize(velocity_diff)
        velocity_diff = vec3_mul(normalized_diff, max_velocity_change)
    end
    
    -- Apply acceleration and preserve vertical velocity
    local new_horizontal = vec3_add(current_horizontal, velocity_diff)
    t_context.current_velocity = vec3(new_horizontal.x, t_context.current_velocity.y, new_horizontal.z)
end

------------------------------------------------

function PlayerMovement.apply_horizontal_deceleration(t_context, t_delta_time, t_deceleration)
    local horizontal_velocity = vec3(t_context.current_velocity.x, 0.0, t_context.current_velocity.z)
    local lerp_factor = math_clamp(t_deceleration * t_delta_time, 0.0, 1.0)
    horizontal_velocity = vec3_lerp(horizontal_velocity, vec3(0.0, 0.0, 0.0), lerp_factor)
    t_context.current_velocity = vec3(horizontal_velocity.x, t_context.current_velocity.y, horizontal_velocity.z)
end

------------------------------------------------

function PlayerMovement.update_speed_multiplier(t_context, t_target_multiplier, t_delta_time, t_transition_speed)
    if not t_context or not t_context.current_speed_multiplier then
        print_error("[PlayerMovement] update_speed_multiplier: invalid context")
        return
    end
    
    -- Calculate the maximum allowed change in speed multiplier based on acceleration and transition speed.
    local acceleration = t_context.acceleration
    local transition_speed = t_transition_speed or 0.6
    
    local multiplier_diff = t_target_multiplier - t_context.current_speed_multiplier
    local max_multiplier_change = math.max(0.0, acceleration * t_delta_time * transition_speed)
    
    -- Clamp the change in speed multiplier to the maximum allowed value.
    t_context.current_speed_multiplier = t_context.current_speed_multiplier + math_clamp(multiplier_diff, -max_multiplier_change, max_multiplier_change)
end

------------------------------------------------

return PlayerMovement
