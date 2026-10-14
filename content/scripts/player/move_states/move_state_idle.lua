local StateMachine = dofile("../content/scripts/shared/state_machine.lua")
local PlayerMovement = dofile("../content/scripts/player/player_movement.lua")

local MoveStateIdle = {}

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function MoveStateIdle.on_fixed_process(t_delta_time, t_context)
    -- If the player is not on the ground, change to fall state.
    if not t_context.is_on_ground then
        StateMachine.change_state(t_context, "fall")
        return
    end

    -- If the player has input, change to walk state.
    if PlayerMovement.get_has_move_input(t_context) then
        StateMachine.change_state(t_context, "walk")
        return
    end

    -- Decelerate the horizontal velocity.
    PlayerMovement.apply_horizontal_deceleration(t_context, t_delta_time, t_context.deceleration)
end

------------------------------------------------

return MoveStateIdle
