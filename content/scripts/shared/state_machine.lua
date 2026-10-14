local StateMachine = {}

------------------------------------------------
-- INTERFACE
------------------------------------------------

function StateMachine.create_new_instance()
    local instance = {
        m_registered_states = {},
        m_active_state_names_stack = {},
        m_active_state_index = 0,
        m_previous_state_name = "",
        m_is_active = false,
    }

    return instance
end

------------------------------------------------

function StateMachine.set_active(t_state_machine_instance, t_active)
    t_state_machine_instance.m_is_active = t_active
end

------------------------------------------------

function StateMachine.get_is_active(t_state_machine_instance)
    return t_state_machine_instance.m_is_active
end

------------------------------------------------

function StateMachine.register_state(t_state_machine_instance, t_state_name, t_behavior_table)
    -- Check if the state machine instance is valid.
    if t_state_machine_instance == nil then
        print_error("Cannot register state to a nil state machine instance.")
        return
    end

    -- Check if the state name is valid.
    if t_state_name == nil or t_state_name == "" then
        print_error("Invalid state name. State machine register state failed.")
        return
    end

    -- Check if the state is already registered.
    if t_state_machine_instance.m_registered_states[t_state_name] then
        print_error("State already registered. State machine register state failed.")
        return
    end

    -- Check if the behavior table is valid.
    if t_behavior_table == nil then
        print_error("Invalid behavior table. State machine register state failed.")
        return
    end

    -- Register the state.
    t_state_machine_instance.m_registered_states[t_state_name] = t_behavior_table
end

------------------------------------------------

function StateMachine.change_state_to(t_state_machine_instance, t_state_name, t_context)
    -- Check if the state machine instance is valid.
    if t_state_machine_instance == nil then
        print_error("Invalid state machine instance")
        return
    end

    -- Check if the state name is valid.
    if t_state_name == nil or t_state_name == "" then
        print_error("Invalid state name: " .. tostring(t_state_name))
        return
    end

    -- Check if the state is registered.
    if t_state_machine_instance.m_registered_states[t_state_name] == nil then
        print_error("State '" .. tostring(t_state_name) .. "' is not registered")
        return
    end

    -- Exit the current state if one is active.
    local prev_index = t_state_machine_instance.m_active_state_index
    if prev_index > 0 then
        local current_state_name = t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
        local old_state = t_state_machine_instance.m_registered_states[current_state_name]

        t_state_machine_instance.m_previous_state_name = current_state_name

        if old_state and old_state.on_exit then
            old_state.on_exit(t_context, t_state_name)
        end
    else
        t_state_machine_instance.m_previous_state_name = ""
    end

    -- Clear the stack in place instead of allocating a new table.
    local stack = t_state_machine_instance.m_active_state_names_stack
    for i = 1, prev_index do
        stack[i] = nil
    end

    -- Set the new state name and index.
    stack[1] = t_state_name
    t_state_machine_instance.m_active_state_index = 1

    -- if there's a new state, call the enter function.
    local new_state = t_state_machine_instance.m_registered_states[t_state_name]
    if new_state and new_state.on_enter then
        new_state.on_enter(t_state_machine_instance.m_previous_state_name, t_context)
    end
end

------------------------------------------------

function StateMachine.change_state(t_context, t_state_name)
    StateMachine.change_state_to(t_context.m_state_machine, t_state_name, t_context)
end

------------------------------------------------

function StateMachine.push_state(t_state_machine_instance, t_state_name, t_context)
    -- Check if the state machine instance is valid.
    if t_state_machine_instance == nil then
        print_error("Invalid state machine instance")
        return
    end

    -- Check if the state name is valid.
    if t_state_name == nil or t_state_name == "" then
        print_error("Invalid state name: " .. tostring(t_state_name))
        return
    end

    -- Check if the state is registered.
    if t_state_machine_instance.m_registered_states[t_state_name] == nil then
        print_error("State '" .. tostring(t_state_name) .. "' is not registered")
        return
    end

    -- Pause the current state without removing it from the stack.
    local current_index = t_state_machine_instance.m_active_state_index
    local current_state_name = ""

    if current_index > 0 then
        current_state_name = t_state_machine_instance.m_active_state_names_stack[current_index]
        local current_state = t_state_machine_instance.m_registered_states[current_state_name]
        if current_state and current_state.on_pause then
            current_state.on_pause(t_context)
        end
    end

    -- Increment the active state index and set the new state name.
    local new_index = current_index + 1
    t_state_machine_instance.m_active_state_index = new_index
    t_state_machine_instance.m_active_state_names_stack[new_index] = t_state_name
    t_state_machine_instance.m_previous_state_name = current_state_name

    -- if there's a new state, call the enter function.
    local new_state = t_state_machine_instance.m_registered_states[t_state_name]
    if new_state and new_state.on_enter then
        new_state.on_enter(t_state_machine_instance.m_previous_state_name, t_context)
    end
