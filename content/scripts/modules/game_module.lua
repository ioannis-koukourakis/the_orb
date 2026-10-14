local GameModule = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local UiWidgets = dofile("../content/scripts/shared/ui_widgets.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")
local TheOrbWhiteFadeIntro = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_white_fade_intro.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

local LOADING_SCREEN_UI_FONT_SIZE = 32.0

local UI_SETTINGS_SECTION = "UI"
local FPS_OVERLAY_SETTINGS_KEY = "fps_overlay_active"

local FPS_LABEL_MARGIN = 0.015
local FPS_LABEL_BG_COLOR = vec4(0.08, 0.08, 0.10, 0.72)
local FPS_LABEL_BG_PADDING = 0.007
local FPS_LABEL_BG_ROUNDING = 0.006
local FPS_LABEL_FONT_SIZE = 0.016
local FPS_LABEL_TEXT_COLOR = Colors.WHITE
local FPS_LABEL_UPDATE_INTERVAL = 0.5

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_pending_spawn_door_name = ""
local m_loading_title = "Loading..."
local m_loading_background_texture = ""
local m_loading_font_id = ""

local m_fps_overlay_active = false
local m_fps_accum_time = 0.0
local m_fps_accum_frames = 0
local m_fps_label = "0 FPS"

local m_exterior_intro_pending = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NO_INTRO
local m_engine_boot_splash_consumed = false

-- Showcase hack for saving the loction of a few dynamic rocks in the exteror world before crossing into the cave.
local m_orb_arrival_movable_layout_for_cave_door = nil

------------------------------------------------
-- INTERFACE
------------------------------------------------

function GameModule.set_pending_spawn_door(t_door_name)
    m_pending_spawn_door_name = t_door_name
end

------------------------------------------------

function GameModule.get_pending_spawn_door()
    local door_name = m_pending_spawn_door_name
    m_pending_spawn_door_name = ""
    return door_name
end

------------------------------------------------

function GameModule.set_loading_screen(t_title, t_background_texture, t_font_id)
    m_loading_title = t_title
    m_loading_background_texture = t_background_texture
    m_loading_font_id = t_font_id
end

------------------------------------------------

function GameModule.get_fps_overlay_active()
    return settings_get_bool(UI_SETTINGS_SECTION, FPS_OVERLAY_SETTINGS_KEY, false)
end

------------------------------------------------

function GameModule.set_exterior_intro_pending_full()
    m_exterior_intro_pending = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NEW_GAME
end

------------------------------------------------

function GameModule.set_exterior_intro_pending_white_auto()
    m_exterior_intro_pending = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_LOOPBACK
end

------------------------------------------------

function GameModule.clear_exterior_intro_pending()
    m_exterior_intro_pending = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NO_INTRO
end

------------------------------------------------

function GameModule.take_exterior_intro_pending()
    local pending = m_exterior_intro_pending
    m_exterior_intro_pending = TheOrbWhiteFadeIntro.WHITE_FADE_INTRO_NO_INTRO
    return pending
end

------------------------------------------------

function GameModule.get_engine_boot_splash_pending()
    return not m_engine_boot_splash_consumed
end

------------------------------------------------

function GameModule.set_engine_boot_splash_consumed(t_consumed)
    m_engine_boot_splash_consumed = t_consumed == true
end

------------------------------------------------

function GameModule.set_orb_arrival_movable_layout_for_cave_door(t_layout)
    -- @TODO: Showcase hack. Seesion memory only.
    -- Replace with a proper save system later. 
    if type(t_layout) ~= "table" then
        print_error("[GameModule] set_orb_arrival_movable_layout_for_cave_door requires a layout table.")
        return
    end
    m_orb_arrival_movable_layout_for_cave_door = t_layout
end

------------------------------------------------

