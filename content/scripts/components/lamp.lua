local Lamp = {}

----------------------------------------------------
-- PARAMETERS
----------------------------------------------------

--@PARAMETER lit BOOL true "Initial lamp state (lit or unlit)."
--@PARAMETER can_interact BOOL true "Can player interact with this lamp."
--@PARAMETER interaction_distance FLOAT 2.0 "Distance at which player can interact."
--@PARAMETER lights_entity ENTITY "" "Child or descendant Light/Mesh container. Drop this entity for self. Empty is none."
--@PARAMETER fade_duration FLOAT 0.3 "Seconds to fade lights/emissive on/off when toggling. 0 for instant."
--@PARAMETER flicker BOOL false "Enable light flickering effect."
--@PARAMETER flicker_preset STRING "flicker_1" "Flicker pattern preset." OPTIONS[flicker_1,slow_strong_pulse,candle_1,fast_strobe,gentle_pulse,flicker_2,candle_2,candle_3,slow_strobe,fluorescent_flicker,slow_pulse,torch,fireplace,oil_lamp,Custom]
--@PARAMETER flicker_custom_pattern STRING "detisengineisawesome" "Custom flicker pattern (a=dim, m=normal, z=bright). Only used when preset is Custom."
--@PARAMETER flicker_speed FLOAT 10.0 "Pattern playback speed in Hz."
--@PARAMETER flicker_smoothness FLOAT 0.5 "Smoothness of transitions (0=instant, 1=very smooth)" 0.0 1.0
--@PARAMETER flicker_random_offset BOOL true "Randomize starting position in pattern."

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local EMISSIVE_UNIFORM = "u_emissive_multiplier"

