-- @NOTE: Patrols until the player is seen, then stops and turns the headlamp toward them.

local DetectionAgent = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local MathHelpers = dofile("../content/scripts/shared/math_helpers.lua")

-- Load the PatrolAgent component.
-- We do this instead of using dofile because dofile uses _G environment by default. 
-- We want to load the file in the DetectionAgent environment (_ENV) so we can access the component.
local patrol_path = resolve_runtime_path("../content/scripts/components/patrol_agent.lua")
-- load fil returns function and error. _ENV is the environment to load the file in.
local load_patrol, load_patrol_error = loadfile(patrol_path, "t", _ENV) 
if load_patrol == nil then 
    error("[DetectionAgent] Failed to load PatrolAgent. " .. tostring(load_patrol_error))
end
-- call the function to get the component.
local PatrolAgent = load_patrol() 

----------------------------------------------------
-- PARAMETERS
----------------------------------------------------

--@PARAMETER_GROUP Movement
--@PARAMETER walk_speed FLOAT 2.0 "Patrol walk speed in meters per second."
--@PARAMETER turn_speed FLOAT 6.0 "Yaw follow speed in radians per second."
--@PARAMETER destination_reached_distance FLOAT 0.45 "Horizontal distance at which a pathnode counts as reached."
--@PARAMETER patrol_wait_time FLOAT 0.75 "Seconds to wait after reaching a patrol pathnode."
--@PARAMETER random_patrol BOOL false "if true, pick a random next pathnode, otherwise walk the folder in order."
--@PARAMETER patrol_points_folder STRING "patrol_points" "World folder name. Resolved once to an ID on ready."

--@PARAMETER_GROUP Vision
--@PARAMETER vision_distance FLOAT 14.0 "Horizontal range in meters."
--@PARAMETER vision_fov_deg FLOAT 70.0 "Full cone in degrees."
--@PARAMETER vision_exit_distance_extra FLOAT 1.5 "Extra meters allowed before losing the player at range."
--@PARAMETER vision_exit_fov_extra_deg FLOAT 8.0 "Extra half cone degrees allowed before losing the player at the cone edge."
--@PARAMETER vision_eye_height FLOAT 1.65 "Ray start height above the agent body."
--@PARAMETER vision_target_height FLOAT 1.1 "Ray end height above the player body."
--@PARAMETER player_entity_name STRING "player" "Resolved once to an ID on ready. Do not look this up every tick."

--@PARAMETER_GROUP Light
--@PARAMETER head_lights_group ENTITY "body/head_light" "Drop the lights folder onto this field."
--@PARAMETER head_light_socket STRING "head_light" "Skeletal socket on the mesh Head bone."
--@PARAMETER PLAYER_DETECTED_HEAD_LIGHT_COLOR COLOR 1.0,0.0,0.0 "Headlamp color while tracking the player."

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_is_tracking_player = false
local m_player_entity_id = 0
local m_player_body_entity_id = 0
local m_body_entity_id = 0
local m_head_lights_group_id = 0 -- The group of lights to turn on and off.
local m_head_light_entity_ids = {} -- The IDs of the lights in the group.
local m_idle_head_light_initial_colors = {}
local m_raycast_entities_to_ignore = {}
local m_vision_cos_limit = 1.0 -- The cosine limit of the vision cone.
local m_vision_exit_cos_limit = 1.0 -- The cosine limit of the vision cone when the player is at the edge of the vision cone.

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function set_lights_tracking_mode_active(t_is_tracking)
    for i = 1, #m_head_light_entity_ids do
        if t_is_tracking then
            light_set_color(m_head_light_entity_ids[i], PLAYER_DETECTED_HEAD_LIGHT_COLOR)
        else
            light_set_color(m_head_light_entity_ids[i], m_idle_head_light_initial_colors[i])
        end
    end
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function DetectionAgent.set_active(t_is_active)
    PatrolAgent.set_active(t_is_active)
    if not t_is_active then
        m_is_tracking_player = false
    end
end

----------------------------------------------------

function DetectionAgent.get_is_active()
    return PatrolAgent.get_is_active()
end

----------------------------------------------------

