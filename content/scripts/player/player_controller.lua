local PlayerController = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local PlayerCamera = dofile("../content/scripts/player/player_camera.lua")
local PlayerFootstepSounds = dofile("../content/scripts/player/player_footstep_sounds.lua")
local PlayerMovement = dofile("../content/scripts/player/player_movement.lua")
local StateMachine = dofile("../content/scripts/shared/state_machine.lua")

local GAME_MODULE = "game_module"

local idle_state = dofile("../content/scripts/player/move_states/move_state_idle.lua")
local walk_state = dofile("../content/scripts/player/move_states/move_state_walk.lua")
local fall_state = dofile("../content/scripts/player/move_states/move_state_fall.lua")
local land_state = dofile("../content/scripts/player/move_states/move_state_land.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

local SIDEWAYS_SPEED_MULTIPLIER = 0.85
local BACKWARD_SPEED_MULTIPLIER = 0.75
local SPRINT_MULTIPLIER = 1.5
local CROUCH_SPEED_MULTIPLIER = 0.6
local STANDING_HEIGHT = 1.8
local CROUCH_HEIGHT = 0.9
local CROUCH_HEIGHT_RATIO = CROUCH_HEIGHT / STANDING_HEIGHT
local MIN_CAPSULE_HEIGHT = 0.05
local JUMP_FORCE = 4.0
local JUMP_BUFFER_TIME = 0.12
local STEP_UP_HEIGHT = 0.30
local MAX_WALKABLE_SLOPE = 45.0
local MIN_CEILING_NORMAL_Y = -0.3

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_movement_speed = 2.5
local m_acceleration = 32.0
local m_deceleration = 16.0
local m_jump_buffer_timer = 0.0
local m_wants_to_jump = false
local m_gamepad_sprint_toggle_active = false
local m_standing_capsule_height = 0.0
local m_standing_capsule_offset_y = 0.0
local m_crouch_capsule_height = 0.0
local m_camera_entity_id = 0
local m_body_entity_id = 0
local m_move_state_machine = nil
local m_can_crouch = true
local m_can_sprint = true
local m_can_jump = true
local m_controls_locked = false
local m_can_fall = true
local m_fall_was_enabled = true
local m_sprint_hold_blocked = false
local m_movement_context = {
    camera_entity_id = 0,
    m_state_machine = nil,

    movement_speed = m_movement_speed,
    sprint_multiplier = SPRINT_MULTIPLIER,
    sideways_speed_multiplier = SIDEWAYS_SPEED_MULTIPLIER,
    backward_speed_multiplier = BACKWARD_SPEED_MULTIPLIER,
    acceleration = m_acceleration,
    deceleration = m_deceleration,
    crouch_speed_multiplier = CROUCH_SPEED_MULTIPLIER,
    current_speed_multiplier = 1.0,

    can_walk = true,
    is_on_ground = false,
    is_crouching = false,
    is_sprinting = false,

    input_move_x = 0.0,
    input_move_z = 0.0,

    current_velocity = vec3(0.0, 0.0, 0.0),
}

------------------------------------------------
-- HELPERS
------------------------------------------------

local function get_capsule_top_offset_y(t_height, t_offset_y, t_radius)
    local half_height = t_height * 0.5
    local center_y = t_offset_y
    return center_y + half_height + t_radius
end

------------------------------------------------

local function get_yaw_from_engine_forward(t_forward)
    -- Engine forward is -Z. Yaw 0 looks down -Z.
    return math_atan2(-t_forward.x, -t_forward.z)
end

------------------------------------------------

local function get_has_ceiling_above(t_from_y, t_to_y, t_x, t_z)
    -- If standing top is below crouch top, then there is no ceiling above.
    if t_to_y <= t_from_y then
        return false
    end

    -- Raycast upward for a ceiling hit.
    local query_group = physics_body_get_collision_layer(m_body_entity_id)
    local query_mask = physics_body_get_collision_mask(m_body_entity_id)
    local filter_entities = { m_body_entity_id }
    local hit_data = physics_raycast(vec3(t_x, t_from_y, t_z),
                                    vec3(t_x, t_to_y, t_z),
                                    filter_entities,
                                    false,
                                    query_group,
                                    query_mask
    )

    -- Check if the raycast hit a ceiling.
    if hit_data == nil or hit_data.has_hit ~= true then
        return false
    end

    -- Treat shallow upward normals as non-ceiling geometry.
    return hit_data.hit_normal.y <= MIN_CEILING_NORMAL_Y
end

------------------------------------------------

local function get_can_stand_up()
    -- Check if the standing capsule height is valid.
    if m_standing_capsule_height <= 0.0 then
        return true
    end

    -- Compare crouch vs standing capsule tops at the current feet position.
    local feet = transform_get_world_position(m_body_entity_id)
    local radius = character_body_get_capsule_radius(m_body_entity_id)

    -- Calculate the crouch top and standing top.
    local height_difference = m_standing_capsule_height - m_crouch_capsule_height
    local crouch_offset_y = m_standing_capsule_offset_y - (height_difference * 0.5)
    local crouch_top_y = feet.y + get_capsule_top_offset_y(m_crouch_capsule_height, crouch_offset_y, radius)
    local standing_top_y = feet.y + get_capsule_top_offset_y(m_standing_capsule_height, m_standing_capsule_offset_y, radius)

    -- Check if the standing capsule top is below the crouch capsule top.
    if standing_top_y <= crouch_top_y then
        return true
    end

    -- Check if there is a ceiling above the crouch capsule.
    return not get_has_ceiling_above(crouch_top_y, standing_top_y, feet.x, feet.z)
end

------------------------------------------------

local function set_player_is_crouching(t_enabled)
    -- Skip if the requested crouch state matches the current state.
    local target_is_crouching = t_enabled == true
    if target_is_crouching == m_movement_context.is_crouching then
        return
    end

    -- Block stand-up if ceiling is above the capsule.
    if not target_is_crouching and not get_can_stand_up() then
        return
    end

    -- Check if the standing capsule height is valid.
    if m_standing_capsule_height <= 0.0 then
        return
    end

    -- Set the target height and offset.
    local target_height = m_standing_capsule_height
    local target_offset_y = m_standing_capsule_offset_y
    if target_is_crouching then
        target_height = m_crouch_capsule_height
        local height_difference = m_standing_capsule_height - m_crouch_capsule_height
        target_offset_y = m_standing_capsule_offset_y - (height_difference * 0.5)
    end

    -- Set the capsule shape.
    if not character_body_set_capsule_shape(m_body_entity_id, target_height, target_offset_y) then
        return
    end

    -- Set the player is crouching and update the camera.
    m_movement_context.is_crouching = target_is_crouching
    PlayerCamera.set_crouching(target_is_crouching)
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function PlayerController.get_camera_entity_id()
    return m_camera_entity_id
end

------------------------------------------------

function PlayerController.get_body_entity_id()
    return m_body_entity_id
end

------------------------------------------------

function PlayerController.set_can_walk(t_enabled)
    m_movement_context.can_walk = t_enabled == true
end

------------------------------------------------

function PlayerController.set_can_crouch(t_enabled)
    m_can_crouch = t_enabled == true
end

------------------------------------------------

function PlayerController.set_can_sprint(t_enabled)
    m_can_sprint = t_enabled == true
end

------------------------------------------------

function PlayerController.set_can_jump(t_enabled)
    m_can_jump = t_enabled == true
end

------------------------------------------------

function PlayerController.set_can_fall(t_enabled)
    m_can_fall = t_enabled == true
end

------------------------------------------------

function PlayerController.set_can_look_around(t_enabled)
    local enabled = t_enabled == true
    PlayerCamera.set_can_look_around(enabled)

    -- Keep cursor mode in sync with look.
    -- Free cursor when look is off.
    if get_game_mode_active() then
        input_set_mouse_capture(enabled)
    end
end

------------------------------------------------

function PlayerController.set_controls_locked(t_locked)
    local locked = t_locked == true
    if locked == m_controls_locked then
        return
    end

    local enabled = locked == false
    PlayerController.set_can_walk(enabled)
    PlayerCamera.set_can_look_around(enabled)
    PlayerController.set_can_jump(enabled)
    PlayerController.set_can_crouch(enabled)
    PlayerController.set_can_sprint(enabled)
    m_controls_locked = locked
end

------------------------------------------------

function PlayerController.set_can_zoom(t_enabled)
    PlayerCamera.set_can_zoom(t_enabled)
end

------------------------------------------------

function PlayerController.set_look_yaw_pitch(t_yaw_radians, t_pitch_radians)
    PlayerCamera.set_initial_rotation(t_yaw_radians, t_pitch_radians)
end

------------------------------------------------

function PlayerController.get_look_radians()
    local pitch_radians, yaw_radians = PlayerCamera.get_pitch_yaw()
    return vec2(pitch_radians, yaw_radians)
end

------------------------------------------------

function PlayerController.get_is_inspect_zoom_active()
    return PlayerCamera.get_is_inspect_zoom_active()
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function PlayerController.on_initialize()
    -- Initialize basic properties.
    m_jump_buffer_timer = 0.0
    m_wants_to_jump = false
    m_gamepad_sprint_toggle_active = false
    m_standing_capsule_height = 0.0
    m_camera_entity_id = 0
    m_body_entity_id = 0
    m_move_state_machine = nil
    m_can_crouch = true
    m_can_sprint = true
    m_can_jump = true
    m_can_fall = true
    m_fall_was_enabled = true
    m_sprint_hold_blocked = false
end

------------------------------------------------

function PlayerController.on_ready()
    -- Make sure the player root has a transform component.
    if not entity_get_has_transform_component(entity_id) then
        print_error("[PlayerController] Missing Transform component on player root.")
        return
    end

    -- Body and camera are siblings under the player prefab root.
    m_body_entity_id = entity_get_child_by_name(entity_id, "body")
    if not entity_get_is_valid(m_body_entity_id) then
        print_error("[PlayerController] Missing child entity named 'body'.")
        return
    end

    -- Make sure the body has a physics component.
    if not entity_get_has_physics_component(m_body_entity_id) then
        print_error("[PlayerController] Missing PhysicsBody / character body on 'body'.")
        return
    end

    -- Set up the camera.
    m_camera_entity_id = entity_get_child_by_name(entity_id, "camera")
    if not entity_get_is_valid(m_camera_entity_id) then
        print_error("[PlayerController] Missing child entity named 'camera'.")
        return
    end

    -- Set up the character capsule.
    local shape_count = physics_body_get_collision_shape_count(m_body_entity_id)
    if shape_count == nil or shape_count < 1 then
        print_error("[PlayerController] Character body has no collision shapes.")
        return
    end

    -- Capsule size and offset.
    local capsule_size = physics_body_get_collision_shape_size(m_body_entity_id, 0)
    local capsule_offset = physics_body_get_collision_shape_offset(m_body_entity_id, 0)
    if capsule_size == nil or capsule_offset == nil or capsule_size.y == nil or capsule_size.y <= 0.0 then
        print_error("[PlayerController] Failed to read standing capsule.")
        return
    end

    -- Capsule height and offset.
    m_standing_capsule_height = capsule_size.y
    m_standing_capsule_offset_y = capsule_offset.y
    m_crouch_capsule_height = math.max(MIN_CAPSULE_HEIGHT, m_standing_capsule_height * CROUCH_HEIGHT_RATIO)

    -- Set up the character body.
    character_body_set_jump_speed(m_body_entity_id, JUMP_FORCE)
    character_body_set_step_height(m_body_entity_id, STEP_UP_HEIGHT)
    character_body_set_max_slope(m_body_entity_id, MAX_WALKABLE_SLOPE)
    transform_set_interpolation_active(m_body_entity_id, true)

    -- Set up the movement context.
    m_movement_context.camera_entity_id = m_camera_entity_id
    m_movement_context.movement_speed = m_movement_speed
    m_movement_context.acceleration = m_acceleration
    m_movement_context.deceleration = m_deceleration
    m_movement_context.current_velocity = vec3(0.0, 0.0, 0.0)

    -- Set up the move state machine.
    m_move_state_machine = StateMachine.create_new_instance()
    StateMachine.register_state(m_move_state_machine, "idle", idle_state)
    StateMachine.register_state(m_move_state_machine, "walk", walk_state)
    StateMachine.register_state(m_move_state_machine, "fall", fall_state)
    StateMachine.register_state(m_move_state_machine, "land", land_state)
    m_movement_context.m_state_machine = m_move_state_machine
    StateMachine.set_active(m_move_state_machine, true)
    StateMachine.change_state_to(m_move_state_machine, "idle", m_movement_context)

    -- Set up footstep playback.
    PlayerFootstepSounds.initialize(m_body_entity_id)

    -- Move to a loading-door spawn marker when this world was entered through a door.
    local spawn_door_name = module_call_function(GAME_MODULE, "get_pending_spawn_door")
    local spawn_applied = false
    local spawn_yaw = 0.0
    if spawn_door_name ~= "" then
        local door_entity_id = world_get_entity_by_name(spawn_door_name)
        if entity_get_is_valid(door_entity_id) then
            local spawn_entity_id = entity_get_child_by_name(door_entity_id, "spawn")
            if entity_get_is_valid(spawn_entity_id) and entity_get_has_transform_component(spawn_entity_id) then
                local spawn_position = transform_get_world_position(spawn_entity_id)
                local spawn_forward = transform_get_world_forward(spawn_entity_id)

                -- Face along the spawn marker's engine forward (-Z).
                spawn_yaw = get_yaw_from_engine_forward(spawn_forward)
                spawn_applied = true

                -- Set the player root first so the body child does not pick up a double offset.
                transform_set_world_position(entity_id, spawn_position)
                transform_set_world_rotation(entity_id, vec3(0.0, 0.0, 0.0))
                character_body_warp(m_body_entity_id, spawn_position)
                character_body_set_linear_velocity(m_body_entity_id, vec3(0.0, 0.0, 0.0))
                character_body_set_world_yaw(m_body_entity_id, spawn_yaw)
            end
        end
    end

    -- Face along the player root's engine forward (-Z) when not using a door spawn.
    if not spawn_applied then
        local spawn_forward = transform_get_world_forward(entity_id)
        spawn_yaw = get_yaw_from_engine_forward(spawn_forward)
    end

    -- Set the initial camera pitch from the camera's local rotation.
    local camera_rotation = transform_get_local_rotation(m_camera_entity_id)
    local pitch_radians = math_radians(camera_rotation.x)

    -- Only take over the active camera and mouse in game mode.
    if get_game_mode_active() then
        transform_set_world_rotation(entity_id, vec3(0.0, 0.0, 0.0))
        character_body_set_world_yaw(m_body_entity_id, spawn_yaw)

        -- Init player camera. 
        PlayerCamera.initialize(m_camera_entity_id, {
            max_pitch_angle_degrees = 83.0,
        }, m_body_entity_id)
        PlayerCamera.set_initial_rotation(spawn_yaw, pitch_radians)
        world_set_current_camera(m_camera_entity_id)
        PlayerController.set_can_look_around(true)
    end
end

------------------------------------------------

function PlayerController.on_process(t_delta_time)
    -- Sample move axes. 
    local move_x = input_get_action_strength("move_right") - input_get_action_strength("move_left")
    local move_z = input_get_action_strength("move_backward") - input_get_action_strength("move_forward")

    -- Set the move input in the movement context.
    m_movement_context.input_move_x = move_x
    m_movement_context.input_move_z = move_z

    -- Sprinting
    local sprint_pressed = input_get_is_action_pressed("sprint")
    if input_get_action_pressed_event("sprint_toggle") then
        if m_movement_context.is_crouching then
            m_gamepad_sprint_toggle_active = true
            m_sprint_hold_blocked = false
        else
            m_gamepad_sprint_toggle_active = not m_gamepad_sprint_toggle_active
        end
    end

    -- Clear gamepad sprint toggle when movement stops.
    if not PlayerMovement.get_has_move_input(m_movement_context) then
        m_gamepad_sprint_toggle_active = false
    end

    if not sprint_pressed and not m_gamepad_sprint_toggle_active then
        m_sprint_hold_blocked = false
    end

    -- Jumping
    if input_get_action_pressed_event("jump") then
        m_jump_buffer_timer = JUMP_BUFFER_TIME
    end

    -- Toggle crouch.
    if m_can_crouch then
        if input_get_action_pressed_event("crouch") then
            local was_crouching = m_movement_context.is_crouching
            set_player_is_crouching(not was_crouching)

            -- Cancel sprint when crouch starts. 
            if m_movement_context.is_crouching and not was_crouching then
                if sprint_pressed or m_gamepad_sprint_toggle_active then
                    m_sprint_hold_blocked = true
                end
            end
        end
    end

    -- Get sprint input.
    local input_sprint = m_can_sprint and (sprint_pressed or m_gamepad_sprint_toggle_active)

    -- Stand up when sprinting from a crouch.
    if input_sprint and m_movement_context.is_crouching and not m_sprint_hold_blocked then
        set_player_is_crouching(false)
    end

    m_movement_context.is_sprinting = input_sprint
                                    and not m_movement_context.is_crouching
                                    and m_movement_context.is_on_ground
end

------------------------------------------------

function PlayerController.on_fixed_process(t_time_step)
    if not entity_get_is_valid(m_body_entity_id) then
        return
    end

    -- Character controller already falls on its gravity. This only turns that off.
    if not m_can_fall then
        character_body_set_gravity(m_body_entity_id, vec3(0.0, 0.0, 0.0))
        local velocity = character_body_get_linear_velocity(m_body_entity_id)
        if velocity.y < 0.0 then
            character_body_set_linear_velocity(m_body_entity_id, vec3(velocity.x, 0.0, velocity.z))
        end
    elseif not m_fall_was_enabled then
        character_body_set_gravity(m_body_entity_id, physics_get_gravity())
    end
    m_fall_was_enabled = m_can_fall

    -- Check if the player is on the ground.
    m_movement_context.is_on_ground = character_body_get_on_ground(m_body_entity_id)

    -- Buffer jump instigation for a short window.
    if m_jump_buffer_timer > 0.0 then
        m_jump_buffer_timer = m_jump_buffer_timer - t_time_step
    end

    -- Check if the player can jump and if the jump buffer is active.
    if m_can_jump and m_jump_buffer_timer > 0.0 and m_movement_context.is_on_ground then
        if m_movement_context.is_crouching then
            set_player_is_crouching(false)
        else
            m_wants_to_jump = true
            m_jump_buffer_timer = 0.0
        end
    end

    -- Update the movement state machine and apply context changes.
    StateMachine.fixed_process(m_move_state_machine, t_time_step, m_movement_context)

    -- Apply buffered jump after the move state has updated velocity.
    local did_jump = false
    if m_wants_to_jump then
        m_wants_to_jump = false
        did_jump = true
        character_body_jump(m_body_entity_id, vec3(0.0, JUMP_FORCE, 0.0))
    end

    -- Set the walk direction.
    local walk_direction = vec3_mul(m_movement_context.current_velocity, t_time_step)
    character_body_set_walk_direction(m_body_entity_id, walk_direction)

    -- Process footstep sounds. 
    PlayerFootstepSounds.process_footstep_sounds(m_movement_context, did_jump)
end

------------------------------------------------

function PlayerController.on_late_process(t_delta_time)
    PlayerCamera.process_look_input(t_delta_time)
    PlayerCamera.process_position(t_delta_time)
    PlayerCamera.process_fov(t_delta_time)
end

------------------------------------------------

function PlayerController.on_shutdown()
    -- Clean up.
    PlayerCamera.on_shutdown()
    PlayerFootstepSounds.shutdown()

    m_move_state_machine = nil
    m_body_entity_id = 0
    m_camera_entity_id = 0
end

------------------------------------------------

return PlayerController
