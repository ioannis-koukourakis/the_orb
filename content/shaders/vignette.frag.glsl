#version 450 core

#include "../../engine/shaders/include/custom_post_process_contract.glsl"
#include "../../engine/shaders/include/shader_math.glsl"

/////////////////////////////////////////////////////////////////////
// Camera post-processing vignette.
// u_intensity: x = intensity
// u_time: x = time
// u_color: x = color, y = color, z = color
// u_scene: x = scene, y = scene, z = scene
// u_extra_texture: x = extra_texture, y = extra_texture, z = extra_texture
// u_params: x = pulse effect hz (0 = consistent)
/////////////////////////////////////////////////////////////////////

out vec4 out_color;
in vec2 UVs;

// -------------------------------------------------------------------

void main()
{
	vec3 scene_color = texture(u_scene, UVs).rgb;
	float mask = texture(u_extra_texture, UVs).r;

	//////////////////////////////////////////////////////////////
	// Pulse effect.
	float pulse = 1.0;
	if (u_params.x > 0.0)
		pulse = 0.65 + 0.35 * sin(u_time * TWO_PI * u_params.x);

	//////////////////////////////////////////////////////////////
	// Apply intensity, pulse, and tint.
	float strength = clamp(u_intensity * pulse, 0.0, 1.0);
	vec3 color = mix(scene_color, u_color, mask * strength);
	out_color = vec4(color, 1.0);
}

// -------------------------------------------------------------------
