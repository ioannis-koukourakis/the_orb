local TheOrbMainMenuWorld = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local LogoSplash = dofile("../content/scripts/shared/logo_splash.lua")
local GammaCalibration = dofile("../content/scripts/worlds/demo_content/the_orb/the_orb_main_menu/gamma_calibration.lua")
local Utilities = dofile("../content/scripts/shared/utilities.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local MAIN_MENU_MODULE_NAME = "MainMenuModule"
local CAMERA_EFFECTS_MODULE_NAME = "CameraEffectsModule"
local GAME_MODULE_NAME = "game_module"

local MAIN_MENU_MUSIC_PATH = "../content/music/main_menu_theme_loop.ogg"
local MAIN_MENU_MUSIC_FADE_IN = 2.0

local MAIN_MENU_WORLD_FADE_IN_TIME = 3.0

local BOOT_SPLASH_LOGO_PATHS = {
    "../engine/graphics/company_logo_label.png",
    "../content/graphics/detis_engine_logo.png",
}
local BOOT_SPLASH_BLACK = vec3(0.0, 0.0, 0.0)

local BOOT_STATE_SPLASH = 0
local BOOT_STATE_GAMMA = 1
local BOOT_STATE_TITLE = 2

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_menu_camera_entity_id = 0
local m_boot_state = BOOT_STATE_TITLE
local m_gamma_return_to_title = false
local m_menu_sound_fade_is_active = false

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function begin_title_menu()
    m_boot_state = BOOT_STATE_TITLE

    -- UI state setup.
    module_call_function(MAIN_MENU_MODULE_NAME, "set_pause_menu_active", false)
    module_call_function(MAIN_MENU_MODULE_NAME, "set_title_menu_screen_active", true)
    module_call_function(MAIN_MENU_MODULE_NAME, "set_menu_open", true)

    -- Menu buttons are on screen.
    if get_game_mode_active() then
        input_set_mouse_capture(false)
    end

    -- Music.
    if get_game_mode_active() then
        music_play(MAIN_MENU_MUSIC_PATH, true, MAIN_MENU_MUSIC_FADE_IN)
    end

    -- Fade From Black.
    module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                        "start_screen_fade",
                        1.0, -- Intensity.
                        BOOT_SPLASH_BLACK, -- Color.
                        0.0, -- Fade In Time.
                        0.0, -- Duration.
                        MAIN_MENU_WORLD_FADE_IN_TIME) -- Fade Out Time.
    
    -- Fade in all sounds as the black screen clears.
    m_menu_sound_fade_is_active = true
    Utilities.sound_set_all_category_mix_multiplier(0.0)
end

----------------------------------------------------

local function begin_gamma_calibration(t_return_to_title)
    -- Hold the title menu until the player confirms gamma.
    GammaCalibration.set_active(true)
    m_boot_state = BOOT_STATE_GAMMA
    m_gamma_return_to_title = t_return_to_title == true
    module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", true)

    -- If returning tothe menu from the gamma calibration screen,
    -- deactivate the title menu and menu open states so it can be resumed.
    if m_gamma_return_to_title then
        module_call_function(MAIN_MENU_MODULE_NAME, "set_title_menu_screen_active", false)
        module_call_function(MAIN_MENU_MODULE_NAME, "set_menu_open", false)
    end

    -- Capture the mouse.
    if get_game_mode_active() then
        input_set_mouse_capture(false)
    end

    -- If returning to the title menu, do not continue.
    if m_gamma_return_to_title then
        return
    end

    -- Stay quiet until the title fade. 
    -- @NOTE: The splash may already have muted the mix.
    m_menu_sound_fade_is_active = false
    Utilities.sound_set_all_category_mix_multiplier(0.0)
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function TheOrbMainMenuWorld.begin_gamma_calibration_from_menu()
    if m_boot_state ~= BOOT_STATE_TITLE then
        return
    end

    begin_gamma_calibration(true)
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function TheOrbMainMenuWorld.on_ready()
    -- Initialize splash state.
    m_boot_state = BOOT_STATE_TITLE
    m_gamma_return_to_title = false
    m_menu_sound_fade_is_active = false
    LogoSplash.set_active(false)
    if module_get_is_valid(MAIN_MENU_MODULE_NAME) then
        module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", false)
    end

    -- Menu Camera.
    m_menu_camera_entity_id = world_get_entity_by_name("menu_camera")
    if not entity_get_is_valid(m_menu_camera_entity_id) then
        print_error("[TheOrbMainMenuWorld] menu_camera entity was not found.")
    -- Sanitty check.
    elseif get_game_mode_active() then
        world_set_current_camera(m_menu_camera_entity_id)
    end

    -- Main menu module.
    if not module_get_is_valid(MAIN_MENU_MODULE_NAME) then
        print_error("[TheOrbMainMenuWorld] MainMenuModule is not valid.")
        return
    end

    -- Check if there is a pending logo splash to play.
    local splash_pending = false
    if get_game_mode_active() and module_get_is_valid(GAME_MODULE_NAME) then
        splash_pending = module_call_function(GAME_MODULE_NAME, "get_engine_boot_splash_pending") == true
    end

    -- Play pending logo splash.
    if splash_pending then
        module_call_function(GAME_MODULE_NAME, "set_engine_boot_splash_consumed", true)
        LogoSplash.set_logo_paths(BOOT_SPLASH_LOGO_PATHS)
        LogoSplash.set_active(true)
        m_boot_state = BOOT_STATE_SPLASH
        module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", true)
        m_menu_sound_fade_is_active = true
        Utilities.sound_set_all_category_mix_multiplier(0.0)
        module_call_function(CAMERA_EFFECTS_MODULE_NAME,
                            "start_screen_fade",
                            1.0,
                            BOOT_SPLASH_BLACK,
                            0.0,
                            -1.0,
                            0.0)
        return
    end

    -- First time we launch we ask for gamma once. All later launches skip this.
    if get_game_mode_active() and GammaCalibration.get_is_pending() then
        begin_gamma_calibration()
        return
    end

    -- If no splashes are pending, begin main menu. 
    begin_title_menu()
