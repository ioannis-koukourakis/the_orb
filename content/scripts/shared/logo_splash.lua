-- @NOTE: Plays a list of logo images on black, in order. Caller feeds the paths.

local LogoSplash = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local Colors = dofile("../content/scripts/shared/colors.lua")

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local LOGO_SPLASH_FADE_IN_DURATION = 1.2
local LOGO_SPLASH_HOLD_DURATION = 2.0
local LOGO_SPLASH_FADE_OUT_DURATION = 0.8
local LOGO_SPLASH_LOGO_HEIGHT = 0.62
local LOGO_SPLASH_DRAW_PRIORITY = 15 -- GameGUI draw priority channels are 0..63. 

local LOGO_SPLASH_STATE_INACTIVE = 0
local LOGO_SPLASH_STATE_FADE_IN = 1
local LOGO_SPLASH_STATE_HOLD = 2
local LOGO_SPLASH_STATE_FADE_OUT = 3

local m_logo_paths = {}
local m_logo_count = 0
local m_logo_index = 0
local m_state = LOGO_SPLASH_STATE_INACTIVE
local m_alpha = 0.0
local m_hold_time = 0.0

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function LogoSplash.set_logo_paths(t_paths)
    if type(t_paths) ~= "table" then
        print_error("[LogoSplash] set_logo_paths requires a list of image paths.")
        return
    end

    m_logo_paths = t_paths
    m_logo_count = #t_paths
end

----------------------------------------------------

function LogoSplash.set_active(t_active)
    -- Deactivate the logo splash sequence.
    if t_active ~= true then
        local was_active = m_state ~= LOGO_SPLASH_STATE_INACTIVE
        m_state = LOGO_SPLASH_STATE_INACTIVE
        m_logo_index = 0
        m_alpha = 0.0
        m_hold_time = 0.0
        if was_active and get_game_mode_active() then
            input_set_mouse_capture(false)
        end
        return
    end

    -- Check if there are any logos to display.
    if m_logo_count < 1 then
        print_error("[LogoSplash] set_active requires at least one logo path.")
        m_state = LOGO_SPLASH_STATE_INACTIVE
        m_logo_index = 0
        return
    end

    -- Initialize the first logo in the sequence.
    m_logo_index = 1
    m_alpha = 0.0
    m_hold_time = 0.0
    m_state = LOGO_SPLASH_STATE_FADE_IN
    if get_game_mode_active() then
        input_set_mouse_capture(true)
    end
end

----------------------------------------------------

function LogoSplash.get_is_active()
    return m_state ~= LOGO_SPLASH_STATE_INACTIVE
end

----------------------------------------------------

function LogoSplash.process(t_delta_time)
    if m_state == LOGO_SPLASH_STATE_INACTIVE then
        return
    end

    -- Check for user input to skip the current logo.
    if m_state == LOGO_SPLASH_STATE_FADE_IN or m_state == LOGO_SPLASH_STATE_HOLD then
        local skip_pressed = false
        local key_name = input_get_just_pressed_key_name()
        if key_name ~= "" then
            skip_pressed = true
        end
        if not skip_pressed and input_get_mouse_action_pressed_event("select") then
            skip_pressed = true
        end
        if not skip_pressed and input_get_action_pressed_event("jump") then
            skip_pressed = true
        end
        if not skip_pressed and input_get_action_pressed_event("interact") then
            skip_pressed = true
        end
        -- skip currently displayed logo if any input is detected
        if skip_pressed then
            m_state = LOGO_SPLASH_STATE_FADE_OUT
        end
    end

    -- Fade in 
    if m_state == LOGO_SPLASH_STATE_FADE_IN then
        m_alpha = m_alpha + (t_delta_time / LOGO_SPLASH_FADE_IN_DURATION)
        if m_alpha >= 1.0 then
            m_alpha = 1.0
            m_hold_time = 0.0
            m_state = LOGO_SPLASH_STATE_HOLD
        end
        return
    end

    -- Hold
    if m_state == LOGO_SPLASH_STATE_HOLD then
        m_hold_time = m_hold_time + t_delta_time
        if m_hold_time >= LOGO_SPLASH_HOLD_DURATION then
            m_state = LOGO_SPLASH_STATE_FADE_OUT
        end
        return
    end

    -- Fade out
    if m_state == LOGO_SPLASH_STATE_FADE_OUT then
        m_alpha = m_alpha - (t_delta_time / LOGO_SPLASH_FADE_OUT_DURATION)
        if m_alpha > 0.0 then
            return
        end

        -- Move to the next logo in the sequence if available.
        if m_logo_index < m_logo_count then
            m_logo_index = m_logo_index + 1
            m_alpha = 0.0
            m_hold_time = 0.0
            m_state = LOGO_SPLASH_STATE_FADE_IN
            return
        end

        -- No more logos to display so deactivate the sequence.
        m_state = LOGO_SPLASH_STATE_INACTIVE
        m_logo_index = 0
        m_alpha = 0.0
        m_hold_time = 0.0
        if get_game_mode_active() then
            input_set_mouse_capture(false)
        end
    end
end

----------------------------------------------------

function LogoSplash.draw()
    if m_state == LOGO_SPLASH_STATE_INACTIVE then
        return
    end

    -- No logo to display at the current index.
    local logo_path = m_logo_paths[m_logo_index]
    if type(logo_path) ~= "string" or logo_path == "" then
        print_error("[LogoSplash] Logo path is missing at index " .. tostring(m_logo_index))
        return
    end

    -- Set proper canvas flags and draw priority for the logo splash.
    local canvas_flags = GuiWindowFlags.NO_MOVE + GuiWindowFlags.NO_INPUTS + GuiWindowFlags.NO_FOCUS_ON_APPEARING
    gui_push_draw_priority(LOGO_SPLASH_DRAW_PRIORITY)
    gui_push_foreground_draw()
    if not gui_begin_screen_canvas("logo_splash", canvas_flags) then
        gui_pop_foreground_draw()
        gui_pop_draw_priority()
        return
    end

    -- Draw the background.
    local layout_size = gui_get_layout_size()
    gui_draw_rect(vec2(0.0, 0.0), layout_size, Colors.BLACK)

    -- Draw the logo at the center of the screen.
    local logo_height = layout_size.y * LOGO_SPLASH_LOGO_HEIGHT
    local logo_size = vec2(logo_height, logo_height)
    local logo_pos = vec2((layout_size.x - logo_size.x) * 0.5, (layout_size.y - logo_size.y) * 0.5)
    gui_draw_image(logo_path, logo_pos, logo_size, Colors.get_with_alpha(Colors.WHITE, m_alpha))

    -- End the screen canvas for the logo splash.
    gui_end_screen_canvas()
    gui_pop_foreground_draw()
    gui_pop_draw_priority()
end

----------------------------------------------------

return LogoSplash
