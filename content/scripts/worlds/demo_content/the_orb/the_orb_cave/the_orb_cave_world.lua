-- @TODO: Better split this between smaller, more manageable scripts. 

local TheOrbCaveWorld = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local Colors = dofile("../content/scripts/shared/colors.lua")
local OrbCaveDeathPit = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_cave/the_orb_cave_death_pit.lua")
local TheOrbWorldPaths = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_world_paths.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local CAMERA_EFFECTS_MODULE_NAME = "CameraEffectsModule"
local GAME_MODULE_NAME = "game_module"

local CAMERA_EFFECT_LOOK_DISTANCE_FAR = 10.0
local CAMERA_EFFECT_LOOK_DISTANCE_NEAR = 3.0

local CAMERA_EFFECT_SHAKE_FORCE_BASE = 0.02
local CAMERA_EFFECT_SHAKE_FORCE_SYNC = 0.25
local CAMERA_EFFECT_SHAKE_RATE_FAR = 4.0
local CAMERA_EFFECT_SHAKE_RATE_NEAR = 18.0
local CAMERA_EFFECT_SHAKE_RATE_SYNC_PEAK = 120.0
local CAMERA_EFFECT_FOV_LOOK = 1.12
local CAMERA_EFFECT_FOV_PRE_SYNC = 1.28
local CAMERA_EFFECT_FOV_SYNC = 1.4
local CAMERA_EFFECT_RADIAL_BLUR_LOOK = 0.35
local CAMERA_EFFECT_RADIAL_BLUR_PRE_SYNC = 0.52
local CAMERA_EFFECT_RADIAL_BLUR_SYNC = 0.75
local CAMERA_EFFECT_SHAKE_RATE_STARE_PEAK = 26.0

local CAMERA_EFFECT_BLEND_SPEED = 8.0
local CAMERA_EFFECT_AFFECTED_AREA_TRIGGER = "tag_trigger_alien_effect"

local CAMERA_EFFECT_SCREEN_EDGE_VIEW_MARGIN = 0.16
local CAMERA_EFFECT_ORB_RADIUS = 1.0

local ORB_LOOKAT_PULL_SPEED_MULTIPLIER = 2.9
local ORB_LOOKAT_PULL_MAX_SPEED_RADIANS_PER_SECOND = 1.55
local ORB_LOOKAT_PULL_ACCELERATION = 8.0
local ORB_LOOKAT_PULL_PRE_SYNC_SPEED_MULTIPLIER = 0.72
local ORB_LOOKAT_PULL_PRE_SYNC_MAX_SPEED_RADIANS_PER_SECOND = 0.38
local ORB_LOOKAT_PULL_PRE_SYNC_ACCELERATION = 2.4
local ORB_LOOKAT_BREAK_ESCAPE_HOLD_DURATION = 1.0

local CAMERA_EFFECT_ENDING_STARE_DISTANCE = 8.0
local CAMERA_EFFECT_ENDING_STARE_INSPECT_ZOOM_EXTRA_DISTANCE_METERS = 1.0
local CAMERA_EFFECT_ENDING_STARE_SCREEN_CENTER_MIN = 0.35

local ENDING_IMAGE_TRAIL_INTENSITY = 0.9
local ENDING_IMAGE_TRAIL_FADE_OUT_DURATION = 8.0

local ENDING_WARP_LEAD_DURATION = 0.8
local ENDING_WARP_VERTIGO_INTENSITY = 0.55
local ENDING_WARP_VERTIGO_HOLD_DURATION = 2.0 -- Duration to hold the vertigo effect before fading out.
local ENDING_WARP_VERTIGO_FADE_OUT_DURATION = 0.25
local ENDING_WARP_VISIBLE_DURATION = ENDING_WARP_LEAD_DURATION + ENDING_WARP_VERTIGO_HOLD_DURATION
local ENDING_WARP_SHAKE_FORCE = 0.45
local ENDING_WARP_SHAKE_RATE = 18.0
local ENDING_WARP_SHAKE_FADE_IN_DURATION = 0.02
local ENDING_WARP_SHAKE_HOLD_DURATION = 0.16
local ENDING_WARP_SHAKE_FADE_OUT_DURATION = 0.12
local ENDING_POST_WHITE_GAME_SOUND_FADE_DURATION = 0.25
local SOUND_CATEGORY_AMBIENT = 2

local ORB_LUMEN_REST = 200.0
local ORB_LUMEN_PRE_SYNC = 600.0
local ORB_LUMEN_SYNC_PULSE = 1200.0

local ORB_SOUND_GAIN_REST = 0.15
local ORB_SOUND_GAIN_PRE_SYNC = 0.55
local ORB_SOUND_GAIN_SYNC_PULSE = 0.75

local ORB_HIGH_SOUND_GAIN_REST = 0.0
local ORB_HIGH_SOUND_GAIN_PRE_SYNC = 0.25
local ORB_HIGH_SOUND_GAIN_SYNC_PULSE = 0.5

local ORB_HALO_MICRO_SURFACE_UNIFORM = "u_micro_surface_scale"
local ORB_HALO_MICRO_SURFACE_SCALE_REST = 2.0
local ORB_HALO_MICRO_SURFACE_SCALE_SYNC_PULSE = 50.0

local ORB_LAMP_FLICKER_PRESET_REST = "oil_lamp"
local ORB_LAMP_FLICKER_PRESET_SYNC = "fireplace"

local ORB_SYNC_PHASE_REST = 0
local ORB_SYNC_PHASE_STARE = 1
local ORB_SYNC_PHASE_SYNCED = 2

local ENDING_STATE_REST = 0
local ENDING_STATE_CHARGING = 1
local ENDING_STATE_SYNCING = 2
local ENDING_STATE_COMMITTED = 3
local ENDING_STATE_TITLE = 4
local ENDING_STATE_LEAVE = 5

local ORB_GLITCH_INTERVAL_BY_SYNC_PHASE = {
    [ORB_SYNC_PHASE_REST] = 1.0,
    [ORB_SYNC_PHASE_STARE] = 0.5,
    [ORB_SYNC_PHASE_SYNCED] = 0.2,
}
local ORB_SHORT_SOUND_FADE_DURATION = 0.03

local ENDING_TITLE_TEXT = "The Orb"
local ENDING_SUBTITLE_TEXT = "Detis Game Engine Tech Demo"
local ENDING_TITLE_FONT_ID = "marcellus_40"
local ENDING_TITLE_FONT_SIZE = 0.09
local ENDING_SUBTITLE_FONT_SIZE = 0.028
local ENDING_TITLE_SUBTITLE_GAP = 0.018

local ENDING_TITLE_FADE_IN_DURATION = 2.5
local ENDING_TITLE_READ_DURATION = 2.5
local ENDING_TITLE_FADE_OUT_DURATION = 1.5
local ENDING_BLOCK_EXTERIOR_WORLD_LOAD_AFTER_SEQUENCE = false
local ENDING_TITLE_DRAW_PRIORITY = 15
local ENDING_WHITE = vec3(1.0, 1.0, 1.0)

local ORB_CHARGE_LOOK_DURATION = 3.0
local ORB_SYNC_STINGER_LEAD = 0.3
local ORB_SYNC_HOLD_DURATION = 10.0
local ORB_SYNC_PULSE_CROSSFADE_DURATION = 0.045
local ORB_DESYNC_CROSSFADE_DURATION = 0.16
local ORB_WHITE_RAMP_PEAK = 0.06
local ORB_WHITE_SNAP_DURATION = 0.18

