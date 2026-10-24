-- @NOTE: One-time brightness screen. No image. Three dark squares on black. The slider lifts them.

local GammaCalibration = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local UiWidgets = dofile("../content/scripts/shared/ui_widgets.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")
local UiSkin = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_main_menu/main_menu_skin.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local GAMMA_CALIBRATION_SECTION = "Calibration"
local GAMMA_CALIBRATION_KEY = "gamma_done"
local GAMMA_CALIBRATION_DEBUG_ALWAYS_SHOW = false
local GAMMA_SLIDER_MIN = 0.5
local GAMMA_SLIDER_MAX = 2.5
local GAMMA_UI_REFERENCE_HEIGHT = 1080.0
local GAMMA_PATCH_LINEAR = { 0.0008, 0.004, 0.02 }
local GAMMA_PATCH_LABELS = { "Vanish", "Faint", "Visible" }
local GAMMA_CALIBRATION_DRAW_PRIORITY = 16

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------
---
local m_active = false
local m_widgets_ready = false
local m_focus_seeded = false
local m_frames_shown = 0
local m_slider = {}
local m_button = {}

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function get_gamma_patch_color(t_linear)
    -- Apply the gamma curve to the linear value.
    local light = t_linear ^ (1.0 / m_slider.value)
    -- Apply the sRGB encode to the light value.
    local encoded = light * 12.92
    if light > 0.0031308 then
        encoded = 1.055 * (light ^ (1.0 / 2.4)) - 0.055
    end
    -- Put the color together in sRGB space.
    return vec4(encoded, encoded, encoded, 1.0)
end

----------------------------------------------------

local function confirm_gamma_calibration()
    if not m_active then
        return
    end

    -- Set the flag to true to keep this screen from coming back.
    -- @NOTE: GAMMA_CALIBRATION_DEBUG_ALWAYS_SHOW will override this.
    settings_set_gamma(m_slider.value)
    settings_set_bool(GAMMA_CALIBRATION_SECTION, GAMMA_CALIBRATION_KEY, true)
    m_active = false
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function GammaCalibration.get_is_pending()
    if GAMMA_CALIBRATION_DEBUG_ALWAYS_SHOW then
        return true
    end

    return settings_get_bool(GAMMA_CALIBRATION_SECTION, GAMMA_CALIBRATION_KEY, false) ~= true
end

----------------------------------------------------

function GammaCalibration.set_active(t_active)
    if t_active ~= true then
        m_active = false
        m_frames_shown = 0
        m_focus_seeded = false
        return
    end

    -- Start the slider at the current gamma and 
    -- clamp it to the range the screen can actually show.
    local gamma = settings_get_gamma()
    if gamma < GAMMA_SLIDER_MIN then
        gamma = GAMMA_SLIDER_MIN
    end
    if gamma > GAMMA_SLIDER_MAX then
        gamma = GAMMA_SLIDER_MAX
    end

    -- Create the widgets.
    if not m_widgets_ready then
        m_slider = UiWidgets.new_slider({id = "gamma_calibration_slider",
                                        width = UiSkin.MENU_BUTTON_WIDTH,
                                        value = gamma,
                                        min_value = GAMMA_SLIDER_MIN,
                                        max_value = GAMMA_SLIDER_MAX,
                                        track = UiSkin.WIDGET_STYLE_IDLE,
                                        fill = UiSkin.SLIDER_VALUE_STYLE,
                                        fill_active = UiSkin.STYLE_FILL,
                                        thumb_idle = UiSkin.SLIDER_STYLE_THUMB,
                                        thumb_hover = UiSkin.SLIDER_STYLE_THUMB_HOVER,
                                        thumb_pressed = UiSkin.SLIDER_STYLE_THUMB_HOVER,
                                        thumb_focused = UiSkin.SLIDER_STYLE_THUMB_HOVER,
                                    })
        
        m_button = UiWidgets.new_button({id = "gamma_calibration_continue",
                                        width = UiSkin.MENU_BUTTON_WIDTH,
                                        label = "Continue",
                                        font_size = UiSkin.MENU_BUTTON_FONT_SIZE,
                                        font_id = UiSkin.MENU_LABEL_FONT_ID,
                                        text_color = UiSkin.BUTTON_TEXT_COLOR,
                                        idle = UiSkin.STYLE_BUTTON_IDLE,
                                        hover = UiSkin.STYLE_BUTTON_HOVER,
                                        pressed = UiSkin.STYLE_BUTTON_PRESSED,
                                        focused = UiSkin.STYLE_BUTTON_FOCUSED,
                                    })
        m_widgets_ready = true
    end

    -- Set the slider to the current gamma and save it.
    m_slider.value = gamma
    settings_set_gamma(gamma)

    -- Reset the frame counter and focus.
    m_frames_shown = 0
    m_focus_seeded = false

    -- Ready to go!
    m_active = true
end

----------------------------------------------------

function GammaCalibration.get_is_active()
    return m_active
end

----------------------------------------------------

function GammaCalibration.process(_t_delta_time)
    if not m_active then
        return
    end

    m_frames_shown = m_frames_shown + 1
