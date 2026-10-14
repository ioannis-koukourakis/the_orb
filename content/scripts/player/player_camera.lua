local PlayerCamera = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

local CAMERA_EFFECTS_MODULE = "CameraEffectsModule"

local DEFAULT_MOUSE_SENSITIVITY = 0.002
local GAMEPLAY_SETTINGS_SECTION = "Gameplay"
local MOUSE_LOOK_SENSITIVITY_KEY = "mouse_look_sensitivity"
local GAMEPAD_LOOK_SENSITIVITY_KEY = "gamepad_look_sensitivity"
local DEFAULT_GAMEPAD_LOOK_SENSITIVITY = 2.5
local DEFAULT_GAMEPAD_LOOK_DEADZONE = 0.18
local DEFAULT_MAX_PITCH_ANGLE_DEGREES = 83.0
local DEFAULT_CROUCH_HEIGHT_MULTIPLIER = 0.6
local DEFAULT_HEIGHT_TRANSITION_SPEED = 8.0

local INSPECT_ZOOM_FOV_MULTIPLIER = 0.65
local INSPECT_ZOOM_DEEP_FOV_MULTIPLIER = 0.5
local INSPECT_ZOOM_BLEND_SPEED = 5.0
local INSPECT_ZOOM_VIGNETTE_INTENSITY = 0.6
local INSPECT_ZOOM_VIGNETTE_COLOR = vec3(0.0, 0.0, 0.0)
local INSPECT_ZOOM_VIGNETTE_FADE_IN = 0.25
local INSPECT_ZOOM_VIGNETTE_FADE_OUT = 0.2

-- Smoothing factors for camera position and rotation.
-- Lower = more responsive, higher = smoother.
local CAMERA_SMOOTHING_POSITION_SAMPLES = 6
local CAMERA_SMOOTHING_ROTATION_SAMPLES = 3

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_camera_entity_id = 0
local m_body_entity_id = 0
local m_camera_pitch = 0.0
local m_camera_yaw = 0.0
local m_mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
local m_max_pitch_angle = math_radians(DEFAULT_MAX_PITCH_ANGLE_DEGREES)
local m_can_look_around = true
local m_can_zoom = true
local m_camera_base_local_position = vec3(0.0, 0.0, 0.0)
local m_camera_base_height = 0.0
local m_camera_height_multiplier = 1.0
local m_camera_target_height_multiplier = 1.0
local m_height_transition_speed = DEFAULT_HEIGHT_TRANSITION_SPEED
local m_base_fov = 65.0
local m_inspect_zoom_multiplier = 1.0
local m_inspect_vignette_active = false
local m_position_smoothing_enabled = true
local m_position_smoothing_samples = CAMERA_SMOOTHING_POSITION_SAMPLES
local m_position_history = {}
local m_rotation_smoothing_enabled = true
local m_rotation_smoothing_samples = CAMERA_SMOOTHING_ROTATION_SAMPLES
local m_pitch_history = {}
local m_yaw_history = {}

------------------------------------------------
-- HELPERS
------------------------------------------------

local function clear_smoothing_history()
    m_position_history = {}
    m_pitch_history = {}
    m_yaw_history = {}
end

------------------------------------------------

local function get_mouse_look_sensitivity_from_settings()
    return settings_get_float(GAMEPLAY_SETTINGS_SECTION, MOUSE_LOOK_SENSITIVITY_KEY, DEFAULT_MOUSE_SENSITIVITY)
end

------------------------------------------------

local function get_gamepad_look_sensitivity_from_settings()
    return settings_get_float(GAMEPLAY_SETTINGS_SECTION, GAMEPAD_LOOK_SENSITIVITY_KEY, DEFAULT_GAMEPAD_LOOK_SENSITIVITY)
end

------------------------------------------------

local function apply_gamepad_look_deadzone(t_value, t_delta_time)
    -- Calculate the magnitude of the value and if it is less than the deadzone, return 0.0.
    local magnitude = math.abs(t_value)
    if magnitude <= DEFAULT_GAMEPAD_LOOK_DEADZONE then
        return 0.0
    end

    -- Calculate the sign and normalized value and return the result.
    local sign = (t_value < 0.0) and -1.0 or 1.0
    local normalized = (magnitude - DEFAULT_GAMEPAD_LOOK_DEADZONE) / (1.0 - DEFAULT_GAMEPAD_LOOK_DEADZONE)
    local gamepad_look_sensitivity = get_gamepad_look_sensitivity_from_settings()
    return sign * normalized * gamepad_look_sensitivity * t_delta_time