local ORB_CHOIR_SYNC_GAIN_START = 0.25
local ORB_CHOIR_SYNC_GAIN_END = 1.0
local ORB_CHOIR_STOP_FADE_DURATION = 0.35

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_world_is_ready_to_run = false
local m_player_entity_id = 0
local m_player_body_entity_id = 0
local m_camera_entity_id = 0
local m_orb_entity_id = 0
local m_orb_light_entity_id = 0
local m_orb_base_lumens = 0.0
local m_orb_brightness_multiplier = 1.0
local m_orb_sync_sound_entries = {}
local m_orb_sound_gain = 0.0
local m_orb_high_sync_sound_entity_id = 0
local m_orb_high_sync_sound_base_gain = 0.0
local m_orb_high_sound_gain = 0.0
local m_orb_halo_refract_entity_id = 0
local m_orb_halo_micro_surface_scale_rest = 0.0
local m_orb_micro_surface_scale = 0.0
local m_orb_effect_trigger_ids = {}
local m_affected_area_overlap_count = 0
local m_camera_shake_id = 0
local m_fov_fade_id = 0
local m_radial_blur_id = 0
local m_shake_force = 0.0
local m_fov_multiplier = 1.0
local m_radial_blur = 0.0
local m_raycast_exclude = {}
local m_ending_state = ENDING_STATE_REST
local m_ending_look_time = 0.0
local m_ending_white = 0.0
local m_ending_title_alpha = 0.0
local m_ending_title_hold_time = 0.0
local m_ending_is_player_locked = false
local m_ending_screen_fade_is_active = false
local m_ending_image_trail_id = 0
local m_ending_image_trail_is_active = false
local m_ending_warp_vertigo_id = 0
local m_ending_warp_vertigo_time_left = 0.0
local m_ending_warp_sound_fade_is_active = false
local m_ending_warp_sound_fade_is_complete = false
local m_ending_game_sound_fade_is_active = false
local m_ending_game_sound_fade_is_complete = false
local m_ending_game_sound_fade_time_elapsed = 0.0
local m_orb_impulse_is_active = false
local m_orb_impulse_timer = 0.0
local m_orb_impulse_fade_seconds = 0.0
local m_orb_impulse_from_brightness = 0.0
local m_orb_impulse_to_brightness = 0.0
local m_orb_impulse_from_sound_gain = 0.0
local m_orb_impulse_to_sound_gain = 0.0
local m_orb_impulse_from_high_sound_gain = 0.0
local m_orb_impulse_to_high_sound_gain = 0.0
local m_orb_impulse_from_micro_surface_scale = 0.0
local m_orb_impulse_to_micro_surface_scale = 0.0
local m_orb_glitch_sound_entity_id = 0
local m_orb_glitch_cooldown_timer = 0.0
local m_orb_glitch_active_sync_phase = 0
local m_ending_sync_completed_sound_entity_id = 0
local m_ending_sync_completed_sound_is_playing = false
local m_ending_sync_stinger_sound_entity_id = 0
local m_ending_sync_stinger_sound_played = false
local m_reveal_stinger_sound_entity_id = 0
local m_reveal_stinger_trigger_entity_id = 0
local m_reveal_stinger_has_played = false
local m_orb_choir_sound_entity_id = 0
local m_orb_choir_sound_authored_gain = 1.0
local m_orb_choir_sound_is_playing = false
local m_orb_lookat_pull_is_active = false
local m_orb_lookat_break_escape_seconds = 0.0
local m_orb_ending_stare_effects_held = false

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function get_player_is_inspect_zoom_active()
    if not entity_get_is_valid(m_player_entity_id) then
        return false
    end

    return world_call_entity_script_function(m_player_entity_id, "get_is_inspect_zoom_active") == true
end

------------------------------------------------

local function get_orb_child_entity_id(t_relative_path, t_child_name)
    local child_entity_id = entity_get_child_by_path(m_orb_entity_id, t_relative_path)
    if not entity_get_is_valid(child_entity_id) then
        child_entity_id = entity_get_child_by_name(m_orb_entity_id, t_child_name)
    end

    return child_entity_id
end

------------------------------------------------

local function set_orb_sound_gain_if_changed(t_sound_entity_id, t_target_gain)
    if not entity_get_is_valid(t_sound_entity_id) then
        return
    end

    local current_gain = sound_get_gain(t_sound_entity_id)
    if math.abs(current_gain - t_target_gain) <= 0.0001 then
        return
    end

    sound_set_gain(t_sound_entity_id, t_target_gain)
end

----------------------------------------------------

local function play_orb_reveal_stinger_once_per_session()
    if m_reveal_stinger_has_played then
        return
    end

    if not entity_get_is_valid(m_reveal_stinger_sound_entity_id)
        or not entity_get_has_sound_component(m_reveal_stinger_sound_entity_id) then
        return
    end

    m_reveal_stinger_has_played = true
    sound_play(m_reveal_stinger_sound_entity_id, ORB_SHORT_SOUND_FADE_DURATION)
end

----------------------------------------------------

local function register_orb_sync_sound(t_sound_entity_id)
    if not entity_get_is_valid(t_sound_entity_id) or not entity_get_has_sound_component(t_sound_entity_id) then
        return
    end

    local base_gain = sound_get_base_gain(t_sound_entity_id)
    if base_gain <= 0.0 then
        base_gain = ORB_SOUND_GAIN_REST
    end

    m_orb_sync_sound_entries[#m_orb_sync_sound_entries + 1] = {
        entity_id = t_sound_entity_id,
        base_gain = base_gain,
    }
end

------------------------------------------------

local function stop_orb_camera_lookat_pull()
    if not m_orb_lookat_pull_is_active then
        return
    end

    m_orb_lookat_pull_is_active = false
    m_orb_lookat_break_escape_seconds = 0.0
    if module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME) then
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_camera_lookat", 0.0)
    end
end

------------------------------------------------

local function apply_orb_camera_lookat_pull_strength()
    local speed_multiplier = ORB_LOOKAT_PULL_PRE_SYNC_SPEED_MULTIPLIER
    local max_speed_radians_per_second = ORB_LOOKAT_PULL_PRE_SYNC_MAX_SPEED_RADIANS_PER_SECOND
    local acceleration = ORB_LOOKAT_PULL_PRE_SYNC_ACCELERATION
    if m_ending_state >= ENDING_STATE_SYNCING then
        speed_multiplier = ORB_LOOKAT_PULL_SPEED_MULTIPLIER
        max_speed_radians_per_second = ORB_LOOKAT_PULL_MAX_SPEED_RADIANS_PER_SECOND
        acceleration = ORB_LOOKAT_PULL_ACCELERATION
    end

    module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                        "set_camera_lookat_pull_strength",
                        speed_multiplier,
                        max_speed_radians_per_second,
                        acceleration,
                        0.0,
                        0.0)
end

------------------------------------------------

local function restore_orb_sync_sound_base_gains()
    for i = 1, #m_orb_sync_sound_entries do
        local sound_entry = m_orb_sync_sound_entries[i]
        if entity_get_is_valid(sound_entry.entity_id) then
            sound_set_gain(sound_entry.entity_id, sound_entry.base_gain)
        end
    end

    if entity_get_is_valid(m_orb_high_sync_sound_entity_id) then
        set_orb_sound_gain_if_changed(m_orb_high_sync_sound_entity_id, m_orb_high_sync_sound_base_gain)
    end
end

----------------------------------------------------

local function set_orb_lamp_flicker_preset(t_preset_name)
    if not entity_get_is_valid(m_orb_light_entity_id) then
        return
    end

    world_call_entity_script_function(m_orb_light_entity_id, "set_flicker_preset", t_preset_name)
end

----------------------------------------------------

local function set_orb_lamp_flicker_preset_rest()
    set_orb_lamp_flicker_preset(ORB_LAMP_FLICKER_PRESET_REST)
end

----------------------------------------------------

local function get_orb_sync_phase(t_is_ending_synced, t_is_ending_stare)
    if m_ending_state >= ENDING_STATE_COMMITTED or t_is_ending_synced then
        return ORB_SYNC_PHASE_SYNCED
    end

    if t_is_ending_stare then
        return ORB_SYNC_PHASE_STARE
    end

    return ORB_SYNC_PHASE_REST
end

----------------------------------------------------

local function stop_orb_choir_sync_sound(t_fade_seconds)
    if not m_orb_choir_sound_is_playing then
        return
    end

    m_orb_choir_sound_is_playing = false
    if entity_get_is_valid(m_orb_choir_sound_entity_id) then
        sound_stop(m_orb_choir_sound_entity_id, t_fade_seconds)
    end
end

----------------------------------------------------

local function update_orb_choir_sync_sound(t_is_ending_synced, t_ending_white_ramp_time, t_ending_white)
    if not entity_get_is_valid(m_orb_choir_sound_entity_id) then
        return
    end

    -- Warp fade already stopped the choir so skip the rest of the update.
    if m_ending_warp_sound_fade_is_complete then
        return
    end

    -- Stop if ending is committed.
    if m_orb_choir_sound_is_playing and t_ending_white >= 1.0 then
        stop_orb_choir_sync_sound(ORB_CHOIR_STOP_FADE_DURATION)
        return
    end

    -- Stop if ending is not synced.
    if not t_is_ending_synced then
        if m_ending_state < ENDING_STATE_COMMITTED or t_ending_white <= 0.0 then
            if m_orb_choir_sound_is_playing then
                stop_orb_choir_sync_sound(0.0)
            end
            return
        end
    end

    -- Calculate total duration of sync.
    local sync_total_duration = ORB_SYNC_HOLD_DURATION + ORB_WHITE_SNAP_DURATION
    local sync_elapsed = 0.0
    if m_ending_state < ENDING_STATE_COMMITTED then
        sync_elapsed = t_ending_white_ramp_time
    else
        sync_elapsed = ORB_SYNC_HOLD_DURATION
        local flash_span = 1.0 - ORB_WHITE_RAMP_PEAK
        if flash_span > 0.0001 then
            local flash_progress = (t_ending_white - ORB_WHITE_RAMP_PEAK) / flash_span
            sync_elapsed = sync_elapsed + math_clamp(flash_progress, 0.0, 1.0) * ORB_WHITE_SNAP_DURATION
        end
    end

    -- Calculate charge.
    local charge = 0.0
    if sync_total_duration > 0.0001 then
        charge = math_clamp(sync_elapsed / sync_total_duration, 0.0, 1.0)
    end

    -- Calculate gain.
    local gain = ORB_CHOIR_SYNC_GAIN_START
        + ((ORB_CHOIR_SYNC_GAIN_END - ORB_CHOIR_SYNC_GAIN_START) * charge)
    gain = gain * m_orb_choir_sound_authored_gain

    -- Play sound.
    if not m_orb_choir_sound_is_playing then
        if not t_is_ending_synced then
            return
        end

        sound_play(m_orb_choir_sound_entity_id, 0.5)
        set_orb_sound_gain_if_changed(m_orb_choir_sound_entity_id, gain)
        m_orb_choir_sound_is_playing = true
        return
    end

    -- Set gain.
    set_orb_sound_gain_if_changed(m_orb_choir_sound_entity_id, gain)
