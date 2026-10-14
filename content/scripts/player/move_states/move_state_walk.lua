local StateMachine = dofile("../content/scripts/shared/state_machine.lua")
local PlayerMovement = dofile("../content/scripts/player/player_movement.lua")

local MoveStateWalk = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

local SPRINT_TRANSITION_SPEED = 1.0

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function MoveStateWalk.on_fixed_process(t_delta_time, t_context)
    -- If the player cannot walk, change to idle state.
    if not t_context.can_walk then
        StateMachine.change_state(t_context, "idle")
        return
    end

    -- If the player is not on the ground, change to fall state.
    if not t_context.is_on_ground then
        StateMachine.change_state(t_context, "fall")
        return
    end

    -- If the player has no input, change to idle state.
    local input_direction = PlayerMovement.get_move_input(t_context)
    if not PlayerMovement.get_wants_to_move(vec3_length(input_direction)) then
        StateMachine.change_state(t_context, "idle")
        return
    end

    -- Crouch uses a fixed speed scale. Standing blends walk and sprint.
    local speed_multiplier = t_context.crouch_speed_multiplier
    if not t_context.is_crouching then
        -- Update the speed multiplier.
        local target_multiplier = t_context.is_sprinting and t_context.sprint_multiplier or 1.0
        PlayerMovement.update_speed_multiplier(t_context, target_multiplier, t_delta_time, SPRINT_TRANSITION_SPEED)
        speed_multiplier = t_context.current_speed_multiplier
    end

    -- Apply camera-relative ground movement.
    PlayerMovement.apply_ground_move(t_context, t_delta_time, input_direction, speed_multiplier)
end

------------------------------------------------

return MoveStateWalk
