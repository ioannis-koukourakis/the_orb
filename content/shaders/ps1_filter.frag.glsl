#version 450 core

#include "../../engine/shaders/include/custom_post_process_contract.glsl"

// -------------------------------------------------------------------
// PS1-style filter.
// u_intensity: x = intensity
// u_resolution: x = resolution, y = resolution
// u_time: x = time
// u_color: x = color, y = color, z = color
// u_scene: x = scene, y = scene, z = scene
// u_extra_texture: x = extra_texture, y = extra_texture, z = extra_texture
// u_params: x = pixel scale, y = color bits, z = dither strength
// -------------------------------------------------------------------

out vec4 out_color;
in vec2 UVs;

// -------------------------------------------------------------------

float get_bayer4(ivec2 t_pixel)
{
	int x = t_pixel.x & 3;
	int y = t_pixel.y & 3;
	int index = x + y * 4;

	/////////////////////////////////
	// 4x4 Bayer matrix / 16.
	const float bayer[16] = float[](
		0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
		12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
		3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
		15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0);
	return bayer[index];
}

// -------------------------------------------------------------------

void main()
{
	vec3 scene_color = texture(u_scene, UVs).rgb;

	//////////////////////////////////////////////////////////////
	// Skip when intensity is off.
	if (u_intensity <= 0.0)
	{
		out_color = vec4(scene_color, 1.0);
		return;
	}

	//////////////////////////////////////////////////////////////
	// Get parameters.
	vec2 resolution = u_resolution;
	float pixel_scale = max(u_params.x, 1.0);
	float color_bits = max(u_params.y, 1.0);
	float dither_strength = clamp(u_params.z, 0.0, 1.0);

	//////////////////////////////////////////////////////////////
	// Snap UVs to a low-res grid for a PS1 framebuffer feel.
	vec2 virtual_res = max(resolution / pixel_scale, vec2(1.0));
	vec2 pixel_uv = (floor(UVs * virtual_res) + 0.5) / virtual_res;
	vec3 ps1_color = texture(u_scene, pixel_uv).rgb;

	//////////////////////////////////////////////////////////////
	// Mild tonemap into a display range so posterize reads like 15-bit.
	vec3 mapped = ps1_color / (ps1_color + vec3(1.0));

	//////////////////////////////////////////////////////////////
	// Ordered dither before quantization.
	float levels = pow(2.0, color_bits) - 1.0;
	float bayer = get_bayer4(ivec2(floor(UVs * virtual_res)));
	mapped += (bayer - 0.5) * dither_strength / levels;

	//////////////////////////////////////////////////////////////
	// Posterize
	mapped = clamp(mapped, 0.0, 1.0);
	mapped = floor(mapped * levels + 0.5) / levels;

	//////////////////////////////////////////////////////////////
	// Inverse soft map back toward HDR working range.
	ps1_color = mapped / max(vec3(1.0) - mapped, vec3(0.001));

	//////////////////////////////////////////////////////////////
	// Mix the scene color with the PS1 color.
	vec3 color = mix(scene_color, ps1_color, clamp(u_intensity, 0.0, 1.0));
	out_color = vec4(color, 1.0);
}
