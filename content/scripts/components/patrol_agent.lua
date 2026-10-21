-- @NOTE: Patrols transform children of a named world folder via A* pathfinding + character walk.

local PatrolAgent = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local MathHelpers = dofile("../content/scripts/shared/math_helpers.lua")

----------------------------------------------------
-- PARAMETERS
----------------------------------------------------

--@PARAMETER_GROUP Movement
--@PARAMETER walk_speed FLOAT 2.0 "Patrol walk speed in meters per second."
--@PARAMETER turn_speed FLOAT 3.0 "Yaw follow speed in radians per second."
--@PARAMETER destination_reached_distance FLOAT 0.45 "Horizontal distance at which a waypoint counts as reached."
--@PARAMETER patrol_wait_time FLOAT 1.5 "Seconds to wait after reaching a patrol waypoint."
--@PARAMETER random_patrol BOOL true "Pick a random next waypoint instead of walking the folder in order."
--@PARAMETER random_patrol BOOL true "Pick random PathNodes as goals so many agents do not share a few markers."
--@PARAMETER patrol_points_folder STRING "patrol_points" "World folder name. Resolved once to an ID on ready."

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local ANIM_BLEND_TIME = 0.25
local PATH_BLOCKING_RADIUS = 0.18
local PATH_BLOCKING_HEIGHT = 0.9
local PATH_BLOCKING_LAYERS_TO_CHECK = PhysicsQuery.LAYER_STATIC + PhysicsQuery.LAYER_KINEMATIC + PhysicsQuery.LAYER_DYNAMIC
local AGENT_OCCUPIED_SPACE_PADDING = 0.25 -- Extra XY space around each capsule. Used for goal picking and crowd push.
local FIND_UNOCCUPIED_DESTINATION_ATTEMPTS_COUNT = 12 -- The number of attempts to find a non-occupied goal.
local NEARBY_AGENT_PUSH_OFF_SPEED = 2.4

local ANIM_STATE_NONE = 0
local ANIM_STATE_IDLE = 1
local ANIM_STATE_WALK = 2

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_is_active = true

