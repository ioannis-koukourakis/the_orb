local FloatingPropGroup = {}

----------------------------------------------------
-- PARAMETERS
----------------------------------------------------

--@PARAMETER_GROUP Target
--@PARAMETER floating_children_container ENTITY "" "Child path under this entity, or drop a folder. Non-recursive mode drives only its direct children."
--@PARAMETER recursive BOOL false "Iterate descendants and drive every entity with a mesh."

--@PARAMETER_GROUP Motion
--@PARAMETER amplitude_x FLOAT 0.08 "Shared horizontal drift along world X in meters."
--@PARAMETER amplitude_y FLOAT 0.14 "Shared vertical float in meters."
--@PARAMETER amplitude_z FLOAT 0.08 "Shared horizontal drift along world Z in meters."
--@PARAMETER frequency_x FLOAT 0.35 "Shared float frequency on X in radians per second."
--@PARAMETER frequency_y FLOAT 0.53 "Shared float frequency on Y in radians per second."
--@PARAMETER frequency_z FLOAT 0.71 "Shared float frequency on Z in radians per second."
--@PARAMETER random_phase_offset BOOL true "Pick phase offsets from each child entity id on ready."
--@PARAMETER phase_x FLOAT 0.0 "Manual phase on X in radians when random is off."
--@PARAMETER phase_y FLOAT 0.0 "Manual phase on Y in radians when random is off."
--@PARAMETER phase_z FLOAT 0.0 "Manual phase on Z in radians when random is off."

--@PARAMETER_GROUP Orbit
--@PARAMETER enable_orbit BOOL false "Orbit each child entity around the container pivot on world Y."
--@PARAMETER orbit_speed_min FLOAT 2.0 "Slowest orbit in degrees per second per child entity."
--@PARAMETER orbit_speed_max FLOAT 8.0 "Fastest orbit in degrees per second per child entity."

--@PARAMETER_GROUP Spin
--@PARAMETER enable_spin BOOL false "Spin each child entity around world Y at its own rate."
--@PARAMETER spin_speed_min FLOAT 4.0 "Slowest spin in degrees per second per child entity."
--@PARAMETER spin_speed_max FLOAT 18.0 "Fastest spin in degrees per second per child entity."

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_container_id = 0
local m_floating_children = {}
local m_motion_time = 0.0
local m_is_ready = false

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function get_entity_hash(t_entity_id, t_salt)
    return math_fract(math.sin((t_entity_id + t_salt) * 12.9898) * 43758.5453)
end

----------------------------------------------------

local function add_floating_child(t_floating_child_entity_id, t_pivot_position)
    if not entity_get_is_valid(t_floating_child_entity_id) then
        return
    end

    if recursive == true and not entity_get_has_mesh_component(t_floating_child_entity_id) then
        return
    end

    local world_position = transform_get_world_position(t_floating_child_entity_id)
    local offset_x = world_position.x - t_pivot_position.x
    local offset_z = world_position.z - t_pivot_position.z

    local phase_x = phase_x
    local phase_y = phase_y
    local phase_z = phase_z
    if random_phase_offset == true then
        phase_x = get_entity_hash(t_floating_child_entity_id, 1.0) * (2.0 * math.pi)
        phase_y = get_entity_hash(t_floating_child_entity_id, 2.0) * (2.0 * math.pi)
        phase_z = get_entity_hash(t_floating_child_entity_id, 3.0) * (2.0 * math.pi)
    end

    local orbit_speed = 0.0
    if enable_orbit == true then
        local orbit_blend = get_entity_hash(t_floating_child_entity_id, 11.0)
        orbit_speed = math_radians(orbit_speed_min + ((orbit_speed_max - orbit_speed_min) * orbit_blend))
    end

    local spin_speed = 0.0
    if enable_spin == true then
        local spin_blend = get_entity_hash(t_floating_child_entity_id, 23.0)
        spin_speed = math_radians(spin_speed_min + ((spin_speed_max - spin_speed_min) * spin_blend))
    end

    local rest_rotation = transform_get_world_rotation(t_floating_child_entity_id)

    m_floating_children[#m_floating_children + 1] = {
        entity_id = t_floating_child_entity_id,
        rest_y = world_position.y,
        offset_x = offset_x,
        offset_z = offset_z,
        phase_x = phase_x,
        phase_y = phase_y,
        phase_z = phase_z,
        orbit_angle = 0.0,
        orbit_speed = orbit_speed,
        spin_angle = 0.0,
        spin_speed = spin_speed,
        rest_rotation_x = rest_rotation.x,
        rest_rotation_y = rest_rotation.y,
        rest_rotation_z = rest_rotation.z,
    }
end

----------------------------------------------------

