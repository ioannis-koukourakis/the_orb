local MoveStateLand = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local StateMachine = dofile("../content/scripts/shared/state_machine.lua")
local PlayerMovement = dofile("../content/scripts/player/player_movement.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

local LAND_DURATION = 0.12

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_land_timer = 0.0

------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function MoveStateLand.on_enter(t_previous_state_name, t_context)
    m_land_timer = 0.0
end

------------------------------------------------

function MoveStateLand.on_fixed_process(t_delta_time, t_context)
    m_land_timer = m_land_timer + t_delta_time

    -- If the player is not on the ground, change to fall state.
    if not t_context.is_on_ground then
        StateMachine.change_state(t_context, "fall")
        return
    end

    -- Check if the player has input.
    local has_input = PlayerMovement.get_has_move_input(t_context)

    if m_land_timer >= LAND_DURATION then
        if has_input then
            StateMachine.change_state(t_context, "walk")
        else
            StateMachine.change_state(t_context, "idle")
        end
        return
    end

    -- Decelerate. 
    local land_deceleration = has_input and 12.0 or 18.0
    PlayerMovement.apply_horizontal_deceleration(t_context, t_delta_time, land_deceleration)
end

------------------------------------------------

function MoveStateLand.on_exit(t_context, t_next_state_name)
    m_land_timer = 0.0
end

------------------------------------------------

return MoveStateLand
