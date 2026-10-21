local OrbCaveOneShotEvents = {}

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local GAME_MODULE_NAME = "game_module"

local WIND_EVENT_ENTITY_NAME = "wind_event"
local WIND_TRIGGER_ENTITY_NAME = "trigger"
local PAPER_PARTICLE_ENTITY_NAME = "paper_particle_1shot"
local WIND_PARTICLE_ENTITY_NAME = "wind_particle_1shot"
local WIND_SOUND_ENTITY_NAME = "snd_wind_blast"

local REVEAL_STINGER_TRIGGER_ENTITY_NAME = "trigger_alien_sphere_reveal_stinger"
local REVEAL_STINGER_SOUND_PATH = "sound/snd_reveal_stinger"
local REVEAL_STINGER_SOUND_ENTITY_NAME = "snd_reveal_stinger"
local REVEAL_STINGER_FADE_DURATION = 0.03

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_wind_event_entity_id = 0
local m_wind_trigger_entity_id = 0
local m_paper_particle_entity_id = 0
local m_wind_particle_entity_id = 0
local m_wind_sound_entity_id = 0

local m_reveal_stinger_sound_entity_id = 0
local m_reveal_stinger_trigger_entity_id = 0

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function get_wind_event_child_entity_id(t_child_name, t_missing_warning)
    local child_entity_id = entity_get_child_by_name(m_wind_event_entity_id, t_child_name)
    if not entity_get_is_valid(child_entity_id) then
        print_warning(t_missing_warning)
        return 0
    end

    return child_entity_id
end

----------------------------------------------------

local function play_particle_system(t_entity_id)
    if not entity_get_is_valid(t_entity_id) or not entity_get_has_particle_system_component(t_entity_id) then
        return
    end

    particle_system_play(t_entity_id)
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function OrbCaveOneShotEvents.setup_one_shot_events()
    -- Find the wind event entity.
    m_wind_event_entity_id = world_get_entity_by_name(WIND_EVENT_ENTITY_NAME)
    if not entity_get_is_valid(m_wind_event_entity_id) then
        print_warning("[OrbCaveOneShotEvents] wind_event was not found.")
        m_wind_event_entity_id = 0
    
    -- Find the wind event entities.
    else
        m_wind_trigger_entity_id = get_wind_event_child_entity_id(WIND_TRIGGER_ENTITY_NAME, "[OrbCaveOneShotEvents] wind_event trigger was not found.")
        if entity_get_is_valid(m_wind_trigger_entity_id) then
            physics_body_set_trigger_callbacks_enabled(m_wind_trigger_entity_id, true)
        end

        m_paper_particle_entity_id = get_wind_event_child_entity_id(PAPER_PARTICLE_ENTITY_NAME, "[OrbCaveOneShotEvents] paper_particle_1shot was not found.")
        if entity_get_is_valid(m_paper_particle_entity_id) and not entity_get_has_particle_system_component(m_paper_particle_entity_id) then
            print_warning("[OrbCaveOneShotEvents] paper_particle_1shot has no particle system.")
            m_paper_particle_entity_id = 0
        end

        m_wind_particle_entity_id = get_wind_event_child_entity_id(WIND_PARTICLE_ENTITY_NAME, "[OrbCaveOneShotEvents] wind_particle_1shot was not found.")
        if entity_get_is_valid(m_wind_particle_entity_id) and not entity_get_has_particle_system_component(m_wind_particle_entity_id) then
            print_warning("[OrbCaveOneShotEvents] wind_particle_1shot has no particle system.")
            m_wind_particle_entity_id = 0
        end

        m_wind_sound_entity_id = get_wind_event_child_entity_id(WIND_SOUND_ENTITY_NAME, "[OrbCaveOneShotEvents] snd_wind_blast was not found.")
        if entity_get_is_valid(m_wind_sound_entity_id) and not entity_get_has_sound_component(m_wind_sound_entity_id) then
            print_warning("[OrbCaveOneShotEvents] snd_wind_blast has no sound component.")
            m_wind_sound_entity_id = 0
        end
    end

    local orb_entity_id = world_get_entity_by_name("alien_sphere")
    -- Find the orb reveal stinger sound entity.
    m_reveal_stinger_sound_entity_id = 0
    if entity_get_is_valid(orb_entity_id) then
        m_reveal_stinger_sound_entity_id = entity_get_child_by_path(orb_entity_id, REVEAL_STINGER_SOUND_PATH)
        if not entity_get_is_valid(m_reveal_stinger_sound_entity_id) then
            m_reveal_stinger_sound_entity_id = entity_get_child_by_name(orb_entity_id, REVEAL_STINGER_SOUND_ENTITY_NAME)
        end
    end
    if not entity_get_is_valid(m_reveal_stinger_sound_entity_id)
        or not entity_get_has_sound_component(m_reveal_stinger_sound_entity_id) then
        print_warning("[OrbCaveOneShotEvents] Alien sphere snd_reveal_stinger was not found.")
        m_reveal_stinger_sound_entity_id = 0
    end

    m_reveal_stinger_trigger_entity_id = world_get_entity_by_name(REVEAL_STINGER_TRIGGER_ENTITY_NAME)
    if not entity_get_is_valid(m_reveal_stinger_trigger_entity_id) then
        print_warning("[OrbCaveOneShotEvents] trigger_orb_reveal_stinger was not found.")
        m_reveal_stinger_trigger_entity_id = 0
    else
        physics_body_set_trigger_callbacks_enabled(m_reveal_stinger_trigger_entity_id, true)
    end