end

----------------------------------------------------

local function process_orb_glitch_sounds(t_delta_time, t_sync_phase, t_is_in_orb_effect_area)
    if not entity_get_is_valid(m_orb_glitch_sound_entity_id) then
        return
    end

    -- Warp fade is running. Leave the glitch silent.
    if m_ending_warp_sound_fade_is_active then
        return
    end

    -- Glitches are sphere ambience so they should not fire across the whole cave in play mode.
    if not t_is_in_orb_effect_area then
        return
    end

    -- Get interval based on sync phase.
    local interval_seconds = ORB_GLITCH_INTERVAL_BY_SYNC_PHASE[t_sync_phase]
    if interval_seconds == nil then
        interval_seconds = ORB_GLITCH_INTERVAL_BY_SYNC_PHASE[ORB_SYNC_PHASE_REST]
    end
    if interval_seconds <= 0.0 then
        return
    end

    -- Reset cooldown timer if sync phase changed.
    if m_orb_glitch_active_sync_phase ~= t_sync_phase then
        m_orb_glitch_active_sync_phase = t_sync_phase
        m_orb_glitch_cooldown_timer = 0.0
    end

    -- Cooldown timer.
    m_orb_glitch_cooldown_timer = m_orb_glitch_cooldown_timer - t_delta_time
    if m_orb_glitch_cooldown_timer > 0.0 then
        return
    end

    -- Play sound.
    sound_play(m_orb_glitch_sound_entity_id, ORB_SHORT_SOUND_FADE_DURATION)
    m_orb_glitch_cooldown_timer = interval_seconds
end

----------------------------------------------------

local function apply_orb_response_state()
    -- Light response
    if entity_get_is_valid(m_orb_light_entity_id) then
        world_call_entity_script_function(m_orb_light_entity_id, "set_brightness_multiplier", m_orb_brightness_multiplier)
    end

    -- Apply sync sounds.
    for i = 1, #m_orb_sync_sound_entries do
        local sound_entry = m_orb_sync_sound_entries[i]
        set_orb_sound_gain_if_changed(sound_entry.entity_id, m_orb_sound_gain)
    end

    set_orb_sound_gain_if_changed(m_orb_high_sync_sound_entity_id, m_orb_high_sound_gain)

    -- Apply halo micro surface scale.
    if entity_get_is_valid(m_orb_halo_refract_entity_id)
        and entity_get_has_particle_system_component(m_orb_halo_refract_entity_id) then
        particle_system_set_uniform_float(m_orb_halo_refract_entity_id, ORB_HALO_MICRO_SURFACE_UNIFORM, m_orb_micro_surface_scale)
    end
end

----------------------------------------------------

local function set_orb_response_to_rest()
    m_orb_brightness_multiplier = ORB_LUMEN_REST / m_orb_base_lumens
    m_orb_sound_gain = ORB_SOUND_GAIN_REST
    m_orb_high_sound_gain = ORB_HIGH_SOUND_GAIN_REST
    if entity_get_is_valid(m_orb_high_sync_sound_entity_id) then
        m_orb_high_sound_gain = m_orb_high_sync_sound_base_gain
    end
    m_orb_micro_surface_scale = m_orb_halo_micro_surface_scale_rest
end

----------------------------------------------------

local function begin_orb_impulse(t_from_brightness,
                                t_to_brightness,
                                t_from_sound_gain,
                                t_to_sound_gain,
                                t_from_high_sound_gain,
                                t_to_high_sound_gain,
                                t_from_micro_surface_scale,
                                t_to_micro_surface_scale,
                                t_fade_seconds)
    m_orb_impulse_is_active = true
    m_orb_impulse_timer = 0.0
    m_orb_impulse_fade_seconds = t_fade_seconds
    m_orb_impulse_from_brightness = t_from_brightness
    m_orb_impulse_to_brightness = t_to_brightness
    m_orb_impulse_from_sound_gain = t_from_sound_gain
    m_orb_impulse_to_sound_gain = t_to_sound_gain
    m_orb_impulse_from_high_sound_gain = t_from_high_sound_gain
    m_orb_impulse_to_high_sound_gain = t_to_high_sound_gain
    m_orb_impulse_from_micro_surface_scale = t_from_micro_surface_scale
    m_orb_impulse_to_micro_surface_scale = t_to_micro_surface_scale
    m_orb_brightness_multiplier = t_from_brightness
    m_orb_sound_gain = t_from_sound_gain
    m_orb_high_sound_gain = t_from_high_sound_gain
    m_orb_micro_surface_scale = t_from_micro_surface_scale
end

----------------------------------------------------

local function begin_orb_sync_pulse_impulse()
    begin_orb_impulse(ORB_LUMEN_PRE_SYNC / m_orb_base_lumens,
                        ORB_LUMEN_SYNC_PULSE / m_orb_base_lumens,
                        ORB_SOUND_GAIN_PRE_SYNC,
                        ORB_SOUND_GAIN_SYNC_PULSE,
                        ORB_HIGH_SOUND_GAIN_PRE_SYNC,
                        ORB_HIGH_SOUND_GAIN_SYNC_PULSE,
                        m_orb_halo_micro_surface_scale_rest,
                        ORB_HALO_MICRO_SURFACE_SCALE_SYNC_PULSE,
                        ORB_SYNC_PULSE_CROSSFADE_DURATION)
end

----------------------------------------------------

local function begin_orb_desync_impulse()
    local desync_high_sound_gain = ORB_HIGH_SOUND_GAIN_REST
    if entity_get_is_valid(m_orb_high_sync_sound_entity_id) then
        desync_high_sound_gain = m_orb_high_sync_sound_base_gain
    end

    begin_orb_impulse(m_orb_brightness_multiplier,
                        ORB_LUMEN_REST / m_orb_base_lumens,
                        m_orb_sound_gain,
                        ORB_SOUND_GAIN_REST,
                        m_orb_high_sound_gain,
                        desync_high_sound_gain,
                        m_orb_micro_surface_scale,
                        m_orb_halo_micro_surface_scale_rest,
                        ORB_DESYNC_CROSSFADE_DURATION)
end

----------------------------------------------------

local function advance_orb_impulse(t_delta_time)
    if not m_orb_impulse_is_active then
        return
    end

    -- Advance the impulse timer and calculate the blend factor.
    m_orb_impulse_timer = m_orb_impulse_timer + t_delta_time
    local blend = 1.0
    if m_orb_impulse_fade_seconds > 0.0001 then
        blend = m_orb_impulse_timer / m_orb_impulse_fade_seconds
    end
    if blend > 1.0 then
        blend = 1.0
    end

    -- Interpolate the orb's response params.
    m_orb_brightness_multiplier = math_lerp(m_orb_impulse_from_brightness, m_orb_impulse_to_brightness, blend)
    m_orb_sound_gain = math_lerp(m_orb_impulse_from_sound_gain, m_orb_impulse_to_sound_gain, blend)
    m_orb_high_sound_gain = math_lerp(m_orb_impulse_from_high_sound_gain, m_orb_impulse_to_high_sound_gain, blend)
    m_orb_micro_surface_scale = math_lerp(m_orb_impulse_from_micro_surface_scale, m_orb_impulse_to_micro_surface_scale, blend)

    -- Set inpulse to inactive once the blend has reached 1.0.
    if blend >= 1.0 then
        m_orb_impulse_is_active = false
    end
end

----------------------------------------------------

local function update_orb_response(t_delta_time, t_is_ending_stare)
    -- Active impulse response means so override any other orb response.
    if m_orb_impulse_is_active then
        advance_orb_impulse(t_delta_time)
        apply_orb_response_state()
        return
    end

    -- Orb's responce to player stare. 
    if t_is_ending_stare then
        -- Player is ending their stare at the orb.
        if m_ending_state >= ENDING_STATE_SYNCING then
            m_orb_brightness_multiplier = ORB_LUMEN_SYNC_PULSE / m_orb_base_lumens
            m_orb_sound_gain = ORB_SOUND_GAIN_SYNC_PULSE
            m_orb_high_sound_gain = ORB_HIGH_SOUND_GAIN_SYNC_PULSE
            m_orb_micro_surface_scale = ORB_HALO_MICRO_SURFACE_SCALE_SYNC_PULSE
        -- Calculate the charge for the pre-sync state.
        else
            local charge = m_ending_look_time / ORB_CHARGE_LOOK_DURATION
            if charge > 1.0 then
                charge = 1.0
            end
            local lumens = math_lerp(ORB_LUMEN_REST, ORB_LUMEN_PRE_SYNC, charge)
            m_orb_brightness_multiplier = lumens / m_orb_base_lumens
            m_orb_sound_gain = math_lerp(ORB_SOUND_GAIN_REST, ORB_SOUND_GAIN_PRE_SYNC, charge)
            m_orb_high_sound_gain = math_lerp(ORB_HIGH_SOUND_GAIN_REST, ORB_HIGH_SOUND_GAIN_PRE_SYNC, charge)
            m_orb_micro_surface_scale = m_orb_halo_micro_surface_scale_rest
        end
    -- Relax, nobody is staring at the orb.
    else
        set_orb_response_to_rest()
    end

    apply_orb_response_state()
end

----------------------------------------------------