local m_patrol_points_entity_id = 0
local m_goal_positions = {}
local m_goal_index = 1
local m_path = {}
local m_path_index = 1
local m_path_wait_timer = 0.0
local m_body_entity_id = 0
local m_mesh_entity_id = 0
local m_current_animation = ANIM_STATE_NONE
local m_current_yaw = 0.0 

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function collect_patrol_goals()
    m_goal_positions = {}

    -- Collect PathNodes from the world.
    if random_patrol then
        local node_ids = world_get_entities_with_component("PathNode")
        for i = 1, #node_ids do
            local node_id = node_ids[i]
            if entity_get_is_valid(node_id) then
                m_goal_positions[#m_goal_positions + 1] = transform_get_world_position(node_id)
            end
        end
        return
    end

    -- Collect patrol points from the related group entity.
    if not entity_get_is_valid(m_patrol_points_entity_id) then
        return
    end

    -- Add children to the patrol points list. 
    -- Note that patrol points are simple transform markers, not PathNodes. We only need positions. 
    local child_count = entity_get_children_count(m_patrol_points_entity_id)
    for i = 1, child_count do
        local point_id = entity_get_child_by_index(m_patrol_points_entity_id, i)
        if entity_get_is_valid(point_id) then
            m_goal_positions[#m_goal_positions + 1] = transform_get_world_position(point_id)
        end
    end
end

----------------------------------------------------

local function get_random_goal_index(t_exclude_index)
    -- Are there any goals?
    local count = #m_goal_positions
    if count <= 1 then
        return 1
    end

    -- No exclusion. Any goal is valid.
    if t_exclude_index < 1 then
        return math.random(count)
    end

    -- Get a random index. 
    -- Skip the goal just reached so the agent does not idle in place.
    local next_index = math.random(count - 1)
    if next_index >= t_exclude_index then
        next_index = next_index + 1
    end

    return next_index
end

----------------------------------------------------

local function get_other_npc_body_ids()
    local other_ids = {}
    local npc_ids = world_get_entities_by_tag("npc")
    for i = 1, #npc_ids do
        local other_id = npc_ids[i]
        if entity_get_is_valid(other_id) and other_id ~= m_body_entity_id then
            other_ids[#other_ids + 1] = other_id
        end
    end
    return other_ids
end

----------------------------------------------------

local function get_occupied_space_radius(t_other_entity_id)
    local self_radius = character_body_get_capsule_radius(m_body_entity_id)
    local other_radius = character_body_get_capsule_radius(t_other_entity_id)
    return self_radius + AGENT_OCCUPIED_SPACE_PADDING + other_radius + AGENT_OCCUPIED_SPACE_PADDING
end

----------------------------------------------------

local function get_is_path_blocked(t_from, t_to)
    -- Are the points too close?
    local dx = t_to.x - t_from.x
    local dz = t_to.z - t_from.z
    if (dx * dx) + (dz * dz) < 0.0001 then
        return false
    end

    -- Sweep a capsule from the from point to the to point.
    local sweep_from = vec3(t_from.x, t_from.y + PATH_BLOCKING_HEIGHT, t_from.z)
    local sweep_to = vec3(t_to.x, t_to.y + PATH_BLOCKING_HEIGHT, t_to.z)
    local hit = physics_sphere_sweep(
        sweep_from,                     -- From point.
        sweep_to,                       -- To point.
        PATH_BLOCKING_RADIUS,           -- Sweep radius.
        { m_body_entity_id },           -- Ignore self.
        false,                          -- Do not return hits.
        PhysicsQuery.QUERY_GROUP_ALL,   -- Query all groups.
        PATH_BLOCKING_LAYERS_TO_CHECK)  -- Filter layers to check.

    -- Did we hit something?
    return hit ~= nil and hit.has_hit == true
end

----------------------------------------------------

local function get_crowd_separation_xz(t_self_position, t_delta_time)
    -- Push off nearby NPCs.
    local push_x = 0.0
    local push_z = 0.0
    local other_ids = get_other_npc_body_ids()
    for i = 1, #other_ids do
        -- Get the occupied space radius of the other NPC.
        local occupied_radius = get_occupied_space_radius(other_ids[i])
        local occupied_radius_sq = occupied_radius * occupied_radius
        local other_position = transform_get_world_position(other_ids[i])

        -- Calculate the distance between the self and the other NPC.
        local away_x = t_self_position.x - other_position.x
        local away_z = t_self_position.z - other_position.z
        local away_dist_sq = (away_x * away_x) + (away_z * away_z)

        -- If the distance is less than the occupied space radius, calculate the push vector.
        if away_dist_sq > 0.0001 and away_dist_sq < occupied_radius_sq then
            local away_dist = math.sqrt(away_dist_sq)
            local strength = (occupied_radius - away_dist) / occupied_radius
            push_x = push_x + (away_x / away_dist) * strength
            push_z = push_z + (away_z / away_dist) * strength
        end
    end

    -- Normalize the push vector.
    local push = vec3(push_x, 0.0, push_z)
    if vec3_length(push) > 1.0 then
        push = vec3_normalize(push)
    end

    -- Scale the push vector by the speed and the delta time.
    local separate_scale = NEARBY_AGENT_PUSH_OFF_SPEED * t_delta_time
    return push_x * separate_scale, push_z * separate_scale
end

----------------------------------------------------

local function begin_path_to_patrol_target()
    -- Reset the path.
    m_path = {}
    m_path_index = 1

    -- Are there any goals?
    if #m_goal_positions == 0 then
        return false
    end

    -- Is the goal index valid?
    if m_goal_index < 1 or m_goal_index > #m_goal_positions then
        m_goal_index = 1
    end

    -- Try to find an unoccupied goal.
    local other_ids = get_other_npc_body_ids()
    for _ = 1, FIND_UNOCCUPIED_DESTINATION_ATTEMPTS_COUNT do
        local candidate_position = m_goal_positions[m_goal_index]

        -- Check if the goal is occupied by another NPC.
        local occupied = false
        for i = 1, #other_ids do
            local occupy_radius = get_occupied_space_radius(other_ids[i])
            local other_position = transform_get_world_position(other_ids[i])
            local occupy_dx = other_position.x - candidate_position.x
            local occupy_dz = other_position.z - candidate_position.z
            if (occupy_dx * occupy_dx) + (occupy_dz * occupy_dz) < occupy_radius * occupy_radius then
                occupied = true
                break
            end
        end

        -- If the goal is not occupied, break the loop.
        if not occupied then
            break
        end

        -- If random_patrol is on, get a random goal index.
        if random_patrol then
            m_goal_index = get_random_goal_index(m_goal_index)
        -- If random_patrol is off, increment the goal index.
        else
            m_goal_index = m_goal_index + 1
            -- If the goal index is greater than the number of goals, reset it to 1.
            if m_goal_index > #m_goal_positions then
                m_goal_index = 1
            end
        end
    end

    -- Character controllers move the body entity child while the root transform stays at spawn spoition.
    local query_entity_id = entity_id
    if entity_get_is_valid(m_body_entity_id) then
        query_entity_id = m_body_entity_id
    end

    
    local self_position = transform_get_world_position(query_entity_id)
    local start_node = pathfinding_find_nearest_node(self_position)
    local goal_position = m_goal_positions[m_goal_index]
    local goal_node = pathfinding_find_nearest_node(goal_position)
    if start_node == nil or goal_node == nil then
        print_warning("[PatrolAgent] Missing start/goal path node.")
        return false
    end

    -- If the start and goal nodes are the same, set the path to the goal node.
    if start_node == goal_node then
        m_path = { goal_node }
    -- If the start and goal nodes are not the same, find a path between them.
    else
        local path = pathfinding_find_path(start_node, goal_node)
        if path == nil or #path == 0 then
            print_warning("[PatrolAgent] No path to patrol goal " .. tostring(m_goal_index))
            m_path = {}
            return false
        end
        m_path = path
    end

    -- Skip path nodes already inside arrive range.
    -- Do not skip the A* start when the agent is not on it.
    m_path_index = 1
    while m_path_index <= #m_path do
        local skip_position = transform_get_world_position(m_path[m_path_index])
        -- Calculate the distance between the self and the skip position.
        local skip_dx = skip_position.x - self_position.x
        local skip_dz = skip_position.z - self_position.z

        -- If the distance is greater than the destination reached distance, break the loop.
        if math.sqrt(skip_dx * skip_dx + skip_dz * skip_dz) > destination_reached_distance then
            break
        end

        -- If the path is blocked, break the loop. Do not walk into walls.
        if get_is_path_blocked(self_position, skip_position) then
            break
        end

        -- Increment the path index.
        m_path_index = m_path_index + 1
    end

    -- Make sure the path index is not greater than the number of path nodes.
    if m_path_index > #m_path then
        m_path_index = #m_path
    end

    -- Path was found.
    return true
end

----------------------------------------------------

local function play_animation(t_animation)
    if not entity_get_is_valid(m_mesh_entity_id) then
        return
    end

    -- Skip unnecessary animation changes.
    if t_animation == m_current_animation then
        return
    end

    -- Play animation.
    m_current_animation = t_animation
    
    -- Walk
    if t_animation == ANIM_STATE_WALK then
        animation_play(m_mesh_entity_id, "walk_loop", true, 0.0, ANIM_BLEND_TIME)
    -- Idle
    else
        animation_play(m_mesh_entity_id, "idle_loop", true, 0.0, ANIM_BLEND_TIME)
    end
end

----------------------------------------------------

local function stop_walking()
    -- Reset walk direction to stop moving.
    if entity_get_is_valid(m_body_entity_id) then
        character_body_set_walk_direction(m_body_entity_id, vec3(0.0, 0.0, 0.0))
    end

    -- Play idle animation.
    play_animation(ANIM_STATE_IDLE)
end

----------------------------------------------------

local function get_body_yaw()
    local forward = transform_get_world_forward(m_body_entity_id)
    return math_atan2(-forward.x, -forward.z)
end

----------------------------------------------------

local function face_target(t_dx, t_dz, t_delta_time)
    -- Mannequin visual forward is +Z. Engine forward is -Z.
    m_current_yaw = get_body_yaw()
    local target_yaw = math_atan2(t_dx, t_dz)
    local yaw_delta = MathHelpers.get_shortest_angle_distance_rad(m_current_yaw, target_yaw)
    local max_yaw_step = turn_speed * t_delta_time
    local is_facing = math_abs(yaw_delta) <= max_yaw_step
    
    -- If the agent is facing the target, set the current yaw to the target yaw.
    if is_facing then
        m_current_yaw = target_yaw
    -- If the agent is not facing the target, turn towards it.
    -- If the yaw delta is greater than 0, turn clockwise.
    elseif yaw_delta > 0.0 then
        m_current_yaw = m_current_yaw + max_yaw_step
    -- If the yaw delta is less than 0, turn counter-clockwise.
    else
        m_current_yaw = m_current_yaw - max_yaw_step
    end

    -- Set the body yaw.
    character_body_set_world_yaw(m_body_entity_id, m_current_yaw)
    return is_facing
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function PatrolAgent.set_active(t_is_active)
    m_is_active = t_is_active
    if not m_is_active then
        stop_walking()
    end
end

----------------------------------------------------

function PatrolAgent.get_is_active()
    return m_is_active
end

----------------------------------------------------

function PatrolAgent.get_body_entity_id()
    return m_body_entity_id
end

----------------------------------------------------

function PatrolAgent.set_look_at_world_position(t_position, t_delta_time)
    if not entity_get_is_valid(m_body_entity_id) then
        return
    end

    -- Get the distance between the self and the target position.
    local self_position = transform_get_world_position(m_body_entity_id)
    local dx = t_position.x - self_position.x
    local dz = t_position.z - self_position.z
    -- Already at the target position. Do not turn.
    if (dx * dx) + (dz * dz) < 0.0001 then
        return
    end

    -- Turn towards the target position.
    face_target(dx, dz, t_delta_time)
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function PatrolAgent.on_ready()
    -- Get the body Entity ID.
    m_body_entity_id = entity_id
    local body_child = entity_get_child_by_name(entity_id, "body")
    if entity_get_is_valid(body_child) then
        m_body_entity_id = body_child
    end

    -- Get the mesh entity ID.
    local mesh_child = entity_get_child_by_name(m_body_entity_id, "mesh")
    if entity_get_is_valid(mesh_child) and entity_get_has_animation_component(mesh_child) then
        m_mesh_entity_id = mesh_child

        -- Play idle animation.
        play_animation(ANIM_STATE_IDLE)
    end

    -- Enable body interpolation for smooth movement.
    -- (Can also be done in the character body component UI).
    transform_set_interpolation_active(m_body_entity_id, true)
    m_current_yaw = get_body_yaw()

    -- Get the patrol points entity ID.
    if not random_patrol then
        m_patrol_points_entity_id = world_get_entity_by_name(patrol_points_folder)
        if not entity_get_is_valid(m_patrol_points_entity_id) then
            print_warning("[PatrolAgent] patrol_points_folder not found. '" .. tostring(patrol_points_folder) .. "'.")
        end
    end

    -- Collect patrol goals.
    collect_patrol_goals()

    -- No patrol goals. Print a warning.
    if #m_goal_positions == 0 then
        if random_patrol then
            print_warning("[PatrolAgent] No PathNodes for random_patrol.")
        else
            print_warning("[PatrolAgent] No patrol points under folder '" .. tostring(patrol_points_folder) .. "'.")
        end
        return
    end

    -- print_info("[PatrolAgent] Patrol waypoints: " .. tostring(#m_goal_positions))

    -- Seed from this entity so several agents do not share the same roll sequence.
    if random_patrol then
        math.randomseed(entity_id)
        m_goal_index = get_random_goal_index(0)
    end

    -- Begin path to patrol target.
    begin_path_to_patrol_target()
end

----------------------------------------------------

function PatrolAgent.on_fixed_process(t_timestep)
    if not m_is_active then
        return
    end

    -- No body entity. Do nothing.
    if not entity_get_is_valid(m_body_entity_id) then
        return
    end

    -- No patrol goals. Stop walking.
    if #m_goal_positions == 0 then
        stop_walking()
        return
    end

    -- Wait for the path wait timer to finish.
    if m_path_wait_timer > 0.0 then
        m_path_wait_timer = m_path_wait_timer - t_timestep
        stop_walking()
        if m_path_wait_timer <= 0.0 then
            -- Get a new goal index.
            if #m_goal_positions > 0 then
                -- Random
                if random_patrol then
                    m_goal_index = get_random_goal_index(m_goal_index)
                -- Sequential
                else
                    m_goal_index = m_goal_index + 1
                    if m_goal_index > #m_goal_positions then
                        m_goal_index = 1
                    end
                end

                -- Begin path to patrol target.
                begin_path_to_patrol_target()
            end
        end
        return
    end

    -- No path. Stop walking.
    if m_path == nil or #m_path == 0 or m_path_index > #m_path then
        stop_walking()
        m_path_wait_timer = patrol_wait_time
        return
    end

    -- Get the next waypoint.
    local waypoint_id = 0
    local dx = 0.0
    local dz = 0.0
    local distance = 0.0
    while m_path_index <= #m_path do
        -- Get the waypoint entity ID.
        waypoint_id = m_path[m_path_index]
        -- Waypoint is invalid. Stop walking.
        if not entity_get_is_valid(waypoint_id) then
            stop_walking()
            begin_path_to_patrol_target()
            return
        end

        -- Get the self position.
        local self_position = transform_get_world_position(m_body_entity_id)
        local waypoint_position = transform_get_world_position(waypoint_id)
        -- Calculate the distance between the self and the waypoint.
        dx = waypoint_position.x - self_position.x
        dz = waypoint_position.z - self_position.z
        distance = math.sqrt(dx * dx + dz * dz)
        -- Path is blocked. Stop walking. Do not walk into walls.
        if get_is_path_blocked(self_position, waypoint_position) then
            stop_walking()
            m_path_wait_timer = patrol_wait_time
            return
        end
        -- Waypoint is too far. Break the loop and continue with the next waypoint.
        if distance > destination_reached_distance then
            break
        end
        -- Increment the path index.
        m_path_index = m_path_index + 1
    end

    -- No more waypoints. Stop walking.
    if m_path_index > #m_path then
        stop_walking()
        m_path_wait_timer = patrol_wait_time
        return
    end

    -- Face the next waypoint.
    local is_facing_waypoint = face_target(dx, dz, t_timestep)

    -- Play walk animation.
    play_animation(ANIM_STATE_WALK)

    -- Not facing the waypoint. Stop walking. Do not slide until facing it.
    if not is_facing_waypoint then
        character_body_set_walk_direction(m_body_entity_id, vec3(0.0, 0.0, 0.0))
        return
    end

    -- Calculate the walk scale.
    local walk_scale = walk_speed * t_timestep / distance
    local path_x = dx * walk_scale
    local path_z = dz * walk_scale

    -- Push off nearby NPCs. Capsules are thinner than the mesh, so they fuse without this.
    -- Get the self position.
    local self_position = transform_get_world_position(m_body_entity_id)
    -- Get the push vector.
    local push_x, push_z = get_crowd_separation_xz(self_position, t_timestep)
    -- Calculate the walk vector.
    local walk_x = path_x + push_x
    local walk_z = path_z + push_z
    local stepped_position = vec3(self_position.x + walk_x, self_position.y, self_position.z + walk_z)
    if get_is_path_blocked(self_position, stepped_position) then
        local push_position = vec3(self_position.x + push_x, self_position.y, self_position.z + push_z)
        if ((push_x * push_x) + (push_z * push_z)) > 0.0000001 and not get_is_path_blocked(self_position, push_position) then
            walk_x = push_x
            walk_z = push_z
        else
            walk_x = path_x
            walk_z = path_z
        end
    end

    -- Set the walk direction.
    character_body_set_walk_direction(m_body_entity_id, vec3(walk_x, 0.0, walk_z))
end

----------------------------------------------------

function PatrolAgent.on_shutdown()
    stop_walking()
end

----------------------------------------------------

return PatrolAgent