end

----------------------------------------------------

function OrbCaveOneShotEvents.get_reveal_stinger_sound_entity_id()
    return m_reveal_stinger_sound_entity_id
end

----------------------------------------------------

function OrbCaveOneShotEvents.on_overlap(t_trigger_entity_id, t_enter)
    -- Check the wind blast trigger.
    local is_wind_trigger = entity_get_is_valid(m_wind_trigger_entity_id) and t_trigger_entity_id == m_wind_trigger_entity_id
    local is_reveal_trigger = entity_get_is_valid(m_reveal_stinger_trigger_entity_id) and t_trigger_entity_id == m_reveal_stinger_trigger_entity_id
    if not is_wind_trigger and not is_reveal_trigger then
        return false
    end

    if not t_enter then
        return true
    end

    -- Game module holds the session flags.
    if not module_get_is_valid(GAME_MODULE_NAME) then
        print_error("[OrbCaveOneShotEvents] game_module is not loaded.")
        return true
    end

    -- Particles and sound play once per play session.
    if is_wind_trigger then
        if module_call_function(GAME_MODULE_NAME, "get_orb_cave_wind_event_has_played") == true then
            return true
        end

        module_call_function(GAME_MODULE_NAME, "set_orb_cave_wind_event_has_played", true)
        play_particle_system(m_paper_particle_entity_id)
        play_particle_system(m_wind_particle_entity_id)
        if entity_get_is_valid(m_wind_sound_entity_id) then
            sound_play(m_wind_sound_entity_id, 0.0)
        end
        return true
    end

    -- Play the orb reveal stinger once per play pass.
    if module_call_function(GAME_MODULE_NAME, "get_orb_cave_reveal_stinger_has_played") == true then
        return true
    end

    if not entity_get_is_valid(m_reveal_stinger_sound_entity_id)
        or not entity_get_has_sound_component(m_reveal_stinger_sound_entity_id) then
        return true
    end

    module_call_function(GAME_MODULE_NAME, "set_orb_cave_reveal_stinger_has_played", true)
    sound_play(m_reveal_stinger_sound_entity_id, REVEAL_STINGER_FADE_DURATION)
    return true
end

----------------------------------------------------

return OrbCaveOneShotEvents