local function stop_ending_warp_vertigo(t_fade_seconds)
    if m_ending_warp_vertigo_id == 0 then
        return
    end

    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_vertigo_effect", m_ending_warp_vertigo_id, t_fade_seconds)
    m_ending_warp_vertigo_id = 0
    m_ending_warp_vertigo_time_left = 0.0
end

----------------------------------------------------

local function set_ending_category_mix_multiplier(t_multiplier)
    sound_set_category_mix_multiplier(0, t_multiplier)
    sound_set_category_mix_multiplier(1, t_multiplier)
    sound_set_category_mix_multiplier(2, t_multiplier)
    sound_set_category_mix_multiplier(3, t_multiplier)
end

----------------------------------------------------

local function play_ending_sync_pulse_camera_burst()
    local fade_in_seconds = ORB_SYNC_PULSE_CROSSFADE_DURATION
    local fade_out_seconds = 0.11
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_fov_fade", 1.1, fade_in_seconds, 0.0, fade_out_seconds)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_radial_blur", 0.92, fade_in_seconds, 0.0, fade_out_seconds)
end

----------------------------------------------------

local function play_ending_desync_pulse_camera_burst()
    local fade_in_seconds = 0.035
    local fade_out_seconds = ORB_DESYNC_CROSSFADE_DURATION
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_fov_fade", 0.94, fade_in_seconds, 0.0, fade_out_seconds)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_radial_blur", 0.65, fade_in_seconds, 0.0, fade_out_seconds)
end

----------------------------------------------------

local function process_held_camera_effects()
    -- Held effects stay up for the whole play session. 

    -- We assume that if a camera shake is active, the rest of the held effects are already in place.
    if m_camera_shake_id ~= 0 then
        return true
    end

    -- Start the held camera effects.
    local shake_id = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_camera_shake", 0.0, CAMERA_EFFECT_SHAKE_RATE_FAR, 0.0, -1.0, 0.0)
    local fov_fade_id = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_fov_fade", 1.0, 0.0, -1.0, 0.0)
    local blur_id = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "add_radial_blur", 0.0, 0.0, -1.0, 0.0)

    -- Avoid assigning invalid effect IDs.
    if type(shake_id) ~= "number" or type(fov_fade_id) ~= "number" or type(blur_id) ~= "number" then
        print_error("[TheOrbCaveWorld] Camera effects did not start.")
        m_world_is_ready_to_run = false
        return false
    end

    -- Assign the effect IDs to the module-level variables.
    m_camera_shake_id = shake_id
    m_fov_fade_id = fov_fade_id
    m_radial_blur_id = blur_id
    return true
end

----------------------------------------------------

local function update_orb_view(t_frame)
    t_frame.is_in_affected_area = m_affected_area_overlap_count > 0
    local camera_position = transform_get_world_position(m_camera_entity_id)
    local sphere_position = transform_get_world_position(m_orb_entity_id)
    
    -- Range reference. 
    local range_reference_position = camera_position
    if entity_get_is_valid(m_player_body_entity_id) then
        range_reference_position = transform_get_world_position(m_player_body_entity_id)
    end
    t_frame.distance = vec3_length(vec3_sub(sphere_position, range_reference_position))

    t_frame.effective_ending_stare_distance = CAMERA_EFFECT_ENDING_STARE_DISTANCE
    if get_player_is_inspect_zoom_active() then
        t_frame.effective_ending_stare_distance = t_frame.effective_ending_stare_distance + CAMERA_EFFECT_ENDING_STARE_INSPECT_ZOOM_EXTRA_DISTANCE_METERS
    end

    t_frame.is_sphere_clearly_on_view = false
    t_frame.is_ending_stare = false
    if not t_frame.is_in_affected_area then
        return
    end

    -- Project the sphere's world position to screen space to determine visibility.
    local projected_screen_position = camera_get_world_to_screen_position(sphere_position)
    if not projected_screen_position then
        return
    end

    -- Determine if the sphere is clearly visible on the screen taking into account screen margins.
    local display_size = gui_get_display_size()
    local margin_x = display_size.x * CAMERA_EFFECT_SCREEN_EDGE_VIEW_MARGIN
    local margin_y = display_size.y * CAMERA_EFFECT_SCREEN_EDGE_VIEW_MARGIN
    local clearly_on_screen = projected_screen_position.x >= margin_x
                                and projected_screen_position.x <= display_size.x - margin_x
                                and projected_screen_position.y >= margin_y
                                and projected_screen_position.y <= display_size.y - margin_y
    
    -- Not on screen so skip.
    if not clearly_on_screen then
        return
    end

    -- The sphere has no collision, so a hit short of its surface is a wall.
    local is_occluded = false
    if t_frame.distance > CAMERA_EFFECT_ORB_RADIUS then
        local ray_result = physics_raycast(camera_position,
                                            sphere_position,
                                            m_raycast_exclude,
                                            false,
                                            PhysicsQuery.QUERY_GROUP_ALL,
                                            PhysicsQuery.QUERY_MASK_NON_TRIGGER)
        
        -- Check if the ray hit something before reaching the sphere's surface.
        if ray_result and ray_result.has_hit == true and ray_result.hit_distance < t_frame.distance - CAMERA_EFFECT_ORB_RADIUS then
            is_occluded = true
        end
    end

    -- It's occluded so skip. 
    if is_occluded then
        return
    end

    -- Used by other systems.
    t_frame.is_sphere_clearly_on_view = true

    -- Calculate the screen offset of the sphere from the center of the screen.
    local center_x = display_size.x * 0.5
    local center_y = display_size.y * 0.5
    local span_x = center_x - margin_x
    local span_y = center_y - margin_y
    local offset_x = 0.0
    local offset_y = 0.0
    if span_x > 0.0 then
        offset_x = math.abs(projected_screen_position.x - center_x) / span_x
    end
    if span_y > 0.0 then
        offset_y = math.abs(projected_screen_position.y - center_y) / span_y
    end

    -- Calculate the off-center factor based on the screen offset.
    local off_center = math_sqrt((offset_x * offset_x) + (offset_y * offset_y))
    if off_center > 1.0 then
        off_center = 1.0
    end
    local facing = 1.0 - off_center

    -- Determine if the player is staring at the orb closely enough and centered on the screen.
    if t_frame.distance <= t_frame.effective_ending_stare_distance and facing >= CAMERA_EFFECT_ENDING_STARE_SCREEN_CENTER_MIN then
        t_frame.is_ending_stare = true
    end
end

----------------------------------------------------

local function process_orb_lookat_pull(t_delta_time, t_frame)
    -- Stop the orb lookat pull.
    if m_orb_lookat_pull_is_active then
        if m_ending_is_player_locked
            or not t_frame.is_in_affected_area
            or t_frame.distance > t_frame.effective_ending_stare_distance then
            stop_orb_camera_lookat_pull()
        elseif t_frame.is_sphere_clearly_on_view then
            m_orb_lookat_break_escape_seconds = 0.0
        else
            m_orb_lookat_break_escape_seconds = m_orb_lookat_break_escape_seconds + t_delta_time
            if m_orb_lookat_break_escape_seconds >= ORB_LOOKAT_BREAK_ESCAPE_HOLD_DURATION then
                stop_orb_camera_lookat_pull()
            end
        end
        apply_orb_camera_lookat_pull_strength()
    -- Activate the orb lookat pull.
    elseif not m_ending_is_player_locked
        and t_frame.is_in_affected_area
        and t_frame.distance <= t_frame.effective_ending_stare_distance
        and t_frame.is_sphere_clearly_on_view then
        m_orb_lookat_pull_is_active = true
        m_orb_lookat_break_escape_seconds = 0.0
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "start_camera_lookat", m_orb_entity_id)
        apply_orb_camera_lookat_pull_strength()
    end

    -- Pull keeps the stare effects up until the player breaks away.
    local is_sphere_gaze_effects_active = m_orb_lookat_pull_is_active
    if t_frame.is_ending_stare then
        m_orb_ending_stare_effects_held = true
    end
    if not is_sphere_gaze_effects_active then
        m_orb_ending_stare_effects_held = false
    end

    -- Define whether the ending stare effects should be applied for this frame.
    t_frame.is_ending_stare_for_effects = t_frame.is_ending_stare
    if m_orb_ending_stare_effects_held and is_sphere_gaze_effects_active then
        t_frame.is_ending_stare_for_effects = true
    end
end

----------------------------------------------------