end

------------------------------------------------

local function apply_camera_rotation()
    if not entity_get_is_valid(m_camera_entity_id) then
        return
    end

    -- Rotation smoothing if enabled.
    if m_rotation_smoothing_enabled and m_rotation_smoothing_samples > 0 then
        -- Add the current pitch and yaw to smoothing history.
        table.insert(m_pitch_history, m_camera_pitch)
        table.insert(m_yaw_history, m_camera_yaw)

        -- Remove the oldest pitch and yaw values if the history becomes too long.
        while #m_pitch_history > m_rotation_smoothing_samples do
            table.remove(m_pitch_history, 1)
        end
        while #m_yaw_history > m_rotation_smoothing_samples do
            table.remove(m_yaw_history, 1)
        end

        -- Calculate smoothed pitch.
        local pitch_sum = 0.0
        for i = 1, #m_pitch_history do
            pitch_sum = pitch_sum + m_pitch_history[i]
        end
        local smoothed_pitch = pitch_sum / #m_pitch_history

        -- Calculate smoothed yaw.
        local yaw_sum = 0.0
        for i = 1, #m_yaw_history do
            yaw_sum = yaw_sum + m_yaw_history[i]
        end
        local smoothed_yaw = yaw_sum / #m_yaw_history

        -- Set camera rotation.
        transform_set_local_rotation(
            m_camera_entity_id,
            vec3(math_degrees(smoothed_pitch), math_degrees(smoothed_yaw), 0.0)
        )
    -- otherwise set the camera rotation directly.
    else
        transform_set_local_rotation(
            m_camera_entity_id,
            vec3(math_degrees(m_camera_pitch), math_degrees(m_camera_yaw), 0.0)
        )
    end
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function PlayerCamera.initialize(t_camera_entity_id, t_settings, t_body_entity_id)
    m_camera_entity_id = t_camera_entity_id or 0
    m_body_entity_id = t_body_entity_id or 0
    clear_smoothing_history()

    -- Settings.
    m_mouse_sensitivity = get_mouse_look_sensitivity_from_settings()
    if t_settings then
        if type(t_settings.mouse_sensitivity) == "number" then
            m_mouse_sensitivity = t_settings.mouse_sensitivity
        end
        if type(t_settings.max_pitch_angle_degrees) == "number" then
            m_max_pitch_angle = math_radians(t_settings.max_pitch_angle_degrees)
        end
        if type(t_settings.height_transition_speed) == "number" then
            m_height_transition_speed = t_settings.height_transition_speed
        end
    end

    -- Set the base position and height.
    if entity_get_is_valid(m_camera_entity_id) then
        m_camera_base_local_position = transform_get_local_position(m_camera_entity_id)
        m_camera_base_height = m_camera_base_local_position.y
        m_base_fov = camera_get_default_fov(m_camera_entity_id) or camera_get_fov(m_camera_entity_id) or 65.0
        transform_set_interpolation_active(m_camera_entity_id, true)
    end
end

------------------------------------------------

function PlayerCamera.set_initial_rotation(t_yaw_radians, t_pitch_radians)
    m_camera_yaw = t_yaw_radians or 0.0
    m_camera_pitch = math_clamp(t_pitch_radians or 0.0, -m_max_pitch_angle, m_max_pitch_angle)
    clear_smoothing_history()

    -- Write camera facing now just in case look input may be locked this frame.
    apply_camera_rotation()
end

------------------------------------------------

function PlayerCamera.set_can_look_around(t_enabled)
    m_can_look_around = t_enabled == true
end

------------------------------------------------

function PlayerCamera.set_can_zoom(t_enabled)
    m_can_zoom = t_enabled == true
end

------------------------------------------------

function PlayerCamera.get_can_zoom()
    return m_can_zoom
end

------------------------------------------------

function PlayerCamera.get_is_inspect_zoom_active()
    if not m_can_look_around or not m_can_zoom or not input_get_mouse_capture() then
        return false
    end

    return input_get_is_action_pressed("select") or input_get_is_action_pressed("aim")
end

------------------------------------------------

function PlayerCamera.set_crouching(t_is_crouching)
    m_camera_target_height_multiplier = t_is_crouching and DEFAULT_CROUCH_HEIGHT_MULTIPLIER or 1.0
end

------------------------------------------------

function PlayerCamera.get_pitch_yaw()
    return m_camera_pitch, m_camera_yaw
end