end

------------------------------------------------

function StateMachine.pop_state(t_state_machine_instance, t_context)
    if t_state_machine_instance == nil then
        print_error("Invalid state machine instance")
        return
    end

    -- Check if there's a state to pop.
    local current_index = t_state_machine_instance.m_active_state_index
    if current_index == 0 then
        print_error("No state left on the stack to pop.")
        return
    end

    -- Get the state to pop name and old state.
    local state_to_pop_name = t_state_machine_instance.m_active_state_names_stack[current_index]
    local old_state = t_state_machine_instance.m_registered_states[state_to_pop_name]
    if old_state and old_state.on_exit then
        old_state.on_exit(t_context, state_to_pop_name)
    end

    -- Clear the current state name.
    t_state_machine_instance.m_active_state_names_stack[current_index] = nil
    local new_index = current_index - 1
    t_state_machine_instance.m_active_state_index = new_index
    t_state_machine_instance.m_previous_state_name = state_to_pop_name

    -- if there's a resumed state, call the resume function.
    if new_index > 0 then
        local resumed_state_name = t_state_machine_instance.m_active_state_names_stack[new_index]
        local resumed_state = t_state_machine_instance.m_registered_states[resumed_state_name]
        if resumed_state and resumed_state.on_resume then
            resumed_state.on_resume(t_context)
        end
    end
end

------------------------------------------------

function StateMachine.get_current_state_name(t_state_machine_instance)
    if t_state_machine_instance.m_active_state_index == 0 then
        return ""
    end

    -- Get the current state name.
    return t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
end

------------------------------------------------

function StateMachine.get_root_state_name(t_state_machine_instance)
    if t_state_machine_instance.m_active_state_index == 0 then
        return ""
    end

    -- Get the root state name.
    return t_state_machine_instance.m_active_state_names_stack[1]
end

------------------------------------------------

function StateMachine.get_previous_state_name(t_state_machine_instance)
    return t_state_machine_instance.m_previous_state_name
end

------------------------------------------------

function StateMachine.get_is_in_state(t_state_machine_instance, t_state_name)
    if t_state_machine_instance.m_active_state_index == 0 then
        return false
    end

    -- Check if the current state name is the same as the target state name.
    local current_state_name = t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
    return current_state_name == t_state_name
end

------------------------------------------------

function StateMachine.process(t_state_machine_instance, t_delta_time, t_context)
    if t_state_machine_instance.m_is_active == false or t_state_machine_instance.m_active_state_index == 0 then
        return
    end

    -- if there's an active state, call the process function.
    local current_state_name = t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
    local current_state = t_state_machine_instance.m_registered_states[current_state_name]
    if current_state and current_state.on_process then
        current_state.on_process(t_delta_time, t_context)
    end
end

------------------------------------------------

function StateMachine.fixed_process(t_state_machine_instance, t_time_step, t_context)
    if t_state_machine_instance.m_is_active == false or t_state_machine_instance.m_active_state_index == 0 then
        return
    end

    -- if there's an active state, call the fixed process function.
    local current_state_name = t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
    local current_state = t_state_machine_instance.m_registered_states[current_state_name]
    if current_state and current_state.on_fixed_process then
        current_state.on_fixed_process(t_time_step, t_context)
    end
end

------------------------------------------------

function StateMachine.late_process(t_state_machine_instance, t_delta_time, t_context)
    if t_state_machine_instance.m_is_active == false or t_state_machine_instance.m_active_state_index == 0 then
        return
    end

    -- if there's an active state, call the late process function.
    local current_state_name = t_state_machine_instance.m_active_state_names_stack[t_state_machine_instance.m_active_state_index]
    local current_state = t_state_machine_instance.m_registered_states[current_state_name]
    if current_state and current_state.on_late_process then
        current_state.on_late_process(t_delta_time, t_context)
    end
end

------------------------------------------------

return StateMachine