function GameModule.take_orb_arrival_movable_layout_for_cave_door()
    local layout = m_orb_arrival_movable_layout_for_cave_door
    m_orb_arrival_movable_layout_for_cave_door = nil
    return layout
end

------------------------------------------------

function GameModule.clear_orb_arrival_movable_layout_for_cave_door()
    m_orb_arrival_movable_layout_for_cave_door = nil
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function GameModule.on_process(t_delta_time)
    m_fps_overlay_active = settings_get_bool(UI_SETTINGS_SECTION, FPS_OVERLAY_SETTINGS_KEY, false)
    if not m_fps_overlay_active then
        m_fps_accum_time = 0.0
        m_fps_accum_frames = 0
        return
    end

    m_fps_accum_time = m_fps_accum_time + t_delta_time
    m_fps_accum_frames = m_fps_accum_frames + 1
    if m_fps_accum_time >= FPS_LABEL_UPDATE_INTERVAL then
        local fps = m_fps_accum_frames / m_fps_accum_time
        m_fps_label = string.format("%.0f FPS", fps)
        m_fps_accum_time = 0.0
        m_fps_accum_frames = 0
    end
end

------------------------------------------------

function GameModule.on_draw(_t_delta_time)
    -- Loading screen
    if world_get_is_loading() then
        if not gui_begin_screen_canvas("loading_screen", UiWidgets.CANVAS_OVERLAY) then
            return
        end

        local ui = gui_get_layout_size()
        gui_draw_rect(vec2(0.0, 0.0), ui, Colors.BLACK)

        if m_loading_background_texture ~= "" then
            gui_draw_image(m_loading_background_texture, vec2(0.0, 0.0), ui, Colors.WHITE)
        end

        gui_draw_text_aligned(
            m_loading_title,
            vec2(0.0, 0.0),
            ui,
            GuiAlignH.CENTER,
            GuiAlignV.MIDDLE,
            LOADING_SCREEN_UI_FONT_SIZE,
            vec4(1.0, 0.0, 0.0, 1.0),
            m_loading_font_id)

        gui_end_screen_canvas()
        return
    end

    -- FPS overlay. 
    if not m_fps_overlay_active then
        return
    end

    if not gui_begin_screen_canvas("game_fps_overlay", UiWidgets.CANVAS_OVERLAY) then
        return
    end

    local ui_size = gui_get_layout_size()
    local fps_margin = gui_get_normalized_to_uniform_size(FPS_LABEL_MARGIN)
    local fps_pad = gui_get_normalized_to_pixels(FPS_LABEL_BG_PADDING)
    local fps_rounding = gui_get_normalized_to_pixels(FPS_LABEL_BG_ROUNDING)
    local fps_font_size = gui_get_normalized_to_pixels(FPS_LABEL_FONT_SIZE)
    local fps_text_size = gui_get_text_size(m_fps_label, fps_font_size)
    local fps_box_size = vec2(fps_text_size.x + fps_pad * 2.0, fps_text_size.y + fps_pad * 2.0)
    local fps_pos = vec2(gui_get_layout_size().x - fps_box_size.x - fps_margin.x, fps_margin.y)
    local fps_box_pos = gui_get_anchored_rect(fps_pos, 
                                            ui_size,
                                            vec2(0.0, 0.0),
                                            vec2(0.0, 0.0),
                                            vec2(0.0, 0.0),
                                            fps_box_size,
                                            vec2(fps_margin.x, fps_margin.y))

    gui_draw_rect_rounded(fps_box_pos, 
                        fps_box_size, 
                        fps_rounding, 
                        FPS_LABEL_BG_COLOR)
    
    gui_draw_text_aligned(m_fps_label,
                        fps_box_pos,
                        fps_box_size,
                        GuiAlignH.CENTER,
                        GuiAlignV.MIDDLE,
                        fps_font_size,
                        FPS_LABEL_TEXT_COLOR)

    gui_end_screen_canvas()
end

------------------------------------------------

return GameModule
