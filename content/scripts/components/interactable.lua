local Interactable = {}

------------------------------------------------
-- PARAMETERS
------------------------------------------------

--@PARAMETER can_interact BOOL true "Can player interact with this entity."
--@PARAMETER interaction_distance FLOAT 2.5 "Distance at which player can interact."
--@PARAMETER interact_label STRING "Interact" "HUD label shown when this entity is targeted."

------------------------------------------------
-- INTERFACE
------------------------------------------------

function Interactable.get_can_interact()
    return can_interact
end

------------------------------------------------

function Interactable.get_interaction_distance()
    return interaction_distance
end

------------------------------------------------

function Interactable.get_interact_label()
    return interact_label
end

------------------------------------------------

function Interactable.on_interact(t_is_pressed, t_instigator_entity_id)
    if not t_is_pressed then
        return
    end

    print_info("[Interactable] '" .. tostring(entity_get_name(entity_id)) .. "' interacted.")
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function Interactable.on_ready()
    if not entity_get_has_tag(entity_id, "interactable") then
        entity_add_tag(entity_id, "interactable")
    end
end

------------------------------------------------

return Interactable