local function process_ending_stare_and_sync(t_delta_time, t_frame)
    t_frame.is_ending_synced = false
    t_frame.ending_white_ramp_time = 0.0

    -- Handle the ending stare and sync logic.
    if m_ending_state >= ENDING_STATE_COMMITTED then
        if m_ending_state == ENDING_STATE_COMMITTED then
            m_ending_white = m_ending_white + ((1.0 - ORB_WHITE_RAMP_PEAK) * (t_delta_time / ORB_WHITE_SNAP_DURATION))
            if m_ending_white > 1.0 then
                m_ending_white = 1.0
            end
            if m_ending_white >= 1.0 then
                m_ending_state = ENDING_STATE_TITLE
            end
        end
        return
    end

    -- Increase ending look time when the player is staring at the orb.
    if t_frame.is_ending_stare_for_effects then
        if m_ending_state == ENDING_STATE_REST then
            m_ending_state = ENDING_STATE_CHARGING
        end
        m_ending_look_time = m_ending_look_time + t_delta_time
    -- Decrease ending look time when the player is not staring at the orb.
    else
        m_ending_look_time = m_ending_look_time - t_delta_time
        if m_ending_look_time < 0.0 then
            m_ending_look_time = 0.0
        end
    end

    -- Determine when to trigger the sync stinger sound based on the player's look time.
    local stinger_trigger_look_seconds = ORB_CHARGE_LOOK_DURATION - ORB_SYNC_STINGER_LEAD
    if m_ending_look_time < stinger_trigger_look_seconds then
        m_ending_sync_stinger_sound_played = false
    end

    -- Looking away and escaping the camera pull before the sync commit returns the ending to rest.
    if (m_ending_state == ENDING_STATE_CHARGING or m_ending_state == ENDING_STATE_SYNCING) and not t_frame.is_ending_stare_for_effects then
        
        -- Play desync effects and reset the ending state when the player looks away.
        if m_ending_state == ENDING_STATE_SYNCING or m_ending_white > 0.0 then
            play_ending_desync_pulse_camera_burst()
        end

        begin_orb_desync_impulse()

        set_orb_lamp_flicker_preset_rest()

        if m_ending_sync_completed_sound_is_playing and entity_get_is_valid(m_ending_sync_completed_sound_entity_id) then
            sound_stop(m_ending_sync_completed_sound_entity_id, 0.0)
            m_ending_sync_completed_sound_is_playing = false
        end
        if entity_get_is_valid(m_ending_sync_stinger_sound_entity_id) and sound_get_is_playing(m_ending_sync_stinger_sound_entity_id) then
            sound_stop(m_ending_sync_stinger_sound_entity_id, 0.0)
        end

        m_ending_sync_stinger_sound_played = false

        stop_orb_choir_sync_sound(0.0)

        m_ending_state = ENDING_STATE_REST
        m_ending_look_time = 0.0
        m_ending_white = 0.0

        stop_ending_warp_vertigo(ENDING_WARP_VERTIGO_FADE_OUT_DURATION)

        m_ending_warp_sound_fade_is_active = false
        m_ending_warp_sound_fade_is_complete = false
        m_ending_game_sound_fade_is_active = false
        m_ending_game_sound_fade_is_complete = false
        m_ending_game_sound_fade_time_elapsed = 0.0

        set_ending_category_mix_multiplier(1.0)
    end

    -- Begin syncing phase.
    if t_frame.is_ending_stare_for_effects and m_ending_state == ENDING_STATE_CHARGING and m_ending_look_time >= ORB_CHARGE_LOOK_DURATION then
        play_ending_sync_pulse_camera_burst()
        begin_orb_sync_pulse_impulse()
        m_ending_state = ENDING_STATE_SYNCING

        -- Sync phase makes the orb light flicker.
        set_orb_lamp_flicker_preset(ORB_LAMP_FLICKER_PRESET_SYNC)

        -- Ramp-up for the synced hold starts the moment charge completes.
        if not m_ending_sync_completed_sound_is_playing and entity_get_is_valid(m_ending_sync_completed_sound_entity_id) then
            sound_play(m_ending_sync_completed_sound_entity_id, 0.0)
            m_ending_sync_completed_sound_is_playing = true
        end
    end

    -- Sync stinger sound to sync start.
    if t_frame.is_ending_stare_for_effects
        and not m_ending_sync_stinger_sound_played
        and entity_get_is_valid(m_ending_sync_stinger_sound_entity_id)
        and m_ending_look_time >= (ORB_CHARGE_LOOK_DURATION - ORB_SYNC_STINGER_LEAD) then
        sound_play(m_ending_sync_stinger_sound_entity_id, 0.0)
        m_ending_sync_stinger_sound_played = true
    end

    -- If synced, play the sequence completed sound.
    -- @NOTE: The name is a bit misleading but,
    -- this is a ramp up sound to prepare for ending that we need to sync here.
    t_frame.is_ending_synced = m_ending_state == ENDING_STATE_SYNCING
        and ORB_SYNC_HOLD_DURATION > 0.0
        and m_ending_look_time >= ORB_CHARGE_LOOK_DURATION

    if t_frame.is_ending_synced then
        t_frame.ending_white_ramp_time = m_ending_look_time - ORB_CHARGE_LOOK_DURATION

        -- Play the sync completed sound in case it was missed by the syncing transiiton.
        if not m_ending_sync_completed_sound_is_playing and entity_get_is_valid(m_ending_sync_completed_sound_entity_id) then
            sound_play(m_ending_sync_completed_sound_entity_id, 0.0)
            m_ending_sync_completed_sound_is_playing = true
        end
    end

    -- Ramp the white wash to the pre-warp peak.
    if t_frame.is_ending_synced and ORB_SYNC_HOLD_DURATION > 0.0 then
        local warp_start_ramp_seconds = ORB_SYNC_HOLD_DURATION - ENDING_WARP_VISIBLE_DURATION
        if t_frame.ending_white_ramp_time <= warp_start_ramp_seconds then
            if warp_start_ramp_seconds > 0.0 then
                m_ending_white = (t_frame.ending_white_ramp_time / warp_start_ramp_seconds) * ORB_WHITE_RAMP_PEAK
            end
        -- Take it to full white with the warp.
        else
            local warp_elapsed = t_frame.ending_white_ramp_time - warp_start_ramp_seconds
            local warp_fade = 0.0
            if ENDING_WARP_VISIBLE_DURATION > 0.0 then
                warp_fade = warp_elapsed / ENDING_WARP_VISIBLE_DURATION
            end
            if warp_fade > 1.0 then
                warp_fade = 1.0
            end
            m_ending_white = ORB_WHITE_RAMP_PEAK + ((1.0 - ORB_WHITE_RAMP_PEAK) * warp_fade)
        end
    end

    -- Initiate the warp effect as the ending sync reaches its final phase.
    if t_frame.is_ending_synced then
        local warp_start_ramp_seconds = ORB_SYNC_HOLD_DURATION - ENDING_WARP_VISIBLE_DURATION
        if t_frame.ending_white_ramp_time >= warp_start_ramp_seconds then
            if not m_ending_warp_sound_fade_is_active then
                m_ending_warp_sound_fade_is_active = true
                if music_get_is_playing() then
                    music_stop(ENDING_WARP_LEAD_DURATION)
                end
            end

            -- Add the vertigo effect.
            -- Drive it with the white fade so the dolly is still moving when the screen is white.
            if m_ending_warp_vertigo_id == 0 then
                local vertigo_id = module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                                                        "add_vertigo_effect",
                                                        0.0,
                                                        0.0,
                                                        -1.0,
                                                        ENDING_WARP_VERTIGO_FADE_OUT_DURATION)

                if type(vertigo_id) == "number" then -- Sanity check.
                    m_ending_warp_vertigo_id = vertigo_id
                    m_ending_warp_vertigo_time_left = ENDING_WARP_LEAD_DURATION + ENDING_WARP_VERTIGO_HOLD_DURATION + ENDING_WARP_VERTIGO_FADE_OUT_DURATION
                    
                    -- @TODO: Replace wit proper sound. snd_sync_stinger stands in until the warp sound exists.
                    if entity_get_is_valid(m_ending_sync_stinger_sound_entity_id) then
                        sound_play(m_ending_sync_stinger_sound_entity_id, 0.0)
                    end
                end
            end
            if m_ending_warp_vertigo_id ~= 0 then
                local warp_elapsed = t_frame.ending_white_ramp_time - warp_start_ramp_seconds
                local warp_fade = 0.0
                if ENDING_WARP_VISIBLE_DURATION > 0.0 then
                    warp_fade = warp_elapsed / ENDING_WARP_VISIBLE_DURATION
                end
                if warp_fade > 1.0 then
                    warp_fade = 1.0
                end
                module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                                    "set_vertigo_effect_intensity",
                                    m_ending_warp_vertigo_id,
                                    ENDING_WARP_VERTIGO_INTENSITY * warp_fade)
            end
        end
    end

    -- Check if the sync is complete and commit to the ending.
    if t_frame.is_ending_synced and m_ending_look_time >= ORB_CHARGE_LOOK_DURATION + ORB_SYNC_HOLD_DURATION then
        stop_ending_warp_vertigo(0.0)
        m_ending_state = ENDING_STATE_COMMITTED
        -- One hard shake as the view is thrown into the white flash.
        module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                            "add_camera_shake",
                            ENDING_WARP_SHAKE_FORCE,
                            ENDING_WARP_SHAKE_RATE,
                            ENDING_WARP_SHAKE_FADE_IN_DURATION,
                            ENDING_WARP_SHAKE_HOLD_DURATION,
                            ENDING_WARP_SHAKE_FADE_OUT_DURATION)
    end
end

----------------------------------------------------

local function process_ending_screen_fade()
    -- Handle the ending screen fade to white effect.
    if m_ending_white > 0.0 or m_ending_screen_fade_is_active then
        if m_ending_white > 0.0 or m_ending_state >= ENDING_STATE_COMMITTED then
            if not m_ending_screen_fade_is_active then
                module_call_function(CAMERA_EFFECTS_MODULE_NAME, "start_screen_fade", m_ending_white, ENDING_WHITE, 0.0, -1.0, 0.0)
                m_ending_screen_fade_is_active = true
            end
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_screen_fade_color", ENDING_WHITE)
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_screen_fade_intensity", m_ending_white)
        elseif m_ending_screen_fade_is_active then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.15)
            m_ending_screen_fade_is_active = false
        end
    end
