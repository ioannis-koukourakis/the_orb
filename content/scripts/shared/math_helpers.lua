local MathHelpers = {}

------------------------------------------------
-- ANGLE
------------------------------------------------

function MathHelpers.get_shortest_angle_distance_rad(t_current_angle, t_target_angle)
    local diff = t_target_angle - t_current_angle
    
    -- Normalize to [-pi, pi]
    while diff > math.pi do
        diff = diff - (2 * math.pi)
    end
    while diff < -math.pi do
        diff = diff + (2 * math.pi)
    end
    
    return diff
end

------------------------------------------------

function MathHelpers.get_distance_xz(t_a, t_b)
    local dx = t_b.x - t_a.x
    local dz = t_b.z - t_a.z
    return math.sqrt(dx * dx + dz * dz)
end

------------------------------------------------

function MathHelpers.get_shortest_angle_distance_deg(t_current_angle, t_target_angle)
    local diff = t_target_angle - t_current_angle
    
    -- Normalize to [-180, 180]
    while diff > 180 do
        diff = diff - 360
    end
    while diff < -180 do
        diff = diff + 360
    end
    
    return diff
end

------------------------------------------------

function MathHelpers.normalize_angle_rad(t_angle)
    local normalized = t_angle % (2 * math.pi)
    if normalized < 0 then
        normalized = normalized + (2 * math.pi)
    end
    return normalized
end

------------------------------------------------

function MathHelpers.normalize_angle_deg(t_angle)
    local normalized = t_angle % 360
    if normalized < 0 then
        normalized = normalized + 360
    end
    return normalized
end

------------------------------------------------
-- NOISE
------------------------------------------------

function MathHelpers.get_hash_noise(t_seed, t_time)
    local x = (t_seed + t_time) * 12.9898
    local frac = math_fract(x)
    return (math.sin(frac * 43758.5453) * 0.5 + 0.5) * 2.0 - 1.0
end

------------------------------------------------

return MathHelpers
