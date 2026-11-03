-- @NOTE: Shared main menu and pause menu. Pause mode hides Start and shows Continue plus return to the main menu.

local MainMenuModule = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local UiWidgets = dofile("../content/scripts/shared/ui_widgets.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")
local UiSkin = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_main_menu/main_menu_skin.lua")
local TheOrbWorldPaths = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_world_paths.lua")
local MotionBlurEffect = dofile("../content/scripts/camera_effects/motion_blur_effect.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local REFERENCE_RESOLUTION = { width = 1920, height = 1080 }
local CONTROLS_SHORTCUT_ROW_GAP = 6.0

-- Page identifiers.
local PAGE_MAIN = 1
local PAGE_OPTIONS = 2
local PAGE_CONTROLS = 3
local PAGE_CREDITS = 4

-- Credits configuration.
local CREDITS_INI_PATH = "../content/config/game_credits.ini"

local CREDITS_ENTRY_SPACING = 16.0
local CREDITS_SECTION_SPACING = 16.0

-- World paths.
local THE_ORB_ARRIVAL_WORLD_PATH = TheOrbWorldPaths.ARRIVAL_WORLD_PATH
local THE_ORB_MAIN_MENU_WORLD_PATH = TheOrbWorldPaths.MAIN_MENU_WORLD_PATH

-- Module names.
local GAME_MODULE_NAME = "game_module"
local CAMERA_EFFECTS_MODULE_NAME = "CameraEffectsModule"

-- Graphics options.
local WINDOW_MODE_OPTIONS = { "Windowed", "Fullscreen", "Borderless" }
-- Classic vsync is left out fr the demo as it waits a whole refresh when a frame is late, 
-- so 60 drops to 30 and makes the game feel slow. 
local VSYNC_MENU_OPTIONS = { "Disabled", "Adaptive" }
local VSYNC_MENU_MODES = { VSyncMode.OFF, VSyncMode.ADAPTIVE }
local ANISOTROPIC_OPTIONS = { "Off", "2x", "4x", "8x", "16x" }
local SSGI_QUALITY_OPTIONS = { "Off", "Low", "High" }
local SHADOW_QUALITY_OPTIONS = { "Off", "Low", "Medium", "High" }
local SHADOW_QUALITY_MENU_MAX = 3
local GTAO_QUALITY_OPTIONS = { "Off", "Low", "Medium", "High" }
local ANTI_ALIASING_OPTIONS = { "None", "FXAA", "TAA" }
-- Off, Low, High. Low is the old medium trace. Saved High stays enum value 3.
local SSR_OPTIONS = { "Off", "Low", "High" }
local SSR_MENU_HIGH_OPTION = 2
local RENDER_SCALE_PERCENTS = { 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200 }
local RENDER_SCALE_WARNING_PERCENT = 100
local WINDOW_MODE_WINDOWED = 0

-- UI settings.
local UI_SETTINGS_SECTION = "UI"
local FPS_OVERLAY_SETTINGS_KEY = "fps_overlay_active"

-- Gameplay settings.
local GAMEPLAY_SETTINGS_SECTION = "Gameplay"
local MOUSE_LOOK_SENSITIVITY_KEY = "mouse_look_sensitivity"
local DEFAULT_MOUSE_LOOK_SENSITIVITY = 0.002
local MOUSE_LOOK_SENSITIVITY_MIN = 0.0005
local MOUSE_LOOK_SENSITIVITY_MAX = 0.006
local GAMEPAD_LOOK_SENSITIVITY_KEY = "gamepad_look_sensitivity"
local DEFAULT_GAMEPAD_LOOK_SENSITIVITY = 4.0
local GAMEPAD_LOOK_SENSITIVITY_MIN = 0.5
local GAMEPAD_LOOK_SENSITIVITY_MAX = 10.0

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_page = PAGE_MAIN
local m_focus_seeded = false
local m_widgets_ready = false
local m_menu_open = false
local m_pause_menu_active = false
local m_title_menu_screen_active = false
local m_boot_splash_active = false
local m_monitors = {}
local m_resolutions = {}

-- Button
local m_button_start = nil
local m_button_continue = nil
local m_button_return_to_main_menu = nil
local m_button_options = nil
local m_button_brightness = nil
local m_button_controls = nil
local m_button_quit = nil
local m_button_credits = nil
local m_button_back = nil

-- Checkbox
local m_checkbox_fps_overlay = nil
local m_checkbox_motion_blur = nil
local m_checkbox_contact_shadows = nil

-- Slider
local m_slider_master_volume = nil
local m_slider_mouse_look_sensitivity = nil
local m_slider_gamepad_look_sensitivity = nil

-- Combo boxes
local m_combo_window_mode = nil
local m_combo_vsync = nil
local m_combo_monitor = nil
local m_combo_resolution = nil
local m_combo_render_scale = nil
local m_combo_anti_aliasing = nil
local m_combo_anisotropic = nil
local m_combo_shadows = nil
local m_combo_ssao = nil
local m_combo_ssgi = nil
local m_combo_ssr = nil

local m_vsync_enabled_brought_down = false

-- Modal 
local m_modal_shadow_restart = nil
local m_button_shadow_restart_ok = nil
local m_modal_reset_defaults = nil
local m_button_reset_defaults_confirm = nil
local m_button_reset_defaults_cancel = nil
local m_button_reset_defaults = nil

-- Community footer buttons.
local m_community_buttons = {}

-- Credits section.
local m_credits_title = ""
local m_credits_subtitle = ""
local m_credits_layers = {}

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function MainMenuModule.set_pause_menu_active(t_active)
    if m_pause_menu_active == t_active then
        return
    end

    -- Update the pause menu state.
    m_pause_menu_active = t_active
    m_page = PAGE_MAIN
    m_focus_seeded = false
end

----------------------------------------------------

function MainMenuModule.get_pause_menu_active()
    return m_pause_menu_active
end

----------------------------------------------------

function MainMenuModule.set_title_menu_screen_active(t_active)
    m_title_menu_screen_active = t_active == true
end

----------------------------------------------------

function MainMenuModule.set_boot_splash_active(t_active)
    m_boot_splash_active = t_active == true
end

----------------------------------------------------

function MainMenuModule.set_menu_open(t_open)
    -- skip if no change needed.
    if m_menu_open == t_open then
        return
    end

    -- Update the menu open state.
    m_menu_open = t_open
    if not m_menu_open then
        if not m_pause_menu_active then
            input_set_mouse_capture(true)
        end
        return
    end

    -- Ref res. 
    gui_set_reference_resolution(REFERENCE_RESOLUTION.width, REFERENCE_RESOLUTION.height)

    -- Match height fills the window top to bottom. 
    -- Layout width grows on ultrawide so the left strip stays fixed while the right stays open for the world.
    gui_set_scale_mode(GuiScaleMode.MATCH_HEIGHT)

    input_set_mouse_capture(false)
    m_page = PAGE_MAIN
    m_focus_seeded = false
end

----------------------------------------------------

function MainMenuModule.get_menu_open()
    return m_menu_open
end

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function set_page(t_page)
    m_page = t_page
    m_focus_seeded = false
end

----------------------------------------------------

local function draw_credits_wrapped_field(t_text, t_color, t_font_size, t_font_id)
    local display_text = ""

    -- iterate through the text.
    local lines = {}
    local part_start = 1
    local text_length = #t_text
    for char_index = 1, text_length + 1 do
        -- Check if we've reached the end of the text or encountered a pipe character, indicating a new line.
        if char_index > text_length or string.sub(t_text, char_index, char_index) == "|" then
            -- Extract the current line and trim any leading or trailing whitespace.
            local line = file_manager_get_trimmed_string(string.sub(t_text, part_start, char_index - 1))
            part_start = char_index + 1
            if line ~= "" then
                lines[#lines + 1] = line
            end
        end
    end
    
    display_text = table.concat(lines, "\n")

    if display_text == "" then
        return
    end

    -- Draw with gui_draw_text so the float size matches the rest of the menu.
    -- Spaces wrap to the scroll width. Pipe characters are newlines.
    local wrap_width = UiSkin.SCROLL_CONTENT_WIDTH
    local paragraph_start = 1
    local text_length = #display_text
    for char_index = 1, text_length + 1 do
        if char_index > text_length or string.sub(display_text, char_index, char_index) == "\n" then
            local paragraph = string.sub(display_text, paragraph_start, char_index - 1)
            paragraph_start = char_index + 1
            local line = ""
            local word_start = 1
            local paragraph_length = #paragraph
            for word_index = 1, paragraph_length + 1 do
                if word_index > paragraph_length or string.sub(paragraph, word_index, word_index) == " " then
                    local word = string.sub(paragraph, word_start, word_index - 1)
                    word_start = word_index + 1
                    if word ~= "" then
                        local candidate = word
                        if line ~= "" then
                            candidate = line .. " " .. word
                        end
                        local candidate_width = gui_get_text_size(candidate, t_font_size, t_font_id).x
                        if line ~= "" and candidate_width > wrap_width then
                            local line_height = gui_get_text_size(line, t_font_size, t_font_id).y
                            gui_dummy(vec2(wrap_width, line_height))
                            gui_draw_text(line, gui_get_item_rect_min(), t_font_size, t_color, t_font_id)
                            line = word
                        else
                            line = candidate
                        end
                    end
                end
            end

            -- Draw the last line of the paragraph if it exists.
            if line ~= "" then
                local line_height = gui_get_text_size(line, t_font_size, t_font_id).y
                gui_dummy(vec2(wrap_width, line_height))
                gui_draw_text(line, gui_get_item_rect_min(), t_font_size, t_color, t_font_id)
            end
        end
    end

    -- Add some spacing after the credits field.
    gui_dummy(vec2(wrap_width, 4.0))
end

----------------------------------------------------

local function close_pause_menu()
    game_set_paused(false)
    m_menu_open = false
    input_set_mouse_capture(true)
end

----------------------------------------------------

local function new_menu_button(t_id, t_label)
    return UiWidgets.new_button({
        id = t_id,
        width = UiSkin.MENU_BUTTON_WIDTH,
        height = UiSkin.BUTTON_HEIGHT,
        label = t_label,
        font_size = UiSkin.MENU_BUTTON_FONT_SIZE,
        font_id = UiSkin.MENU_LABEL_FONT_ID,
        text_color = UiSkin.BUTTON_TEXT_COLOR,
        idle = UiSkin.STYLE_BUTTON_IDLE,
        hover = UiSkin.STYLE_BUTTON_HOVER,
        pressed = UiSkin.STYLE_BUTTON_PRESSED,
        focused = UiSkin.STYLE_BUTTON_FOCUSED,
    })
end

----------------------------------------------------

local function new_menu_footer_button(t_id, t_label, t_width)
    return UiWidgets.new_button({
        id = t_id,
        width = t_width,
        height = UiSkin.MENU_FOOTER_BUTTON_HEIGHT,
        label = t_label,
        font_size = UiSkin.MENU_FOOTER_BUTTON_FONT_SIZE,
        font_id = UiSkin.MENU_LABEL_FONT_ID,
        text_color = UiSkin.BUTTON_TEXT_COLOR,
        idle = UiSkin.STYLE_BUTTON_IDLE,
        hover = UiSkin.STYLE_BUTTON_HOVER,
        pressed = UiSkin.STYLE_BUTTON_PRESSED,
        focused = UiSkin.STYLE_BUTTON_FOCUSED,
    })
end

----------------------------------------------------

local function new_menu_combo(t_id, t_options)
    return UiWidgets.new_combo({
        id = t_id,
        options = t_options,
        selected = 1,
        width = UiSkin.COMPO_WIDTH,
        height = UiSkin.ROW_HEIGHT,
        font_size = UiSkin.MENU_ROW_FONT_SIZE,
        font_id = UiSkin.MENU_ROW_LABEL_FONT_ID,
        text_color = UiSkin.COLOR_CREAM,
        text_color_on_accent = UiSkin.COLOR_CREAM,
        idle = UiSkin.WIDGET_STYLE_IDLE,
        hover = UiSkin.WIDGET_STYLE_HOVER,
        pressed = UiSkin.WIDGET_STYLE_PRESSED,
        focused = UiSkin.WIDGET_STYLE_FOCUSED,
        popup = UiSkin.WIDGET_STYLE_IDLE,
        popup_hover = UiSkin.WIDGET_STYLE_HOVER,
    })
end

----------------------------------------------------

local function new_menu_slider(t_id, t_value, t_min_value, t_max_value)
    return UiWidgets.new_slider({
        id = t_id,
        width = UiSkin.SCROLL_CONTENT_WIDTH,
        value = t_value,
        min_value = t_min_value,
        max_value = t_max_value,
        track = UiSkin.WIDGET_STYLE_IDLE,
        fill = UiSkin.SLIDER_VALUE_STYLE,
        fill_active = UiSkin.STYLE_FILL,
        thumb_idle = UiSkin.SLIDER_STYLE_THUMB,
        thumb_hover = UiSkin.SLIDER_STYLE_THUMB_HOVER,
        thumb_pressed = UiSkin.SLIDER_STYLE_THUMB_HOVER,
        thumb_focused = UiSkin.SLIDER_STYLE_THUMB_HOVER,
    })
end

----------------------------------------------------

local function draw_labeled_combo(t_label, t_combo, t_selected_index, t_set_value)
    if not t_combo.open then -- Only adjust the selected index if the combo box is not open.
        local option_count = #t_combo.options
        local selected_index = t_selected_index
        if option_count < 1 then
            selected_index = 1
        elseif selected_index < 1 then
            selected_index = 1
        elseif selected_index > option_count then
            selected_index = option_count
        end
        t_combo.selected = selected_index
    end

    t_combo.apply_fn = t_set_value

    UiWidgets.label_row(t_label, UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
    UiWidgets.combo(t_combo)
    gui_dummy(vec2(1.0, 8.0))
end

----------------------------------------------------

local function apply_ssr_quality_setting(t_zero_based_index)
    -- The third menu row is High. Its saved value is not the row index.
    local quality = t_zero_based_index
    if t_zero_based_index >= SSR_MENU_HIGH_OPTION then
        quality = SSRQuality.HIGH
    end
    settings_set_ssr_quality(quality)
end

----------------------------------------------------

local function apply_shadow_map_quality_setting(t_zero_based_index)
    local previous_quality = settings_get_shadow_map_quality()
    if t_zero_based_index == previous_quality then
        return
    end
    settings_set_shadow_map_quality(t_zero_based_index)
    m_modal_shadow_restart.open = true
end

----------------------------------------------------

local function apply_monitor_combo_setting(t_zero_based_index)
    local monitor = m_monitors[t_zero_based_index + 1]
    if monitor then
        settings_set_monitor_index(monitor.index)
    end
end

----------------------------------------------------

local function apply_resolution_combo_setting(t_zero_based_index)
    local resolution = m_resolutions[t_zero_based_index + 1]
    if resolution then
        settings_set_resolution(resolution.width, resolution.height)
    end
end

----------------------------------------------------

local function apply_window_mode_setting(t_zero_based_index)
    settings_set_window_mode(t_zero_based_index)
end

----------------------------------------------------

local function apply_vsync_menu_setting(t_zero_based_index)
    local mode = VSYNC_MENU_MODES[t_zero_based_index + 1]
    if mode == settings_get_vsync_mode() then
        return
    end
    settings_set_vsync_mode(mode)
end

----------------------------------------------------

local function apply_render_scale_combo_setting(t_zero_based_index)
    settings_set_render_scale(RENDER_SCALE_PERCENTS[t_zero_based_index + 1] / 100.0)
end

----------------------------------------------------

local function get_mouse_look_sensitivity_setting()
    return settings_get_float(GAMEPLAY_SETTINGS_SECTION, MOUSE_LOOK_SENSITIVITY_KEY, DEFAULT_MOUSE_LOOK_SENSITIVITY)
end

----------------------------------------------------

local function set_mouse_look_sensitivity_setting(t_value)
    settings_set_float(GAMEPLAY_SETTINGS_SECTION, MOUSE_LOOK_SENSITIVITY_KEY, t_value)
end

----------------------------------------------------

local function get_gamepad_look_sensitivity_setting()
    return settings_get_float(GAMEPLAY_SETTINGS_SECTION, GAMEPAD_LOOK_SENSITIVITY_KEY, DEFAULT_GAMEPAD_LOOK_SENSITIVITY)
end

----------------------------------------------------

local function get_master_volume_percent()
    return settings_get_master_volume() * 100.0
end

----------------------------------------------------

local function set_master_volume_percent(t_value)
    settings_set_master_volume(t_value / 100.0)
end

----------------------------------------------------

local function set_gamepad_look_sensitivity_setting(t_value)
    settings_set_float(GAMEPLAY_SETTINGS_SECTION, GAMEPAD_LOOK_SENSITIVITY_KEY, t_value)
end

----------------------------------------------------

local function apply_settings_reset_to_defaults()
    local shadow_quality_before_reset = settings_get_shadow_map_quality()

    if not settings_reset_to_defaults() then
        return
    end

    MotionBlurEffect.set_enabled_from_saved_setting()
    m_monitors = {}
    m_resolutions = {}
    m_vsync_enabled_brought_down = false
    m_slider_master_volume.value = get_master_volume_percent()
    m_slider_mouse_look_sensitivity.value = get_mouse_look_sensitivity_setting()
    m_slider_gamepad_look_sensitivity.value = get_gamepad_look_sensitivity_setting()

    if settings_get_shadow_map_quality() ~= shadow_quality_before_reset then
        m_modal_shadow_restart.open = true
    end
end

----------------------------------------------------

local function draw_slider_row(t_format, t_slider, t_get_value, t_set_value)
    if not t_slider.held then
        t_slider.value = t_get_value()
    end

    UiWidgets.label(string.format(t_format, t_slider.value), UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_CREAM, UiSkin.MENU_ROW_LABEL_FONT_ID)
    
    gui_dummy(vec2(1.0, 4.0))

    if UiWidgets.slider(t_slider) then
        t_set_value(t_slider.value)
    end

    gui_dummy(vec2(1.0, 12.0))
end

----------------------------------------------------

local function refresh_monitor_combo()
    if m_combo_monitor.open then
        return
    end

    -- Refresh the list of available monitors and update the combo box accordingly.
    m_monitors = settings_get_available_monitors()
    local labels = {}
    local selected_index = 1
    local current_index = settings_get_monitor_index()
    for i = 1, #m_monitors do
        local monitor = m_monitors[i]
        labels[i] = string.format("%s  %dx%d", monitor.name, monitor.width, monitor.height)
        if monitor.index == current_index then
            selected_index = i
        end
    end
    m_combo_monitor.options = labels
    m_combo_monitor.selected = selected_index
end

----------------------------------------------------

local function refresh_resolution_combo()
    if m_combo_resolution.open then
        return
    end

    m_resolutions = settings_get_available_resolutions()
    local labels = {}
    local selected_index = 1
    local current = settings_get_resolution()
    for i = 1, #m_resolutions do
        local resolution = m_resolutions[i]
        labels[i] = string.format("%d x %d", resolution.width, resolution.height)
        if resolution.width == current.width and resolution.height == current.height then
            selected_index = i
        end
    end
    m_combo_resolution.options = labels
    m_combo_resolution.selected = selected_index
end

----------------------------------------------------

local function get_action_prompt_display_string(t_action_name)
    local binding = input_get_action_prompt_display_string(t_action_name)
    if type(binding) ~= "string" or binding == "" then
        return "?"
    end
    return binding
end

----------------------------------------------------

local function get_look_prompt_display_string()
    if input_get_is_last_input_device_gamepad() and input_get_has_gamepad_connected() then
        return "Right stick"
    end
    return "Mouse"
end

----------------------------------------------------

local function get_move_prompt_display_string()
    if input_get_is_last_input_device_gamepad() and input_get_has_gamepad_connected() then
        return "Left stick"
    end

    local forward_key = input_get_action_binding_string("move_forward")
    local left_key = input_get_action_binding_string("move_left")
    local backward_key = input_get_action_binding_string("move_backward")
    local right_key = input_get_action_binding_string("move_right")
    if type(forward_key) ~= "string" or forward_key == "" then
        forward_key = "?"
    end
    if type(left_key) ~= "string" or left_key == "" then
        left_key = "?"
    end
    if type(backward_key) ~= "string" or backward_key == "" then
        backward_key = "?"
    end
    if type(right_key) ~= "string" or right_key == "" then
        right_key = "?"
    end
    return input_get_binding_display_string(forward_key)
        .. " "
        .. input_get_binding_display_string(left_key)
        .. " "
        .. input_get_binding_display_string(backward_key)
        .. " "
        .. input_get_binding_display_string(right_key)
end

----------------------------------------------------

local function draw_controls_shortcut_row(t_label, t_binding_text)
    local row_height = UiSkin.ROW_HEIGHT * 0.5
    local font_id = UiSkin.MENU_ROW_LABEL_FONT_ID
    local binding_width = UiSkin.SCROLL_CONTENT_WIDTH - UiSkin.LABEL_WIDTH - UiSkin.LABEL_ROW_GAP
    local text_y_offset = (row_height - UiSkin.MENU_CONTROLS_SHORTCUT_FONT_SIZE) * 0.5

    gui_dummy(vec2(UiSkin.LABEL_WIDTH, row_height))
    local row_rect_min = gui_get_item_rect_min()
    gui_draw_text(
        t_label,
        vec2(row_rect_min.x, row_rect_min.y + text_y_offset),
        UiSkin.MENU_CONTROLS_SHORTCUT_FONT_SIZE,
        UiSkin.COLOR_MUTED,
        font_id)
    gui_same_line(0.0, UiSkin.LABEL_ROW_GAP)

    gui_dummy(vec2(binding_width, row_height))
    local binding_rect_min = gui_get_item_rect_min()
    gui_draw_text(
        t_binding_text,
        vec2(binding_rect_min.x, binding_rect_min.y + text_y_offset),
        UiSkin.MENU_CONTROLS_SHORTCUT_FONT_SIZE,
        UiSkin.COLOR_CREAM,
        font_id)
    gui_dummy(vec2(1.0, CONTROLS_SHORTCUT_ROW_GAP))
end

----------------------------------------------------

local function draw_controls_page()
    UiWidgets.label("Controls", UiSkin.MENU_CONTROLS_HEADER_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_LABEL_FONT_ID)
    gui_dummy(vec2(1.0, 5.0))

    draw_controls_shortcut_row("Move", get_move_prompt_display_string())
    draw_controls_shortcut_row("Look", get_look_prompt_display_string())
    draw_controls_shortcut_row("Jump", get_action_prompt_display_string("jump"))
    draw_controls_shortcut_row("Crouch", get_action_prompt_display_string("crouch"))
    local sprint_prompt = get_action_prompt_display_string("sprint")
    if input_get_is_last_input_device_gamepad() then
        sprint_prompt = get_action_prompt_display_string("sprint_toggle")
    end
    draw_controls_shortcut_row("Sprint", sprint_prompt)
    draw_controls_shortcut_row("Interact", get_action_prompt_display_string("interact"))
    draw_controls_shortcut_row("Focus", get_action_prompt_display_string("aim"))
    draw_controls_shortcut_row("Focus Alt", get_action_prompt_display_string("select"))
    draw_controls_shortcut_row("Pause", get_action_prompt_display_string("game_pause"))
end

----------------------------------------------------

local function draw_menu_button(t_button)
    local indent = (UiSkin.CONTENT_WIDTH - t_button.width) * 0.5
    if indent > 0.0 then
        gui_dummy(vec2(indent, t_button.height))
        gui_same_line(0.0, 0.0)
    end
    return UiWidgets.button(t_button)
end

----------------------------------------------------

local function draw_community_buttons()
    -- Iterrate the community buttons table and draw them.
    local link_count = #m_community_buttons
    for link_index = 1, link_count do
        if link_index > 1 then
            gui_same_line(0.0, UiSkin.MENU_FOOTER_BUTTON_GAP)
        end

        if UiWidgets.button(m_community_buttons[link_index]) then
            local link = UiSkin.COMMUNITY_LINKS[link_index]
            platform_open_url(link.url)
        end
    end
end

----------------------------------------------------

local function draw_main_page()
    -- Pause mode
    -- Continue btn
    if m_pause_menu_active then
        if draw_menu_button(m_button_continue) then
            close_pause_menu()
        end
    -- Main menu mode. 
    else
        -- Start btn
        if draw_menu_button(m_button_start) then
            -- Close the title menu and prepare for gameplay.
            m_title_menu_screen_active = false
            m_pause_menu_active = false
            m_menu_open = false
            input_set_mouse_capture(true)

            -- Temp Hack to mitigate the absence of a proper save system. 
            -- Clear any existing changes the player might have made and reset events.
            if module_get_is_valid(GAME_MODULE_NAME) then
                module_call_function(GAME_MODULE_NAME, "clear_orb_arrival_play_pass")
                module_call_function(GAME_MODULE_NAME, "set_exterior_intro_pending_full")
            end

            -- If fails to load the world, revert to the main menu.
            if not world_load_from_file(THE_ORB_ARRIVAL_WORLD_PATH) then
                print_error("[MainMenuModule] Failed to load the orb arrival world.")
                MainMenuModule.set_title_menu_screen_active(true)
                MainMenuModule.set_menu_open(true)
            end
        end
    end

    -- Seed the default focus for the menu items if it hasn't been done yet.
    if not m_focus_seeded then
        gui_set_item_default_focus()
        m_focus_seeded = true
    end

    -- Options btn
    gui_dummy(vec2(1.0, 12.0))
    if draw_menu_button(m_button_options) then
        set_page(PAGE_OPTIONS)
    end

    -- Main menu
    if not m_pause_menu_active then
        -- Gamma claibration.
        gui_dummy(vec2(1.0, 12.0))
        if draw_menu_button(m_button_brightness) then
            world_call_script_function("begin_gamma_calibration_from_menu")
        end
    end

    -- Controls btn
    gui_dummy(vec2(1.0, 12.0))
    if draw_menu_button(m_button_controls) then
        set_page(PAGE_CONTROLS)
    end

    if not m_pause_menu_active then
        -- Credits btn
        gui_dummy(vec2(1.0, 12.0))
        if draw_menu_button(m_button_credits) then
            set_page(PAGE_CREDITS)
        end
    end

    -- Return to main menu btn
    if m_pause_menu_active then
        gui_dummy(vec2(1.0, 12.0))
        if draw_menu_button(m_button_return_to_main_menu) then
            game_set_paused(false)
            m_menu_open = false

            -- Stop any ongoing camera effects before returning to the main menu.
            if module_get_is_valid(CAMERA_EFFECTS_MODULE_NAME) then
                module_call_function(CAMERA_EFFECTS_MODULE_NAME, "stop_screen_fade", 0.0)
            end
            -- Clear any pending exterior intro state in the game module.
            if module_get_is_valid(GAME_MODULE_NAME) then
                module_call_function(GAME_MODULE_NAME, "clear_exterior_intro_pending")
            end

            -- Set flags to indicate main menu is the goal now. 
            MainMenuModule.set_pause_menu_active(false)
            MainMenuModule.set_title_menu_screen_active(true)
            MainMenuModule.set_menu_open(true)

            -- Attempt to load the main menu world and handle failure. 
            if not world_load_from_file(THE_ORB_MAIN_MENU_WORLD_PATH) then
                print_error("[MainMenuModule] Failed to load the main menu world.")
                MainMenuModule.set_pause_menu_active(true)
                MainMenuModule.set_title_menu_screen_active(false)
                MainMenuModule.set_menu_open(true)
            end
        end
    end

    -- Quit game btn
    gui_dummy(vec2(1.0, 12.0))
    if draw_menu_button(m_button_quit) then
        engine_quit()
    end
end

----------------------------------------------------

local function draw_options_page()
    UiWidgets.label("Display", UiSkin.MENU_SECTION_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_SECTION_FONT_ID)
    gui_dummy(vec2(1.0, 8.0))

    -- GPU used by the application.
    -- Clip the name to the menu column so a long string stays inside the scroll.
    local gpu_name = renderer_get_gpu_name()
    UiWidgets.label_row("GPU", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
    gui_dummy(vec2(UiSkin.COMPO_WIDTH, UiSkin.ROW_HEIGHT))
    local gpu_rect_min = gui_get_item_rect_min()
    local gpu_text_y = gpu_rect_min.y + (UiSkin.ROW_HEIGHT - UiSkin.MENU_ROW_FONT_SIZE) * 0.5
    gui_push_clip_rect(gpu_rect_min, gpu_rect_min + vec2(UiSkin.COMPO_WIDTH, UiSkin.ROW_HEIGHT), true)
    gui_draw_text(gpu_name, vec2(gpu_rect_min.x, gpu_text_y), UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_CREAM, UiSkin.MENU_ROW_LABEL_FONT_ID)
    gui_pop_clip_rect()
    gui_dummy(vec2(1.0, 8.0))

    -- Display settings.
    draw_labeled_combo("Window Mode", m_combo_window_mode, settings_get_window_mode() + 1, apply_window_mode_setting)

    local vsync_mode = settings_get_vsync_mode()
    if vsync_mode == VSyncMode.ON and not m_vsync_enabled_brought_down then
        m_vsync_enabled_brought_down = true
        settings_set_vsync_mode(VSyncMode.ADAPTIVE)
        vsync_mode = settings_get_vsync_mode()
    end
    local vsync_menu_index = 1
    for mode_index = 1, #VSYNC_MENU_MODES do
        if VSYNC_MENU_MODES[mode_index] == vsync_mode then
            vsync_menu_index = mode_index
        end
    end
    -- The driver can refuse Adaptive and stay on Enabled. Keep the menu on Adaptive.
    if vsync_mode == VSyncMode.ON then
        vsync_menu_index = 2
    end
    draw_labeled_combo("VSync", m_combo_vsync, vsync_menu_index, apply_vsync_menu_setting)

    -- Refresh the list of available monitors.
    -- Monitor index is the display id. 
    if #m_monitors == 0 then
        refresh_monitor_combo()
    end
    -- If there are available monitors, display the monitor selection combo.
    -- Of course, if there are no monitors, nothing will be displayed anyway :P 
    if #m_monitors > 0 then
        m_combo_monitor.apply_fn = apply_monitor_combo_setting
        UiWidgets.label_row("Monitor", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
        UiWidgets.combo(m_combo_monitor)
        gui_dummy(vec2(1.0, 8.0))
    end

    -- Window size only applies while windowed.
    if settings_get_window_mode() == WINDOW_MODE_WINDOWED then
        if #m_resolutions == 0 then
            refresh_resolution_combo()
        end
    end
    if settings_get_window_mode() == WINDOW_MODE_WINDOWED and #m_resolutions > 0 then
        m_combo_resolution.apply_fn = apply_resolution_combo_setting
        UiWidgets.label_row("Resolution", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
        UiWidgets.combo(m_combo_resolution)
        gui_dummy(vec2(1.0, 8.0))
    end

    gui_dummy(vec2(1.0, 16.0))

    -- Interface settings.
    -- Just an fps overlay toggle for now.
    UiWidgets.label("Interface", UiSkin.MENU_SECTION_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_SECTION_FONT_ID)
    gui_dummy(vec2(1.0, 8.0))

    m_checkbox_fps_overlay.checked = settings_get_bool(UI_SETTINGS_SECTION, FPS_OVERLAY_SETTINGS_KEY, false)
    UiWidgets.label_row("Show FPS", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
    if UiWidgets.checkbox(m_checkbox_fps_overlay) then
        settings_set_bool(UI_SETTINGS_SECTION, FPS_OVERLAY_SETTINGS_KEY, m_checkbox_fps_overlay.checked)
    end
    gui_dummy(vec2(1.0, 16.0))

    -- Gameplay settings.
    UiWidgets.label("Gameplay", UiSkin.MENU_SECTION_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_SECTION_FONT_ID)
    gui_dummy(vec2(1.0, 8.0))

    -- Motion blur.
    m_checkbox_motion_blur.checked = MotionBlurEffect.get_enabled_setting()
    UiWidgets.label_row("Motion blur", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
    if UiWidgets.checkbox(m_checkbox_motion_blur) then
        MotionBlurEffect.set_enabled_setting(m_checkbox_motion_blur.checked)
    end
    gui_dummy(vec2(1.0, 12.0))

    -- Mouse and gamepad look sensitivity sliders.
    draw_slider_row(
        "Mouse look  %.4f",
        m_slider_mouse_look_sensitivity,
        get_mouse_look_sensitivity_setting,
        set_mouse_look_sensitivity_setting)
    draw_slider_row(
        "Gamepad look  %.1f",
        m_slider_gamepad_look_sensitivity,
        get_gamepad_look_sensitivity_setting,
        set_gamepad_look_sensitivity_setting)
    gui_dummy(vec2(1.0, 16.0))

    -- Graphics settings.
    UiWidgets.label("Graphics", UiSkin.MENU_SECTION_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_SECTION_FONT_ID)
    gui_dummy(vec2(1.0, 8.0))

    -- Render scale combo.
    -- Need to convert the current render scale to the nearest available option.
    -- Steps of 10 from 50 to 200. 25 percent is way too low for this demo.
    -- Above 100 the row warns that it can hurt framerate.
    local render_scale_selected_index = 1
    local current_render_percent = math.floor(settings_get_render_scale() * 100.0 + 0.5)
    local menu_min_render_percent = RENDER_SCALE_PERCENTS[1]
    local menu_max_render_percent = RENDER_SCALE_PERCENTS[#RENDER_SCALE_PERCENTS]
    if current_render_percent < menu_min_render_percent then
        current_render_percent = menu_min_render_percent
        settings_set_render_scale(menu_min_render_percent / 100.0)
    elseif current_render_percent > menu_max_render_percent then
        current_render_percent = menu_max_render_percent
        settings_set_render_scale(menu_max_render_percent / 100.0)
    end
    local nearest_distance = 999999 -- large initial value to find the nearest render scale.
    for i = 1, #RENDER_SCALE_PERCENTS do
        local distance = math.abs(RENDER_SCALE_PERCENTS[i] - current_render_percent)
        if distance < nearest_distance then
            nearest_distance = distance
            render_scale_selected_index = i
        end
    end
    draw_labeled_combo("Render Scale", m_combo_render_scale, render_scale_selected_index, apply_render_scale_combo_setting)

    -- Print a warning for multisampling. 
    if current_render_percent > RENDER_SCALE_WARNING_PERCENT then
        UiWidgets.label("Can hurt framerate.", UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_WARNING, UiSkin.MENU_ROW_LABEL_FONT_ID)
        gui_dummy(vec2(1.0, 8.0))
    end
    
    -- Anti-aliasing. None, FXAA, or temporal.
    draw_labeled_combo("Anti-Aliasing", m_combo_anti_aliasing, settings_get_anti_aliasing() + 1, settings_set_anti_aliasing)

    -- Shadows stop at High for the demo to keep it performant.
    local shadow_quality = settings_get_shadow_map_quality()
    if shadow_quality > SHADOW_QUALITY_MENU_MAX then
        apply_shadow_map_quality_setting(SHADOW_QUALITY_MENU_MAX)
        shadow_quality = SHADOW_QUALITY_MENU_MAX
    end
    -- Other regular graphics settings.
    draw_labeled_combo("Anisotropic", m_combo_anisotropic, settings_get_anisotropic_filter_level() + 1, settings_set_anisotropic_filter_level)
    draw_labeled_combo("Shadows", m_combo_shadows, shadow_quality + 1, apply_shadow_map_quality_setting)

    -- Sun contact shadows. The cascade map stays on either way.
    m_checkbox_contact_shadows.checked = settings_get_screen_space_contact_shadow_active()
    UiWidgets.label_row("Contact Shadows", UiSkin.LABEL_WIDTH, UiSkin.ROW_HEIGHT, UiSkin.MENU_ROW_FONT_SIZE, UiSkin.COLOR_MUTED, UiSkin.MENU_ROW_LABEL_FONT_ID)
    if UiWidgets.checkbox(m_checkbox_contact_shadows) then
        settings_set_screen_space_contact_shadow_active(m_checkbox_contact_shadows.checked)
    end
    gui_dummy(vec2(1.0, 8.0))
    draw_labeled_combo("SSAO", m_combo_ssao, settings_get_ssao_quality() + 1, settings_set_ssao_quality)
    draw_labeled_combo("Bounce", m_combo_ssgi, settings_get_ssgi_quality() + 1, settings_set_ssgi_quality)
    -- Saved Medium reads as Low. High is the last row, not quality plus one.
    local ssr_quality = settings_get_ssr_quality()
    local ssr_selected_index = ssr_quality + 1
    if ssr_quality >= SSRQuality.HIGH then
        ssr_selected_index = SSR_MENU_HIGH_OPTION + 1
    elseif ssr_quality == SSRQuality.MEDIUM then
        ssr_selected_index = SSRQuality.LOW + 1
    end
    draw_labeled_combo("Reflections", m_combo_ssr, ssr_selected_index, apply_ssr_quality_setting)
    gui_dummy(vec2(1.0, 16.0))

    -- Sound settings.
    UiWidgets.label("Sound", UiSkin.MENU_SECTION_FONT_SIZE, UiSkin.COLOR_EMBER, UiSkin.MENU_SECTION_FONT_ID)
    gui_dummy(vec2(1.0, 8.0))
    draw_slider_row("Master  %.0f%%",
                    m_slider_master_volume,
                    get_master_volume_percent,
                    set_master_volume_percent)
    gui_dummy(vec2(1.0, 16.0))

    if UiWidgets.button(m_button_reset_defaults) then
        m_modal_reset_defaults.open = true
    end
end

----------------------------------------------------

local function draw_credits_page()
    gui_dummy(vec2(UiSkin.SCROLL_CONTENT_WIDTH, 1.0))

    -- Title and subtitle.
    if m_credits_title ~= "" then
        draw_credits_wrapped_field(m_credits_title, UiSkin.COLOR_EMBER, UiSkin.CREDITS_TITLE_FONT_SIZE, UiSkin.CREDITS_TITLE_FONT_ID)
        gui_dummy(vec2(1.0, 6.0))
    end

    if m_credits_subtitle ~= "" then
        draw_credits_wrapped_field(m_credits_subtitle, UiSkin.COLOR_CREAM, UiSkin.CREDITS_BODY_FONT_SIZE, UiSkin.CREDITS_BODY_FONT_ID)
        gui_dummy(vec2(1.0, 14.0))
    end

    gui_dummy(vec2(1.0, 14.0))

    -- Iterate through each credits layer.
    for layer_index = 1, #m_credits_layers do
        local layer = m_credits_layers[layer_index]
        draw_credits_wrapped_field(layer.section_name, UiSkin.COLOR_EMBER, UiSkin.CREDITS_SECTION_FONT_SIZE, UiSkin.CREDITS_SECTION_FONT_ID)
        gui_dummy(vec2(1.0, 8.0))

        -- Iterate through each entry.
        for entry_index = 1, #layer.entries do
            local entry = layer.entries[entry_index]
            local entry_value = ""
            if entry.value ~= nil then
                entry_value = entry.value
            end

            -- Draw the entry name and value.
            draw_credits_wrapped_field(entry.name, UiSkin.COLOR_CREAM, UiSkin.CREDITS_BODY_FONT_SIZE, UiSkin.CREDITS_BODY_FONT_ID)
            if entry_value ~= "" then
                gui_dummy(vec2(1.0, 4.0))
                draw_credits_wrapped_field(entry_value, UiSkin.COLOR_MUTED, UiSkin.CREDITS_BODY_FONT_SIZE, UiSkin.CREDITS_BODY_FONT_ID)
                gui_dummy(vec2(1.0, CREDITS_ENTRY_SPACING))
            end
        end

        gui_dummy(vec2(1.0, CREDITS_SECTION_SPACING))
    end
end

----------------------------------------------------

local function draw_menu_strip()
    local layout_size = gui_get_layout_size()
    local panel_pos = vec2(0.0, 0.0)

    -- Draw the background panel for the menu strip.
    local strip_bleed = 1.0
    UiWidgets.panel(vec2(-strip_bleed, -strip_bleed),
                    vec2(UiSkin.PANEL_WIDTH + strip_bleed * 2.0, layout_size.y + strip_bleed * 2.0),
                    UiSkin.STYLE_PANEL,
                    UiSkin.PANEL_CORNER_ROUNDING)

    -- Draw the title band.
    local title = settings_get_game_title()
    local header_pos = vec2(panel_pos.x + UiSkin.PANEL_PADDING_LEFT, panel_pos.y + 28.0)
    local header_width = UiSkin.PANEL_WIDTH - UiSkin.PANEL_PADDING_LEFT - UiSkin.PANEL_PADDING_RIGHT
    gui_draw_text_aligned(title,
                            header_pos,
                            vec2(header_width, UiSkin.MENU_TITLE_FONT_SIZE + 4.0),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            UiSkin.MENU_TITLE_FONT_SIZE,
                            UiSkin.COLOR_CREAM,
                            UiSkin.MENU_TITLE_FONT_ID)
    
    -- Draw the rule under the title.
    local title_rule_width = 96.0
    local title_rule_x = header_pos.x + (header_width - title_rule_width) * 0.5
    gui_draw_rect(vec2(title_rule_x, header_pos.y + UiSkin.MENU_TITLE_FONT_SIZE + 8.0),
                    vec2(title_rule_width, 3.0),
                    UiSkin.COLOR_EMBER)
    
    -- Draw the subtitle below the title rule.
    local subtitle_y = header_pos.y + UiSkin.MENU_TITLE_FONT_SIZE + 8.0 + 3.0 + 10.0
    gui_draw_text_aligned(UiSkin.MENU_SUBTITLE_TEXT,
                            vec2(header_pos.x, subtitle_y),
                            vec2(header_width, UiSkin.MENU_SUBTITLE_FONT_SIZE + 8.0),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            UiSkin.MENU_SUBTITLE_FONT_SIZE,
                            UiSkin.COLOR_CREAM,
                            UiSkin.MENU_SUBTITLE_FONT_ID)

    -- Draw the engine version at the bottom right if the main menu screen is active.
    if m_title_menu_screen_active then
        local version_margin = UiSkin.ENGINE_VERSION_MARGIN
        local engine_version_label = "Detis Engine " .. engine_get_version()
        gui_draw_text_aligned(engine_version_label,
                                vec2(version_margin, layout_size.y - version_margin),
                                vec2(layout_size.x - version_margin * 2.0, UiSkin.ENGINE_VERSION_FONT_SIZE + 6.0),
                                GuiAlignH.RIGHT,
                                GuiAlignV.BOTTOM,
                                UiSkin.ENGINE_VERSION_FONT_SIZE,
                                UiSkin.COLOR_CREAM,
                                UiSkin.ENGINE_VERSION_FONT_ID)
    end

    -- Begin the main body section of the menu.
    local body_pos = vec2(panel_pos.x + UiSkin.PANEL_PADDING_LEFT, panel_pos.y + UiSkin.HEADER_BAND_HEIGHT)
    local body_height = layout_size.y - UiSkin.HEADER_BAND_HEIGHT - UiSkin.PANEL_PADDING_BOTTOM
    gui_set_cursor_screen_pos(body_pos)
    local body_child_open = gui_begin_child("main_menu_body",
                                            vec2(UiSkin.CONTENT_WIDTH, body_height),
                                            GuiWindowFlags.NO_BACKGROUND + GuiWindowFlags.NO_SCROLLBAR + GuiWindowFlags.NO_SCROLL_WITH_MOUSE)

    -- Check if the main body child window was successfully opened.
    if body_child_open and m_page == PAGE_MAIN then
        -- Set item spacing to zero for the main menu body.
        gui_push_style_var_vec2(GuiStyleVar.ITEM_SPACING, vec2(0.0, 0.0))

        -- Calculate the height for the community footer and the main list.
        local community_footer_height = UiSkin.MENU_FOOTER_BUTTON_HEIGHT + 8.0
        local main_list_height = body_height - community_footer_height
        if main_list_height < UiSkin.BUTTON_HEIGHT then
            main_list_height = UiSkin.BUTTON_HEIGHT
        end

        -- Begin the main list child window. 
        local main_list_open = gui_begin_child("main_menu_main_list",
                        vec2(UiSkin.CONTENT_WIDTH, main_list_height),
                        GuiWindowFlags.NO_BACKGROUND + GuiWindowFlags.NO_SCROLLBAR + GuiWindowFlags.NO_SCROLL_WITH_MOUSE)
        
        -- Draw the main page content if the main list child window is open.
        if main_list_open then
            draw_main_page()
            gui_end_child() -- end main_menu_main_list
        end

        -- Draw the community footer if it has a positive height.
        if community_footer_height > 0.0 then
            local footer_child_open = gui_begin_child("main_menu_community_footer",
                            vec2(UiSkin.CONTENT_WIDTH, community_footer_height),
                            GuiWindowFlags.NO_BACKGROUND + GuiWindowFlags.NO_SCROLLBAR + GuiWindowFlags.NO_SCROLL_WITH_MOUSE)
            
            -- Draw the community buttons if the footer child window is open.
            if footer_child_open then
                draw_community_buttons()
            end
            if footer_child_open then
                gui_end_child() -- end main_menu_community_footer
            end
        end

        -- End the main menu body child window.
        gui_pop_style_var(1)

    -- If the main menu body child window is open but not on the main page.
    elseif body_child_open then
        gui_push_style_var_vec2(GuiStyleVar.ITEM_SPACING, vec2(0.0, 0.0))
        
        -- Calculate the scroll height for the subpage content.
        local scroll_height = body_height - UiSkin.BUTTON_HEIGHT - UiSkin.MENU_BACK_BUTTON_GAP
        if UiWidgets.begin_scroll("main_menu_subpage_scroll", vec2(UiSkin.CONTENT_WIDTH, scroll_height), nil, 6.0) then
            if m_page == PAGE_OPTIONS then
                draw_options_page()
            elseif m_page == PAGE_CONTROLS then
                draw_controls_page()
            elseif m_page == PAGE_CREDITS then
                draw_credits_page()
            end
        end

        UiWidgets.end_scroll() -- end main_menu_subpage_scroll

        gui_dummy(vec2(1.0, UiSkin.MENU_BACK_BUTTON_GAP))

        -- Draw the back row with the back button.
        local back_row_child_open = gui_begin_child("main_menu_back_row",  
                                                    vec2(UiSkin.CONTENT_WIDTH, UiSkin.BUTTON_HEIGHT),
                                                    GuiWindowFlags.NO_BACKGROUND + GuiWindowFlags.NO_SCROLLBAR + GuiWindowFlags.NO_SCROLL_WITH_MOUSE)

        if back_row_child_open then
            if draw_menu_button(m_button_back) then
                set_page(PAGE_MAIN)
            end

            -- Focus the back button if the focus has not been seeded yet.
            if not m_focus_seeded then
                gui_set_item_default_focus()
                m_focus_seeded = true
            end
        end

        -- End the back row child window (main_menu_back_row)
        if back_row_child_open then
            gui_end_child()
        end

        -- Pop the style variable for the main menu body.
        gui_pop_style_var(1)
    end

    -- End the main menu body child window if it is open.
    if body_child_open then
        gui_end_child()
    end
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function MainMenuModule.on_initialize()
    -- Initialize main menu buttons.
    m_button_start = new_menu_button("main_menu_start", "Start")
    m_button_continue = new_menu_button("main_menu_continue", "Continue")
    m_button_return_to_main_menu = new_menu_button("main_menu_return", "Main Menu")
    m_button_options = new_menu_button("main_menu_options", "Options")
    m_button_brightness = new_menu_button("main_menu_brightness", "Gamma")
    m_button_controls = new_menu_button("main_menu_controls", "Controls")
    m_button_credits = new_menu_button("main_menu_credits", "Credits")
    m_button_quit = new_menu_button("main_menu_quit", "Quit")
    m_button_back = new_menu_button("main_menu_back", "Back")

    -- Initialize credits data.
    m_credits_title = ""
    m_credits_subtitle = ""
    m_credits_layers = {}

    local credits_ini = file_manager_load_ini(CREDITS_INI_PATH)
    if credits_ini == nil then
        print_error("[MainMenuModule] Credits config not found at " .. CREDITS_INI_PATH)
    else
        -- Iterate through sections and entries in the order they appear in the ini.
        for section_index = 1, #credits_ini do
            local section_name = credits_ini[section_index]
            local section_table = credits_ini[section_name]
            local layer = {
                section_name = section_name,
                entries = {},
            }

            for entry_index = 1, #section_table do
                local entry_name = section_table[entry_index]
                if entry_name ~= "name_header" and entry_name ~= "value_header" then
                    layer.entries[#layer.entries + 1] = {
                        name = entry_name,
                        value = section_table[entry_name],
                    }
                end
            end

            m_credits_layers[#m_credits_layers + 1] = layer
        end
    end

    m_credits_title = UiSkin.DEMO_CREDITS_TITLE
    m_credits_subtitle = UiSkin.DEMO_CREDITS_SUBTITLE

    -- Initialize community buttons.
    local community_link_count = #UiSkin.COMMUNITY_LINKS
    local footer_button_gap = UiSkin.MENU_FOOTER_BUTTON_GAP
    local footer_button_width = UiSkin.CONTENT_WIDTH
    if community_link_count > 1 then
        footer_button_width = (UiSkin.CONTENT_WIDTH - footer_button_gap * (community_link_count - 1)) / community_link_count
    end

    m_community_buttons = {}
    for link_index = 1, community_link_count do
        local link = UiSkin.COMMUNITY_LINKS[link_index]
        m_community_buttons[link_index] = new_menu_footer_button(
            "main_menu_community_" .. link.label,
            link.label,
            footer_button_width)
    end

    -- Initialize render scale labels.
    local render_scale_labels = {}
    for i = 1, #RENDER_SCALE_PERCENTS do
        render_scale_labels[i] = string.format("%d%%", RENDER_SCALE_PERCENTS[i])
    end

    -- Initialize graphics settings combos.
    m_combo_window_mode = new_menu_combo("main_menu_window_mode", WINDOW_MODE_OPTIONS)
    m_combo_vsync = new_menu_combo("main_menu_vsync", VSYNC_MENU_OPTIONS)
    m_combo_monitor = new_menu_combo("main_menu_monitor", { "Monitor" })
    m_combo_monitor.on_before_open = refresh_monitor_combo
    m_combo_resolution = new_menu_combo("main_menu_resolution", { "Resolution" })
    m_combo_resolution.on_before_open = refresh_resolution_combo
    m_combo_render_scale = new_menu_combo("main_menu_render_scale", render_scale_labels)
    m_combo_anti_aliasing = new_menu_combo("main_menu_anti_aliasing", ANTI_ALIASING_OPTIONS)
    m_combo_anisotropic = new_menu_combo("main_menu_anisotropic", ANISOTROPIC_OPTIONS)
    m_combo_shadows = new_menu_combo("main_menu_shadows", SHADOW_QUALITY_OPTIONS)
    m_combo_ssao = new_menu_combo("main_menu_ssao", GTAO_QUALITY_OPTIONS)
    m_combo_ssgi = new_menu_combo("main_menu_ssgi", SSGI_QUALITY_OPTIONS)
    m_combo_ssr = new_menu_combo("main_menu_ssr", SSR_OPTIONS)

    -- Initialize graphics settings sliders.
    m_slider_master_volume = new_menu_slider("main_menu_master_volume", get_master_volume_percent(), 0.0, 100.0)
    m_slider_mouse_look_sensitivity = new_menu_slider("main_menu_mouse_look_sensitivity",
                                                        get_mouse_look_sensitivity_setting(),
                                                        MOUSE_LOOK_SENSITIVITY_MIN,
                                                        MOUSE_LOOK_SENSITIVITY_MAX)
    
    m_slider_gamepad_look_sensitivity = new_menu_slider("main_menu_gamepad_look_sensitivity",
                                                        get_gamepad_look_sensitivity_setting(),
                                                        GAMEPAD_LOOK_SENSITIVITY_MIN,
                                                        GAMEPAD_LOOK_SENSITIVITY_MAX)
    
    -- Initialize checkboxes.
    m_checkbox_fps_overlay = UiWidgets.new_checkbox({
            id = "main_menu_fps_overlay",
            label = "",
            size = vec2(22.0, 22.0),
            row_height = UiSkin.ROW_HEIGHT,
            checked = settings_get_bool(UI_SETTINGS_SECTION, FPS_OVERLAY_SETTINGS_KEY, false),
            font_size = UiSkin.MENU_CHECKBOX_FONT_SIZE,
            text_color = UiSkin.COLOR_CREAM,
            border_color = UiSkin.COLOR_MUTED,
            border_thickness = 2.0,
            hover = { color = UiSkin.COLOR_EMBER_BRIGHT },
            focused = { color = UiSkin.COLOR_EMBER_BRIGHT },
            pressed = { color = UiSkin.COLOR_EMBER_BRIGHT },
            check_idle = { color = UiSkin.COLOR_MUTED },
            check = UiSkin.STYLE_FILL,
        }
    )

    m_checkbox_contact_shadows = UiWidgets.new_checkbox({
            id = "main_menu_contact_shadows",
            label = "",
            size = vec2(22.0, 22.0),
            row_height = UiSkin.ROW_HEIGHT,
            checked = settings_get_screen_space_contact_shadow_active(),
            font_size = UiSkin.MENU_CHECKBOX_FONT_SIZE,
            text_color = UiSkin.COLOR_CREAM,
            border_color = UiSkin.COLOR_MUTED,
            border_thickness = 2.0,
            hover = { color = UiSkin.COLOR_EMBER_BRIGHT },
            focused = { color = UiSkin.COLOR_EMBER_BRIGHT },
            pressed = { color = UiSkin.COLOR_EMBER_BRIGHT },
            check_idle = { color = UiSkin.COLOR_MUTED },
            check = UiSkin.STYLE_FILL,
        }
    )

    m_checkbox_motion_blur = UiWidgets.new_checkbox({
            id = "main_menu_motion_blur",
            label = "",
            size = vec2(22.0, 22.0),
            row_height = UiSkin.ROW_HEIGHT,
            checked = MotionBlurEffect.get_enabled_setting(),
            font_size = UiSkin.MENU_CHECKBOX_FONT_SIZE,
            text_color = UiSkin.COLOR_CREAM,
            border_color = UiSkin.COLOR_MUTED,
            border_thickness = 2.0,
            hover = { color = UiSkin.COLOR_EMBER_BRIGHT },
            focused = { color = UiSkin.COLOR_EMBER_BRIGHT },
            pressed = { color = UiSkin.COLOR_EMBER_BRIGHT },
            check_idle = { color = UiSkin.COLOR_MUTED },
            check = UiSkin.STYLE_FILL,
        }
    )

    -- Initialize shadow restart modal.
    m_button_shadow_restart_ok = UiWidgets.new_button({
            id = "main_menu_shadow_restart_ok",
            width = 120.0,
            height = 44.0,
            label = "OK",
            font_size = UiSkin.MENU_MODAL_BUTTON_FONT_SIZE,
            font_id = UiSkin.MENU_LABEL_FONT_ID,
            text_color = UiSkin.BUTTON_TEXT_COLOR,
            idle = UiSkin.STYLE_BUTTON_IDLE,
            hover = UiSkin.STYLE_BUTTON_HOVER,
            pressed = UiSkin.STYLE_BUTTON_PRESSED,
            focused = UiSkin.STYLE_BUTTON_FOCUSED,
        }
    )
    m_modal_shadow_restart = UiWidgets.new_modal({
            id = "main_menu_shadow_restart",
            title = "Restart required",
            message = "Restart the engine for the new shadow map\nresolution and cascade count to take effect.",
            font_size = UiSkin.MENU_MODAL_TITLE_FONT_SIZE,
            message_font_size = UiSkin.MENU_MODAL_MESSAGE_FONT_SIZE,
            title_font_id = UiSkin.MENU_MODAL_TITLE_FONT_ID,
            message_font_id = UiSkin.MENU_ROW_LABEL_FONT_ID,
            title_color = UiSkin.COLOR_CREAM,
            message_color = UiSkin.COLOR_CREAM,
            panel = UiSkin.WIDGET_STYLE_IDLE,
            dim = { color = Colors.get_with_alpha(Colors.BLACK, 0.45) },
            confirm_button = m_button_shadow_restart_ok,
        }
    )

    m_button_reset_defaults_confirm = UiWidgets.new_button({
            id = "main_menu_reset_defaults_confirm",
            width = 120.0,
            height = 44.0,
            label = "Reset",
            font_size = UiSkin.MENU_MODAL_BUTTON_FONT_SIZE,
            font_id = UiSkin.MENU_LABEL_FONT_ID,
            text_color = UiSkin.BUTTON_TEXT_COLOR,
            idle = UiSkin.STYLE_BUTTON_IDLE,
            hover = UiSkin.STYLE_BUTTON_HOVER,
            pressed = UiSkin.STYLE_BUTTON_PRESSED,
            focused = UiSkin.STYLE_BUTTON_FOCUSED,
        }
    )
    m_button_reset_defaults_cancel = UiWidgets.new_button({
            id = "main_menu_reset_defaults_cancel",
            width = 120.0,
            height = 44.0,
            label = "Cancel",
            font_size = UiSkin.MENU_MODAL_BUTTON_FONT_SIZE,
            font_id = UiSkin.MENU_LABEL_FONT_ID,
            text_color = UiSkin.BUTTON_TEXT_COLOR,
            idle = UiSkin.STYLE_BUTTON_IDLE,
            hover = UiSkin.STYLE_BUTTON_HOVER,
            pressed = UiSkin.STYLE_BUTTON_PRESSED,
            focused = UiSkin.STYLE_BUTTON_FOCUSED,
        }
    )
    m_modal_reset_defaults = UiWidgets.new_modal({
            id = "main_menu_reset_defaults",
            title = "Reset settings?",
            message = "Restore all options to their shipped defaults.",
            font_size = UiSkin.MENU_MODAL_TITLE_FONT_SIZE,
            message_font_size = UiSkin.MENU_MODAL_MESSAGE_FONT_SIZE,
            title_font_id = UiSkin.MENU_MODAL_TITLE_FONT_ID,
            message_font_id = UiSkin.MENU_ROW_LABEL_FONT_ID,
            title_color = UiSkin.COLOR_CREAM,
            message_color = UiSkin.COLOR_CREAM,
            panel = UiSkin.WIDGET_STYLE_IDLE,
            dim = { color = Colors.get_with_alpha(Colors.BLACK, 0.45) },
            confirm_button = m_button_reset_defaults_confirm,
            cancel_button = m_button_reset_defaults_cancel,
        }
    )

    m_button_reset_defaults = UiWidgets.new_button({
            id = "main_menu_reset_defaults",
            width = UiSkin.SCROLL_CONTENT_WIDTH,
            height = UiSkin.BUTTON_HEIGHT,
            label = "Reset to defaults",
            font_size = UiSkin.MENU_BUTTON_FONT_SIZE,
            font_id = UiSkin.MENU_LABEL_FONT_ID,
            text_color = UiSkin.BUTTON_TEXT_COLOR,
            idle = UiSkin.STYLE_BUTTON_IDLE,
            hover = UiSkin.STYLE_BUTTON_HOVER,
            pressed = UiSkin.STYLE_BUTTON_PRESSED,
            focused = UiSkin.STYLE_BUTTON_FOCUSED,
        }
    )

    -- Set initial page and menu state.
    m_page = PAGE_MAIN
    m_focus_seeded = false
    m_widgets_ready = true
    m_menu_open = false
    m_pause_menu_active = false
    m_title_menu_screen_active = false
    m_boot_splash_active = false
end

----------------------------------------------------

function MainMenuModule.on_process(_t_delta_time)
    if not get_game_mode_active() then
        return
    end

    -- Xbox B and PS Circle are both the cancel binding.
    if m_menu_open and input_get_action_pressed_event("cancel") then
        -- Skip if a modal or combo is open.
        if m_modal_shadow_restart.open or m_modal_reset_defaults.open or UiWidgets.get_is_any_combo_open() then
            return
        end

        -- Go back to the main page (only one level deep atm so this is good enough).
        if m_page ~= PAGE_MAIN then
            set_page(PAGE_MAIN)
            return
        end

        -- If it's a pause menu and main page is active, close the pause menu.
        if m_pause_menu_active then
            close_pause_menu()
            return
        end
    end

    -- Pause game.
    if not input_get_action_pressed_event("game_pause") then
        return
    end

    -- A modal or combo is open. Leave this press for that close.
    if m_menu_open and (m_modal_shadow_restart.open or m_modal_reset_defaults.open or UiWidgets.get_is_any_combo_open()) then
        return
    end

    -- We are in the main menu. Do not open the pause menu.
    -- Escape is back. The title page itself stays put.
    if m_title_menu_screen_active then
        if m_page ~= PAGE_MAIN then
            set_page(PAGE_MAIN)
        end
        return
    end

    -- Logos are on screen so Escape skips the logo.
    if m_boot_splash_active then
        return
    end

    -- If the menu is already open and the pause menu is active, handle closing it.
    if m_menu_open and m_pause_menu_active then
        if m_page ~= PAGE_MAIN then
            set_page(PAGE_MAIN)
            return
        end
        close_pause_menu()
        return
    end

    -- Open the pause menu if it is not already active.
    MainMenuModule.set_pause_menu_active(true)
    MainMenuModule.set_menu_open(true)
    game_set_paused(true)
end

----------------------------------------------------

function MainMenuModule.on_shutdown()
    m_menu_open = false
    m_pause_menu_active = false
    m_title_menu_screen_active = false
    m_boot_splash_active = false
end

----------------------------------------------------

function MainMenuModule.on_draw(_t_delta_time)
    -- If the widgets are not ready or the menu is not open, skip drawing.
    if not m_widgets_ready or not m_menu_open then
        return
    end

    -- Begin drawing the main menu canvas.
    if not UiWidgets.begin_menu_canvas("MainMenuCanvas", UiWidgets.CANVAS_INTERACTIVE) then
        return
    end

    -- Draw the menu strip within the main menu canvas.
    draw_menu_strip()

    -- End drawing the main menu canvas.
    UiWidgets.end_menu_canvas()

    -- Reset defaults modal.
    local reset_defaults_result = UiWidgets.modal(m_modal_reset_defaults)
    if reset_defaults_result == "confirm" then
        apply_settings_reset_to_defaults()
    end

    -- Shadow restart modal.
    UiWidgets.modal(m_modal_shadow_restart)
end

----------------------------------------------------

return MainMenuModule