end

----------------------------------------------------

local function process_ending_warp_fade(t_delta_time, t_frame)
    -- Fade the ambient category across the warp. Game stays up for the warp stinger.
    if m_ending_warp_sound_fade_is_active and not m_ending_warp_sound_fade_is_complete then
        local mix = 0.0
        if t_frame.ending_white_ramp_time > 0.0 then
            local warp_start_ramp_seconds = ORB_SYNC_HOLD_DURATION - ENDING_WARP_VISIBLE_DURATION
            local elapsed = t_frame.ending_white_ramp_time - warp_start_ramp_seconds
            if elapsed < 0.0 then
                elapsed = 0.0
            end
            mix = 1.0 - (elapsed / ENDING_WARP_LEAD_DURATION)
            if mix < 0.0 then
                mix = 0.0
            end
        end

        -- Apply the calculated mix to the ambient sound category.
        sound_set_category_mix_multiplier(SOUND_CATEGORY_AMBIENT, mix)

        -- Stop all orb sync sounds once the ambient mix reaches zero.
        if mix <= 0.0 then
            for i = 1, #m_orb_sync_sound_entries do
                local sound_entry = m_orb_sync_sound_entries[i]
                if entity_get_is_valid(sound_entry.entity_id) then
                    sound_stop(sound_entry.entity_id, 0.0)
                end
            end
            if entity_get_is_valid(m_orb_high_sync_sound_entity_id) then
                sound_stop(m_orb_high_sync_sound_entity_id, 0.0)
            end
            if entity_get_is_valid(m_orb_glitch_sound_entity_id) then
                sound_stop(m_orb_glitch_sound_entity_id, 0.0)
            end
            if entity_get_is_valid(m_reveal_stinger_sound_entity_id) then
                sound_stop(m_reveal_stinger_sound_entity_id, 0.0)
            end
            stop_orb_choir_sync_sound(0.0)
            m_ending_warp_sound_fade_is_complete = true
        end
    end

    -- After the screen is fully white, drop the game bus fast so the warp stinger can finish on its own.
    if m_ending_state >= ENDING_STATE_COMMITTED and m_ending_white >= 1.0 and not m_ending_game_sound_fade_is_complete then
        if not m_ending_game_sound_fade_is_active then
            m_ending_game_sound_fade_is_active = true
            m_ending_game_sound_fade_time_elapsed = 0.0
        end

        m_ending_game_sound_fade_time_elapsed = m_ending_game_sound_fade_time_elapsed + t_delta_time
        local game_mix = 1.0 - (m_ending_game_sound_fade_time_elapsed / ENDING_POST_WHITE_GAME_SOUND_FADE_DURATION)
        if game_mix < 0.0 then
            game_mix = 0.0
        end

        sound_set_category_mix_multiplier(0, game_mix)
        if game_mix <= 0.0 then
            if entity_get_is_valid(m_ending_sync_stinger_sound_entity_id) then
                sound_stop(m_ending_sync_stinger_sound_entity_id, 0.0)
            end
            m_ending_game_sound_fade_is_complete = true
        end
    end

    -- The vertigo effect removes itself when its fade ends.
    -- Drop the id so a later stop does not look up a dead instance.
    if m_ending_warp_vertigo_id ~= 0 then
        m_ending_warp_vertigo_time_left = m_ending_warp_vertigo_time_left - t_delta_time
        if m_ending_warp_vertigo_time_left <= 0.0 then
            m_ending_warp_vertigo_id = 0
            m_ending_warp_vertigo_time_left = 0.0
        end
    end
end

----------------------------------------------------

local function process_orb_sync_presentation(t_delta_time, t_frame)
    -- Sync phase drives the glitch sounds.
    local orb_sync_phase = get_orb_sync_phase(t_frame.is_ending_synced, t_frame.is_ending_stare_for_effects)
    process_orb_glitch_sounds(t_delta_time, orb_sync_phase, t_frame.is_in_affected_area)
end

----------------------------------------------------

local function process_gaze_camera_effects(t_delta_time, t_frame)
    local shake_force = 0.0
    local shake_rate = CAMERA_EFFECT_SHAKE_RATE_FAR
    local fov_multiplier = 1.0
    local radial_blur = 0.0

    if t_frame.is_in_affected_area then
        -- Calculate the player's proximity to the sphere so we can define the intensity of the camera shake.
        local proximity = 0.0
        if t_frame.distance <= CAMERA_EFFECT_LOOK_DISTANCE_NEAR then
            proximity = 1.0
        elseif t_frame.distance < CAMERA_EFFECT_LOOK_DISTANCE_FAR then
            proximity = (CAMERA_EFFECT_LOOK_DISTANCE_FAR - t_frame.distance) / (CAMERA_EFFECT_LOOK_DISTANCE_FAR - CAMERA_EFFECT_LOOK_DISTANCE_NEAR)
        end

        shake_force = CAMERA_EFFECT_SHAKE_FORCE_BASE
        shake_rate = math_lerp(CAMERA_EFFECT_SHAKE_RATE_FAR, CAMERA_EFFECT_SHAKE_RATE_NEAR, proximity)
    end

    -- Apply camera effects based on the sphere gaze.
    if m_orb_lookat_pull_is_active then
        fov_multiplier = CAMERA_EFFECT_FOV_LOOK
        radial_blur = CAMERA_EFFECT_RADIAL_BLUR_LOOK
    end

    -- Apply orb pre-sync / post-sync camera effects based on the ending stare.
    local is_post_sync_pulse = t_frame.is_ending_stare_for_effects and m_ending_state >= ENDING_STATE_SYNCING
    if t_frame.is_ending_stare_for_effects then
        -- Gradually increase camera effects as the player stares at the orb.
        if m_ending_state < ENDING_STATE_SYNCING then
            local charge = m_ending_look_time / ORB_CHARGE_LOOK_DURATION
            if charge > 1.0 then
                charge = 1.0
            end
            fov_multiplier = math_lerp(CAMERA_EFFECT_FOV_LOOK, CAMERA_EFFECT_FOV_PRE_SYNC, charge)
            radial_blur = math_lerp(CAMERA_EFFECT_RADIAL_BLUR_LOOK, CAMERA_EFFECT_RADIAL_BLUR_PRE_SYNC, charge)
            shake_rate = math_lerp(shake_rate, CAMERA_EFFECT_SHAKE_RATE_STARE_PEAK, charge)
        -- Apply pre-sync camera effects.
        elseif t_frame.is_ending_synced and ORB_SYNC_HOLD_DURATION > 0.0 then
            shake_force = CAMERA_EFFECT_SHAKE_FORCE_SYNC
            fov_multiplier = CAMERA_EFFECT_FOV_SYNC
            radial_blur = CAMERA_EFFECT_RADIAL_BLUR_SYNC
            local charge = t_frame.ending_white_ramp_time / ORB_SYNC_HOLD_DURATION
            if charge > 1.0 then
                charge = 1.0
            end
            shake_rate = math_lerp(CAMERA_EFFECT_SHAKE_RATE_STARE_PEAK, CAMERA_EFFECT_SHAKE_RATE_SYNC_PEAK, charge)
        -- Apply post-sync camera effects.
        else
            fov_multiplier = CAMERA_EFFECT_FOV_PRE_SYNC
            radial_blur = CAMERA_EFFECT_RADIAL_BLUR_PRE_SYNC
            shake_rate = CAMERA_EFFECT_SHAKE_RATE_STARE_PEAK
        end
    end

    -- Look away. FOV and blur ease off. Shake stays if we are still inside a trigger.
    local blend = math_clamp(CAMERA_EFFECT_BLEND_SPEED * t_delta_time * 0.25, 0.0, 1.0)
    m_shake_force = math_lerp(m_shake_force, shake_force, blend)
    m_fov_multiplier = math_lerp(m_fov_multiplier, fov_multiplier, blend)
    m_radial_blur = math_lerp(m_radial_blur, radial_blur, blend)

    -- Apply the calculated camera shake, FOV, and radial blur effects.
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_camera_shake_force", m_camera_shake_id, m_shake_force)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_camera_shake_rate", m_camera_shake_id, shake_rate)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_fov_fade_multiplier", m_fov_fade_id, m_fov_multiplier)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_radial_blur_intensity", m_radial_blur_id, m_radial_blur)

    -- Handle the ending image trail effect based on the post-sync pulse state.
    if is_post_sync_pulse and not m_ending_image_trail_is_active then
        m_ending_image_trail_id = module_call_function(
            CAMERA_EFFECTS_MODULE_NAME,
            "add_image_trail",
            ENDING_IMAGE_TRAIL_INTENSITY,
            0.0,
            -1.0,
            ENDING_IMAGE_TRAIL_FADE_OUT_DURATION)
        m_ending_image_trail_is_active = true
    -- Deactivate the ending image trail if we are no longer in the post-sync pulse state.
    elseif not is_post_sync_pulse and m_ending_image_trail_is_active then
        if m_ending_image_trail_id ~= 0 then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_image_trail", m_ending_image_trail_id, ENDING_IMAGE_TRAIL_FADE_OUT_DURATION)
        end
        m_ending_image_trail_id = 0
        m_ending_image_trail_is_active = false
    end
