local PlayerFootstepSounds = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local StateMachine = dofile("../content/scripts/shared/state_machine.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local STEP_DISTANCE_WALK = 1.4
local STEP_DISTANCE_CROUCH = 0.9
local STEP_DISTANCE_SPRINT = 1.25
local SURFACE_RAY_START_OFFSET_Y = 0.15
local SURFACE_RAY_END_OFFSET_Y = -2.0
local WATER_ZONE_HALF_EXTENT = 0.5
local WATER_SHALLOW_MAX_DEPTH = 0.2
local WATER_ZONE_TAG = "water_zone"
local DEFAULT_SOUND_TYPE = "default"

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_initialized = false
local m_body_entity_id = 0
local m_traveled_distance = 0.0
local m_last_position = vec3(0.0, 0.0, 0.0)
local m_has_last_position = false
local m_was_landing = false

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function reset_state()
    m_initialized = false
    m_body_entity_id = 0
    m_traveled_distance = 0.0
    m_last_position = vec3(0.0, 0.0, 0.0)
    m_has_last_position = false
    m_was_landing = false
end

----------------------------------------------------

local function play_surface_sound_type()
    local feet_position = transform_get_world_position(m_body_entity_id)
    local sound_type = ""

    -- Water volumes win over the ground contact type.
    local water_zone_ids = world_get_entities_by_tag(WATER_ZONE_TAG)
    local water_zone_id = 0
    for zone_index = 1, #water_zone_ids do
        local zone_id = water_zone_ids[zone_index]
        if not entity_get_is_valid(zone_id) then
            print_error("[PlayerFootstepSounds] water_zone entity is invalid.")
        elseif not entity_get_has_transform_component(zone_id) then
            print_error("[PlayerFootstepSounds] water_zone is missing a Transform.")
        else
            local local_position = transform_world_to_local_point(zone_id, feet_position)
            if math_abs(local_position.x) <= WATER_ZONE_HALF_EXTENT
                and math_abs(local_position.y) <= WATER_ZONE_HALF_EXTENT
                and math_abs(local_position.z) <= WATER_ZONE_HALF_EXTENT then
                water_zone_id = zone_id
                break
            end
        end
    end

    -- If the player is in a water zone, play the water sound type.
    if entity_get_is_valid(water_zone_id) then
        local surface_point = transform_local_to_world_point(water_zone_id, vec3(0.0, WATER_ZONE_HALF_EXTENT, 0.0))
        local immersion = surface_point.y - feet_position.y
        if immersion > 0.0 then
            if immersion <= WATER_SHALLOW_MAX_DEPTH then
                sound_type = "water_shallow"
            else
                sound_type = "water"
            end
        end
    end

    -- Raycast to get the surface type.
    if sound_type == "" then
        local ray_from = vec3(feet_position.x, feet_position.y + SURFACE_RAY_START_OFFSET_Y, feet_position.z)
        local ray_to = vec3(feet_position.x, feet_position.y + SURFACE_RAY_END_OFFSET_Y, feet_position.z)
        local surface_hit = surface_get_from_raycast(
            ray_from,
            ray_to,
            { m_body_entity_id },
            false,
            PhysicsQuery.QUERY_GROUP_ALL,       -- All groups.
            PhysicsQuery.QUERY_MASK_NON_TRIGGER -- Only colliding bodies.
        )

        -- Surface type comes from the hit material.
        if surface_hit.has_hit == true then
            sound_type = surface_hit.surface_type
            if sound_type == "" then
                sound_type = DEFAULT_SOUND_TYPE
            end
        end
    end

    -- If no surface type was found, use the default sound type.
    if sound_type == "" then
        return
    end

    -- Play the named sound type. 
    local sound_id = entity_get_child_by_path(m_body_entity_id, "sound/footsteps/" .. sound_type)
    -- If the sound type is missing, use the default sound type.
    if not entity_get_is_valid(sound_id) then
        sound_id = entity_get_child_by_path(m_body_entity_id, "sound/footsteps/" .. DEFAULT_SOUND_TYPE)
    end

    -- If the sound type is missing, log an error.
    if not entity_get_is_valid(sound_id) then
        print_error("[PlayerFootstepSounds] Missing footstep sound type '" .. sound_type .. "'.")
        return
    end

    -- Play the sound.
    sound_play(sound_id, 0.0)
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function PlayerFootstepSounds.initialize(t_body_entity_id)
    reset_state()

    -- If the body entity is invalid, log an error.
    if not entity_get_is_valid(t_body_entity_id) then
        print_error("[PlayerFootstepSounds] Missing character body entity.")
        return
    end

    -- Get the default sound type.
    local default_sound_id = entity_get_child_by_path(t_body_entity_id, "sound/footsteps/" .. DEFAULT_SOUND_TYPE)
    if not entity_get_is_valid(default_sound_id) then
        print_error("[PlayerFootstepSounds] Missing child entity named 'sound/footsteps/" .. DEFAULT_SOUND_TYPE .. "'.")
        return
    end

    -- Set the body entity ID.
    m_body_entity_id = t_body_entity_id

    -- All set.
    m_initialized = true
end

----------------------------------------------------

function PlayerFootstepSounds.process_footstep_sounds(t_context, t_did_jump)
    if not m_initialized then
        return
    end

    -- Isthe body entity valid? 
    if not entity_get_is_valid(m_body_entity_id) then
        print_error("[PlayerFootstepSounds] Character body is invalid.")
        m_initialized = false
        return
    end

    -- Get required data.
    local feet_position = transform_get_world_position(m_body_entity_id)
    local state_name = StateMachine.get_current_state_name(t_context.m_state_machine)
    local is_landing = state_name == "land"

    -- Play a jump sample when the body leaves the ground.
    if t_did_jump == true then
        play_surface_sound_type()
        m_traveled_distance = 0.0
        m_has_last_position = false
        m_was_landing = is_landing
        m_last_position = feet_position
        return
    end

    -- Play a land sample when the move state first enters land.
    if is_landing and not m_was_landing then
        play_surface_sound_type()
        m_traveled_distance = 0.0
        m_was_landing = true
        m_last_position = feet_position
        m_has_last_position = true
        return
    end

    m_was_landing = is_landing

    -- Make sure we walk and remain on the ground before playing a step sound.
    local is_walking = state_name == "walk"
    if not t_context.is_on_ground or not is_walking then
        m_traveled_distance = 0.0
        m_last_position = feet_position
        m_has_last_position = true
        return
    end

    -- Set last position. 
    if not m_has_last_position then
        m_last_position = feet_position
        m_has_last_position = true
        return
    end

    -- Calculate horizontal travel.
    local offset_x = feet_position.x - m_last_position.x
    local offset_z = feet_position.z - m_last_position.z
    m_traveled_distance = m_traveled_distance + math_sqrt((offset_x * offset_x) + (offset_z * offset_z))
    m_last_position = feet_position

    local step_distance = STEP_DISTANCE_WALK
    if t_context.is_crouching then
        step_distance = STEP_DISTANCE_CROUCH
    elseif t_context.is_sprinting then
        step_distance = STEP_DISTANCE_SPRINT
    end

    -- Is the player within the step distance?
    if m_traveled_distance < step_distance then
        return
    end

    -- Get the remaining distance before playing the next step and play sound. 
    m_traveled_distance = m_traveled_distance - step_distance
    play_surface_sound_type()
end

----------------------------------------------------

function PlayerFootstepSounds.shutdown()
    reset_state()
end

----------------------------------------------------

return PlayerFootstepSounds
