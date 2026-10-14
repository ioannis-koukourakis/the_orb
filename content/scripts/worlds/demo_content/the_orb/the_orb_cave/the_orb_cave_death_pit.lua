local OrbCaveDeathPit = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local TheOrbWorldPaths = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_world_paths.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")
local Utilities = dofile("../content/scripts/shared/utilities.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local CAMERA_EFFECTS_MODULE_NAME = "CameraEffectsModule"
local GAME_MODULE_NAME = "game_module"
local MAIN_MENU_MODULE_NAME = "MainMenuModule"

local THE_ORB_MAIN_MENU_WORLD_PATH = TheOrbWorldPaths.MAIN_MENU_WORLD_PATH
local DEATH_TRIGGER_NAME = "trigger_death_pit"

local DEATH_MESSAGE_TEXT = "Watch your step!"
local DEATH_FADE_TO_BLACK_DURATION = 0.35
local DEATH_MESSAGE_FADE_IN_DURATION = 1.2
local DEATH_MESSAGE_HOLD_DURATION = 0.8
local DEATH_MESSAGE_FADE_OUT_DURATION = 1.2
local DEATH_MESSAGE_FONT_SIZE = 0.05
local DEATH_DRAW_UI_LAYER_PRIORITY = 15 -- Use a high value to cover other UI elements. Range is 0 - 63 (64 in total). 

-- Death sequence phases.
local DEATH_PHASE_FADE_TO_BLACK = 1
local DEATH_PHASE_MESSAGE = 2

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_player_entity_id = 0
local m_trigger_entity_id = 0
local m_sequence_is_active = false
local m_phase = 0
local m_timer = 0.0
local m_message_alpha = 0.0
local m_screen_fade_is_active = false

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function load_main_menu_after_death_pit()
    -- Reset sound states to normal before loading the main menu. 
    --Utilities.sound_set_all_category_mix_multiplier(1.0)
    -- Unpause the game before transitioning to the main menu.
    --game_set_paused(false)

    -- Stop any ongoing screen fade before loading the main menu.
    if module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME) and m_screen_fade_is_active then
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
        m_screen_fade_is_active = false
    end
    -- Reset any game-specific states before loading the main menu.
    if module_get_is_valid(GAME_MODULE_NAME) then
        module_call_function(GAME_MODULE_NAME, "clear_exterior_intro_pending")
    end

    -- Load the main menu.
    if module_get_is_valid(MAIN_MENU_MODULE_NAME) then
        module_call_function(MAIN_MENU_MODULE_NAME, "set_pause_menu_active", false)
        module_call_function(MAIN_MENU_MODULE_NAME, "set_title_menu_screen_active", true)
        module_call_function(MAIN_MENU_MODULE_NAME, "set_menu_open", true)
    end

    -- Ensure the main menu is loaded properly.
    if not world_load_from_file(THE_ORB_MAIN_MENU_WORLD_PATH) then
        print_error("[OrbCaveDeathPit] Failed to load the main menu after the death pit.")
        m_sequence_is_active = false
        return
    end

    -- Mark death pit sequence inactive.
    m_sequence_is_active = false
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function OrbCaveDeathPit.set_player_entity_id(t_player_entity_id)
    m_player_entity_id = t_player_entity_id
end

----------------------------------------------------

function OrbCaveDeathPit.setup_trigger()
    -- Set up the trigger for the death pit sequence.
    m_trigger_entity_id = world_get_entity_by_name(DEATH_TRIGGER_NAME)
    if not entity_get_is_valid(m_trigger_entity_id) then
        print_warning("[OrbCaveDeathPit] trigger_death_pit was not found.")
        m_trigger_entity_id = 0
        return
    end

    -- Ensure the trigger entity is valid before enabling callbacks.
    -- @NOTE: Can be done in the editor too obviously. This is mostly an example case. 
    physics_body_set_trigger_callbacks_enabled(m_trigger_entity_id, true)
end

----------------------------------------------------

function OrbCaveDeathPit.get_is_sequence_active()
    return m_sequence_is_active
end

----------------------------------------------------

