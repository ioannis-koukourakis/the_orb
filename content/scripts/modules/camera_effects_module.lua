local CameraEffects = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local CameraShakeEffect = dofile("../content/scripts/camera_effects/camera_shake_effect.lua")
local FovShakeEffect = dofile("../content/scripts/camera_effects/fov_shake_effect.lua")
local FovFadeEffect = dofile("../content/scripts/camera_effects/fov_fade_effect.lua")
local VignetteEffect = dofile("../content/scripts/camera_effects/vignette_effect.lua")
local Ps1FilterEffect = dofile("../content/scripts/camera_effects/ps1_filter_effect.lua")
local RadialBlurEffect = dofile("../content/scripts/camera_effects/radial_blur_effect.lua")
local ImageTrailEffect = dofile("../content/scripts/camera_effects/image_trail_effect.lua")
local VertigoEffect = dofile("../content/scripts/camera_effects/vertigo_effect.lua")
local ScreenFadeEffect = dofile("../content/scripts/camera_effects/screen_fade_effect.lua")
local CameraLookAtEffect = dofile("../content/scripts/camera_effects/camera_lookat_effect.lua")
local MotionBlur = dofile("../content/scripts/camera_effects/motion_blur.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

-- Custom post process pass indices.
local VIGNETTE_PASS_INDEX = 1
local VIGNETTE_SHADER_FILE = "../content/shaders/vignette.frag.glsl"
local VIGNETTE_IMG_FILE = "../content/graphics/demo_content/vignette.png"
-- vignette.frag.glsl u_params. x = pulse rate in Hz (0 = steady). yzw unused.
-- Intensity and tint use renderer_set_custom_post_process_intensity / _color, not this vec4.
local VIGNETTE_PARAMS = vec4(0.0, 0.0, 0.0, 0.0)

local PS1_FILTER_PASS_INDEX = 2
local PS1_FILTER_SHADER_FILE = "../content/shaders/ps1_filter.frag.glsl"
-- ps1_filter.frag.glsl u_params. x = pixel scale, y = color bits, z = dither strength. w unused.
local PS1_FILTER_PARAMS = vec4(4.0, 5.0, 0.75, 0.0)

-- Accumulation modes for the different effect types that support multiple instances all at once. 
local ACCUM_VECTOR3_ADD      = 1
local ACCUM_SCALAR_MULTIPLY  = 2
local ACCUM_SCALAR_ADD       = 3
local ACCUM_COMPOUND_VERTIGO = 4
local ACCUM_ADD_INTENSITY    = 5

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_next_effect_id = 1
local m_id_to_instance = {}

local m_camera_shake_instances = {}
local m_fov_shake_instances = {}
local m_fov_fade_instances = {}
local m_radial_blur_instances = {}
local m_image_trail_instances = {}
local m_vertigo_effect_instances = {}

local m_vignette_effect = nil
local m_ps1_filter_effect = nil
local m_screen_fade_effect = nil
local m_camera_lookat_effect = nil

local m_current_camera_shake = vec3(0.0, 0.0, 0.0)
local m_current_fov_multiplier = 1.0
local m_current_fov_shake = 0.0
local m_current_vignette_intensity = 0.0
local m_current_ps1_filter_intensity = 0.0
local m_current_screen_fade_intensity = 0.0
local m_current_screen_fade_color = vec3(0.0, 0.0, 0.0)
local m_current_radial_blur_intensity = 0.0
local m_current_image_trail_intensity = 0.0
local m_current_vertigo_fov_multiplier = 1.0
local m_current_vertigo_camera_offset = 0.0
local m_current_vignette_color = vec3(0.0, 0.0, 0.0)

local m_accumulated_world_offset = vec3(0.0, 0.0, 0.0)
local m_accumulated_fov_fade = { value = 1.0 }
local m_accumulated_fov_shake = { value = 0.0 }
local m_accumulated_vertigo = { fov_multiplier = 1.0, camera_offset = 0.0 }
local m_accumulated_radial_blur  = { value = 0.0 }
local m_accumulated_image_trail  = { value = 0.0 }

------------------------------------------------
-- HELPERS
------------------------------------------------

local function set_no_vignette_effect()
    renderer_set_custom_post_process_active(VIGNETTE_PASS_INDEX, false)
    renderer_set_custom_post_process_intensity(VIGNETTE_PASS_INDEX, 0.0)
    renderer_set_custom_post_process_color(VIGNETTE_PASS_INDEX, vec3(0.0, 0.0, 0.0))
end

------------------------------------------------

local function set_vignette_effect(t_intensity, t_color)
    local intensity = t_intensity
    if intensity > 1.0 then
        intensity = 1.0
    end

    if intensity <= 0.0 then
        set_no_vignette_effect()
        return
    end

    renderer_set_custom_post_process_intensity(VIGNETTE_PASS_INDEX, intensity)
    renderer_set_custom_post_process_color(VIGNETTE_PASS_INDEX, t_color)
    renderer_set_custom_post_process_active(VIGNETTE_PASS_INDEX, true)
end

------------------------------------------------

local function set_no_ps1_filter_effect()
    renderer_set_custom_post_process_active(PS1_FILTER_PASS_INDEX, false)
    renderer_set_custom_post_process_intensity(PS1_FILTER_PASS_INDEX, 0.0)
    m_current_ps1_filter_intensity = 0.0
end

------------------------------------------------

local function set_ps1_filter_effect(t_intensity)
    local intensity = t_intensity
    if intensity < 0.0 then
        intensity = 0.0
    end

    if intensity <= 0.0 then
        set_no_ps1_filter_effect()
        return
    end

    renderer_set_custom_post_process_intensity(PS1_FILTER_PASS_INDEX, intensity)
    renderer_set_custom_post_process_active(PS1_FILTER_PASS_INDEX, true)
    m_current_ps1_filter_intensity = intensity
end

------------------------------------------------

local function get_next_effect_id()
    local id = m_next_effect_id
    m_next_effect_id = m_next_effect_id + 1
    return id
end

------------------------------------------------

local function register_instance(t_instance)
    local id = t_instance:get_id()
    m_id_to_instance[id] = t_instance
    return id
end

------------------------------------------------

local function unregister_instance(t_instance)
    local id = t_instance:get_id()
    m_id_to_instance[id] = nil
end

------------------------------------------------

local function get_instance_by_id(t_id, t_label)
    local instance = m_id_to_instance[t_id]
    if instance == nil then
        print_error("[CameraEffectsModule] Could not find " .. t_label .. " instance with ID " .. tostring(t_id))
        return nil
    end
    return instance
end

------------------------------------------------

local function add_list_instance(t_list, t_instance)
    table.insert(t_list, t_instance)
    return register_instance(t_instance)
end

------------------------------------------------

local function process_effect_list(t_list, t_delta_time, t_use_process, t_accum_mode, t_out)
    -- process the effect instances
    for i = #t_list, 1, -1 do
        local instance = t_list[i]
        if t_use_process then
            instance:process(t_delta_time)
        else
            instance:late_process(t_delta_time)
        end

        -- Centralized logic for accumulating the effect values.
        -- Camera shake vector.
        if t_accum_mode == ACCUM_VECTOR3_ADD then
            local shake = instance:get_shake()
            t_out.x = t_out.x + shake.x
            t_out.y = t_out.y + shake.y
            t_out.z = t_out.z + shake.z
        -- FOV Multiplier.
        elseif t_accum_mode == ACCUM_SCALAR_MULTIPLY then
            t_out.value = t_out.value * instance:get_fov_multiplier()
        -- Camera shake scalar.
        elseif t_accum_mode == ACCUM_SCALAR_ADD then
            t_out.value = t_out.value + instance:get_shake()
        -- FOV and camera offset.
        elseif t_accum_mode == ACCUM_COMPOUND_VERTIGO then
            t_out.fov_multiplier = t_out.fov_multiplier * instance:get_fov_multiplier()
            t_out.camera_offset = t_out.camera_offset + instance:get_camera_offset()
        elseif t_accum_mode == ACCUM_ADD_INTENSITY then
            t_out.value = t_out.value + instance:get_intensity()
        end

        -- Check if the instance is ended.
        if instance:get_is_ended() then
            unregister_instance(instance)
            table.remove(t_list, i)
        end
    end
end

------------------------------------------------

local function clear_list(t_list)
    for i = 1, #t_list do
        t_list[i] = nil
    end
end

------------------------------------------------

local function reset_all_effects()
    -- clear all effect instances
    clear_list(m_camera_shake_instances)
    clear_list(m_fov_shake_instances)
    clear_list(m_fov_fade_instances)
    clear_list(m_radial_blur_instances)
    clear_list(m_image_trail_instances)
    clear_list(m_vertigo_effect_instances)
    m_id_to_instance = {}
    m_next_effect_id = 1

    -- reset all effect instances
    m_vignette_effect = nil
    m_ps1_filter_effect = nil
    m_screen_fade_effect = nil
    m_camera_lookat_effect = nil

    -- reset screen fade and radial blur intensity
    renderer_set_screen_fade_intensity(0.0)
    renderer_set_radial_blur_intensity(0.0)
    renderer_set_image_trail_intensity(0.0)

    -- reset custom post process passes
    set_no_vignette_effect()
    set_no_ps1_filter_effect()

    -- reset all current values
    m_current_camera_shake = vec3(0.0)
    m_current_fov_multiplier = 1.0
    m_current_fov_shake = 0.0
    m_current_vignette_intensity = 0.0
    m_current_screen_fade_intensity = 0.0
    m_current_screen_fade_color = vec3(0.0)
    m_current_radial_blur_intensity = 0.0
    m_current_image_trail_intensity = 0.0
    m_current_vertigo_fov_multiplier = 1.0
    m_current_vertigo_camera_offset = 0.0
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function CameraEffects.start_camera_lookat(t_target_entity_id)
    if m_camera_lookat_effect ~= nil then
        m_camera_lookat_effect:stop(0.0)
        m_camera_lookat_effect = nil
    end

    local params = {
        id = get_next_effect_id(),
        fade_in = 0.0,
        duration = -1.0,
        fade_out = 0.0,
        target_entity_id = t_target_entity_id,
        speed_mul = 2.0,
        max_speed = 2.0,
        acceleration = 10.0,
    }

    m_camera_lookat_effect = CameraLookAtEffect:new(params)
end

------------------------------------------------

function CameraEffects.set_camera_lookat_pull_strength(t_speed_mul, t_max_speed, t_acceleration, t_immediate_pull_fraction, t_immediate_pull_cap_fraction)
    if m_camera_lookat_effect == nil then
        return
    end

    m_camera_lookat_effect:set_pull_strength(t_speed_mul, t_max_speed, t_acceleration, t_immediate_pull_fraction or 0.0, t_immediate_pull_cap_fraction or 0.0)
end

------------------------------------------------

function CameraEffects.get_camera_lookat_delta(t_delta_time, t_camera_entity_id, t_pitch, t_yaw)
    if m_camera_lookat_effect == nil or not entity_get_is_valid(t_camera_entity_id) then
        return vec2(0.0, 0.0)
    end

    -- Get the lookat delta.
    local delta_pitch = 0.0
    local delta_yaw = 0.0
    delta_pitch, delta_yaw = m_camera_lookat_effect:process(t_delta_time, t_camera_entity_id, t_pitch, t_yaw)

    -- Check if the effect is ended.
    if m_camera_lookat_effect:get_is_ended() then
        m_camera_lookat_effect = nil
    end

    return vec2(delta_pitch, delta_yaw)
end

------------------------------------------------

function CameraEffects.stop_camera_lookat(t_fade_out_time)
    if m_camera_lookat_effect == nil then
        return false
    end

    m_camera_lookat_effect:stop(t_fade_out_time or 0.0)
    if (t_fade_out_time or 0.0) <= 0.0 then
        m_camera_lookat_effect = nil
    end
    return true
end

------------------------------------------------

function CameraEffects.add_camera_shake(t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    local instance = CameraShakeEffect:new()
    instance:init(get_next_effect_id(), t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    return add_list_instance(m_camera_shake_instances, instance)
end

------------------------------------------------

function CameraEffects.set_camera_shake_force(t_id, t_force)
    local instance = get_instance_by_id(t_id, "camera shake")
    if instance == nil then
        return
    end
    instance:set_force(t_force)
end

------------------------------------------------

function CameraEffects.set_camera_shake_rate(t_id, t_rate)
    local instance = get_instance_by_id(t_id, "camera shake")
    if instance == nil then
        return
    end
    instance:set_rate(t_rate)
end

------------------------------------------------

function CameraEffects.stop_camera_shake(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "camera shake")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.add_fov_shake(t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    local instance = FovShakeEffect:new()
    instance:init(get_next_effect_id(), t_force, t_rate, t_fade_in, t_duration, t_fade_out)
    return add_list_instance(m_fov_shake_instances, instance)
end

------------------------------------------------

function CameraEffects.set_fov_shake_force(t_id, t_force)
    local instance = get_instance_by_id(t_id, "FOV shake")
    if instance == nil then
        return
    end
    instance:set_force(t_force)
end

------------------------------------------------

function CameraEffects.stop_fov_shake(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "FOV shake")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.add_fov_fade(t_fov_multiplier, t_fade_in, t_duration, t_fade_out, t_ease_in, t_ease_out)
    local instance = FovFadeEffect:new()
    instance:init(get_next_effect_id(), t_fov_multiplier, t_fade_in, t_duration, t_fade_out)

    if t_ease_in then
        instance:set_ease_in(t_ease_in)
    end
    if t_ease_out then
        instance:set_ease_out(t_ease_out)
    end

    return add_list_instance(m_fov_fade_instances, instance)
end

------------------------------------------------

function CameraEffects.set_fov_fade_multiplier(t_id, t_multiplier)
    local instance = get_instance_by_id(t_id, "FOV fade")
    if instance == nil then
        return
    end
    instance:set_fov_multiplier(t_multiplier)
end

------------------------------------------------

function CameraEffects.stop_fov_fade(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "FOV fade")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.get_camera_shake()
    return m_current_camera_shake
end

------------------------------------------------

function CameraEffects.get_camera_shake_world_offset(t_camera_yaw)
    -- Initialize the world offset.
    m_accumulated_world_offset.x = 0.0
    m_accumulated_world_offset.y = 0.0
    m_accumulated_world_offset.z = 0.0

    -- Calculate the world offset.
    for i = 1, #m_camera_shake_instances do
        local shake = m_camera_shake_instances[i]
        if not shake:get_is_ended() then
            local offset = shake:get_world_offset(t_camera_yaw)
            m_accumulated_world_offset.x = m_accumulated_world_offset.x + offset.x
            m_accumulated_world_offset.y = m_accumulated_world_offset.y + offset.y
            m_accumulated_world_offset.z = m_accumulated_world_offset.z + offset.z
        end
    end

    -- Return the world offset.
    return m_accumulated_world_offset
end

------------------------------------------------

function CameraEffects.get_fov_fade()
    return m_current_fov_multiplier
end

------------------------------------------------

function CameraEffects.get_fov_shake()
    return m_current_fov_shake
end

------------------------------------------------

function CameraEffects.start_vignette(t_intensity, t_color, t_fade_in, t_duration, t_fade_out)
    if m_vignette_effect then
        unregister_instance(m_vignette_effect)
        m_vignette_effect = nil
    end

    local instance = VignetteEffect:new()
    instance:init(get_next_effect_id(), t_intensity, t_color, t_fade_in, t_duration, t_fade_out)
    register_instance(instance)
    m_vignette_effect = instance
    return true
end

------------------------------------------------

function CameraEffects.set_vignette_intensity(t_intensity)
    if m_vignette_effect == nil then
        print_error("[CameraEffectsModule] No active vignette effect")
        return
    end
    m_vignette_effect:set_intensity(t_intensity)
end

------------------------------------------------

function CameraEffects.set_vignette_color(t_color)
    if m_vignette_effect == nil then
        print_error("[CameraEffectsModule] No active vignette effect")
        return
    end
    m_vignette_effect:set_color(t_color)
end

------------------------------------------------

function CameraEffects.stop_vignette(t_fade_out_time)
    if m_vignette_effect == nil then
        return false
    end
    m_vignette_effect:stop(t_fade_out_time)
    return true
end

------------------------------------------------

function CameraEffects.get_vignette()
    return m_current_vignette_intensity
end

------------------------------------------------

function CameraEffects.start_ps1_filter(t_intensity, t_fade_in, t_duration, t_fade_out)
    if m_ps1_filter_effect then
        unregister_instance(m_ps1_filter_effect)
        m_ps1_filter_effect = nil
    end

    local instance = Ps1FilterEffect:new()
    instance:init(get_next_effect_id(), t_intensity, t_fade_in, t_duration, t_fade_out)
    register_instance(instance)
    m_ps1_filter_effect = instance
    return true
end

------------------------------------------------

function CameraEffects.set_ps1_filter_intensity(t_intensity)
    if m_ps1_filter_effect == nil then
        print_error("[CameraEffectsModule] No active PS1 filter effect")
        return
    end
    m_ps1_filter_effect:set_intensity(t_intensity)
end

------------------------------------------------

function CameraEffects.stop_ps1_filter(t_fade_out_time)
    if m_ps1_filter_effect == nil then
        return false
    end
    m_ps1_filter_effect:stop(t_fade_out_time)
    return true
end

------------------------------------------------

function CameraEffects.get_ps1_filter()
    return m_current_ps1_filter_intensity
end

------------------------------------------------

function CameraEffects.start_screen_fade(t_intensity, t_color, t_fade_in, t_duration, t_fade_out)
    local current_intensity = 0.0
    if m_screen_fade_effect ~= nil then
        current_intensity = m_screen_fade_effect:get_intensity()
        m_screen_fade_effect:stop(0.0)
    end

    m_screen_fade_effect = ScreenFadeEffect:new()
    m_screen_fade_effect:init(-1, t_intensity, t_color, t_fade_in, t_duration, t_fade_out)

    -- Continue smoothly from the previous fade intensity when replacing an active fade.
    if current_intensity > 0.0 and t_intensity > 0.0 then
        local normalized_current = current_intensity / t_intensity
        if t_fade_in > 0.0 then
            m_screen_fade_effect:set_fade_in_from_normalized_intensity(normalized_current, t_fade_in)
        elseif t_fade_in == 0.0 and t_duration == 0.0 and t_fade_out > 0.0 then
            m_screen_fade_effect:set_fade_out_from_normalized_intensity(normalized_current)
        end
    end
end

------------------------------------------------

function CameraEffects.stop_screen_fade(t_fade_out_time)
    if m_screen_fade_effect == nil then
        m_current_screen_fade_intensity = 0.0
        m_current_screen_fade_color = vec3(0.0, 0.0, 0.0)
        renderer_set_screen_fade_intensity(0.0)
        renderer_set_screen_fade_color(vec3(0.0, 0.0, 0.0))
        return false
    end

    if t_fade_out_time == nil or t_fade_out_time <= 0.0 then
        m_screen_fade_effect = nil
        m_current_screen_fade_intensity = 0.0
        m_current_screen_fade_color = vec3(0.0, 0.0, 0.0)
        renderer_set_screen_fade_intensity(0.0)
        renderer_set_screen_fade_color(vec3(0.0, 0.0, 0.0))
        return true
    end

    m_screen_fade_effect:stop(t_fade_out_time)
    return true
end

------------------------------------------------

function CameraEffects.set_screen_fade_intensity(t_intensity)
    if m_screen_fade_effect == nil then
        print_error("[CameraEffectsModule] No active screen fade effect")
        return
    end
    m_screen_fade_effect:set_intensity(t_intensity)
end

------------------------------------------------

function CameraEffects.set_screen_fade_color(t_color)
    if m_screen_fade_effect == nil then
        print_error("[CameraEffectsModule] No active screen fade effect")
        return
    end
    m_screen_fade_effect:set_color(t_color)
end

------------------------------------------------

function CameraEffects.get_screen_fade()
    return m_current_screen_fade_intensity, m_current_screen_fade_color
end

------------------------------------------------

function CameraEffects.add_radial_blur(t_intensity, t_fade_in, t_duration, t_fade_out)
    local instance = RadialBlurEffect:new()
    instance:init(get_next_effect_id(), t_intensity, t_fade_in, t_duration, t_fade_out)
    return add_list_instance(m_radial_blur_instances, instance)
end

------------------------------------------------

function CameraEffects.set_radial_blur_intensity(t_id, t_intensity)
    local instance = get_instance_by_id(t_id, "radial blur")
    if instance == nil then
        return
    end
    instance:set_intensity(t_intensity)
end

------------------------------------------------

function CameraEffects.stop_radial_blur(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "radial blur")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.get_radial_blur()
    return m_current_radial_blur_intensity
end

------------------------------------------------

function CameraEffects.add_image_trail(t_intensity, t_fade_in, t_duration, t_fade_out)
    local instance = ImageTrailEffect:new()
    instance:init(get_next_effect_id(), t_intensity, t_fade_in, t_duration, t_fade_out)
    return add_list_instance(m_image_trail_instances, instance)
end

------------------------------------------------

function CameraEffects.set_image_trail_intensity(t_id, t_intensity)
    local instance = get_instance_by_id(t_id, "image trail")
    if instance == nil then
        return
    end

    local intensity = t_intensity
    if intensity < 0.0 then
        intensity = 0.0
    elseif intensity > 0.95 then
        intensity = 0.95
    end

    instance:set_intensity(intensity)
end

------------------------------------------------

function CameraEffects.stop_image_trail(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "image trail")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.get_image_trail()
    return m_current_image_trail_intensity
end

------------------------------------------------

function CameraEffects.add_vertigo_effect(t_intensity, t_fade_in, t_duration, t_fade_out)
    local instance = VertigoEffect:new()
    instance:init(get_next_effect_id(), t_intensity, t_fade_in, t_duration, t_fade_out)
    return add_list_instance(m_vertigo_effect_instances, instance)
end

------------------------------------------------

function CameraEffects.set_vertigo_effect_intensity(t_id, t_intensity)
    local instance = get_instance_by_id(t_id, "vertigo effect")
    if instance == nil then
        return
    end
    instance:set_intensity(t_intensity)
end

------------------------------------------------

function CameraEffects.stop_vertigo_effect(t_id, t_fade_out_time)
    local instance = get_instance_by_id(t_id, "vertigo effect")
    if instance == nil then
        return
    end
    instance:stop(t_fade_out_time)
end

------------------------------------------------

function CameraEffects.get_vertigo_effect()
    return {
        fov_multiplier = m_current_vertigo_fov_multiplier,
        camera_offset = m_current_vertigo_camera_offset
    }
end

------------------------------------------------

function CameraEffects.get_vertigo_world_offset(t_camera_entity_id)
    -- Initialize the world offset.
    m_accumulated_world_offset.x = 0.0
    m_accumulated_world_offset.y = 0.0
    m_accumulated_world_offset.z = 0.0

    -- Calculate the world offset.
    for i = 1, #m_vertigo_effect_instances do
        local vertigo = m_vertigo_effect_instances[i]
        if not vertigo:get_is_ended() then
            local offset = vertigo:get_world_offset(t_camera_entity_id)
            m_accumulated_world_offset.x = m_accumulated_world_offset.x + offset.x
            m_accumulated_world_offset.y = m_accumulated_world_offset.y + offset.y
            m_accumulated_world_offset.z = m_accumulated_world_offset.z + offset.z
        end
    end

    -- Return the world offset.
    return m_accumulated_world_offset
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function CameraEffects.on_initialize()
    -- Set the custom post process shader and texture files for the vignette pass.
    renderer_set_custom_post_process_shader_file(VIGNETTE_PASS_INDEX, VIGNETTE_SHADER_FILE)
    renderer_set_custom_post_process_texture_file(VIGNETTE_PASS_INDEX, VIGNETTE_IMG_FILE)
    renderer_set_custom_post_process_params(VIGNETTE_PASS_INDEX, VIGNETTE_PARAMS)
    set_no_vignette_effect()

    -- Set the custom post process shader and texture files for the PS1 filter pass.
    renderer_set_custom_post_process_shader_file(PS1_FILTER_PASS_INDEX, PS1_FILTER_SHADER_FILE)
    renderer_set_custom_post_process_texture_file(PS1_FILTER_PASS_INDEX, "")
    renderer_set_custom_post_process_params(PS1_FILTER_PASS_INDEX, PS1_FILTER_PARAMS)
    set_no_ps1_filter_effect()

    -- Set the custom post process shader for the motion blur pass.
    MotionBlur.initialize()
end

------------------------------------------------

function CameraEffects.on_ready()
    -- Set the custom post process passes to idle.
    set_no_vignette_effect()
    set_no_ps1_filter_effect()
end

------------------------------------------------

function CameraEffects.on_late_process(t_delta_time)
    -- Process the camera shake instances.
    m_current_camera_shake.x = 0.0
    m_current_camera_shake.y = 0.0
    m_current_camera_shake.z = 0.0
    process_effect_list(m_camera_shake_instances, t_delta_time, false, ACCUM_VECTOR3_ADD, m_current_camera_shake)

    -- Process the FOV fade instances.
    m_accumulated_fov_fade.value = 1.0
    process_effect_list(m_fov_fade_instances, t_delta_time, false, ACCUM_SCALAR_MULTIPLY, m_accumulated_fov_fade)
    m_current_fov_multiplier = m_accumulated_fov_fade.value

    -- Process the vertigo effect instances.
    -- Vertigo must run before FOV shake so both combine in one FOV write.
    m_accumulated_vertigo.fov_multiplier = 1.0
    m_accumulated_vertigo.camera_offset = 0.0
    process_effect_list(m_vertigo_effect_instances, t_delta_time, true, ACCUM_COMPOUND_VERTIGO, m_accumulated_vertigo)
    m_current_vertigo_fov_multiplier = m_accumulated_vertigo.fov_multiplier
    m_current_vertigo_camera_offset = m_accumulated_vertigo.camera_offset
    m_current_fov_multiplier = m_current_fov_multiplier * m_current_vertigo_fov_multiplier

    -- Process the FOV shake instances.
    m_accumulated_fov_shake.value = 0.0
    process_effect_list(m_fov_shake_instances, t_delta_time, false, ACCUM_SCALAR_ADD, m_accumulated_fov_shake)
    m_current_fov_shake = m_accumulated_fov_shake.value

    -- Tick the vignette effect and read intensity/color.
    m_current_vignette_intensity = 0.0
    if m_vignette_effect then
        m_vignette_effect:late_process(t_delta_time)
        m_current_vignette_intensity = m_vignette_effect:get_intensity()
        m_current_vignette_color = m_vignette_effect:get_color()

        if m_vignette_effect:get_is_ended() then
            unregister_instance(m_vignette_effect)
            m_vignette_effect = nil
            m_current_vignette_intensity = 0.0
        end
    else
        m_current_vignette_color = vec3(0.0, 0.0, 0.0)
    end

    -- Apply the vignette pass to the renderer.
    if m_vignette_effect then
        set_vignette_effect(
            m_current_vignette_intensity,
            m_current_vignette_color)
    else
        set_no_vignette_effect()
    end

    -- Process the PS1 filter effect.
    if m_ps1_filter_effect then
        m_ps1_filter_effect:late_process(t_delta_time)
        set_ps1_filter_effect(m_ps1_filter_effect:get_intensity())

        if m_ps1_filter_effect:get_is_ended() then
            unregister_instance(m_ps1_filter_effect)
            m_ps1_filter_effect = nil
            set_no_ps1_filter_effect()
        end
    else
        set_no_ps1_filter_effect()
    end

    -- Tick the screen fade effect and read intensity/color.
    m_current_screen_fade_intensity = 0.0
    if m_screen_fade_effect then
        m_screen_fade_effect:late_process(t_delta_time)
        m_current_screen_fade_intensity = m_screen_fade_effect:get_intensity()
        m_current_screen_fade_color = m_screen_fade_effect:get_color()

        if m_screen_fade_effect:get_is_ended() then
            m_screen_fade_effect = nil
        end
    else
        m_current_screen_fade_color = vec3(0.0, 0.0, 0.0)
    end

    -- Apply the screen fade intensity and color to the renderer.
    if m_current_screen_fade_intensity > 0.0 then
        renderer_set_screen_fade_intensity(m_current_screen_fade_intensity)
        renderer_set_screen_fade_color(m_current_screen_fade_color)
    -- If the screen fade intensity is 0.0, clear the screen fade on the renderer.
    else
        renderer_set_screen_fade_intensity(0.0)
        renderer_set_screen_fade_color(vec3(0.0, 0.0, 0.0))
    end

    -- Process the radial blur instances.
    m_accumulated_radial_blur.value = 0.0
    process_effect_list(m_radial_blur_instances, t_delta_time, false, ACCUM_ADD_INTENSITY, m_accumulated_radial_blur)
    m_current_radial_blur_intensity = m_accumulated_radial_blur.value

    if m_current_radial_blur_intensity > 0.0 then
        renderer_set_radial_blur_intensity(m_current_radial_blur_intensity)
    else
        renderer_set_radial_blur_intensity(0.0)
    end

    -- Process the image trail instances.
    m_accumulated_image_trail.value = 0.0
    process_effect_list(m_image_trail_instances, t_delta_time, false, ACCUM_ADD_INTENSITY, m_accumulated_image_trail)
    m_current_image_trail_intensity = m_accumulated_image_trail.value

    if m_current_image_trail_intensity > 0.0 then
        renderer_set_image_trail_intensity(m_current_image_trail_intensity)
    else
        renderer_set_image_trail_intensity(0.0)
    end
end

------------------------------------------------

function CameraEffects.on_editor_mode_active(t_is_active)
    if t_is_active then
        reset_all_effects()
    end
end

------------------------------------------------

function CameraEffects.on_shutdown()
    reset_all_effects()

    -- Turn off the motion blur pass.
    MotionBlur.shutdown()
end

------------------------------------------------

return CameraEffects
