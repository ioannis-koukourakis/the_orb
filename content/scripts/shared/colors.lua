-- @NOTE: Standard colors. Menu and HUD skins stay in their own files.

local Colors = {}

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

Colors.BLACK = vec4(0.0, 0.0, 0.0, 1.0)
Colors.WHITE = vec4(1.0, 1.0, 1.0, 1.0)
Colors.CLEAR = vec4(0.0, 0.0, 0.0, 0.0)

Colors.RED = vec4(1.0, 0.0, 0.0, 1.0)
Colors.GREEN = vec4(0.0, 1.0, 0.0, 1.0)
Colors.BLUE = vec4(0.0, 0.0, 1.0, 1.0)
Colors.YELLOW = vec4(1.0, 1.0, 0.0, 1.0)

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

--- Same red, green, and blue as t_color, with t_alpha.
--- @param t_color vec4
--- @param t_alpha number
--- @return vec4
function Colors.get_with_alpha(t_color, t_alpha)
    return vec4(t_color.x, t_color.y, t_color.z, t_alpha)
end

----------------------------------------------------

function Colors.get_vec3(t_color)
    return vec3(t_color.x, t_color.y, t_color.z)
end

----------------------------------------------------

return Colors