------------------------------------------------

function PlayerCamera.process_look_input(t_delta_time)
    -- Make sure the camera is valid.
    if not entity_get_is_valid(m_camera_entity_id) then
        return
    end

    -- Update look input.
    if m_can_look_around then
        local look_x = 0.0
        local look_y = 0.0

        -- Get gamepad look input.
        if input_get_is_last_input_device_gamepad() and input_get_has_gamepad_connected() then
            local stick_x = input_get_gamepad_axis("right_x")
            local stick_y = input_get_gamepad_axis("right_y")
            look_x = apply_gamepad_look_deadzone(stick_x, t_delta_time)
            look_y = apply_gamepad_look_deadzone(stick_y, t_delta_time)
        -- Get mouse look input.
        else
            local mouse_delta = input_get_mouse_delta()
            local mouse_sensitivity = get_mouse_look_sensitivity_from_settings()
            look_x = mouse_delta.x * mouse_sensitivity
            look_y = mouse_delta.y * mouse_sensitivity
        end

        -- Match look speed to the zoom multiplier.
        look_x = look_x * m_inspect_zoom_multiplier
        look_y = look_y * m_inspect_zoom_multiplier

        -- Update the camera pitch and yaw.
        m_camera_yaw = m_camera_yaw - look_x
        m_camera_pitch = math_clamp(m_camera_pitch - look_y, -m_max_pitch_angle, m_max_pitch_angle)
    end

    -- Apply the lookat delta from the camera effects module.
    -- Keep this last so that it can override the player's look input.
    -- Scale the pull with the active look speed.
    if module_get_is_valid(CAMERA_EFFECTS_MODULE) then
        local lookat_delta = module_call_function(CAMERA_EFFECTS_MODULE, "get_camera_lookat_delta", t_delta_time, m_camera_entity_id, m_camera_pitch, m_camera_yaw)
        if lookat_delta ~= nil then
            local look_sensitivity_scale = m_inspect_zoom_multiplier
            if input_get_is_last_input_device_gamepad() and input_get_has_gamepad_connected() then
                look_sensitivity_scale = look_sensitivity_scale * (get_gamepad_look_sensitivity_from_settings() / DEFAULT_GAMEPAD_LOOK_SENSITIVITY)
            else
                look_sensitivity_scale = look_sensitivity_scale * (get_mouse_look_sensitivity_from_settings() / DEFAULT_MOUSE_SENSITIVITY)
            end

            m_camera_yaw = m_camera_yaw + (lookat_delta.y * look_sensitivity_scale)
            m_camera_pitch = math_clamp(m_camera_pitch + (lookat_delta.x * look_sensitivity_scale), -m_max_pitch_angle, m_max_pitch_angle)
        end
    end

    -- Apply the camera rotation.
    apply_camera_rotation()
end

------------------------------------------------

function PlayerCamera.process_position(t_delta_time)
    -- Make sure the camera and body are valid.
    if not entity_get_is_valid(m_camera_entity_id) or not entity_get_is_valid(m_body_entity_id) then
        return
    end

    -- Calculate the height lerp factor and apply it to the camera height multiplier.
    local height_lerp = math_clamp(m_height_transition_speed * t_delta_time, 0.0, 1.0)
    m_camera_height_multiplier = math_lerp(
        m_camera_height_multiplier,
        m_camera_target_height_multiplier,
        height_lerp
    )

    -- Calculate the body position and camera height.
    local body_position = transform_get_world_position(m_body_entity_id)
    local camera_height = m_camera_base_height * m_camera_height_multiplier

    -- Calculate the shake offset from the camera effects module.
    local shake_x = 0.0
    local shake_y = 0.0
    local shake_z = 0.0
    local vertigo_x = 0.0
    local vertigo_y = 0.0
    local vertigo_z = 0.0
    if module_get_is_valid(CAMERA_EFFECTS_MODULE) then
        local shake_offset = module_call_function(
            CAMERA_EFFECTS_MODULE,
            "get_camera_shake_world_offset",
            m_camera_yaw
        )
        shake_x = shake_offset.x
        shake_y = shake_offset.y
        shake_z = shake_offset.z

        local vertigo_offset = module_call_function(
            CAMERA_EFFECTS_MODULE,
            "get_vertigo_world_offset",
            m_camera_entity_id
        )
        vertigo_x = vertigo_offset.x
        vertigo_y = vertigo_offset.y
        vertigo_z = vertigo_offset.z
    end

    -- Calculate the desired camera position.
    local desired_camera_position = vec3(
        body_position.x + m_camera_base_local_position.x + shake_x + vertigo_x,
        body_position.y + camera_height + shake_y + vertigo_y,
        body_position.z + m_camera_base_local_position.z + shake_z + vertigo_z
    )

    -- Calculate the final position and apply smoothing if enabled.
    local final_position = desired_camera_position
    if m_position_smoothing_enabled and m_position_smoothing_samples > 0 then
        table.insert(m_position_history, desired_camera_position)

        while #m_position_history > m_position_smoothing_samples do
            table.remove(m_position_history, 1)
        end

        local sum_x, sum_y, sum_z = 0.0, 0.0, 0.0
        for i = 1, #m_position_history do
            local pos = m_position_history[i]
            sum_x = sum_x + pos.x
            sum_y = sum_y + pos.y
            sum_z = sum_z + pos.z
        end

        local count = #m_position_history
        final_position = vec3(sum_x / count, sum_y / count, sum_z / count)
    end

    -- Set the camera position.
    transform_set_world_position(m_camera_entity_id, final_position)