end

----------------------------------------------------

function TheOrbMainMenuWorld.on_process(t_delta_time)
    -- Process the logo splash and begin the main menu when it finishes.
    if m_boot_state == BOOT_STATE_SPLASH then
        LogoSplash.process(t_delta_time)
        if not LogoSplash.get_is_active() then
            module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", false)
            if get_game_mode_active() and GammaCalibration.get_is_pending() then
                begin_gamma_calibration()
            else
                begin_title_menu()
            end
        end
    
    -- Gamma calibration screen.
    elseif m_boot_state == BOOT_STATE_GAMMA then
        GammaCalibration.process(t_delta_time)
        if not GammaCalibration.get_is_active() then
            module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", false)

            -- Resume the title menu.
            if m_gamma_return_to_title then
                m_gamma_return_to_title = false
                m_boot_state = BOOT_STATE_TITLE
                module_call_function(MAIN_MENU_MODULE_NAME, "set_pause_menu_active", false)
                module_call_function(MAIN_MENU_MODULE_NAME, "set_title_menu_screen_active", true)
                module_call_function(MAIN_MENU_MODULE_NAME, "set_menu_open", true)
            -- Otherwise, begin the title menu.
            else
                begin_title_menu()
            end
        end
    end

    -- Fade in the menu sound as the black screen clears.
    if not m_menu_sound_fade_is_active then
        return
    end

    local fade_intensity = module_call_function(CAMERA_EFFECTS_MODULE_NAME, "get_screen_fade")
    if type(fade_intensity) ~= "number" then
        fade_intensity = 0.0
    end
    Utilities.sound_set_all_category_mix_multiplier(1.0 - fade_intensity)
    if m_boot_state ~= BOOT_STATE_SPLASH and fade_intensity <= 0.0 then
        m_menu_sound_fade_is_active = false
    end
end

----------------------------------------------------

function TheOrbMainMenuWorld.on_draw(_t_delta_time)
    -- Draw the logo splash.
    if m_boot_state == BOOT_STATE_SPLASH then
        LogoSplash.draw()
    -- Draw the gamma calibration screen.
    elseif m_boot_state == BOOT_STATE_GAMMA then
        GammaCalibration.draw()
    end
end

----------------------------------------------------

function TheOrbMainMenuWorld.on_shutdown()
    m_boot_state = BOOT_STATE_TITLE
    m_gamma_return_to_title = false
    m_menu_sound_fade_is_active = false
    LogoSplash.set_active(false)
    GammaCalibration.set_active(false)
    if module_get_is_valid(MAIN_MENU_MODULE_NAME) then
        module_call_function(MAIN_MENU_MODULE_NAME, "set_boot_splash_active", false)
    end

    -- Stop any ongoing music when shutting down the main menu world.
    if get_game_mode_active() then
        music_stop(0.0)
    end

    -- Deactivate the main menu module.
    if module_get_is_valid(MAIN_MENU_MODULE_NAME) then
        module_call_function(MAIN_MENU_MODULE_NAME, "set_title_menu_screen_active", false)
        module_call_function(MAIN_MENU_MODULE_NAME, "set_menu_open", false)
        module_call_function(MAIN_MENU_MODULE_NAME, "set_pause_menu_active", false)
    end

    -- Restore cursor capture. 
    if get_game_mode_active() then
        input_set_mouse_capture(true)
    end
end

----------------------------------------------------

return TheOrbMainMenuWorld
