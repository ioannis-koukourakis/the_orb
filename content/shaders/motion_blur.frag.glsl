#version 450 core

#include "../../engine/shaders/include/custom_post_process_contract.glsl"

//////////////////////////////////////////////////////////////////////
// Per-pixel motion blur from G-buffer velocity.
// u_intensity: max mix toward blurred result (0-1).
// u_params.x: velocity length scale (shutter).
// u_params.y: min |velocity| in UV before any blur mixes in.
// Strength ramps from 0 at min speed to full u_intensity at 8x min speed.
/////////////////////////////////////////////////////////////////////

#define MOTION_BLUR_FULL_SPEED_MULTIPLIER 8.0
#define MOTION_BLUR_SAMPLES 12

out vec4 out_color;
in vec2 UVs;

// -------------------------------------------------------------------

void main()
{
	//////////////////////////////////////
	// Get the scene color.
	vec3 scene_color = texture(u_scene, UVs).rgb;

	//////////////////////////////////////
	// Skip if the intensity is too low.
	if (u_intensity <= 0.001)
	{
		out_color = vec4(scene_color, 1.0);
		return;
	}

	//////////////////////////////////////
	// Get the velocity from the G-buffer.
	ivec2 pixel = ivec2(gl_FragCoord.xy);
	vec2 velocity = texelFetch(u_velocity, pixel, 0).rg;
	velocity *= u_params.x;

	//////////////////////////////////////
	// Skip if the speed is too low.
	float speed = length(velocity);
	float min_speed = u_params.y;
	if (speed < min_speed)
	{
		out_color = vec4(scene_color, 1.0);
		return;
	}

	//////////////////////////////////////
	// Skip if the motion mix is too low.
	float full_speed = max(min_speed * MOTION_BLUR_FULL_SPEED_MULTIPLIER, min_speed + 1.0e-5);
	float motion_mix = smoothstep(min_speed, full_speed, speed) * clamp(u_intensity, 0.0, 1.0);
	if (motion_mix <= 0.001)
	{
		out_color = vec4(scene_color, 1.0);
		return;
	}

	//////////////////////////////////////
	// Blur the scene color and calculate the total weight.
	vec3 blurred_color = vec3(0.0);
	float total_weight = 0.0;
	for (int i = 0; i < MOTION_BLUR_SAMPLES; i++)
	{
		float t = float(i) / float(MOTION_BLUR_SAMPLES - 1);
		vec2 sample_uv = UVs - velocity * (t - 0.5);
		float weight = 1.0 - abs(t * 2.0 - 1.0);

		if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 && sample_uv.y >= 0.0 && sample_uv.y <= 1.0)
		{
			blurred_color += texture(u_scene, sample_uv).rgb * weight;
			total_weight += weight;
		}
	}

	//////////////////////////////////////
	// Combine blurred color with scene color.
	if (total_weight > 0.0) // Skip division by zero.
	{
		blurred_color /= total_weight;
		scene_color = mix(scene_color, blurred_color, motion_mix);
	}

	//////////////////////////////////////
	// All done!
	out_color = vec4(scene_color, 1.0);
}