end

----------------------------------------------------

local function lock_player_for_ending()
    if m_ending_state < ENDING_STATE_COMMITTED or m_ending_is_player_locked then
        return
    end

    world_call_entity_script_function(m_player_entity_id, "set_controls_locked", true)
    if get_game_mode_active() then
        input_set_mouse_capture(true)
    end
    m_ending_is_player_locked = true
end

----------------------------------------------------

local function process_ending_title(t_delta_time)
    if m_ending_state < ENDING_STATE_TITLE then
        return
    end

    -- Process the ending title fade in, hold, and fade out.
    if m_ending_title_hold_time < ENDING_TITLE_READ_DURATION then
        if m_ending_title_alpha < 1.0 then
            m_ending_title_alpha = m_ending_title_alpha + (t_delta_time / ENDING_TITLE_FADE_IN_DURATION)
            if m_ending_title_alpha > 1.0 then
                m_ending_title_alpha = 1.0
            end
        else
            m_ending_title_hold_time = m_ending_title_hold_time + t_delta_time
            if m_ending_title_hold_time > ENDING_TITLE_READ_DURATION then
                m_ending_title_hold_time = ENDING_TITLE_READ_DURATION
            end
        end
    elseif m_ending_title_alpha > 0.0 then
        m_ending_title_alpha = m_ending_title_alpha - (t_delta_time / ENDING_TITLE_FADE_OUT_DURATION)
        if m_ending_title_alpha < 0.0 then
            m_ending_title_alpha = 0.0
        end
    end
end

----------------------------------------------------

local function process_ending_title_game_sound()
    -- Fade out the ending game sound based on the title alpha.
    if m_ending_game_sound_fade_is_complete or m_ending_title_alpha <= 0.0 then
        return
    end

    local sound_mix_multiplier = 1.0 - m_ending_title_alpha
    sound_set_category_mix_multiplier(0, sound_mix_multiplier)
end

----------------------------------------------------

local function process_ending_world_change()
    if m_ending_state ~= ENDING_STATE_TITLE or m_ending_title_hold_time < ENDING_TITLE_READ_DURATION or m_ending_title_alpha > 0.0 then
        return
    end

    m_ending_state = ENDING_STATE_LEAVE
    if ENDING_BLOCK_EXTERIOR_WORLD_LOAD_AFTER_SEQUENCE then
        return
    end

    if module_get_is_valid(GAME_MODULE_NAME) then
        module_call_function(GAME_MODULE_NAME, "clear_orb_arrival_movable_layout_for_cave_door")
        module_call_function(GAME_MODULE_NAME, "set_exterior_intro_pending_white_auto")
    end

    if not world_load_from_file(TheOrbWorldPaths.ARRIVAL_WORLD_PATH, true) then
        print_error("[TheOrbCaveWorld] Failed to load the orb arrival world after the ending sequence.")
    end
end

----------------------------------------------------
-- CALLBACKS
----------------------------------------------------

