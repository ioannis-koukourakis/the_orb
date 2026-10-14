local PushImpulseInteractable = {}

------------------------------------------------
-- PARAMETERS
------------------------------------------------

--@PARAMETER can_interact BOOL true "Can the player interact with this entity."
--@PARAMETER interaction_distance FLOAT 2.5 "Max interact distance."
--@PARAMETER interact_label STRING "Push" "HUD / interact label."
--@PARAMETER impulse_strength FLOAT 40.0 "Impulse magnitude along camera yaw forward."

------------------------------------------------
-- INTERFACE
------------------------------------------------

function PushImpulseInteractable.get_can_interact()
    return can_interact == true
end

------------------------------------------------

function PushImpulseInteractable.get_interaction_distance()
    return interaction_distance
end

------------------------------------------------

function PushImpulseInteractable.get_interact_label()
    return interact_label
end

------------------------------------------------

function PushImpulseInteractable.on_interact(t_is_pressed, t_instigator_entity_id)
    -- Check if the interaction is pressed.
    if not t_is_pressed then
        return
    end

    -- Check if the entity can be interacted with.
    if not PushImpulseInteractable.get_can_interact() then
        return
    end

    -- Get the camera.
    local camera_id = world_get_current_camera()
    if not entity_get_is_valid(camera_id) and entity_get_is_valid(t_instigator_entity_id) then
        camera_id = entity_get_child_by_name(t_instigator_entity_id, "camera")
    end

    -- Check if the camera is valid.
    if not entity_get_is_valid(camera_id) then
        print_error("[PushImpulseInteractable] No valid camera for push direction.")
        return
    end

    -- Get the forward direction.
    local forward = transform_get_world_forward(camera_id)

    -- Skip pitch so looking up/down does not lift the body.
    forward = vec3(forward.x, 0.0, forward.z)
    local length = vec3_length(forward)
    if length < 0.0001 then
        return
    end

    -- Normalize forward dir.
    forward = vec3_mul(forward, 1.0 / length)

    -- Check if the impulse strength is valid.
    if impulse_strength <= 0.0 then
        print_error("[PushImpulseInteractable] impulse_strength must be > 0.")
        return
    end

    -- Apply the impulse.
    dynamic_body_apply_central_impulse(entity_id, vec3_mul(forward, impulse_strength))
end

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function PushImpulseInteractable.on_ready()
    if not entity_get_has_tag(entity_id, "interactable") then
        entity_add_tag(entity_id, "interactable")
    end
end

------------------------------------------------

return PushImpulseInteractable