end

------------------------------------------------

function PlayerCamera.process_fov(t_delta_time)
    if not entity_get_is_valid(m_camera_entity_id) then
        return
    end

    -- Get the FOV fade and shake from the camera effects module.
    local effects_fov_fade = 1.0
    local effects_fov_shake = 0.0
    if module_get_is_valid(CAMERA_EFFECTS_MODULE) then
        effects_fov_fade = module_call_function(CAMERA_EFFECTS_MODULE, "get_fov_fade") or 1.0
        effects_fov_shake = module_call_function(CAMERA_EFFECTS_MODULE, "get_fov_shake") or 0.0
    end

    -- Hold select or aim to inspect. Both together zoom in further.
    local inspect_zoom_target = 1.0
    local select_pressed = input_get_is_action_pressed("select")
    local aim_pressed = input_get_is_action_pressed("aim")
    local wants_inspect_zoom = select_pressed or aim_pressed
    if m_can_look_around and m_can_zoom and input_get_mouse_capture() and wants_inspect_zoom then
        if select_pressed and aim_pressed then
            inspect_zoom_target = INSPECT_ZOOM_DEEP_FOV_MULTIPLIER
        else
            inspect_zoom_target = INSPECT_ZOOM_FOV_MULTIPLIER
        end
    end

    local zoom_blend = math_clamp(INSPECT_ZOOM_BLEND_SPEED * t_delta_time, 0.0, 1.0)
    m_inspect_zoom_multiplier = math_lerp(m_inspect_zoom_multiplier, inspect_zoom_target, zoom_blend)

    -- Add vignette effect for extra focus.
    if module_get_is_valid(CAMERA_EFFECTS_MODULE) then
        if inspect_zoom_target < 1.0 then
            if not m_inspect_vignette_active then
                module_call_function(CAMERA_EFFECTS_MODULE,
                                    "start_vignette",
                                    INSPECT_ZOOM_VIGNETTE_INTENSITY,
                                    INSPECT_ZOOM_VIGNETTE_COLOR,
                                    INSPECT_ZOOM_VIGNETTE_FADE_IN,
                                    -1.0,
                                    INSPECT_ZOOM_VIGNETTE_FADE_OUT
                                )
                m_inspect_vignette_active = true
            end
        elseif m_inspect_vignette_active then
            module_call_function(CAMERA_EFFECTS_MODULE, "stop_vignette", INSPECT_ZOOM_VIGNETTE_FADE_OUT)
            m_inspect_vignette_active = false
        end
    end

    -- Calculate the final FOV and set it.
    local final_fov = (m_base_fov * effects_fov_fade * m_inspect_zoom_multiplier) + effects_fov_shake
    camera_set_fov(m_camera_entity_id, final_fov)
end

------------------------------------------------

function PlayerCamera.on_shutdown()
    -- Stop vignette effect.
    if m_inspect_vignette_active and module_get_is_valid(CAMERA_EFFECTS_MODULE) then
        module_call_function(CAMERA_EFFECTS_MODULE, "stop_vignette", INSPECT_ZOOM_VIGNETTE_FADE_OUT)
    end

    -- Reset the camera.
    clear_smoothing_history()
    m_inspect_zoom_multiplier = 1.0
    m_inspect_vignette_active = false
    m_can_zoom = true
    m_camera_entity_id = 0
    m_body_entity_id = 0
end

------------------------------------------------

return PlayerCamera
