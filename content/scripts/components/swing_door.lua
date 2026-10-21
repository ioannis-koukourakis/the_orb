local SwingDoor = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local Easing = dofile("../content/scripts/shared/easing.lua")

------------------------------------------------
-- PARAMETERS
------------------------------------------------

--@PARAMETER can_interact BOOL true "Whether the player can interact with this door."
--@PARAMETER interaction_distance FLOAT 2.0 "Distance at which the player can interact."
--@PARAMETER open_angle FLOAT 89.0 "Degrees the door rotates to when fully open."
--@PARAMETER initial_angle FLOAT 0.0 "Initial angle of the door in degrees."
--@PARAMETER open_duration FLOAT 1.0 "Seconds to swing fully open."
--@PARAMETER close_duration FLOAT 1.0 "Seconds to swing fully closed."

------------------------------------------------
-- SETTINGS
------------------------------------------------

local DOOR_STATE_CLOSED = "closed"
local DOOR_STATE_OPEN = "open"
local DOOR_STATE_CLOSING = "closing"
local MIN_ANIMATION_DURATION = 0.0001

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_state = DOOR_STATE_CLOSED
local m_current_angle = 0.0
local m_target_angle = 0.0
local m_open_sign = 1.0
local m_is_animating = false
local m_anim_t = 0.0
local m_anim_start_angle = 0.0
local m_base_rotation_x = 0.0
local m_base_rotation_z = 0.0
local m_can_interact = true
local m_interaction_distance = 2.0
local m_open_angle_max = 89.0
local m_open_duration = 1.0
local m_close_duration = 1.0

------------------------------------------------
-- HELPERS
------------------------------------------------

local function apply_door_yaw(t_yaw_degrees)
    transform_set_local_rotation(entity_id, vec3(m_base_rotation_x, t_yaw_degrees, m_base_rotation_z))
end

------------------------------------------------

local function get_instigator_world_position(t_instigator_entity_id)
    -- Check if the instigator entity is valid.
    if not entity_get_is_valid(t_instigator_entity_id) then
        return nil
    end

    -- Get the body child.
    local body_id = entity_get_child_by_name(t_instigator_entity_id, "body")
    if entity_get_is_valid(body_id) then
        return transform_get_world_position(body_id)
    end

    -- Return the instigator's world position.
    return transform_get_world_position(t_instigator_entity_id)
end

------------------------------------------------

local function get_open_sign(t_instigator_entity_id)
    -- Swing away from whichever face of the door the instigator is standing on.
    -- Use door forward from face normal. 
    local door_pos = transform_get_world_position(entity_id)
    local instigator_pos = get_instigator_world_position(t_instigator_entity_id)
    if door_pos == nil or instigator_pos == nil then
        print_error("[SwingDoor] Missing door or instigator position for open sign.")
        return 1.0
    end

    -- Calculate the open sign.
    local door_forward = transform_get_world_forward(entity_id)
    local offset = vec3_sub(instigator_pos, door_pos)
    local side = vec3_dot(vec3(offset.x, 0.0, offset.z), vec3(door_forward.x, 0.0, door_forward.z))
    return (side >= 0.0) and -1.0 or 1.0
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function SwingDoor.get_can_interact()
    return m_can_interact
end

------------------------------------------------

function SwingDoor.get_interaction_distance()
    return m_interaction_distance
end

------------------------------------------------

function SwingDoor.get_interact_label()
    if m_state == DOOR_STATE_OPEN then
        return "Close"
    end
    return "Open"
end

------------------------------------------------

function SwingDoor.set_open(t_open, t_instigator_entity_id)
    -- If the door is opening, set the target angle to the open angle and set the state to open.
    if t_open and m_state ~= DOOR_STATE_OPEN then
        m_open_sign = get_open_sign(t_instigator_entity_id)
        m_target_angle = m_open_sign * m_open_angle_max
        m_state = DOOR_STATE_OPEN
        m_anim_start_angle = m_current_angle
        m_anim_t = 0.0
        m_is_animating = true

    -- If the door is closing, set the target angle to 0.0 and set the state to closing.
    elseif not t_open and m_state ~= DOOR_STATE_CLOSED then
        m_target_angle = 0.0
        m_state = DOOR_STATE_CLOSING
        m_anim_start_angle = m_current_angle
        m_anim_t = 0.0
        m_is_animating = true
    end
end

------------------------------------------------
-- CALLBACKS
------------------------------------------------

function SwingDoor.on_interact(t_is_pressed, t_instigator_entity_id)
    -- Makes sure we get triggere donly on button press. 
    if not t_is_pressed then
        return
    end

    -- Check if the door can be interacted with.
    if not m_can_interact then
        return
    end

    -- Check if the door is closed.
    if m_state == DOOR_STATE_CLOSED then
        SwingDoor.set_open(true, t_instigator_entity_id)
    -- Check if the door is open.
    elseif m_state == DOOR_STATE_OPEN then
        SwingDoor.set_open(false, t_instigator_entity_id)
    -- Check if the door is closing.
    elseif m_state == DOOR_STATE_CLOSING then
        SwingDoor.set_open(true, t_instigator_entity_id)
    end
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function SwingDoor.on_initialize()
    -- Set the initial state.
    m_state = DOOR_STATE_CLOSED
    m_current_angle = 0.0
    m_target_angle = 0.0
    m_open_sign = 1.0
    m_is_animating = false
    m_anim_t = 0.0
    m_anim_start_angle = 0.0

    -- Engine seeds @PARAMETER globals from the declarations above.
    m_can_interact = can_interact
    m_interaction_distance = interaction_distance
    m_open_angle_max = open_angle
    m_open_duration = math.max(open_duration, MIN_ANIMATION_DURATION)
    m_close_duration = math.max(close_duration, MIN_ANIMATION_DURATION)
end

------------------------------------------------

function SwingDoor.on_ready()
    -- Add the interactable tag if it is not already present.
    if not entity_get_has_tag(entity_id, "interactable") then
        entity_add_tag(entity_id, "interactable")
    end

    -- Get the base rotation.
    local current_rot = transform_get_local_rotation(entity_id)
    m_base_rotation_x = current_rot.x
    m_base_rotation_z = current_rot.z

    -- Set the current angle, target angle, and animation start angle.
    m_current_angle = initial_angle
    m_target_angle = initial_angle
    m_anim_start_angle = initial_angle
    apply_door_yaw(m_current_angle)
end

------------------------------------------------

function SwingDoor.on_process(t_delta_time)
    -- Check if the door is animating.
    if not m_is_animating then
        return
    end

    -- Check if the current angle is equal to the target angle.
    if m_current_angle == m_target_angle then
        m_is_animating = false
        return
    end

    -- Calculate the duration and eased value.
    local duration = (m_state == DOOR_STATE_CLOSING) and m_close_duration or m_open_duration
    m_anim_t = math.min(1.0, m_anim_t + t_delta_time / duration)
    local eased = Easing.in_out_quad(m_anim_t)

    -- Calculate the current angle.
    m_current_angle = m_anim_start_angle + (m_target_angle - m_anim_start_angle) * eased

    -- Check if the animation is complete.
    if m_anim_t >= 1.0 then
        m_current_angle = m_target_angle
        m_is_animating = false

        -- If the door is closing, set the current angle to 0.0 and set the state to closed.
        if m_state == DOOR_STATE_CLOSING then
            m_current_angle = 0.0
            m_state = DOOR_STATE_CLOSED
        end
    end

    -- Apply the door yaw.
    apply_door_yaw(m_current_angle)
end

------------------------------------------------

return SwingDoor