local function collect_floating_children_recursive(t_entity_id, t_pivot_position)
    if not entity_get_is_valid(t_entity_id) then
        return
    end

    if entity_get_has_mesh_component(t_entity_id) then
        add_floating_child(t_entity_id, t_pivot_position)
    end

    local child_count = entity_get_children_count(t_entity_id)
    for child_index = 1, child_count do
        local child_id = entity_get_child_by_index(t_entity_id, child_index)
        collect_floating_children_recursive(child_id, t_pivot_position)
    end
end

----------------------------------------------------

local function collect_floating_children_from_container(t_container_id)
    if not entity_get_is_valid(t_container_id) then
        return
    end

    local pivot_position = transform_get_world_position(t_container_id)
    local child_count = entity_get_children_count(t_container_id)

    for child_index = 1, child_count do
        local child_id = entity_get_child_by_index(t_container_id, child_index)
        if recursive == true then
            collect_floating_children_recursive(child_id, pivot_position)
        elseif entity_get_is_valid(child_id) then
            add_floating_child(child_id, pivot_position)
        end
    end
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function FloatingPropGroup.on_ready()
    m_container_id = 0
    m_floating_children = {}
    m_motion_time = 0.0
    m_is_ready = false

    -- Early exit if container is empty.
    local container_path = file_manager_get_trimmed_string(floating_children_container ~= nil and floating_children_container or "")
    if container_path == "" then
        print_error("[FloatingPropGroup] floating_children_container is empty on entity '" .. tostring(entity_get_name(entity_id)) .. "'.")
        return
    end

    -- Grab the container entity ID once. 
    m_container_id = entity_id

    -- Set container ID from path if not root.
    if container_path ~= "." then
        m_container_id = entity_get_child_by_path(entity_id, container_path)
    end

    -- Early exit if container is invalid.
    if not entity_get_is_valid(m_container_id) then
        print_error("[FloatingPropGroup] floating_children_container not found: '" .. container_path .. "' on entity '" .. tostring(entity_get_name(entity_id)) .. "'.")
        return
    end

    -- Collect floating children from container.
    collect_floating_children_from_container(m_container_id)

    -- Early exit if no children found.
    if #m_floating_children == 0 then
        print_error("[FloatingPropGroup] No child entities to drive under '" .. container_path .. "' on entity '" .. tostring(entity_get_name(entity_id)) .. "'.")
        return
    end

    m_is_ready = true
end

----------------------------------------------------

function FloatingPropGroup.on_process(t_delta_time)
    -- Early exit if not ready.
    if not m_is_ready then
        return
    end

    -- Early exit if container is invalid.
    if not entity_get_is_valid(m_container_id) then
        print_error("[FloatingPropGroup] container is invalid on entity '" .. tostring(entity_get_name(entity_id)) .. "'.")
        return
    end

    -- Update motion time.
    m_motion_time = m_motion_time + t_delta_time
    local pivot_position = transform_get_world_position(m_container_id)

    -- Apply motion to each child entity.
    for floating_child_index = 1, #m_floating_children do
        local floating_child = m_floating_children[floating_child_index]
        if entity_get_is_valid(floating_child.entity_id) then
            -- Calculate offsets.
            local float_offset_x = amplitude_x * math.sin((m_motion_time * frequency_x) + floating_child.phase_x)
            local float_offset_y = amplitude_y * math.sin((m_motion_time * frequency_y) + floating_child.phase_y)
            local float_offset_z = amplitude_z * math.sin((m_motion_time * frequency_z) + floating_child.phase_z)
            local offset_x = floating_child.offset_x
            local offset_z = floating_child.offset_z

            -- Orbiting around container pivot on world Y.
            if enable_orbit == true then
                floating_child.orbit_angle = floating_child.orbit_angle + (floating_child.orbit_speed * t_delta_time)
                local cos_angle = math.cos(floating_child.orbit_angle)
                local sin_angle = math.sin(floating_child.orbit_angle)
                offset_x = (floating_child.offset_x * cos_angle) - (floating_child.offset_z * sin_angle)
                offset_z = (floating_child.offset_x * sin_angle) + (floating_child.offset_z * cos_angle)
            end

            -- Apply position to child entity.
            local world_position = vec3(
                pivot_position.x + offset_x + float_offset_x,
                floating_child.rest_y + float_offset_y,
                pivot_position.z + offset_z + float_offset_z)

            transform_set_world_position(floating_child.entity_id, world_position)

            -- Spinning in place on world Y.
            if enable_spin == true then
                floating_child.spin_angle = floating_child.spin_angle + (floating_child.spin_speed * t_delta_time)
                transform_set_world_rotation(floating_child.entity_id,
                                            vec3(
                                                floating_child.rest_rotation_x,
                                                floating_child.rest_rotation_y + math_degrees(floating_child.spin_angle),
                                                floating_child.rest_rotation_z))
            end
        end
    end
end

----------------------------------------------------

return FloatingPropGroup
