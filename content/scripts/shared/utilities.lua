local Utilities = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------
---
local SOUND_CATEGORY_COUNT = 4

------------------------------------------------
-- SCRIPT COMPONENTS
------------------------------------------------

--- Checks if an entity has a script component.
--- @param t_entity_id The ID of the entity to check.
--- @return True if the entity has a script component, false otherwise.
function Utilities.get_entity_has_script_component(t_entity_id)
    if not entity_get_is_valid(t_entity_id) then
        return false
    end

    return entity_get_has_script_component(t_entity_id)
end

------------------------------------------------

--- Checks if an entity has a specific script function.
--- @param t_entity_id The ID of the entity to check.
--- @param t_function_name The name of the script function to check for.
--- @return True if the entity has the specified script function, false otherwise.
function Utilities.get_entity_has_script_function(t_entity_id, t_function_name)
    if t_function_name == nil or t_function_name == "" then
        return false
    end

    if not Utilities.get_entity_has_script_component(t_entity_id) then
        return false
    end

    return entity_get_function(t_entity_id, t_function_name) ~= nil
end

------------------------------------------------
-- SOUND
------------------------------------------------

--- Sets the mix multiplier for all sound categories.
--- @param t_multiplier The multiplier to set for all sound categories.
function Utilities.sound_set_all_category_mix_multiplier(t_multiplier)
    for category_index = 0, SOUND_CATEGORY_COUNT - 1 do
        sound_set_category_mix_multiplier(category_index, t_multiplier)
    end
end

------------------------------------------------

return Utilities