end

----------------------------------------------------

function GammaCalibration.draw()
    if not m_active or not m_widgets_ready then
        return
    end

    -- Start the canvas.
    local canvas_flags = GuiWindowFlags.NO_MOVE
    gui_push_draw_priority(GAMMA_CALIBRATION_DRAW_PRIORITY)
    gui_push_foreground_draw()
    if not gui_begin_screen_canvas("gamma_calibration", canvas_flags) then
        gui_pop_foreground_draw()
        gui_pop_draw_priority()
        return
    end

    -- Background.
    local layout_size = gui_get_layout_size()
    local ui_scale = layout_size.y / GAMMA_UI_REFERENCE_HEIGHT
    gui_draw_rect(vec2(0.0, 0.0), layout_size, Colors.BLACK)

    -- Title.
    gui_draw_text_aligned(
        "Gamma Calibration",
        vec2(0.0, layout_size.y * 0.07),
        vec2(layout_size.x, 52.0 * ui_scale),
        GuiAlignH.CENTER,
        GuiAlignV.MIDDLE,
        UiSkin.MENU_TITLE_FONT_SIZE * ui_scale,
        UiSkin.COLOR_CREAM,
        UiSkin.MENU_TITLE_FONT_ID,
        1.0)

    -- Instructions.
    gui_draw_text_aligned("Adjust until the left square vanishes and the middle square is only just visible.",
                            vec2(0.0, layout_size.y * 0.145),
                            vec2(layout_size.x, 36.0 * ui_scale),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            UiSkin.MENU_SUBTITLE_FONT_SIZE * ui_scale,
                            UiSkin.COLOR_MUTED,
                            UiSkin.MENU_SUBTITLE_FONT_ID,
                            1.0)


    -- Gamma test squares.
    local patch_size = 150.0 * ui_scale
    local patch_gap = 36.0 * ui_scale
    local patch_count = #GAMMA_PATCH_LINEAR
    local row_width = patch_count * patch_size + (patch_count - 1) * patch_gap
    local row_x = (layout_size.x - row_width) * 0.5
    local row_y = layout_size.y * 0.28
    for patch_index = 1, patch_count do
        local patch_x = row_x + (patch_index - 1) * (patch_size + patch_gap)
        gui_draw_rect(vec2(patch_x, row_y),
                        vec2(patch_size, patch_size),
                        get_gamma_patch_color(GAMMA_PATCH_LINEAR[patch_index]))

        gui_draw_text_aligned(GAMMA_PATCH_LABELS[patch_index],
                                vec2(patch_x, row_y + patch_size + 8.0 * ui_scale),
                                vec2(patch_size, 28.0 * ui_scale),
                                GuiAlignH.CENTER,
                                GuiAlignV.MIDDLE,
                                UiSkin.MENU_ROW_FONT_SIZE * ui_scale,
                                UiSkin.COLOR_MUTED,
                                UiSkin.MENU_ROW_LABEL_FONT_ID,
                                1.0)
    end

    -- Slider and confirm.
    local control_width = 640.0 * ui_scale
    if control_width > layout_size.x * 0.5 then
        control_width = layout_size.x * 0.5
    end
    local control_x = (layout_size.x - control_width) * 0.5
    local slider_y = row_y + patch_size + 88.0 * ui_scale
    m_slider.width = control_width
    m_slider.height = UiSkin.ROW_HEIGHT * ui_scale
    
    -- Gamma value label.
    gui_draw_text_aligned(string.format("%.2f", m_slider.value),
                        vec2(0.0, slider_y - 32.0 * ui_scale),
                        vec2(layout_size.x, 28.0 * ui_scale),
                        GuiAlignH.CENTER,
                        GuiAlignV.MIDDLE,
                        UiSkin.MENU_ROW_FONT_SIZE * ui_scale,
                        UiSkin.COLOR_CREAM,
                        UiSkin.MENU_ROW_LABEL_FONT_ID,
                        1.0)
    -- Gamma slider.
    gui_set_cursor_screen_pos(vec2(control_x, slider_y))
    if UiWidgets.slider(m_slider) then
        settings_set_gamma(m_slider.value)
    end

    -- Last focused item becomes the default focus.
    if not m_focus_seeded then
        gui_set_item_default_focus()
        m_focus_seeded = true
    end

    -- Confirm button.
    m_button.width = control_width
    m_button.height = UiSkin.BUTTON_HEIGHT * ui_scale
    m_button.font_size = UiSkin.MENU_BUTTON_FONT_SIZE * ui_scale
    gui_set_cursor_screen_pos(vec2(control_x, slider_y + m_slider.height + 18.0 * ui_scale))
    
    -- Confirm with the Continue button but wait a few frames first.
    -- If the splash is playing, the first frame will be the skip press.
    if m_frames_shown >= 2 and UiWidgets.button(m_button) then
        confirm_gamma_calibration()
    end

    -- End the canvas.
    gui_end_screen_canvas()
    gui_pop_foreground_draw()
    gui_pop_draw_priority()
end

----------------------------------------------------

return GammaCalibration
