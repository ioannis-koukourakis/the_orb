-- @NOTE: game_module exterior intro pending selects the path: WHITE_FADE_INTRO_NO_INTRO (cave door / direct load), WHITE_FADE_INTRO_NEW_GAME (main menu), WHITE_FADE_INTRO_LOOPBACK (cave orb ending).
-- @NOTE: Showcase hack for a couple of movable rocks. Snapshot on the cave door, restore on the way back. Not a save system.

local TheOrbArrivalWorld = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local Utilities = dofile("../content/scripts/shared/utilities.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")
local TheOrbWhiteFadeIntro = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_white_fade_intro.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local CAMERA_EFFECTS_MODULE_NAME = "CameraEffectsModule"
local GAME_MODULE_NAME = "game_module"

local WHITE_FADE_INTRO_NO_INTRO = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NO_INTRO
local WHITE_FADE_INTRO_NEW_GAME = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NEW_GAME
local WHITE_FADE_INTRO_LOOPBACK = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_LOOPBACK

local INTRO_WHITE_COLOR = vec3(1.0, 1.0, 1.0)
local INTRO_FADE_OUT_DURATION = 5.0
local INTRO_LOOPBACK_FADE_OUT_DURATION = 5.0
local INTRO_LOOPBACK_WHITE_THRESHOLD = 0.99 -- Threshold at which the loopback fade is considered fully white.
local INTRO_SOUND_CATEGORY_COUNT = 4 -- Number of sound categories used in the intro. @NOTE: Not the best way to do it, but works for now.
local INTRO_STORY_TEXT =
    "This is a tech demo, not a finished game.\n"
    .. "There is no ending to beat. Just immerse \n"
    .. "yourself in the world and enjoy the experience.\n"
local INTRO_CONTINUE_TEXT = "Press any key to continue."
local INTRO_STORY_FONT_SIZE = 0.042
local INTRO_CONTINUE_FONT_SIZE = 0.028
local INTRO_CONTINUE_BOTTOM_BAND_NORMALIZED = 0.12
local INTRO_DRAW_PRIORITY = 15

local INTRO_STATE_WAIT = 1
local INTRO_STATE_FADE_OUT = 2

local CAVE_LOADING_DOOR_ENTITY_NAME = "door_cave_entrance"
local MOVABLE_ENTITY_TAG = "movable"

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_camera_effects_module_valid = false
local m_intro_kind = WHITE_FADE_INTRO_NO_INTRO
local m_intro_state = 0
local m_intro_story_alpha = 0.0
local m_player_entity_id = 0
local m_intro_sound_fade_is_active = false
local m_pending_movable_layout_for_late_restore = nil

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function set_player_intro_input_locked(t_locked)
    if not entity_get_is_valid(m_player_entity_id) then
        return
    end

    world_call_entity_script_function(m_player_entity_id, "set_controls_locked", t_locked)
    if get_game_mode_active() then
        input_set_mouse_capture(true)
    end
end

----------------------------------------------------

local function set_intro_sound_category_mix(t_multiplier)
    for category_index = 0, INTRO_SOUND_CATEGORY_COUNT - 1 do
        sound_set_category_mix_multiplier(category_index, t_multiplier)
    end
end

----------------------------------------------------

local function begin_intro_white_fade_out(t_fade_out_seconds)
    local fade_out_seconds = INTRO_FADE_OUT_DURATION
    if type(t_fade_out_seconds) == "number" and t_fade_out_seconds > 0.0 then
        fade_out_seconds = t_fade_out_seconds
    end

    module_call_function(
        CAMERA_EFFECTS_MODULE_NAME,
        "start_screen_fade",
        1.0,
        INTRO_WHITE_COLOR,
        0.0,
        0.0,
        fade_out_seconds)
end

----------------------------------------------------

local function finish_intro()
    m_intro_kind = WHITE_FADE_INTRO_NO_INTRO
    m_intro_state = 0
    m_intro_story_alpha = 0.0
    m_intro_sound_fade_is_active = false
    set_intro_sound_category_mix(1.0)
    set_player_intro_input_locked(false)
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
end

----------------------------------------------------

local function begin_intro_white_fade_out_from_continue(t_fade_out_seconds)
    m_intro_story_alpha = 0.0
    begin_intro_white_fade_out(t_fade_out_seconds)
    m_intro_state = INTRO_STATE_FADE_OUT
end

----------------------------------------------------

local function ensure_intro_white_at_full_intensity()
    -- Check the current screen fade intensity before starting a new fade.
    local fade_intensity = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "get_screen_fade")
    if type(fade_intensity) ~= "number" then
        fade_intensity = 0.0
    end

    if fade_intensity >= INTRO_LOOPBACK_WHITE_THRESHOLD then
        return
    end

    module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                        "start_screen_fade",
                        1.0,
                        INTRO_WHITE_COLOR,
                        0.0,
                        -1.0, -- no fade out.
                        0.0)

    -- Start the screen fade to white at full intensity.
    module_call_function(CAMERA_EFFECTS_MODULE_NAME, "set_screen_fade_intensity", 1.0)
