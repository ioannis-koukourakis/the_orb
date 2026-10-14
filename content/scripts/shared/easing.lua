local Easing = {}

------------------------------------------------
-- INTERFACE
------------------------------------------------

function Easing.linear(t)
    return t
end

------------------------------------------------

function Easing.in_quad(t)
    return t * t
end

function Easing.out_quad(t)
    return t * (2.0 - t)
end

function Easing.in_out_quad(t)
    if t < 0.5 then
        return 2.0 * t * t
    else
        return -1.0 + (4.0 - 2.0 * t) * t
    end
end

------------------------------------------------

function Easing.in_cubic(t)
    return t * t * t
end

function Easing.out_cubic(t)
    local f = t - 1.0
    return f * f * f + 1.0
end

function Easing.in_out_cubic(t)
    if t < 0.5 then
        return 4.0 * t * t * t
    else
        local f = ((2.0 * t) - 2.0)
        return 0.5 * f * f * f + 1.0
    end
end

------------------------------------------------

function Easing.in_quart(t)
    return t * t * t * t
end

function Easing.out_quart(t)
    local f = t - 1.0
    return 1.0 - f * f * f * f
end

function Easing.in_out_quart(t)
    if t < 0.5 then
        return 8.0 * t * t * t * t
    else
        local f = t - 1.0
        return 1.0 - 8.0 * f * f * f * f
    end
end

------------------------------------------------

function Easing.in_quint(t)
    return t * t * t * t * t
end

function Easing.out_quint(t)
    local f = t - 1.0
    return f * f * f * f * f + 1.0
end

function Easing.in_out_quint(t)
    if t < 0.5 then
        return 16.0 * t * t * t * t * t
    else
        local f = ((2.0 * t) - 2.0)
        return 0.5 * f * f * f * f * f + 1.0
    end
end

------------------------------------------------

function Easing.in_sine(t)
    return 1.0 - math.cos(t * (math.pi * 0.5))
end

function Easing.out_sine(t)
    return math.sin(t * (math.pi * 0.5))
end

function Easing.in_out_sine(t)
    return 0.5 * (1.0 - math.cos(math.pi * t))
end

------------------------------------------------

function Easing.in_expo(t)
    if t == 0.0 then
        return 0.0
    end
    return math.pow(2.0, 10.0 * (t - 1.0))
end

function Easing.out_expo(t)
    if t == 1.0 then
        return 1.0
    end
    return 1.0 - math.pow(2.0, -10.0 * t)
end

function Easing.in_out_expo(t)
    if t == 0.0 or t == 1.0 then
        return t
    end
    
    if t < 0.5 then
        return 0.5 * math.pow(2.0, (20.0 * t) - 10.0)
    else
        return 0.5 * (2.0 - math.pow(2.0, (-20.0 * t) + 10.0))
    end
end

------------------------------------------------

function Easing.in_circ(t)
    return 1.0 - math.sqrt(1.0 - (t * t))
end

function Easing.out_circ(t)
    return math.sqrt((2.0 - t) * t)
end

function Easing.in_out_circ(t)
    if t < 0.5 then
        return 0.5 * (1.0 - math.sqrt(1.0 - 4.0 * (t * t)))
    else
        return 0.5 * (math.sqrt(-((2.0 * t) - 3.0) * ((2.0 * t) - 1.0)) + 1.0)
    end
end

------------------------------------------------

function Easing.in_back(t)
    local s = 1.70158
    return t * t * ((s + 1.0) * t - s)
end

function Easing.out_back(t)
    local s = 1.70158
    local f = 1.0 - t
    return 1.0 - (f * f * ((s + 1.0) * f - s))
end

function Easing.in_out_back(t)
    local s = 1.70158 * 1.525
    if t < 0.5 then
        return 0.5 * (4.0 * t * t * ((s + 1.0) * 2.0 * t - s))
    else
        local f = 2.0 * t - 2.0
        return 0.5 * (1.0 + f * f * ((s + 1.0) * f + s))
    end
end

------------------------------------------------

function Easing.in_elastic(t)
    if t == 0.0 or t == 1.0 then
        return t
    end
    return -math.pow(2.0, 10.0 * (t - 1.0)) * math.sin((t - 1.1) * 5.0 * math.pi)
end

function Easing.out_elastic(t)
    if t == 0.0 or t == 1.0 then
        return t
    end
    return math.pow(2.0, -10.0 * t) * math.sin((t - 0.1) * 5.0 * math.pi) + 1.0
end

function Easing.in_out_elastic(t)
    if t == 0.0 or t == 1.0 then
        return t
    end
    
    local scaled_t = t * 2.0
    if scaled_t < 1.0 then
        return -0.5 * math.pow(2.0, 10.0 * (scaled_t - 1.0)) * math.sin((scaled_t - 1.1) * 5.0 * math.pi)
    else
        return 0.5 * math.pow(2.0, -10.0 * (scaled_t - 1.0)) * math.sin((scaled_t - 1.1) * 5.0 * math.pi) + 1.0
    end
end

------------------------------------------------

function Easing.out_bounce(t)
    if t < (1.0 / 2.75) then
        return 7.5625 * t * t
    elseif t < (2.0 / 2.75) then
        local bounce_t = t - (1.5 / 2.75)
        return 7.5625 * bounce_t * bounce_t + 0.75
    elseif t < (2.5 / 2.75) then
        local bounce_t = t - (2.25 / 2.75)
        return 7.5625 * bounce_t * bounce_t + 0.9375
    else
        local bounce_t = t - (2.625 / 2.75)
        return 7.5625 * bounce_t * bounce_t + 0.984375
    end
end

function Easing.in_bounce(t)
    return 1.0 - Easing.out_bounce(1.0 - t)
end

function Easing.in_out_bounce(t)
    if t < 0.5 then
        return Easing.in_bounce(t * 2.0) * 0.5
    else
        return Easing.out_bounce(t * 2.0 - 1.0) * 0.5 + 0.5
    end
end

------------------------------------------------

return Easing
