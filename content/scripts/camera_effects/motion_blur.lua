-- Singleton reference.
-- The script is loaded once and stored in the package.loaded table.

local SCRIPT_DOFILE_PATH = "../content/scripts/camera_effects/motion_blur.lua"

if package ~= nil and package.loaded ~= nil then
    local cached_module = package.loaded[SCRIPT_DOFILE_PATH]
    if cached_module ~= nil then
        return cached_module
    end
end

------------------------------------------------

local MotionBlur = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

-- Custom post pass 3. Passes 1-2 are vignette and PS1 filter in CameraEffectsModule.
local PASS_INDEX = 3
local SHADER_FILE = "../content/shaders/motion_blur.frag.glsl"

local GAMEPLAY_SETTINGS_SECTION = "Gameplay"
local ENABLED_SETTINGS_KEY = "motion_blur_enabled"
local DEFAULT_ENABLED = false

-- 1 = only very fast motion blurs. 0 = blur on almost any visible motion.
local VELOCITY_THRESHOLD = 0.5
-- Peak mix toward the motion-blurred image (0-1).
local MAX_AMOUNT = 1.0

-- Min |velocity| in UV when threshold is 0 / 1.
local MIN_SPEED_UV_AT_THRESHOLD_ZERO = 0.00015
local MIN_SPEED_UV_AT_THRESHOLD_ONE = 0.0025
local VELOCITY_LENGTH_SCALE = 1.0

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_is_initialized = false
local m_is_enabled = DEFAULT_ENABLED

------------------------------------------------
-- INTERFACE
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

    renderer_set_custom_post_process_shader_file(PASS_INDEX, SHADER_FILE)
    renderer_set_custom_post_process_texture_file(PASS_INDEX, "")
    renderer_set_custom_post_process_intensity(PASS_INDEX, 0.0)
    renderer_set_custom_post_process_active(PASS_INDEX, false)

    m_is_initialized = true
    MotionBlur.set_enabled(MotionBlur.get_enabled_setting())
end

------------------------------------------------

function MotionBlur.shutdown()
    if not m_is_initialized then
        return
    end

    renderer_set_custom_post_process_active(PASS_INDEX, false)
    renderer_set_custom_post_process_intensity(PASS_INDEX, 0.0)
    m_is_initialized = false
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

if package ~= nil and package.loaded ~= nil then
    package.loaded[SCRIPT_DOFILE_PATH] = MotionBlur
end

return MotionBlur