end

----------------------------------------------------

local function apply_orb_arrival_movable_layout_from_cave_door(t_layout)
    if t_layout == nil then
        return
    end

    -- Iterate over all saved entity transforms and apply them to the corresponding entities in the world.
    for entity_name, saved_transform in pairs(t_layout) do
        local entity_id = world_get_entity_by_name(entity_name)
        if entity_get_is_valid(entity_id) then
            if saved_transform.position ~= nil then
                transform_set_world_position(entity_id, saved_transform.position)
            end
            if saved_transform.rotation_quat ~= nil then
                transform_set_world_rotation_quat(entity_id, saved_transform.rotation_quat)
            end
            if entity_get_has_physics_component(entity_id) then
                physics_body_warp_to_transform(entity_id)
            end
        end
    end
end

----------------------------------------------------
-- CALLBACKS
----------------------------------------------------

function TheOrbArrivalWorld.on_interact(t_entity_id, t_is_pressed, _t_instigator_entity_id)
    -- @NOTE: Not a proper save method. 
    -- This is just a hack to maintain the movable layout of entities before transitioning through the cave door.

    -- Validate btn press and data. 
    if not t_is_pressed then
        return
    end
    if not entity_get_is_valid(t_entity_id) then
        return
    end
    if entity_get_name(t_entity_id) ~= CAVE_LOADING_DOOR_ENTITY_NAME then
        return
    end
    if not module_get_is_valid(GAME_MODULE_NAME) then
        return
    end

    -- Get all movable entities in the world.
    local movable_entity_ids = world_get_entities_by_tag(MOVABLE_ENTITY_TAG)
    if movable_entity_ids == nil then
        return
    end

    -- Store the current transforms of all movable entities.
    local layout = {}
    for entity_index = 1, #movable_entity_ids do
        local movable_entity_id = movable_entity_ids[entity_index]
        if entity_get_is_valid(movable_entity_id) then
            local entity_name = entity_get_name(movable_entity_id)
            if entity_name == "" then
                print_error("[TheOrbArrivalWorld] Movable entity is missing a name. Tag: " .. MOVABLE_ENTITY_TAG)
            else
                layout[entity_name] = {
                    position = transform_get_world_position(movable_entity_id),
                    rotation_quat = transform_get_world_rotation_quat(movable_entity_id),
                }
            end
        end
    end

    -- Send the stored layout to the game module for the cave door.
    module_call_function(GAME_MODULE_NAME, "set_orb_arrival_movable_layout_for_cave_door", layout)
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function TheOrbArrivalWorld.on_ready()
    -- Check if the CameraEffects module is valid.
    m_camera_effects_module_valid = module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME)
    if not m_camera_effects_module_valid then
        print_error("[TheOrbArrivalWorld] CameraEffects module is not valid.")
        return
    end

    -- Get the player entity ID.
    m_player_entity_id = world_get_entity_by_name("player")
    if not entity_get_is_valid(m_player_entity_id) then
        print_error("[TheOrbArrivalWorld] Player entity was not found.")
    end

    -- Initialize intro.
    m_intro_kind = WHITE_FADE_INTRO_NO_INTRO
    m_intro_story_alpha = 0.0

    -- Attempt to restore the movable layout for the cave door if available.
    if module_get_is_valid(GAME_MODULE_NAME) then
        local movable_layout = module_call_function(GAME_MODULE_NAME, "take_orb_arrival_movable_layout_for_cave_door")
        apply_orb_arrival_movable_layout_from_cave_door(movable_layout)
        if movable_layout ~= nil then
            m_pending_movable_layout_for_late_restore = movable_layout
        end
    end

    -- If the game module is not valid, stop the screen fade and return.
    if not module_get_is_valid(GAME_MODULE_NAME) then
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
        return
    end

    -- Check if there is an intro pending for the exterior.
    local intro_kind = module_call_function(GAME_MODULE_NAME, "take_exterior_intro_pending")
    if intro_kind ~= WHITE_FADE_INTRO_NEW_GAME and intro_kind ~= WHITE_FADE_INTRO_LOOPBACK then
        if intro_kind ~= WHITE_FADE_INTRO_NO_INTRO then
            print_error("[TheOrbArrivalWorld] Unknown exterior intro pending mode: " .. tostring(intro_kind))
        end
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
        return
    end

    -- Initialize the intro sequence.
    m_intro_kind = intro_kind
    m_intro_story_alpha = 0.0
    set_player_intro_input_locked(true)

    -- Begin the white fade out sequence.
    if m_intro_kind == WHITE_FADE_INTRO_LOOPBACK then
        m_intro_sound_fade_is_active = true
        set_intro_sound_category_mix(0.0)
        ensure_intro_white_at_full_intensity()

        -- Begin the white fade-out sequence from the continue point.
        begin_intro_white_fade_out_from_continue(INTRO_LOOPBACK_FADE_OUT_DURATION)
        return
    end

    -- Begin the white fade-in phase of the intro.
    module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                        "start_screen_fade",
                        1.0,
                        INTRO_WHITE_COLOR,
                        0.0,
                        -1.0, -- no fade out.
                        INTRO_FADE_OUT_DURATION)

    -- Begin the wait phase of the intro for a new game.
    m_intro_state = INTRO_STATE_WAIT
    m_intro_story_alpha = 1.0