function TheOrbCaveWorld.on_overlap(t_trigger_entity_id, t_other_entity_id, t_enter, _t_point, _t_normal, _t_rel_vel)
    if not m_world_is_ready_to_run then
        return
    end

    -- Check that it's the player entity triggering the overlap.
    local is_player = false
    if entity_get_is_valid(t_other_entity_id) then
        if t_other_entity_id == m_player_entity_id then
            is_player = true
        elseif entity_get_is_valid(m_player_body_entity_id) and t_other_entity_id == m_player_body_entity_id then
            is_player = true
        else
            local parent_entity_id = entity_get_parent(t_other_entity_id)
            if entity_get_is_valid(parent_entity_id) and parent_entity_id == m_player_entity_id then
                is_player = true
            end
        end
    end

    if not is_player then
        return
    end

    -- Check for overlap with the alien cave death pit.
    if OrbCaveDeathPit.on_overlap(t_trigger_entity_id, t_enter) then
        return
    end

    -- Check for overlap with the orb reveal stinger trigger.
    if entity_get_is_valid(m_reveal_stinger_trigger_entity_id)
        and t_trigger_entity_id == m_reveal_stinger_trigger_entity_id then
        if t_enter then
            play_orb_reveal_stinger_once_per_session()
        end
        return
    end

    -- Check for overlap with the orb effect triggers.
    if m_orb_effect_trigger_ids[t_trigger_entity_id] ~= true then
        return
    end

    if t_enter then
        m_affected_area_overlap_count = m_affected_area_overlap_count + 1
    else
        m_affected_area_overlap_count = m_affected_area_overlap_count - 1
        if m_affected_area_overlap_count < 0 then
            m_affected_area_overlap_count = 0
        end
    end
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function TheOrbCaveWorld.on_ready()
    -- Retrieve essential entity IDs.
    m_player_entity_id = world_get_entity_by_name("player")
    m_orb_entity_id = world_get_entity_by_name("alien_sphere")
    if not entity_get_is_valid(m_player_entity_id) then
        print_error("[TheOrbCaveWorld] Player entity was not found.")
        return
    end
    if not entity_get_is_valid(m_orb_entity_id) then
        print_error("[TheOrbCaveWorld] Alien sphere entity was not found.")
        return
    end

    -- Alien sphere light setup.
    m_orb_light_entity_id = entity_get_child_by_path(m_orb_entity_id, "systems/light")
    if not entity_get_is_valid(m_orb_light_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere lamp entity was not found under systems/light or light.")
    elseif entity_get_has_light_component(m_orb_light_entity_id) then
        m_orb_base_lumens = light_get_default_lumens(m_orb_light_entity_id)
    end
    if m_orb_base_lumens <= 0.0 then
        m_orb_base_lumens = ORB_LUMEN_REST
    end

    -- Alien sphere sync sounds.
    register_orb_sync_sound(get_orb_child_entity_id("sound/snd_noise", "snd_noise"))
    register_orb_sync_sound(get_orb_child_entity_id("sound/snd_earthquake", "snd_earthquake"))

    -- Orb high noise sound.
    local high_noise_sound_entity_id = get_orb_child_entity_id("sound/snd_noise_high", "snd_noise_high")
    if entity_get_is_valid(high_noise_sound_entity_id) and entity_get_has_sound_component(high_noise_sound_entity_id) then
        m_orb_high_sync_sound_entity_id = high_noise_sound_entity_id
        m_orb_high_sync_sound_base_gain = sound_get_base_gain(high_noise_sound_entity_id)
    end

    -- Orb glitch sound
    m_orb_glitch_sound_entity_id = get_orb_child_entity_id("sound/snd_glitch", "snd_glitch")
    if not entity_get_is_valid(m_orb_glitch_sound_entity_id)
        or not entity_get_has_sound_component(m_orb_glitch_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere snd_glitch was not found.")
        m_orb_glitch_sound_entity_id = 0
    else
        m_orb_glitch_cooldown_timer = ORB_GLITCH_INTERVAL_BY_SYNC_PHASE[ORB_SYNC_PHASE_REST]
    end

    -- Stringers
    m_ending_sync_completed_sound_entity_id = get_orb_child_entity_id("sound/snd_sync_completed", "snd_sync_completed")
    if not entity_get_is_valid(m_ending_sync_completed_sound_entity_id)
        or not entity_get_has_sound_component(m_ending_sync_completed_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere snd_sync_completed was not found.")
        m_ending_sync_completed_sound_entity_id = 0
    end

    m_reveal_stinger_sound_entity_id = get_orb_child_entity_id("sound/snd_reveal_stinger", "snd_reveal_stinger")
    if not entity_get_is_valid(m_reveal_stinger_sound_entity_id)
        or not entity_get_has_sound_component(m_reveal_stinger_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere snd_reveal_stinger was not found.")
        m_reveal_stinger_sound_entity_id = 0
    end

    m_ending_sync_stinger_sound_entity_id = get_orb_child_entity_id("sound/snd_sync_stinger", "snd_sync_stinger")
    if not entity_get_is_valid(m_ending_sync_stinger_sound_entity_id)
        or not entity_get_has_sound_component(m_ending_sync_stinger_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere snd_sync_stinger was not found.")
        m_ending_sync_stinger_sound_entity_id = 0
    end

    m_reveal_stinger_trigger_entity_id = world_get_entity_by_name("trigger_alien_sphere_reveal_stinger")
    if not entity_get_is_valid(m_reveal_stinger_trigger_entity_id) then
        print_warning("[TheOrbCaveWorld] trigger_orb_reveal_stinger was not found.")
        m_reveal_stinger_trigger_entity_id = 0
    else
        physics_body_set_trigger_callbacks_enabled(m_reveal_stinger_trigger_entity_id, true)
    end

    -- Setup the Orb Cave Death Pit system.
    OrbCaveDeathPit.set_player_entity_id(m_player_entity_id)
    OrbCaveDeathPit.setup_trigger()

    -- Get the orb's choir sound entity.
    m_orb_choir_sound_entity_id = get_orb_child_entity_id("sound/snd_choir", "snd_choir")
    -- Check if the orb choir sound entity is valid and has a sound component.
    if not entity_get_is_valid(m_orb_choir_sound_entity_id)
        or not entity_get_has_sound_component(m_orb_choir_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere snd_choir was not found.")
        m_orb_choir_sound_entity_id = 0
    -- Initialize the orb choir sound. 
    else
        m_orb_choir_sound_authored_gain = sound_get_base_gain(m_orb_choir_sound_entity_id)
        if m_orb_choir_sound_authored_gain <= 0.0 then
            m_orb_choir_sound_authored_gain = 1.0
        end
        
        sound_set_looping(m_orb_choir_sound_entity_id, true)
        if sound_get_is_playing(m_orb_choir_sound_entity_id) then
            sound_stop(m_orb_choir_sound_entity_id, 0.0)
        end
    end

    -- Get the orb's halo refract particle system entity.
    local halo_refract_entity_id = entity_get_child_by_path(m_orb_entity_id, "systems/particles/ps_halo_refract")
    
    if entity_get_is_valid(halo_refract_entity_id) and entity_get_has_particle_system_component(halo_refract_entity_id) then
        m_orb_halo_refract_entity_id = halo_refract_entity_id
        m_orb_halo_micro_surface_scale_rest = particle_system_get_uniform_float(halo_refract_entity_id, ORB_HALO_MICRO_SURFACE_UNIFORM)
    end
    if m_orb_halo_micro_surface_scale_rest <= 0.0 then
        m_orb_halo_micro_surface_scale_rest = ORB_HALO_MICRO_SURFACE_SCALE_REST
    end

    -- Set the orb's response to its rest state.
    set_orb_response_to_rest()

    -- Apply the orb's response state.
    apply_orb_response_state()

    -- Orb sync sounds.
    if #m_orb_sync_sound_entries == 0 and not entity_get_is_valid(m_orb_high_sync_sound_entity_id) then
        print_warning("[TheOrbCaveWorld] Alien sphere sync sounds were not found.")
    end

    -- Get the player's camera entity.
    m_camera_entity_id = entity_get_child_by_name(m_player_entity_id, "camera")
    if not entity_get_is_valid(m_camera_entity_id) then
        print_error("[TheOrbCaveWorld] Player camera was not found.")
        return
    end

    -- Get the player's body.
    m_player_body_entity_id = entity_get_child_by_name(m_player_entity_id, "body")

    -- Validate the tagged triggers for the orb behavior.
    local tagged_trigger_ids = world_get_entities_by_tag(CAMERA_EFFECT_AFFECTED_AREA_TRIGGER)
    if tagged_trigger_ids == nil or #tagged_trigger_ids == 0 then
        print_error("[TheOrbCaveWorld] No entities with tag " .. CAMERA_EFFECT_AFFECTED_AREA_TRIGGER .. ".")
        return
    end

    for i = 1, #tagged_trigger_ids do
        local trigger_entity_id = tagged_trigger_ids[i]
        if not entity_get_is_valid(trigger_entity_id) then
            print_error("[TheOrbCaveWorld] Alien sphere trigger was not found.")
            return
        end

        m_orb_effect_trigger_ids[trigger_entity_id] = true
        physics_body_set_trigger_callbacks_enabled(trigger_entity_id, true)
    end

    -- Ensure the CameraEffects module is valid before proceeding.
    if not module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME) then
        print_error("[TheOrbCaveWorld] CameraEffects module is not valid.")
        return
    end

    -- Exclude the player and camera from raycasts toward the orb.
    m_raycast_exclude[1] = m_camera_entity_id
    m_raycast_exclude[2] = m_player_entity_id
    if entity_get_is_valid(m_player_body_entity_id) then
        m_raycast_exclude[3] = m_player_body_entity_id
    end

    -- Ready to go. 
    m_world_is_ready_to_run = true
end

----------------------------------------------------

function TheOrbCaveWorld.on_process(t_delta_time)
    if not m_world_is_ready_to_run then
        return
    end

    -- Player fell into the death pit.
    if OrbCaveDeathPit.get_is_sequence_active() then
        stop_orb_camera_lookat_pull()
        OrbCaveDeathPit.process(t_delta_time)
        return
    end

    -- Process held camera effects first.
    if not process_held_camera_effects() then
        return
    end

    -- Frame data for the current update cycle.
    local frame = {
        is_in_affected_area = false,
        distance = 0.0,
        effective_ending_stare_distance = 0.0,
        is_sphere_clearly_on_view = false,
        is_ending_stare = false,
        is_ending_stare_for_effects = false,
        is_ending_synced = false,
        ending_white_ramp_time = 0.0,
    }

    -- Player sees the orb and a close stare pull the camera.
    update_orb_view(frame)
    process_orb_lookat_pull(t_delta_time, frame)

    -- Stare builds up the orb sync state.
    process_ending_stare_and_sync(t_delta_time, frame)
    process_ending_screen_fade()
    process_ending_warp_fade(t_delta_time, frame)

    -- Sound and light follow the orb-sync and camera effects follow the gaze.
    update_orb_choir_sync_sound(frame.is_ending_synced, frame.ending_white_ramp_time, m_ending_white)
    process_orb_sync_presentation(t_delta_time, frame)
    update_orb_response(t_delta_time, frame.is_ending_stare_for_effects)
    process_gaze_camera_effects(t_delta_time, frame)

    -- Committed gaze freezes the player and the title plays on the white bg.
    lock_player_for_ending()
    process_ending_title(t_delta_time)
    process_ending_title_game_sound()
    process_ending_world_change()
end

----------------------------------------------------

function TheOrbCaveWorld.on_draw(_t_delta_time)
    -- Draw the ending title and subtitle if applicable.
    if (OrbCaveDeathPit.get_is_sequence_active()) then
        OrbCaveDeathPit.draw()
        return
    end

    -- If the ending title is fully transparent skip drawing altogether.
    if m_ending_title_alpha <= 0.0 then
        return
    end

    -- 
    -- Push draw priritis
    gui_push_draw_priority(ENDING_TITLE_DRAW_PRIORITY)
    gui_push_foreground_draw()

    -- Begin drawing the ending screen canvas.
    local canvas_flags = GuiWindowFlags.NO_MOVE + GuiWindowFlags.NO_INPUTS + GuiWindowFlags.NO_FOCUS_ON_APPEARING
    if (not gui_begin_screen_canvas("ending_screen", canvas_flags)) then
        gui_pop_foreground_draw()
        gui_pop_draw_priority()
        return
    end

    -- Calculate layout and text properties for the ending title and subtitle.
    local layout_size = gui_get_layout_size()
    local title_font_size = gui_get_normalized_to_pixels(ENDING_TITLE_FONT_SIZE)
    local subtitle_font_size = gui_get_normalized_to_pixels(ENDING_SUBTITLE_FONT_SIZE)
    local title_gap = gui_get_normalized_to_pixels(ENDING_TITLE_SUBTITLE_GAP)
    local block_height = title_font_size + title_gap + subtitle_font_size
    local block_y = (layout_size.y - block_height) * 0.5
    local text_color = Colors.get_with_alpha(Colors.BLACK, m_ending_title_alpha)

    -- Draw the ending title at the center of the screen.
    gui_draw_text_aligned(ENDING_TITLE_TEXT,
                            vec2(0.0, block_y),
                            vec2(layout_size.x, title_font_size),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            title_font_size,
                            text_color,
                            ENDING_TITLE_FONT_ID)
    
    -- Draw the ending subtitle below the title.
    gui_draw_text_aligned(ENDING_SUBTITLE_TEXT,
                            vec2(0.0, block_y + title_font_size + title_gap),
                            vec2(layout_size.x, subtitle_font_size),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            subtitle_font_size,
                            text_color,
                            ENDING_TITLE_FONT_ID)

    -- End of the ending title drawing section.
    gui_end_screen_canvas()
    gui_pop_foreground_draw()
    gui_pop_draw_priority()
end

----------------------------------------------------

function TheOrbCaveWorld.on_shutdown()
    stop_orb_camera_lookat_pull()
    OrbCaveDeathPit.on_shutdown()

    -- Stop any active camera effects.
    if(module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME)) then
        if m_camera_shake_id ~= 0 then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_camera_shake", m_camera_shake_id, 0.0)
        end
        if m_fov_fade_id ~= 0 then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_fov_fade", m_fov_fade_id, 0.0)
        end
        if m_radial_blur_id ~= 0 then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_radial_blur", m_radial_blur_id, 0.0)
        end
        if m_ending_image_trail_id ~= 0 then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_image_trail", m_ending_image_trail_id, 0.0)
        end
        stop_ending_warp_vertigo(0.0)
        if m_ending_screen_fade_is_active and m_ending_state ~= ENDING_STATE_LEAVE then
            module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
        end
    end

    -- Reset orb state and related effects.
    m_orb_impulse_is_active = false
    m_orb_impulse_timer = 0.0
    m_orb_impulse_fade_seconds = 0.0
    set_orb_response_to_rest()
    apply_orb_response_state()
    set_orb_lamp_flicker_preset_rest()
    m_orb_glitch_active_sync_phase = ORB_SYNC_PHASE_REST
    m_orb_glitch_cooldown_timer = ORB_GLITCH_INTERVAL_BY_SYNC_PHASE[ORB_SYNC_PHASE_REST]
    restore_orb_sync_sound_base_gains()
    stop_orb_choir_sync_sound(0.0)
    set_ending_category_mix_multiplier(1.0)
end

----------------------------------------------------

return TheOrbCaveWorld