function DetectionAgent.get_is_tracking()
    return m_is_tracking_player
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function DetectionAgent.on_ready()
    PatrolAgent.on_ready()

    -- Get the id of the body entity.
    m_body_entity_id = PatrolAgent.get_body_entity_id()

    -- Get the ids of the player entity.
    m_player_entity_id = world_get_entity_by_name(player_entity_name)
    if not entity_get_is_valid(m_player_entity_id) then
        print_error("[DetectionAgent] Player entity '" .. tostring(player_entity_name) .. "' was not found.")
    else
        local player_body_id = entity_get_child_by_name(m_player_entity_id, "body")
        if entity_get_is_valid(player_body_id) then
            m_player_body_entity_id = player_body_id
        else
            print_error("[DetectionAgent] Player has no body child.")
        end
    end

    -- Initialize entity ids and initial head lights colors.
    m_head_lights_group_id = 0
    m_head_light_entity_ids = {}
    m_idle_head_light_initial_colors = {}

    -- Get the id of the head lights group.
    local group_path = file_manager_get_trimmed_string(head_lights_group ~= nil and head_lights_group or "")
    -- If the group path is empty let us know. 
    if group_path == "" then
        print_error("[DetectionAgent] head_lights_group is empty.")
    -- Otherwise get the id of the head lights group.
    else
        local group_id = entity_id
        if group_path ~= "." then
            group_id = entity_get_child_by_path(entity_id, group_path)
        end

        -- If the group id is not valid our setup is invalid so shout it out.
        if not entity_get_is_valid(group_id) then
            print_error("[DetectionAgent] head_lights_group not found. '" .. group_path .. "'.")
        -- Populate the entity ids and initial head lights colors.
        else
            m_head_lights_group_id = group_id
            local child_count = entity_get_children_count(group_id)
            for i = 1, child_count do
                local child_id = entity_get_child_by_index(group_id, i)
                if entity_get_is_valid(child_id) and entity_get_has_light_component(child_id) then
                    m_head_light_entity_ids[#m_head_light_entity_ids + 1] = child_id
                    local idle_color = light_get_color(child_id)
                    m_idle_head_light_initial_colors[#m_idle_head_light_initial_colors + 1] = vec3(idle_color.x, idle_color.y, idle_color.z)
                end
            end

            -- If no head lights are found print an error.
            if #m_head_light_entity_ids == 0 then
                print_error("[DetectionAgent] No Light components in head_lights_group.")
            end
        end
    end

    -- Ignore the sentry physics body so the LOS ray hits the world and the player.
    m_raycast_entities_to_ignore = { entity_id, m_body_entity_id }

    -- Calculate the cosine limits for the vision cone (half the full FOV).
    local vision_half_angle_deg = vision_fov_deg * 0.5
    m_vision_cos_limit = math.cos(math.rad(vision_half_angle_deg))
    m_vision_exit_cos_limit = math.cos(math.rad(vision_half_angle_deg + vision_exit_fov_extra_deg))

    -- Initialize tracking state.
    m_is_tracking_player = false
end

----------------------------------------------------

function DetectionAgent.on_fixed_process(t_timestep)
    if not entity_get_is_valid(m_body_entity_id) then
        return
    end

    -- Check if the player is in view.
    local can_see_player = false

    if entity_get_is_valid(m_player_body_entity_id) then
        -- Calculate the distance between the listener body (this agent) and the target body (player).
        local listener_position = transform_get_world_position(m_body_entity_id)
        local target_position = transform_get_world_position(m_player_body_entity_id)
        local distance_xz = MathHelpers.get_distance_xz(listener_position, target_position)

        -- While tracking keep a wider range and cone so the edge does not flicker.
        local max_distance = vision_distance
        local cos_limit = m_vision_cos_limit
        if m_is_tracking_player then
            max_distance = vision_distance + vision_exit_distance_extra
            cos_limit = m_vision_exit_cos_limit
        end

        -- If the player is within the maximum distance then check if they are in view.
        if distance_xz <= max_distance then
            -- Spotlight and body look along +Z (engine forward is -Z).
            local engine_forward = transform_get_world_forward(m_body_entity_id)
            local facing_x = -engine_forward.x
            local facing_z = -engine_forward.z
            local to_player_x = target_position.x - listener_position.x
            local to_player_z = target_position.z - listener_position.z

            -- If the player is standing on the listener then they are in view.
            if distance_xz <= 1.0 then
                can_see_player = true

            -- Raycast to check if the player is in view.
            else
                -- Check if the player is in the vision cone.
                local dot = math_clamp(((facing_x * to_player_x) + (facing_z * to_player_z)) / distance_xz, -1.0, 1.0)
                if dot >= cos_limit then
                    local ray_start = vec3(listener_position.x, listener_position.y + vision_eye_height, listener_position.z)
                    local ray_end = vec3(target_position.x, target_position.y + vision_target_height, target_position.z)
                    local ray_result = physics_raycast(
                        ray_start,
                        ray_end,
                        m_raycast_entities_to_ignore,
                        false,
                        PhysicsQuery.QUERY_GROUP_ALL,
                        PhysicsQuery.QUERY_MASK_NON_TRIGGER)
                    
                    -- if raycast hits nothing then the player is in view.
                    if ray_result == nil or ray_result.has_hit ~= true then
                        can_see_player = true
                    -- if raycast hits the player then the player is in view.
                    -- if raycast hits anything else then the player is not in view.
                    else
                        local hit_id = ray_result.hit_entity_id
                        if hit_id == m_player_entity_id or hit_id == m_player_body_entity_id then
                            can_see_player = true
                        end
                    end
                end
            end
        end
    end

    -- If the player is in view then start tracking and turn the headlamp toward them.
    if can_see_player then
        if not m_is_tracking_player then
            m_is_tracking_player = true
            PatrolAgent.set_active(false)
            set_lights_tracking_mode_active(true)
        end
        PatrolAgent.set_look_at_world_position(transform_get_world_position(m_player_body_entity_id), t_timestep)
        return
    end

    -- If the player is not in view then stop tracking and turn the headlamp away from them.
    if m_is_tracking_player then
        m_is_tracking_player = false
        set_lights_tracking_mode_active(false)
        PatrolAgent.set_active(true)
    end

    -- Continue the patrol.
    PatrolAgent.on_fixed_process(t_timestep)
end

----------------------------------------------------

function DetectionAgent.on_shutdown()
    PatrolAgent.on_shutdown()
end

----------------------------------------------------

return DetectionAgent
