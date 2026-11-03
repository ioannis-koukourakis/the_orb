-- Singleton pattern.
local MODULE_DOFILE_PATH = "../content/scripts/camera_effects/motion_blur_effect.lua"

if package ~= nil and package.loaded ~= nil then
    local cached_module = package.loaded[MODULE_DOFILE_PATH]
    if cached_module ~= nil then
        return cached_module
    end
end

local MotionBlur = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

-- Custom post pass 3. 
-- Passes 1-2 are vignette and PS1 filter in CameraEffectsModule.
local PASS_INDEX = 3
local SHADER_FILE = "../content/shaders/motion_blur.frag.glsl"

local GAMEPLAY_SETTINGS_SECTION = "Gameplay"
local ENABLED_SETTINGS_KEY = "motion_blur_enabled"
local DEFAULT_ENABLED = true
local VELOCITY_THRESHOLD = 0.5  -- 0 = only very fast motion blurs. 1 = blur on almost any visible motion.
local MAX_AMOUNT = 0.75          -- Peak mix toward the motion-blurred image (0-1).
local MIN_SPEED_UV_AT_THRESHOLD_ZERO = 0.00015  -- Min |velocity| in UV when threshold is 0.
local MIN_SPEED_UV_AT_THRESHOLD_ONE = 0.0025    -- Min |velocity| in UV when threshold is 1.
local VELOCITY_LENGTH_SCALE = 1.0               -- Scale the velocity vector by this amount.

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_is_initialized = false
local m_is_enabled = DEFAULT_ENABLED

------------------------------------------------
-- HELPERS
------------------------------------------------

local function apply_pass_settings()
    local min_speed = MIN_SPEED_UV_AT_THRESHOLD_ZERO +
        (MIN_SPEED_UV_AT_THRESHOLD_ONE - MIN_SPEED_UV_AT_THRESHOLD_ZERO) * VELOCITY_THRESHOLD
    if min_speed < 0.0 then
        min_speed = 0.0
    end

    renderer_set_custom_post_process_params(PASS_INDEX, vec4(VELOCITY_LENGTH_SCALE, min_speed, 0.0, 0.0))
    renderer_set_custom_post_process_intensity(PASS_INDEX, MAX_AMOUNT)
    renderer_set_custom_post_process_active(PASS_INDEX, true)
end

------------------------------------------------
-- INTERFACE
------------------------------------------------

function MotionBlur.get_enabled_setting()
    return settings_get_bool(GAMEPLAY_SETTINGS_SECTION, ENABLED_SETTINGS_KEY, DEFAULT_ENABLED)
end

------------------------------------------------

function MotionBlur.set_enabled_setting(t_enabled)
    local enabled = t_enabled == true
    settings_set_bool(GAMEPLAY_SETTINGS_SECTION, ENABLED_SETTINGS_KEY, enabled)
    MotionBlur.set_enabled(enabled)
end

------------------------------------------------

function MotionBlur.initialize()
    if m_is_initialized then
        return
    end

    -- Bind the shader once. The pass stays off until the saved setting is applied.
    renderer_set_custom_post_process_shader_file(PASS_INDEX, SHADER_FILE)
    renderer_set_custom_post_process_texture_file(PASS_INDEX, "")
    renderer_set_custom_post_process_intensity(PASS_INDEX, 0.0)
    renderer_set_custom_post_process_active(PASS_INDEX, false)

    m_is_initialized = true
end

------------------------------------------------

function MotionBlur.set_enabled_from_saved_setting()
    MotionBlur.set_enabled(MotionBlur.get_enabled_setting())
end

------------------------------------------------

function MotionBlur.shutdown()
    if not m_is_initialized then
        return
    end

    -- Pass goes idle. The shader binding from initialize stays.
    renderer_set_custom_post_process_active(PASS_INDEX, false)
    renderer_set_custom_post_process_intensity(PASS_INDEX, 0.0)
end

------------------------------------------------

function MotionBlur.set_enabled(t_enabled)
    m_is_enabled = t_enabled == true
    if not m_is_initialized then
        return
    end

    if not m_is_enabled then
        renderer_set_custom_post_process_active(PASS_INDEX, false)
        renderer_set_custom_post_process_intensity(PASS_INDEX, 0.0)
        return
    end

    apply_pass_settings()
end

------------------------------------------------

-- Singleton pattern.
if package ~= nil and package.loaded ~= nil then
    package.loaded[MODULE_DOFILE_PATH] = MotionBlur
end

return MotionBlur