end

----------------------------------------------------

function TheOrbArrivalWorld.on_late_process(_t_delta_time)
    if m_pending_movable_layout_for_late_restore == nil then
        return
    end

    -- Apply pending movable entities layout. 
    -- This is used to restore the dynamic bodies position as they were left by the player before leaving this map. 
    apply_orb_arrival_movable_layout_from_cave_door(m_pending_movable_layout_for_late_restore)
    m_pending_movable_layout_for_late_restore = nil -- Clear the pending layout after applying it.
end

----------------------------------------------------

function TheOrbArrivalWorld.on_process(_t_delta_time)
    if m_intro_kind == WHITE_FADE_INTRO_NO_INTRO or not m_camera_effects_module_valid then
        return
    end

    -- Handle intro state. 
    if m_intro_state == INTRO_STATE_WAIT then
        local continue_pressed = false

        -- Check for input to continue the intro.
        local key_name = input_get_just_pressed_key_name()
        if key_name ~= "" and key_name ~= "Escape" then
            continue_pressed = true
        end

        if not continue_pressed and input_get_mouse_action_pressed_event("select") then
            continue_pressed = true
        end

        if not continue_pressed and input_get_action_pressed_event("jump") then
            continue_pressed = true
        end

        if not continue_pressed and input_get_action_pressed_event("interact") then
            continue_pressed = true
        end

        if not continue_pressed then
            return
        end

        -- Begin the fade out sequence for the intro.
        begin_intro_white_fade_out_from_continue()
        return
    end

    -- Use the camera effects module to get the current screen fade intensity and use it to adjust the intro sound mix.
    if m_intro_state == INTRO_STATE_FADE_OUT then
        local fade_intensity = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "get_screen_fade")
        if m_intro_sound_fade_is_active then
            local sound_mix_multiplier = 1.0 - fade_intensity
            Utilities.sound_set_all_category_mix_multiplier(sound_mix_multiplier)
        end
        if fade_intensity <= 0.0 then
            finish_intro()
        end
    end
end

----------------------------------------------------

function TheOrbArrivalWorld.on_draw(_t_delta_time)
    if m_intro_kind == WHITE_FADE_INTRO_NO_INTRO or m_intro_state ~= INTRO_STATE_WAIT then
        return
    end

    if m_intro_story_alpha <= 0.0 then
        return
    end

    -- Begin text canvas.
    local canvas_flags = GuiWindowFlags.NO_MOVE + GuiWindowFlags.NO_INPUTS + GuiWindowFlags.NO_FOCUS_ON_APPEARING
    gui_push_draw_priority(INTRO_DRAW_PRIORITY)
    gui_push_foreground_draw()
    if not gui_begin_screen_canvas("exterior_intro_text", canvas_flags) then
        gui_pop_foreground_draw()
        gui_pop_draw_priority()
        return
    end

    -- Draw the intro text centered on the screen.
    local layout_size = gui_get_layout_size()
    local story_font_size = gui_get_normalized_to_pixels(INTRO_STORY_FONT_SIZE)
    local story_color = Colors.get_with_alpha(Colors.BLACK, m_intro_story_alpha)
    gui_draw_text_aligned(INTRO_STORY_TEXT,
                            vec2(0.0, 0.0),
                            layout_size,
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            story_font_size,
                            story_color,
                            "")

    -- Draw the continue prompt at the bottom of the screen.
    local continue_band_height = gui_get_normalized_to_pixels(INTRO_CONTINUE_BOTTOM_BAND_NORMALIZED)
    local continue_pos = vec2(0.0, layout_size.y - continue_band_height)
    local continue_size = vec2(layout_size.x, continue_band_height)
    local continue_font_size = gui_get_normalized_to_pixels(INTRO_CONTINUE_FONT_SIZE)
    local continue_color = Colors.BLACK
    gui_draw_text_aligned(INTRO_CONTINUE_TEXT,
                            continue_pos,
                            continue_size,
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            continue_font_size,
                            continue_color,
                            "")

    -- End intro text drawing
    gui_end_screen_canvas()
    gui_pop_foreground_draw()
    gui_pop_draw_priority()
end

----------------------------------------------------

function TheOrbArrivalWorld.on_shutdown()
    if m_intro_kind ~= WHITE_FADE_INTRO_NO_INTRO then
        finish_intro()
        return
    end

    -- Reset intro state and related variables.
    set_intro_sound_category_mix(1.0)
    set_player_intro_input_locked(false)
    if m_camera_effects_module_valid then
        module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
    end
end

----------------------------------------------------

return TheOrbArrivalWorld
