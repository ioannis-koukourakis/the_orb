local LoadingDoor = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local GAME_MODULE = "game_module"

------------------------------------------------
-- PARAMETERS
------------------------------------------------

--@PARAMETER can_interact BOOL true "Can player interact with this entity."
--@PARAMETER interaction_distance FLOAT 3.0 "Distance at which player can interact."
--@PARAMETER target_world FILE "" "World file to load." FILTER[World files{.world},.*]
--@PARAMETER target_door STRING "" "Named door in the destination world. Player spawns at its spawn child when present."
--@PARAMETER loading_title STRING "Loading..." "Title drawn on the loading screen."
--@PARAMETER loading_background FILE "" "Optional fullscreen loading image." FILTER[Image files{.dds,.png,.jpg,.jpeg,.tga},.*]
--@PARAMETER loading_font STRING "" "Font id from fonts.ini. Empty uses the default UI font."

------------------------------------------------
-- INTERFACE
------------------------------------------------

function LoadingDoor.get_can_interact()
    return can_interact == true
end

------------------------------------------------

function LoadingDoor.get_interaction_distance()
    return interaction_distance
end

------------------------------------------------

function LoadingDoor.get_interact_label()
    return "Enter"
end

------------------------------------------------
-- CALLBACKS
------------------------------------------------

function LoadingDoor.on_interact(t_is_pressed, _t_instigator_entity_id)
    -- Only check the button press. 
    if not t_is_pressed then
        return
    end

    -- Check if the door can be interacted with.
    if not LoadingDoor.get_can_interact() then
        return
    end

    -- Is a target world assigned?
    if type(target_world) ~= "string" or target_world == "" then
        print_error("[LoadingDoor] Cannot load world: no target world specified.")
        return
    end

    -- Get the destination door name. Empty keeps the map player spawn. 
    local spawn_door_name = ""
    if type(target_door) == "string" then
        spawn_door_name = target_door
    end

    -- Is the game module loaded?
    if module_get_is_valid(GAME_MODULE) then
        -- Get the loading screen data.
        local title = "Loading..."
        if type(loading_title) == "string" then
            title = loading_title
        end

        local background = ""
        if type(loading_background) == "string" then
            background = loading_background
        end

        local font = ""
        if type(loading_font) == "string" then
            font = loading_font
        end

        -- Set the loading screen data.
        module_call_function(GAME_MODULE, "set_pending_spawn_door", spawn_door_name)
        module_call_function(GAME_MODULE, "set_loading_screen", title, background, font)
    
    -- The game module is not loaded. Use the engine loading screen.
    else
        print_error("[LoadingDoor] game_module is not loaded. Using the engine loading screen.")
    end

    -- Load the target world.
    local success = world_load_from_file(target_world)
    if not success then
        print_error("[LoadingDoor] Failed to load world: " .. tostring(target_world))
    end
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function LoadingDoor.on_ready()
    -- Add the interactable tag if it is not already present.
    if not entity_get_has_tag(entity_id, "interactable") then
        entity_add_tag(entity_id, "interactable")
    end
end

------------------------------------------------

return LoadingDoor
