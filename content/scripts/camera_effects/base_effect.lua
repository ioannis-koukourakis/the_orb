local BaseEffect = {}
BaseEffect.__index = BaseEffect

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local Easing = dofile("../content/scripts/shared/easing.lua")

------------------------------------------------

BaseEffect.STATE_FADE_IN = 1
BaseEffect.STATE_FULL = 2
BaseEffect.STATE_FADE_OUT = 3
BaseEffect.STATE_ENDED = 4

------------------------------------------------

function BaseEffect:new()
    local effect = {}
    setmetatable(effect, BaseEffect)
    
    effect.m_id = -1
    effect.m_amount = 0.0
    effect.m_max_amount = 0.0
    effect.m_multiplier = 0.0
    effect.m_fade_in_time = 0.0
    effect.m_duration = 0.0
    effect.m_fade_out_time = 0.0
    effect.m_max_fade_in_time = 0.0
    effect.m_max_fade_out_time = 0.0
    effect.m_fade_out_start_multiplier = 1.0
    effect.m_time_elapsed = 0.0
    effect.m_state = BaseEffect.STATE_FADE_IN
    effect.m_ease_in = Easing.linear
    effect.m_ease_out = Easing.linear
    
    return effect
end

------------------------------------------------

function BaseEffect:process_fade(t_delta_time)
    self.m_time_elapsed = self.m_time_elapsed + t_delta_time
    
    -- Fade in.
    if self.m_state == BaseEffect.STATE_FADE_IN then
        self.m_fade_in_time = self.m_fade_in_time + t_delta_time
        
        -- If greater or equal to max fade in time, set multiplier to 1.0 and set state to full.
        if self.m_fade_in_time >= self.m_max_fade_in_time then
            self.m_multiplier = 1.0
            self.m_state = BaseEffect.STATE_FULL
        -- Otherwise, calculate multiplier based on ease in function.
        else
            local t = self.m_fade_in_time / self.m_max_fade_in_time
            self.m_multiplier = self.m_ease_in(t)
        end
    
    -- Full effect duration.
    elseif self.m_state == BaseEffect.STATE_FULL then
        self.m_multiplier = 1.0
        
        -- If duration is negative, stay in full state indefinitely.
        if self.m_duration >= 0.0 then
            -- If time elapsed is greater or equal to max fade in time plus duration, 
            -- set fade out start multiplier to current multiplier, 
            -- set state to fade out and reset fade out timer.
            if self.m_time_elapsed >= self.m_max_fade_in_time + self.m_duration then
                self.m_fade_out_start_multiplier = self.m_multiplier
                self.m_state = BaseEffect.STATE_FADE_OUT
                self.m_fade_out_time = 0.0  -- Reset fade out timer.
            end
        end
    
    -- Fade out.
    elseif self.m_state == BaseEffect.STATE_FADE_OUT then
        self.m_fade_out_time = self.m_fade_out_time + t_delta_time
        
        -- If greater or equal to max fade out time, set multiplier to 0.0 and set state to ended.
        if self.m_fade_out_time >= self.m_max_fade_out_time then
            self.m_multiplier = 0.0
            self.m_state = BaseEffect.STATE_ENDED
        -- Otherwise, calculate multiplier based on ease out function.
        else
            local t = self.m_fade_out_time / self.m_max_fade_out_time
            local eased = self.m_ease_out(t)
            self.m_multiplier = self.m_fade_out_start_multiplier * (1.0 - eased)
        end
    end
end

------------------------------------------------

function BaseEffect:process(t_delta_time)
    self:process_fade(t_delta_time)
end

------------------------------------------------

function BaseEffect:late_process(t_delta_time)
    self:process_fade(t_delta_time)
end

------------------------------------------------

function BaseEffect:stop(t_fade_out_time)
    -- Get current multiplier to fade out from current position.
    self.m_fade_out_start_multiplier = self.m_multiplier
    
    -- Use provided fade out time, or fall back to the original configured time.
    if t_fade_out_time and t_fade_out_time > 0.0 then
        self.m_max_fade_out_time = t_fade_out_time
    end

    -- Reset fade out timer to start from 0
    self.m_fade_out_time = 0.0
    self.m_state = BaseEffect.STATE_FADE_OUT
end

------------------------------------------------

function BaseEffect:get_is_ended()
    return self.m_state == BaseEffect.STATE_ENDED
end

------------------------------------------------

function BaseEffect:get_state()
    return self.m_state
end

------------------------------------------------

function BaseEffect:get_id()
    return self.m_id
end

------------------------------------------------

function BaseEffect:set_ease_in(t_ease_function)
    self.m_ease_in = t_ease_function or Easing.linear
end

------------------------------------------------

function BaseEffect:set_ease_out(t_ease_function)
    self.m_ease_out = t_ease_function or Easing.linear
end

------------------------------------------------

return BaseEffect