-- Flicker pattern presets. Quake 3 style.
local FLICKER_PRESETS = {
    flicker_1 = "mmnmmommommnonmmonqnmmo",
    slow_strong_pulse = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba",
    candle_1 = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg",
    fast_strobe = "mamamamamama",
    gentle_pulse = "jklmnopqrstuvwxyzyxwvutsrqponmlkj",
    flicker_2 = "nmonqnmomnmomomno",
    candle_2 = "mmmaaaabcdefgmmmmaaaammmaamm",
    candle_3 = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa",
    slow_strobe = "aaaaaaaazzzzzzzz",
    fluorescent_flicker = "mmamammmmammamamaaamammma",
    slow_pulse = "abcdefghijklmnopqrrqponmlkjihgfedcba",
    torch = "mmnmmommommnonmmonqnmmommmmrmmomommmnonmmonqnmmomnmmmnommomqnmmommmonnmmmqnmmommmnomm",
    fireplace = "ztmztrrmtttmrzzmzzmmzmrmtmtmtrmrmrzzmzmzkkmmrrmtrmjtjrthmktrtzmmzmrtzmmzmzmrtmmz",
    oil_lamp = "mmmmnmlmmmmmnmlmmmmmmnmmmmmmnlmmmmmnmlmmmmmnmmmmmmnmlmmmmmnlmmmmmmnmlmmmmm"
}

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_light_entity_ids = {}
-- { entity_id = number, default_emissive = number }
local m_emissive_meshes = {}
local m_fade_t = 1.0
local m_fade_target = 1.0
local m_fade_speed = 0.0
local m_flicker_time = 0.0
local m_flicker_index = 0
local m_flicker_current_value = 1.0
local m_flicker_target_value = 1.0
local m_flicker_pattern_values = {}
local m_flicker_pattern_length = 0
local m_flicker_start_offset = 0
local m_flicker_lerp_factor = 0.0
local m_flicker_smoothness = 0.5
local m_flicker_enabled = false
local m_flicker_speed = 10.0
local m_brightness_multiplier = 1.0
local m_lit = true

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function collect_controlled_entities_recursive(t_entity_id)
    if not entity_get_is_valid(t_entity_id) then
        return
    end

    -- Collect the light entity ids.
    if entity_get_has_light_component(t_entity_id) then
        m_light_entity_ids[#m_light_entity_ids + 1] = t_entity_id
    end

    -- Collect the emissive mesh ids.
    if entity_get_has_mesh_component(t_entity_id) then
        -- Keep a unique editor copy. 
        if not mesh_get_is_unique_material(t_entity_id) then
            mesh_set_unique_material(t_entity_id, true)
        end
        -- Store the default emissive value.
        local default_emissive = mesh_get_uniform_float(t_entity_id, EMISSIVE_UNIFORM)
        m_emissive_meshes[#m_emissive_meshes + 1] = {
            entity_id = t_entity_id,
            default_emissive = default_emissive,
        }
    end

    -- Loop to collect the inherited entities. 
    local children_count = entity_get_children_count(t_entity_id)
    for child_index = 1, children_count do
        collect_controlled_entities_recursive(entity_get_child_by_index(t_entity_id, child_index))
    end
end

----------------------------------------------------

local function get_brightness_mul()
    local flicker_value = m_flicker_enabled and m_flicker_current_value or 1.0
    return m_brightness_multiplier * m_fade_t * flicker_value
end

----------------------------------------------------

local function apply_visuals()
    local brightness_mul = get_brightness_mul()

    -- Dim the lights with the same fade and flicker as the light.
    for _, light_id in ipairs(m_light_entity_ids) do
        if entity_get_is_valid(light_id) and entity_get_has_light_component(light_id) then
            light_set_lumens(light_id, light_get_default_lumens(light_id) * brightness_mul)
        end
    end

    -- Dim the emissive meshes with the same fade and flicker as the light.
    for _, mesh_info in ipairs(m_emissive_meshes) do
        local mesh_id = mesh_info.entity_id
        if entity_get_is_valid(mesh_id) and entity_get_has_mesh_component(mesh_id) then
            mesh_set_uniform_float(mesh_id, EMISSIVE_UNIFORM, mesh_info.default_emissive * brightness_mul)
        end
    end
end

----------------------------------------------------

local function rebuild_flicker_pattern(t_pattern)
    -- Initialize the flicker pattern values.
    m_flicker_pattern_values = {}

    -- Loop to convert the pattern to normalized values.
    local byte_a = string.byte("a")
    for i = 1, #t_pattern do
        local char_code = string.byte(t_pattern, i)
        -- Convert the character code to a normalized value.
        local normalized = (char_code - byte_a) / 25.0
        -- Scale the normalized value to 2.0 (a=0.0, m=1.0, z=2.0).
        m_flicker_pattern_values[i] = normalized * 2.0
    end

    -- Calculate the length of the flicker pattern.
    m_flicker_pattern_length = #m_flicker_pattern_values

    -- If the pattern is empty disable flicker.
    if m_flicker_pattern_length == 0 then
        print_warning("[Lamp] Flicker pattern is empty. Disabling flicker.")
        m_flicker_enabled = false
    end

    -- Calculate the lerp factor for the flicker.
    m_flicker_lerp_factor = (1.0 - m_flicker_smoothness) * 20.0
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

function Lamp.set_lit(t_lit)
    m_lit = t_lit == true
    m_fade_target = m_lit and 1.0 or 0.0
end

----------------------------------------------------

function Lamp.toggle_lit()
    Lamp.set_lit(not m_lit)
end

----------------------------------------------------

function Lamp.get_is_lit()
    return m_lit
end

----------------------------------------------------

function Lamp.set_brightness_multiplier(t_multiplier)
    m_brightness_multiplier = t_multiplier
    apply_visuals()
end

----------------------------------------------------

function Lamp.set_flicker(t_enabled)
    m_flicker_enabled = t_enabled == true
    if not m_flicker_enabled then
        m_flicker_current_value = 1.0
        apply_visuals()
    end
end

----------------------------------------------------

function Lamp.set_flicker_preset(t_preset_name)
    -- Get the flicker pattern for the preset name.
    local flicker_pattern = FLICKER_PRESETS[t_preset_name]
    if not flicker_pattern then
        print_warning("[Lamp] Preset '" .. tostring(t_preset_name) .. "' not found.")
        return
    end

    -- Set the preset name and rebuild the flicker pattern.
    flicker_preset = t_preset_name
    rebuild_flicker_pattern(flicker_pattern)
end

----------------------------------------------------

function Lamp.get_can_interact()
    if can_interact == nil then
        return true
    end
    return can_interact == true
end

----------------------------------------------------

function Lamp.get_interaction_distance()
    return interaction_distance
end

----------------------------------------------------

function Lamp.get_interact_label()
    if m_lit then
        return "Extinguish"
    end
    return "Ignite"
end

----------------------------------------------------
-- CALLBACKS
----------------------------------------------------

function Lamp.on_interact(t_is_pressed, _t_instigator_entity_id)
    if not t_is_pressed then
        return
    end

    if not Lamp.get_can_interact() then
        return
    end

    Lamp.toggle_lit()
end

----------------------------------------------------
-- LIFECYCLE
----------------------------------------------------

function Lamp.on_initialize()
    m_light_entity_ids = {}
    m_emissive_meshes = {}

    -- Get the lights entity path and collect the controlled entities.
    local lights_entity_path = file_manager_get_trimmed_string(lights_entity ~= nil and lights_entity or "")
    if lights_entity_path ~= "" then
        local container_id = entity_id
        if lights_entity_path ~= "." then
            container_id = entity_get_child_by_path(entity_id, lights_entity_path)
        end
        if not entity_get_is_valid(container_id) then
            print_warning("[Lamp] lights_entity not found: '" .. lights_entity_path .. "' on entity '" .. tostring(entity_get_name(entity_id)) .. "'.")
        else
            collect_controlled_entities_recursive(container_id)
        end
    end

    -- Initialize the flicker pattern.
    local flicker_pattern = nil
    if flicker_preset == "Custom" then
        flicker_pattern = flicker_custom_pattern
    else
        flicker_pattern = FLICKER_PRESETS[flicker_preset]
        if not flicker_pattern then
            print_warning("[Lamp] Preset '" .. tostring(flicker_preset) .. "' not found.")
            flicker_pattern = "detisengineisawesome"
        end
    end

    -- Initialize the flicker start offset.
    if flicker_random_offset then
        m_flicker_start_offset = math.random(5, 25)
    end

    -- Initialize the brightness multiplier.
    m_brightness_multiplier = 1.0

    -- Initialize the flicker enabled state.
    m_flicker_enabled = flicker == true
    m_flicker_speed = flicker_speed ~= nil and flicker_speed or 10.0
    m_flicker_smoothness = math_clamp(flicker_smoothness ~= nil and flicker_smoothness or 0.5, 0.0, 1.0)

    -- Initialize the fade speed.
    local raw_fade_duration = fade_duration ~= nil and fade_duration or 0.3
    m_fade_speed = raw_fade_duration > 0.0001 and (1.0 / raw_fade_duration) or math.huge

    -- Rebuild the flicker pattern.
    rebuild_flicker_pattern(flicker_pattern)

    -- Set the initial lit state and snap to it with no fade animation.
    Lamp.set_lit(lit == true)
    m_fade_t = m_fade_target
    apply_visuals()
end

----------------------------------------------------

function Lamp.on_ready()
    if not entity_get_has_tag(entity_id, "interactable") then
        entity_add_tag(entity_id, "interactable")
    end
end

----------------------------------------------------

function Lamp.on_process(t_delta_time)
    -- Fade the lamp to the target state.
    if m_fade_t ~= m_fade_target then
        local step = m_fade_speed * t_delta_time
        if m_fade_target > m_fade_t then
            m_fade_t = math.min(m_fade_target, m_fade_t + step)
        else
            m_fade_t = math.max(m_fade_target, m_fade_t - step)
        end
    end

    -- Apply the flicker effect.

    -- Check if there are any visuals to apply the flicker effect to.
    local has_visuals = (#m_light_entity_ids > 0) or (#m_emissive_meshes > 0) --
    if m_flicker_enabled and has_visuals and m_flicker_pattern_length > 0 then

        -- Increment the flicker time.
        m_flicker_time = m_flicker_time + t_delta_time * m_flicker_speed

        -- Wrap the flicker time if it exceeds the pattern length.
        if m_flicker_time >= m_flicker_pattern_length then
            m_flicker_time = m_flicker_time - m_flicker_pattern_length
        end

        -- Calculate the new flicker index.
        local new_index = ((math.floor(m_flicker_time) + m_flicker_start_offset) % m_flicker_pattern_length) + 1
        if new_index ~= m_flicker_index then
            m_flicker_index = new_index
            -- Set the new flicker target value.
            m_flicker_target_value = m_flicker_pattern_values[m_flicker_index]
        end

        -- Set the current value to the target value.
        if m_flicker_smoothness == 0.0 then
            m_flicker_current_value = m_flicker_target_value
        -- Lerp the current value to the target value.
        else
            m_flicker_current_value = m_flicker_current_value + (m_flicker_target_value - m_flicker_current_value) * m_flicker_lerp_factor * t_delta_time
        end
    end

    apply_visuals()
end

----------------------------------------------------

function Lamp.on_shutdown()
    -- Write the captured editor unique emissive back before reload recaptures it.
    for _, mesh_info in ipairs(m_emissive_meshes) do
        local mesh_id = mesh_info.entity_id
        if entity_get_is_valid(mesh_id) and entity_get_has_mesh_component(mesh_id) then
            mesh_set_uniform_float(mesh_id, EMISSIVE_UNIFORM, mesh_info.default_emissive)
        end
    end
end

----------------------------------------------------

return Lamp
