local PlayerInteraction = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local Utilities = dofile("../content/scripts/shared/utilities.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

local INTERACT_INPUT_KEY = "interact"
local AIM_RAY_DISTANCE = 3.0 -- 
local DEFAULT_INTERACT_DISTANCE = 2.5 -- 

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_player_entity_id = 0
local m_camera_entity_id = 0
local m_current_target_id = 0
local m_can_interact = true
local m_raycast_exclude = {}

------------------------------------------------
-- HELPERS
------------------------------------------------

local function get_current_interactable_entity_id()
    -- Check if the camera is valid.
    if not entity_get_is_valid(m_camera_entity_id) then
        return 0
    end

    -- Get the camera position and forward.
    local camera_pos = transform_get_world_position(m_camera_entity_id)
    local camera_forward = transform_get_world_forward(m_camera_entity_id)

    -- Rebuild the exclude list in place for this aim ray.
    m_raycast_exclude[1] = m_camera_entity_id
    m_raycast_exclude[2] = m_player_entity_id
    local body_id = entity_get_child_by_name(m_player_entity_id, "body")
    if entity_get_is_valid(body_id) then
        m_raycast_exclude[3] = body_id
    else
        m_raycast_exclude[3] = nil
    end

    -- Raycast.
    local ray_end = vec3_add(camera_pos, vec3_mul(camera_forward, AIM_RAY_DISTANCE))
    local result = physics_raycast(
        camera_pos,
        ray_end,
        m_raycast_exclude,
        false,
        PhysicsQuery.QUERY_GROUP_ALL,
        PhysicsQuery.QUERY_MASK_NON_TRIGGER)

    -- Check if we hit an entity.
    if not result or not result.has_hit or not entity_get_is_valid(result.hit_entity_id) then
        return 0
    end

    -- Is the hit entity interactable? 
    local hit_id = result.hit_entity_id
    if not entity_get_has_tag(hit_id, "interactable") then
        return 0
    end

    -- Check if within the interaction distance. 
    local max_distance = DEFAULT_INTERACT_DISTANCE
    if Utilities.get_entity_has_script_function(hit_id, "get_interaction_distance") then
        local distance = world_call_entity_script_function(hit_id, "get_interaction_distance")
        if type(distance) ~= "number" or distance <= 0.0 then
            print_error("[PlayerInteraction] get_interaction_distance returned an invalid value.")
            return 0
        end
        max_distance = distance -- Override the default interact distance with the target's interact distance.
    end

    -- Check if the hit distance is greater than the max distance.
    if result.hit_distance > max_distance then
        return 0
    end

    return hit_id
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function PlayerInteraction.get_current_interaction_target_entity_id()
    return m_current_target_id
end

------------------------------------------------

function PlayerInteraction.get_current_interact_label()
    -- Check if the current target is valid.
    if not entity_get_is_valid(m_current_target_id) then
        return nil
    end

    -- Check if the current target has a get_interact_label function.
    if Utilities.get_entity_has_script_function(m_current_target_id, "get_interact_label") then
        local label = world_call_entity_script_function(m_current_target_id, "get_interact_label")
        if type(label) == "string" and label ~= "" then
            return label
        end
    end

    -- Return the default interact label.
    return "Interact"
end

------------------------------------------------

function PlayerInteraction.set_can_interact(t_enabled)
    m_can_interact = t_enabled == true
    if not m_can_interact then
        m_current_target_id = 0
    end
end

------------------------------------------------

function PlayerInteraction.get_interact_input_display()
    local binding = input_get_action_prompt_display_string(INTERACT_INPUT_KEY)
    if type(binding) == "string" and binding ~= "" then
        return binding
    end
    return "?"
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function PlayerInteraction.on_ready()
    -- Get player root from this script entity's parent.
    -- Gotta make sure the player is setup correctly.
    m_player_entity_id = entity_get_parent(entity_id)

    -- Check if the player entity ID is valid.
    if not entity_get_is_valid(m_player_entity_id) then
        print_error("[PlayerInteraction] Failed to resolve player entity from hierarchy.")
        return
    end

    -- Resolve the camera entity ID from the player entity ID.
    m_camera_entity_id = entity_get_child_by_name(m_player_entity_id, "camera")
    if not entity_get_is_valid(m_camera_entity_id) then
        print_error("[PlayerInteraction] Failed to resolve player camera child.")
        return
    end

    -- Reset the current target ID.
    m_current_target_id = 0
end

------------------------------------------------

function PlayerInteraction.on_process(_t_delta_time)
    if not m_can_interact then
        m_current_target_id = 0
        return
    end

    -- Get the current interactable entity ID.
    m_current_target_id = get_current_interactable_entity_id()

    -- Check if the interact input is pressed.
    if not input_get_action_pressed_event(INTERACT_INPUT_KEY) then
        return
    end

    -- Check if the target is valid.
    if not entity_get_is_valid(m_current_target_id) then
        return
    end

    -- Check if the target has an on_interact function.
    if not Utilities.get_entity_has_script_function(m_current_target_id, "on_interact") then
        print_error("[PlayerInteraction] Interactable target is missing on_interact.")
        return
    end

    -- World script runs first so map logic can run before the target handles the press.
    world_call_script_function("on_interact", m_current_target_id, true, m_player_entity_id)

    -- Call the on_interact function on the current target.
    world_call_entity_script_function(m_current_target_id, "on_interact", true, m_player_entity_id)
end

------------------------------------------------

function PlayerInteraction.on_shutdown()
    m_player_entity_id = 0
    m_camera_entity_id = 0
    m_current_target_id = 0
    m_can_interact = true
end

------------------------------------------------

return PlayerInteraction
