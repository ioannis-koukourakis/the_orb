local StateMachine = dofile("../content/scripts/shared/state_machine.lua")
local PlayerMovement = dofile("../content/scripts/player/player_movement.lua")

local MoveStateFall = {}

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function MoveStateFall.on_fixed_process(t_delta_time, t_context)
    -- If the player is on the ground, change to land state.
    if t_context.is_on_ground then
        StateMachine.change_state(t_context, "land")
        return
    end

    -- Deacceleration
    local air_deceleration = 0.5
    PlayerMovement.apply_horizontal_deceleration(t_context, t_delta_time, air_deceleration)

    -- Any attempt for movement?
    local input_direction = PlayerMovement.get_move_input(t_context)
    if not PlayerMovement.get_wants_to_move(vec3_length(input_direction)) then
        return
    end
    
    -- Add some air control mostly so we don't get stuck. 
    PlayerMovement.apply_ground_move(t_context, t_delta_time, input_direction, 1.0)
end

------------------------------------------------

return MoveStateFall