function OrbCaveDeathPit.on_overlap(t_trigger_entity_id, t_enter)
    if not t_enter then
        return false
    end

    if not entity_get_is_valid(m_trigger_entity_id) then
        return false
    end

    if t_trigger_entity_id ~= m_trigger_entity_id then
        return false
    end

    if m_sequence_is_active then
        return
    end

    -- Begin the death pit sequence.
    m_sequence_is_active = true
    m_phase = DEATH_PHASE_FADE_TO_BLACK
    m_timer = 0.0
    m_message_alpha = 0.0

    -- Lock player controls and capture the mouse.
    if entity_get_is_valid(m_player_entity_id) then
        world_call_entity_script_function(m_player_entity_id, "set_controls_locked", true)
    end
    if get_game_mode_active() then
        input_set_mouse_capture(true)
    end

    -- Fade & stiop any ongoing music.
    music_stop(DEATH_FADE_TO_BLACK_DURATION)

    -- Initiate the screen fade effect.
    module_call_function(
        CAMERA_EFFECTS_MODULE_NAME,
        "start_screen_fade",
        1.0,
        vec3(0.0, 0.0, 0.0),
        DEATH_FADE_TO_BLACK_DURATION,
        -1.0,
        0.0)
    m_screen_fade_is_active = true
    return true
end

----------------------------------------------------

function OrbCaveDeathPit.process(t_delta_time)
    if not m_sequence_is_active then
        return
    end

    -- Sequence timer. 
    m_timer = m_timer + t_delta_time

    -- Fade out to black.
    if m_phase == DEATH_PHASE_FADE_TO_BLACK then
        local fade_progress = m_timer / DEATH_FADE_TO_BLACK_DURATION
        if fade_progress > 1.0 then
            fade_progress = 1.0
        end

        -- Fade sound volume based on the progress of the fade to black.
        Utilities.sound_set_all_category_mix_multiplier(1.0 - fade_progress)

        -- Transition to the message phase if the fade to black is complete.
        if fade_progress >= 1.0 then
            m_phase = DEATH_PHASE_MESSAGE
            m_timer = 0.0
            m_message_alpha = 0.0
        end

        -- Do not proceed if the fade to black is still in progress.
        return
    end

    -- Display the death message.
    if m_phase == DEATH_PHASE_MESSAGE then
        local message_total_seconds = DEATH_MESSAGE_FADE_IN_DURATION
                                    + DEATH_MESSAGE_HOLD_DURATION
                                    + DEATH_MESSAGE_FADE_OUT_DURATION
        
        -- Handle state transitions for death message.
        local message_time = m_timer
        if message_time < DEATH_MESSAGE_FADE_IN_DURATION then
            m_message_alpha = message_time / DEATH_MESSAGE_FADE_IN_DURATION
        elseif message_time < DEATH_MESSAGE_FADE_IN_DURATION + DEATH_MESSAGE_HOLD_DURATION then
            m_message_alpha = 1.0
        elseif message_time < message_total_seconds then
            local fade_out_time = message_time - DEATH_MESSAGE_FADE_IN_DURATION - DEATH_MESSAGE_HOLD_DURATION
            m_message_alpha = 1.0 - (fade_out_time / DEATH_MESSAGE_FADE_OUT_DURATION)
        else
            m_message_alpha = 0.0
            load_main_menu_after_death_pit()
        end

        -- Clamp the message alpha to the range [0.0, 1.0].
        m_message_alpha = math_clamp(m_message_alpha, 0.0, 1.0)
    end
end

----------------------------------------------------

function OrbCaveDeathPit.draw()
    -- Skip if alpha is zero or the sequence is not active.
    if not m_sequence_is_active or m_message_alpha <= 0.0 then
        return
    end

    gui_push_draw_priority(DEATH_DRAW_UI_LAYER_PRIORITY) -- Keep it above other UI elements.
    gui_push_foreground_draw() -- Ensure the death message is drawn in the foreground.

    -- Set up the canvas for drawing the death message.
    local canvas_flags = GuiWindowFlags.NO_MOVE + GuiWindowFlags.NO_INPUTS + GuiWindowFlags.NO_FOCUS_ON_APPEARING
    if gui_begin_screen_canvas("death_pit_message", canvas_flags) then
        -- Draw the death message.
        local layout_size = gui_get_layout_size()
        local font_size = gui_get_normalized_to_pixels(DEATH_MESSAGE_FONT_SIZE)
        local text_color = vec4(Colors.WHITE.x, Colors.WHITE.y, Colors.WHITE.z, m_message_alpha)
        gui_draw_text_aligned(
            DEATH_MESSAGE_TEXT,
            vec2(0.0, 0.0),
            layout_size,
            GuiAlignH.CENTER,
            GuiAlignV.MIDDLE,
            font_size,
            text_color,
            "")
        gui_end_screen_canvas()
    end

    -- End of the death message drawing section.
    gui_pop_foreground_draw()
    gui_pop_draw_priority()
end

----------------------------------------------------

function OrbCaveDeathPit.on_shutdown()
    -- Skip if not fading or module is missing. 
    if not m_screen_fade_is_active or not module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME) then
        return
    end

    -- Stop the screen fade effec.
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
    m_screen_fade_is_active = false
end

----------------------------------------------------

return OrbCaveDeathPit
