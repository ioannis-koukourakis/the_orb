-- Auto-generated C++ Engine API stubs.
-- This file is only refreshed when script_api C++ sources are available.
-- DO NOT EDIT!

---@meta

---@class vec2
---@class vec3
---@class vec4
---@class quat
---@class mat3
---@class mat4

-- Animation

---@param t_entity_id integer
---@param t_file_path string
function animation_add(t_entity_id, t_file_path) end

---@param t_entity_id integer
---@return string
function animation_get_current_name(t_entity_id) end

---@param t_entity_id integer
---@param t_animation_name string
---@return number
function animation_get_duration(t_entity_id, t_animation_name) end

---@param t_entity_id integer
---@return boolean
function animation_get_is_finished(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function animation_get_is_looping(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function animation_get_is_paused(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function animation_get_is_playing(t_entity_id) end

function animation_get_socket_names() end

function animation_get_socket_world_position() end

function animation_get_socket_world_rotation() end

---@param t_entity_id integer
---@return number
function animation_get_speed(t_entity_id) end

---@param t_entity_id integer
---@return number
function animation_get_time(t_entity_id) end

---@param t_entity_id integer
---@param t_animation_name string
---@param t_boolean_3 boolean
---@param t_number_4 number
---@param t_number_5 number
function animation_play(t_entity_id, t_animation_name, t_boolean_3, t_number_4, t_number_5) end

---@param t_entity_id integer
---@param t_animation_name string
function animation_remove(t_entity_id, t_animation_name) end

---@param t_entity_id integer
---@param t_looping boolean
function animation_set_looping(t_entity_id, t_looping) end

---@param t_entity_id integer
---@param t_paused boolean
function animation_set_paused(t_entity_id, t_paused) end

---@param t_entity_id integer
---@param t_speed number
function animation_set_speed(t_entity_id, t_speed) end

---@param t_entity_id integer
---@param t_time number
function animation_set_time(t_entity_id, t_time) end

---@param t_entity_id integer
function animation_stop(t_entity_id) end

-- Billboard

---@param t_entity_id integer
---@return string
function billboard_get_clip(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function billboard_get_constant_screen_size(t_entity_id) end

---@param t_entity_id integer
---@return string
function billboard_get_flipbook_file(t_entity_id) end

---@param t_entity_id integer
---@return integer
function billboard_get_frame(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function billboard_get_is_unique_material(t_entity_id) end

---@param t_entity_id integer
---@return string
function billboard_get_material_file(t_entity_id) end

---@param t_entity_id integer
---@return integer
function billboard_get_type(t_entity_id) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return boolean
function billboard_get_uniform_bool(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return number
function billboard_get_uniform_float(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return vec2
function billboard_get_uniform_vec2(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return vec3
function billboard_get_uniform_vec3(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return vec4
function billboard_get_uniform_vec4(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_animated boolean
function billboard_set_animated(t_entity_id, t_animated) end

---@param t_entity_id integer
---@param t_clip_name string
function billboard_set_clip(t_entity_id, t_clip_name) end

---@param t_entity_id integer
---@param t_constant boolean
function billboard_set_constant_screen_size(t_entity_id, t_constant) end

---@param t_entity_id integer
---@param t_current_time number
function billboard_set_current_time(t_entity_id, t_current_time) end

---@param t_entity_id integer
---@param t_file string
function billboard_set_flipbook_file(t_entity_id, t_file) end

---@param t_entity_id integer
---@param t_frame integer
function billboard_set_frame(t_entity_id, t_frame) end

---@param t_entity_id integer
---@param t_frame_rate number
function billboard_set_frame_rate(t_entity_id, t_frame_rate) end

---@param t_entity_id integer
---@param t_file string
function billboard_set_material_file(t_entity_id, t_file) end

---@param t_entity_id integer
---@param t_playback_mode string
function billboard_set_playback_mode(t_entity_id, t_playback_mode) end

---@param t_entity_id integer
---@param t_billboard_type integer
function billboard_set_type(t_entity_id, t_billboard_type) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value boolean
function billboard_set_uniform_bool(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value number
function billboard_set_uniform_float(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec2
function billboard_set_uniform_vec2(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec3
function billboard_set_uniform_vec3(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec4
function billboard_set_uniform_vec4(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_unique boolean
function billboard_set_unique_material(t_entity_id, t_unique) end

-- Bone_attachment

---@param t_entity_id integer
function bone_attachment_detach(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function bone_attachment_get_is_active(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function bone_attachment_get_local_position(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function bone_attachment_get_local_rotation(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function bone_attachment_get_local_scale(t_entity_id) end

---@param t_entity_id integer
---@return string
function bone_attachment_get_socket_name(t_entity_id) end

---@param t_entity_id integer
---@return integer
function bone_attachment_get_target_entity_id(t_entity_id) end

---@param t_entity_id integer
---@param t_active boolean
function bone_attachment_set_active(t_entity_id, t_active) end

---@param t_entity_id integer
---@param t_position vec3
function bone_attachment_set_local_position(t_entity_id, t_position) end

---@param t_entity_id integer
---@param t_rotation vec3
function bone_attachment_set_local_rotation(t_entity_id, t_rotation) end

---@param t_entity_id integer
---@param t_scale vec3
function bone_attachment_set_local_scale(t_entity_id, t_scale) end

---@param t_entity_id integer
---@param t_socket_name string
function bone_attachment_set_socket_name(t_entity_id, t_socket_name) end

---@param t_entity_id integer
---@param t_target_entity_id integer
---@param t_socket_name string
function bone_attachment_set_target(t_entity_id, t_target_entity_id, t_socket_name) end

---@param t_entity_id integer
---@param t_target_entity_id integer
function bone_attachment_set_target_entity_id(t_entity_id, t_target_entity_id) end

-- Camera

---@param t_entity_id integer
---@return number
function camera_get_default_fov(t_entity_id) end

---@param t_entity_id integer
---@return number
function camera_get_fov(t_entity_id) end

---@param t_world_position vec3
---@return vec2
function camera_get_world_to_screen_position(t_world_position) end

---@param t_entity_id integer
function camera_reset_fov(t_entity_id) end

---@param t_entity_id integer
---@param t_default_fov number
function camera_set_default_fov(t_entity_id, t_default_fov) end

---@param t_entity_id integer
---@param t_fov number
function camera_set_fov(t_entity_id, t_fov) end

-- Character_body

---@param t_entity_id integer
---@return boolean
function character_body_get_can_jump(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_capsule_height(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_capsule_radius(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_fall_speed(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function character_body_get_gravity(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function character_body_get_ground_normal(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_jump_speed(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_linear_damping(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function character_body_get_linear_velocity(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_max_penetration_depth(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_max_slope(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function character_body_get_on_ground(t_entity_id) end

---@param t_entity_id integer
---@return number
function character_body_get_step_height(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function character_body_get_up_vector(t_entity_id) end

---@param t_entity_id integer
---@param t_direction vec3
function character_body_jump(t_entity_id, t_direction) end

---@param t_entity_id integer
function character_body_reset(t_entity_id) end

---@param t_entity_id integer
---@param t_height number
function character_body_set_capsule_height(t_entity_id, t_height) end

---@param t_entity_id integer
---@param t_radius number
function character_body_set_capsule_radius(t_entity_id, t_radius) end

---@param t_entity_id integer
---@param t_height number
---@param t_offset_y number
---@return boolean
function character_body_set_capsule_shape(t_entity_id, t_height, t_offset_y) end

---@param t_entity_id integer
---@param t_fall_speed number
function character_body_set_fall_speed(t_entity_id, t_fall_speed) end

---@param t_entity_id integer
---@param t_gravity vec3
function character_body_set_gravity(t_entity_id, t_gravity) end

---@param t_entity_id integer
---@param t_jump_speed number
function character_body_set_jump_speed(t_entity_id, t_jump_speed) end

---@param t_entity_id integer
---@param t_damping number
function character_body_set_linear_damping(t_entity_id, t_damping) end

---@param t_entity_id integer
---@param t_velocity vec3
function character_body_set_linear_velocity(t_entity_id, t_velocity) end

---@param t_entity_id integer
---@param t_depth number
function character_body_set_max_penetration_depth(t_entity_id, t_depth) end

---@param t_entity_id integer
---@param t_max_slope_degrees number
function character_body_set_max_slope(t_entity_id, t_max_slope_degrees) end

---@param t_entity_id integer
---@param t_step_height number
function character_body_set_step_height(t_entity_id, t_step_height) end

---@param t_entity_id integer
---@param t_up_vector vec3
function character_body_set_up_vector(t_entity_id, t_up_vector) end

---@param t_entity_id integer
---@param t_velocity vec3
---@param t_time_interval number
function character_body_set_velocity_for_time_interval(t_entity_id, t_velocity, t_time_interval) end

---@param t_entity_id integer
---@param t_direction vec3
function character_body_set_walk_direction(t_entity_id, t_direction) end

---@param t_entity_id integer
---@param t_yaw_radians number
function character_body_set_world_yaw(t_entity_id, t_yaw_radians) end

---@param t_entity_id integer
---@param t_position vec3
function character_body_warp(t_entity_id, t_position) end

-- Debug_overlay

---@param t_x number?
---@param t_y number?
function debug_overlay_fps(t_x, t_y) end

---@param t_text string
---@param t_x number?
---@param t_y number?
function debug_overlay_text(t_text, t_x, t_y) end

-- Dynamic_body

---@param t_entity_id integer
---@param t_force vec3
function dynamic_body_apply_central_force(t_entity_id, t_force) end

---@param t_entity_id integer
---@param t_impulse vec3
function dynamic_body_apply_central_impulse(t_entity_id, t_impulse) end

---@param t_entity_id integer
---@param t_force vec3
---@param t_position vec3
function dynamic_body_apply_force(t_entity_id, t_force, t_position) end

---@param t_entity_id integer
---@param t_impulse vec3
---@param t_position vec3
function dynamic_body_apply_impulse(t_entity_id, t_impulse, t_position) end

---@param t_entity_id integer
---@param t_torque vec3
function dynamic_body_apply_torque(t_entity_id, t_torque) end

---@param t_entity_id integer
---@param t_torque_impulse vec3
function dynamic_body_apply_torque_impulse(t_entity_id, t_torque_impulse) end

---@param t_entity_id integer
function dynamic_body_clear_forces(t_entity_id) end

---@param t_entity_id integer
---@return number
function dynamic_body_get_angular_damping(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function dynamic_body_get_angular_factor(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function dynamic_body_get_angular_velocity(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function dynamic_body_get_auto_sleep(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function dynamic_body_get_force_awake(t_entity_id) end

---@param t_entity_id integer
---@return number
function dynamic_body_get_friction(t_entity_id) end

---@param t_entity_id integer
---@return number
function dynamic_body_get_linear_damping(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function dynamic_body_get_linear_factor(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function dynamic_body_get_linear_velocity(t_entity_id) end

---@param t_entity_id integer
---@return number
function dynamic_body_get_mass(t_entity_id) end

---@param t_entity_id integer
---@return number
function dynamic_body_get_restitution(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function dynamic_body_get_simulation_enabled(t_entity_id) end

---@param t_entity_id integer
---@param t_angular_damping number
function dynamic_body_set_angular_damping(t_entity_id, t_angular_damping) end

---@param t_entity_id integer
---@param t_factor vec3
function dynamic_body_set_angular_factor(t_entity_id, t_factor) end

---@param t_entity_id integer
---@param t_velocity vec3
function dynamic_body_set_angular_velocity(t_entity_id, t_velocity) end

---@param t_entity_id integer
---@param t_auto_sleep boolean
function dynamic_body_set_auto_sleep(t_entity_id, t_auto_sleep) end

---@param t_entity_id integer
---@param t_force_awake boolean
function dynamic_body_set_force_awake(t_entity_id, t_force_awake) end

---@param t_entity_id integer
---@param t_friction number
function dynamic_body_set_friction(t_entity_id, t_friction) end

---@param t_entity_id integer
---@param t_linear_damping number
function dynamic_body_set_linear_damping(t_entity_id, t_linear_damping) end

---@param t_entity_id integer
---@param t_factor vec3
function dynamic_body_set_linear_factor(t_entity_id, t_factor) end

---@param t_entity_id integer
---@param t_velocity vec3
function dynamic_body_set_linear_velocity(t_entity_id, t_velocity) end

---@param t_entity_id integer
---@param t_mass number
function dynamic_body_set_mass(t_entity_id, t_mass) end

---@param t_entity_id integer
---@param t_restitution number
function dynamic_body_set_restitution(t_entity_id, t_restitution) end

---@param t_entity_id integer
---@param t_enabled boolean
function dynamic_body_set_simulation_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
function dynamic_body_wake_up(t_entity_id) end

-- Editor

---@return table
function editor_settings_get_available_themes() end

---@return string
function editor_settings_get_theme_name() end

---@param t_string_1 string
function editor_settings_set_theme_name(t_string_1) end

-- Engine

---@return string
function engine_get_version() end

function engine_quit() end

-- Entity

---@param t_entity_id integer
---@param t_component_type string
---@return boolean
function entity_add_component(t_entity_id, t_component_type) end

---@param t_entity_id integer
---@param t_tag string
function entity_add_tag(t_entity_id, t_tag) end

---@param t_entity_id integer
---@param t_index integer
---@return integer
function entity_get_child_by_index(t_entity_id, t_index) end

---@param t_entity_id integer
---@param t_child_name string
---@return integer
function entity_get_child_by_name(t_entity_id, t_child_name) end

---@param t_parent_entity_id integer
---@param t_path string
---@return integer
function entity_get_child_by_path(t_parent_entity_id, t_path) end

---@param t_entity_id integer
---@return integer
function entity_get_children_count(t_entity_id) end

---@param t_entity_id integer
---@param t_tag string
---@return table
function entity_get_entities_by_tag(t_entity_id, t_tag) end

---@param t_entity_id integer
---@param t_function_name string
---@return table
function entity_get_function(t_entity_id, t_function_name) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_animation_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_billboard_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_bone_attachment_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_camera_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_fog_volume_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_light_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_mesh_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_particle_system_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_pathnode_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_physics_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_physics_constraint_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_script_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_skeletal_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_sound_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_sound_zone_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_soundscape_zone_component(t_entity_id) end

---@param t_entity_id integer
---@param t_tag string
---@return boolean
function entity_get_has_tag(t_entity_id, t_tag) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_text_mesh_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_has_transform_component(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_is_active(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function entity_get_is_valid(t_entity_id) end

---@param t_entity_id integer
---@return string
function entity_get_name(t_entity_id) end

---@param t_entity_id integer
---@return integer
function entity_get_parent(t_entity_id) end

---@param t_entity_id integer
---@return table
function entity_get_tags(t_entity_id) end

---@param t_file_path string
---@return integer
function entity_load_prefab_from_file(t_file_path) end

---@param t_entity_id integer
---@param t_component_type string
---@return boolean
function entity_remove_component(t_entity_id, t_component_type) end

---@param t_entity_id integer
---@param t_tag string
function entity_remove_tag(t_entity_id, t_tag) end

---@param t_entity_id integer
---@param t_active boolean
function entity_set_active(t_entity_id, t_active) end

---@param t_entity_id integer
---@param t_name string
function entity_set_name(t_entity_id, t_name) end

---@param t_child_entity_id integer
---@param t_parent_entity_id integer
---@param t_keep_world_pose boolean?
---@return boolean
function entity_set_parent(t_child_entity_id, t_parent_entity_id, t_keep_world_pose) end

-- File_manager

---@param t_file_path string
---@return string
function file_manager_get_absolute_path_relative_to_executable(t_file_path) end

---@return string
function file_manager_get_documents_path() end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value boolean
---@return boolean
function file_manager_get_ini_bool(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value number?
---@return number
function file_manager_get_ini_float(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value integer?
---@return integer
function file_manager_get_ini_int(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value string?
---@return string
function file_manager_get_ini_string(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value vec2
---@return vec2
function file_manager_get_ini_vec2(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_default_value vec3
---@return vec3
function file_manager_get_ini_vec3(t_table_1, t_section, t_key, t_default_value) end

---@param t_table_1 table
---@param t_key string
---@param t_default_value boolean
---@return boolean
function file_manager_get_json_bool(t_table_1, t_key, t_default_value) end

---@param t_table_1 table
---@param t_key string
---@param t_default_value number?
---@return number
function file_manager_get_json_float(t_table_1, t_key, t_default_value) end

---@param t_table_1 table
---@param t_key string
---@param t_default_value integer?
---@return integer
function file_manager_get_json_int(t_table_1, t_key, t_default_value) end

---@param t_table_1 table
---@param t_key string
---@param t_default_value string?
---@return string
function file_manager_get_json_string(t_table_1, t_key, t_default_value) end

---@param t_table_1 table
---@param t_key string
---@return table
function file_manager_get_json_string_array(t_table_1, t_key) end

---@param t_table_1 table
---@param t_key string
---@return vec3
function file_manager_get_json_vec3(t_table_1, t_key) end

---@param t_file_path string
---@return string
function file_manager_get_relative_path(t_file_path) end

---@param t_value string?
---@return string
function file_manager_get_trimmed_string(t_value) end

---@return string
function file_manager_get_user_path() end

---@param t_file_path string
---@return table
function file_manager_load_ini(t_file_path) end

---@param t_file_path string
function file_manager_load_json(t_file_path) end

---@param t_table_1 table
---@param t_file_path string
---@return boolean
function file_manager_save_ini(t_table_1, t_file_path) end

---@param t_table_1 table
---@param t_file_path string
---@return boolean
function file_manager_save_json(t_table_1, t_file_path) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_value boolean
---@return table
function file_manager_set_ini_bool(t_table_1, t_section, t_key, t_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_value number
---@return table
function file_manager_set_ini_float(t_table_1, t_section, t_key, t_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_value integer
---@return table
function file_manager_set_ini_int(t_table_1, t_section, t_key, t_value) end

---@param t_table_1 table
---@param t_section string
---@param t_key string
---@param t_value string
---@return table
function file_manager_set_ini_string(t_table_1, t_section, t_key, t_value) end

---@param t_table_1 table
---@param t_key string
---@param t_value boolean
function file_manager_set_json_bool(t_table_1, t_key, t_value) end

---@param t_table_1 table
---@param t_key string
---@param t_value number
function file_manager_set_json_float(t_table_1, t_key, t_value) end

---@param t_table_1 table
---@param t_key string
---@param t_value integer
function file_manager_set_json_int(t_table_1, t_key, t_value) end

---@param t_table_1 table
---@param t_key string
---@param t_value string
function file_manager_set_json_string(t_table_1, t_key, t_value) end

---@param t_table_1 table
---@param t_key string
function file_manager_set_json_vec3(t_table_1, t_key) end

-- Fog_volume

---@param t_entity_id integer
---@return boolean
function fog_volume_get_backface_visibility(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function fog_volume_get_color(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_density(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_falloff_exp(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_height_factor(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_height_start(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_luminance(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function fog_volume_get_luminance_inherits_world(t_entity_id) end

---@param t_entity_id integer
---@return number
function fog_volume_get_start(t_entity_id) end

---@param t_entity_id integer
---@param t_backface_visibility boolean
function fog_volume_set_backface_visibility(t_entity_id, t_backface_visibility) end

---@param t_entity_id integer
---@param t_color vec3
function fog_volume_set_color(t_entity_id, t_color) end

---@param t_entity_id integer
---@param t_density number
function fog_volume_set_density(t_entity_id, t_density) end

---@param t_entity_id integer
---@param t_falloff_exp number
function fog_volume_set_falloff_exp(t_entity_id, t_falloff_exp) end

---@param t_entity_id integer
---@param t_height_factor number
function fog_volume_set_height_factor(t_entity_id, t_height_factor) end

---@param t_entity_id integer
---@param t_height_start number
function fog_volume_set_height_start(t_entity_id, t_height_start) end

---@param t_entity_id integer
---@param t_luminance number
function fog_volume_set_luminance(t_entity_id, t_luminance) end

---@param t_entity_id integer
---@param t_luminance_inherits_world boolean
function fog_volume_set_luminance_inherits_world(t_entity_id, t_luminance_inherits_world) end

---@param t_entity_id integer
---@param t_fog_start number
function fog_volume_set_start(t_entity_id, t_fog_start) end

-- Game

---@return boolean
function game_get_is_paused() end

---@return string
function game_get_settings_ini_path() end

---@return string
function game_get_settings_user_path() end

---@param t_paused boolean
function game_set_paused(t_paused) end

-- Get

---@return boolean
function get_game_mode_active() end

---@param t_name string
function get_global(t_name) end

-- Gui

---@param t_value number
---@param t_min_value number
---@param t_max_value number
---@param t_step number
---@return number
function gui_apply_focused_step_tweak(t_value, t_min_value, t_max_value, t_step) end

---@param t_id string
---@param t_size vec2
---@param t_flags integer?
---@return boolean
function gui_begin_child(t_id, t_size, t_flags) end

---@param t_name string
---@param t_flags integer
---@return boolean
function gui_begin_design_canvas(t_name, t_flags) end

---@param t_name string
---@param t_flags integer?
---@return boolean
function gui_begin_popup_modal(t_name, t_flags) end

---@param t_name string
---@param t_flags integer
---@return boolean
function gui_begin_screen_canvas(t_name, t_flags) end

---@param t_name string
---@param t_flags integer?
---@return boolean
function gui_begin_window(t_name, t_flags) end

---@param t_label string
---@return boolean
function gui_button(t_label) end

---@param t_label string
---@param t_value boolean
---@return boolean
function gui_checkbox(t_label, t_value) end

function gui_close_current_popup() end

---@param t_center vec2
---@param t_radius number
---@param t_color vec4
function gui_draw_circle(t_center, t_radius, t_color) end

---@param t_center vec2
---@param t_radius number
---@param t_thickness number
---@param t_color vec4
function gui_draw_circle_outlined(t_center, t_radius, t_thickness, t_color) end

---@param t_texture_path string
---@param t_position vec2
---@param t_size vec2
---@param t_color vec4
function gui_draw_image(t_texture_path, t_position, t_size, t_color) end

---@param t_texture_path string
---@param t_position vec2
---@param t_size vec2
---@param t_uv_min vec2
---@param t_uv_max vec2
---@param t_color vec4
function gui_draw_image_region(t_texture_path, t_position, t_size, t_uv_min, t_uv_max, t_color) end

---@param t_texture_path string
---@param t_position vec2
---@param t_size vec2
---@param t_border_left number
---@param t_border_top number
---@param t_border_right number
---@param t_border_bottom number
---@param t_color vec4
function gui_draw_image_sliced(t_texture_path, t_position, t_size, t_border_left, t_border_top, t_border_right, t_border_bottom, t_color) end

---@param t_p1 vec2
---@param t_p2 vec2
---@param t_thickness number
---@param t_color vec4
function gui_draw_line(t_p1, t_p2, t_thickness, t_color) end

---@param t_position vec2
---@param t_size vec2
---@param t_progress number
---@param t_bg_color vec4
---@param t_fill_color vec4
function gui_draw_progress_bar(t_position, t_size, t_progress, t_bg_color, t_fill_color) end

---@param t_position vec2
---@param t_size vec2
---@param t_color vec4
function gui_draw_rect(t_position, t_size, t_color) end

---@param t_position vec2
---@param t_size vec2
---@param t_rounding number
---@param t_color vec4
function gui_draw_rect_rounded(t_position, t_size, t_rounding, t_color) end

---@param t_text string
---@param t_position vec2
---@param t_font_size number
---@param t_color vec4
---@param t_font_id string
---@param t_scale number
function gui_draw_text(t_text, t_position, t_font_size, t_color, t_font_id, t_scale) end

---@param t_text string
---@param t_rect_position vec2
---@param t_rect_size vec2
---@param t_h_align integer
---@param t_v_align integer
---@param t_font_size number
---@param t_color vec4
---@param t_font_id string
---@param t_scale number
function gui_draw_text_aligned(t_text, t_rect_position, t_rect_size, t_h_align, t_v_align, t_font_size, t_color, t_font_id, t_scale) end

---@param t_text string
---@param t_position vec2
---@param t_font_size number
---@param t_color vec4
---@param t_font_id string
---@param t_scale number
function gui_draw_text_shadowed(t_text, t_position, t_font_size, t_color, t_font_id, t_scale) end

---@param t_size vec2
function gui_dummy(t_size) end

function gui_end_child() end

function gui_end_design_canvas() end

function gui_end_popup() end

function gui_end_screen_canvas() end

function gui_end_window() end

---@param t_container_position vec2
---@param t_container_size vec2
---@param t_content_size vec2
---@param t_h_align integer
---@param t_v_align integer
---@param t_margin vec2
---@return vec2
function gui_get_aligned_position(t_container_position, t_container_size, t_content_size, t_h_align, t_v_align, t_margin) end

---@param t_parent_position vec2
---@param t_parent_size vec2
---@param t_content_size vec2
---@param t_anchor vec2
---@param t_pivot vec2
---@param t_offset vec2
---@return vec2
function gui_get_anchored_position(t_parent_position, t_parent_size, t_content_size, t_anchor, t_pivot, t_offset) end

---@param t_parent_position vec2
---@param t_parent_size vec2
---@param t_anchor_min vec2
---@param t_anchor_max vec2
---@param t_pivot vec2
---@param t_size_delta vec2
---@param t_anchored_position vec2
---@return vec2
function gui_get_anchored_rect(t_parent_position, t_parent_size, t_anchor_min, t_anchor_max, t_pivot, t_size_delta, t_anchored_position) end

---@return vec2
function gui_get_content_region_avail() end

---@return vec2
function gui_get_cursor_screen_pos() end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_design_to_screen_position(t_vec2_1) end

---@param t_number_1 number
---@return number
function gui_get_design_to_screen_scalar(t_number_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_design_to_screen_size(t_vec2_1) end

---@return vec2
function gui_get_display_size() end

---@return integer
function gui_get_draw_priority() end

---@return integer
function gui_get_focused_nav_step_y() end

---@return number
function gui_get_font_global_scale() end

---@return boolean
function gui_get_is_design_space_active() end

---@return boolean
function gui_get_is_interacting() end

---@return boolean
function gui_get_is_item_active() end

---@return boolean
function gui_get_is_item_focused() end

---@return boolean
function gui_get_is_item_hovered() end

---@return boolean
function gui_get_is_ui_nav_activate_pressed() end

---@return vec2
function gui_get_item_rect_min() end

---@return vec2
function gui_get_item_rect_size() end

---@return vec2
function gui_get_layout_size() end

---@return vec2
function gui_get_letterbox_offset() end

---@return number
function gui_get_letterbox_scale() end

---@return integer
function gui_get_menu_nav_step_y() end

---@param t_number_1 number
---@return number
function gui_get_normalized_to_pixels(t_number_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_normalized_to_position(t_vec2_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_normalized_to_size(t_vec2_1) end

---@param t_number_1 number
---@return vec2
function gui_get_normalized_to_uniform_size(t_number_1) end

---@param t_number_1 number
---@return number
function gui_get_pixels_to_normalized(t_number_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_position_to_normalized(t_vec2_1) end

---@return vec2
function gui_get_reference_resolution() end

---@return integer
function gui_get_scale_mode() end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_screen_to_design_position(t_vec2_1) end

---@param t_number_1 number
---@return number
function gui_get_screen_to_design_scalar(t_number_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_screen_to_design_size(t_vec2_1) end

---@param t_vec2_1 vec2
---@return vec2
function gui_get_size_to_normalized(t_vec2_1) end

---@param t_text string
---@param t_font_size number
---@param t_font_id string
---@param t_scale number
---@return vec2
function gui_get_text_size(t_text, t_font_size, t_font_id, t_scale) end

---@return boolean
function gui_get_want_capture_keyboard() end

---@return boolean
function gui_get_want_capture_mouse() end

---@return vec2
function gui_get_window_size() end

---@param t_texture_path string
---@param t_size vec2
function gui_image(t_texture_path, t_size) end

---@param t_id string
---@param t_text string
---@param t_width number
---@param t_max_length integer?
---@return boolean
function gui_input_text(t_id, t_text, t_width, t_max_length) end

---@param t_id string
---@param t_size vec2
---@param t_enable_nav boolean?
---@return boolean
function gui_invisible_button(t_id, t_size, t_enable_nav) end

---@param t_name string
function gui_open_popup(t_name) end

function gui_pop_clip_rect() end

function gui_pop_design_space() end

function gui_pop_draw_priority() end

function gui_pop_font() end

function gui_pop_foreground_draw() end

---@param t_count integer?
function gui_pop_style_color(t_count) end

---@param t_count integer?
function gui_pop_style_var(t_count) end

function gui_pop_text_wrap_pos() end

---@param t_fraction number
---@param t_overlay_text string
function gui_progress_bar(t_fraction, t_overlay_text) end

---@param t_clip_min vec2
---@param t_clip_max vec2
---@param t_intersect boolean
function gui_push_clip_rect(t_clip_min, t_clip_max, t_intersect) end

function gui_push_design_space() end

---@param t_priority integer
function gui_push_draw_priority(t_priority) end

---@param t_font_id string
function gui_push_font(t_font_id) end

function gui_push_foreground_draw() end

---@param t_color_idx integer
---@param t_color vec4
function gui_push_style_color(t_color_idx, t_color) end

---@param t_style_var integer
---@param t_value number
function gui_push_style_var_float(t_style_var, t_value) end

---@param t_style_var integer
---@param t_value vec2
function gui_push_style_var_vec2(t_style_var, t_value) end

---@param t_design_width number
function gui_push_text_wrap_width(t_design_width) end

---@param t_offset_from_start_x number
---@param t_spacing_w number
function gui_same_line(t_offset_from_start_x, t_spacing_w) end

function gui_separator() end

---@param t_position vec2
function gui_set_cursor_screen_pos(t_position) end

function gui_set_item_default_focus() end

---@param t_alpha number
function gui_set_next_window_bg_alpha(t_alpha) end

---@param t_position vec2
---@param t_cond integer?
function gui_set_next_window_pos(t_position, t_cond) end

---@param t_size vec2
---@param t_cond integer?
function gui_set_next_window_size(t_size, t_cond) end

---@param t_width number
---@param t_height number
function gui_set_reference_resolution(t_width, t_height) end

---@param t_mode integer
function gui_set_scale_mode(t_mode) end

---@param t_text string
function gui_set_tooltip(t_text) end

---@param t_label string
---@param t_value number
---@param t_min_value number
---@param t_max_value number
---@return number
function gui_slider_float(t_label, t_value, t_min_value, t_max_value) end

---@param t_spacing number
---@param t_boolean_2 boolean
function gui_spacing(t_spacing, t_boolean_2) end

---@param t_text string
function gui_text(t_text) end

---@param t_color vec4
---@param t_text string
function gui_text_colored(t_color, t_text) end

---@param t_text string
function gui_text_wrapped(t_text) end

-- Input

---@param t_binding string
---@return string
function input_get_action_binding_string(t_binding) end

---@param t_binding string
---@return string
function input_get_action_gamepad_binding_string(t_binding) end

---@param t_string_1 string
---@return boolean
function input_get_action_pressed_event(t_string_1) end

---@param t_binding string
---@return string
function input_get_action_prompt_binding_string(t_binding) end

---@param t_display string
---@return string
function input_get_action_prompt_display_string(t_display) end

---@param t_string_1 string
---@return boolean
function input_get_action_released_event(t_string_1) end

---@param t_string_1 string
---@return number
function input_get_action_strength(t_string_1) end

---@param t_display string
---@return string
function input_get_binding_display_string(t_display) end

---@param t_string_1 string
---@return number
function input_get_gamepad_axis(t_string_1) end

---@return boolean
function input_get_gamepad_rebind_allowed() end

---@return boolean
function input_get_has_gamepad_connected() end

---@param t_string_1 string
---@return boolean
function input_get_is_action_pressed(t_string_1) end

---@return boolean
function input_get_is_last_input_device_gamepad() end

---@return boolean
function input_get_is_last_input_device_mouse() end

---@param t_string_1 string
---@return boolean
function input_get_is_mouse_action_pressed(t_string_1) end

---@return string
function input_get_just_pressed_key_name() end

---@param t_string_1 string
---@return boolean
function input_get_mouse_action_pressed_event(t_string_1) end

---@param t_string_1 string
---@return boolean
function input_get_mouse_action_released_event(t_string_1) end

---@return boolean
function input_get_mouse_capture() end

---@return vec2
function input_get_mouse_delta() end

---@return vec2
function input_get_mouse_position() end

---@return boolean
function input_get_mouse_wheel_down() end

---@return boolean
function input_get_mouse_wheel_up() end

---@param t_string_1 string
---@param t_string_2 string
function input_set_action_binding_string(t_string_1, t_string_2) end

---@param t_boolean_1 boolean
function input_set_gamepad_rebind_allowed(t_boolean_1) end

---@param t_boolean_1 boolean
function input_set_mouse_capture(t_boolean_1) end

-- Light

---@param t_entity_id integer
---@return number
function light_get_angle(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function light_get_cast_shadows(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function light_get_cast_specular(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function light_get_color(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_default_lumens(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_default_temperature_k(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function light_get_effective_color(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function light_get_ignore_distance_culling(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_lumens(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_range(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_shadow_bias(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_shadow_blur(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_shadow_normal_bias(t_entity_id) end

---@param t_entity_id integer
---@return number
function light_get_temperature_k(t_entity_id) end

---@param t_entity_id integer
---@return integer
function light_get_type(t_entity_id) end

---@param t_entity_id integer
---@param t_angle_degrees number
function light_set_angle(t_entity_id, t_angle_degrees) end

---@param t_entity_id integer
---@param t_cast_shadows boolean
function light_set_cast_shadows(t_entity_id, t_cast_shadows) end

---@param t_entity_id integer
---@param t_cast_specular boolean
function light_set_cast_specular(t_entity_id, t_cast_specular) end

---@param t_entity_id integer
---@param t_color vec3
function light_set_color(t_entity_id, t_color) end

---@param t_entity_id integer
---@param t_ignore_distance_culling boolean
function light_set_ignore_distance_culling(t_entity_id, t_ignore_distance_culling) end

---@param t_entity_id integer
---@param t_lumens number
function light_set_lumens(t_entity_id, t_lumens) end

---@param t_entity_id integer
---@param t_range number
function light_set_range(t_entity_id, t_range) end

---@param t_entity_id integer
---@param t_bias number
function light_set_shadow_bias(t_entity_id, t_bias) end

---@param t_entity_id integer
---@param t_blur number
function light_set_shadow_blur(t_entity_id, t_blur) end

---@param t_entity_id integer
---@param t_normal_bias number
function light_set_shadow_normal_bias(t_entity_id, t_normal_bias) end

---@param t_entity_id integer
---@param t_temperature_k number
function light_set_temperature_k(t_entity_id, t_temperature_k) end

---@param t_entity_id integer
---@param t_light_type integer
function light_set_type(t_entity_id, t_light_type) end

-- Mat3

---@param t_diagonal number
---@return mat3
function mat3(t_diagonal) end

---@param t_mat mat3
---@return number
function mat3_determinant(t_mat) end

---@param t_quat quat
---@return mat3
function mat3_from_quat(t_quat) end

---@return mat3
function mat3_identity() end

---@param t_mat mat3
---@return mat3
function mat3_inverse(t_mat) end

---@param t_a mat3
---@param t_b mat3
---@return mat3
function mat3_mul(t_a, t_b) end

---@param t_mat mat3
---@param t_vec vec3
---@return vec3
function mat3_mul_vec3(t_mat, t_vec) end

---@param t_mat mat3
---@return mat3
function mat3_transpose(t_mat) end

-- Mat4

---@param t_diagonal number
---@return mat4
function mat4(t_diagonal) end

---@param t_mat mat4
---@return number
function mat4_determinant(t_mat) end

---@param t_quat quat
---@return mat4
function mat4_from_quat(t_quat) end

---@return mat4
function mat4_identity() end

---@param t_mat mat4
---@return mat4
function mat4_inverse(t_mat) end

---@param t_eye vec3
---@param t_center vec3
---@param t_up vec3
---@return mat4
function mat4_look_at(t_eye, t_center, t_up) end

---@param t_a mat4
---@param t_b mat4
---@return mat4
function mat4_mul(t_a, t_b) end

---@param t_mat mat4
---@param t_vec vec4
---@return vec4
function mat4_mul_vec4(t_mat, t_vec) end

---@param t_left number
---@param t_right number
---@param t_bottom number
---@param t_top number
---@param t_near_val number
---@param t_far_val number
---@return mat4
function mat4_ortho(t_left, t_right, t_bottom, t_top, t_near_val, t_far_val) end

---@param t_fovy number
---@param t_aspect number
---@param t_near_val number
---@param t_far_val number
---@return mat4
function mat4_perspective(t_fovy, t_aspect, t_near_val, t_far_val) end

---@param t_mat mat4
---@param t_angle number
---@param t_axis vec3
---@return mat4
function mat4_rotate(t_mat, t_angle, t_axis) end

---@param t_mat mat4
---@param t_scale vec3
---@return mat4
function mat4_scale(t_mat, t_scale) end

---@param t_mat mat4
---@param t_translation vec3
---@return mat4
function mat4_translate(t_mat, t_translation) end

---@param t_mat mat4
---@return mat4
function mat4_transpose(t_mat) end

-- Math

---@param t_value number
---@return number
function math_abs(t_value) end

---@param t_value number
---@return number
function math_acos(t_value) end

---@param t_value number
---@return number
function math_asin(t_value) end

---@param t_value number
---@return number
function math_atan(t_value) end

---@param t_y number
---@param t_x number
---@return number
function math_atan2(t_y, t_x) end

---@param t_value number
---@return number
function math_ceil(t_value) end

---@param t_value number
---@param t_min_val number
---@param t_max_val number
---@return number
function math_clamp(t_value, t_min_val, t_max_val) end

---@param t_value number
---@return number
function math_cos(t_value) end

---@param t_radians number
---@return number
function math_degrees(t_radians) end

---@param t_value number
---@return number
function math_floor(t_value) end

---@param t_value number
---@return number
function math_fract(t_value) end

---@param t_a number
---@param t_b number
---@param t_t number
---@return number
function math_lerp(t_a, t_b, t_t) end

---@param t_a number
---@param t_b number
---@return number
function math_max(t_a, t_b) end

---@param t_a number
---@param t_b number
---@return number
function math_min(t_a, t_b) end

---@param t_x number
---@param t_y number
---@return number
function math_mod(t_x, t_y) end

---@param t_base number
---@param t_exponent number
---@return number
function math_pow(t_base, t_exponent) end

---@param t_degrees number
---@return number
function math_radians(t_degrees) end

---@param t_value number
---@return number
function math_round(t_value) end

---@param t_value number
---@return number
function math_sin(t_value) end

---@param t_edge0 number
---@param t_edge1 number
---@param t_x number
---@return number
function math_smoothstep(t_edge0, t_edge1, t_x) end

---@param t_value number
---@return number
function math_sqrt(t_value) end

---@param t_edge number
---@param t_x number
---@return number
function math_step(t_edge, t_x) end

---@param t_value number
---@return number
function math_tan(t_value) end

-- Mesh

---@param t_entity_id integer
---@return boolean
function mesh_get_casts_shadows(t_entity_id) end

---@param t_entity_id integer
---@return string
function mesh_get_file(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function mesh_get_is_gpu_instancing_active(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function mesh_get_is_unique_material(t_entity_id) end

---@param t_entity_id integer
---@param t_integer_2 integer
---@return string
function mesh_get_material_file(t_entity_id, t_integer_2) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_integer_3 integer
---@return boolean
function mesh_get_uniform_bool(t_entity_id, t_uniform_name, t_integer_3) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_integer_3 integer
---@return number
function mesh_get_uniform_float(t_entity_id, t_uniform_name, t_integer_3) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_integer_3 integer
---@return vec2
function mesh_get_uniform_vec2(t_entity_id, t_uniform_name, t_integer_3) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_integer_3 integer
---@return vec3
function mesh_get_uniform_vec3(t_entity_id, t_uniform_name, t_integer_3) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_integer_3 integer
---@return vec4
function mesh_get_uniform_vec4(t_entity_id, t_uniform_name, t_integer_3) end

---@param t_entity_id integer
---@return boolean
function mesh_get_visible(t_entity_id) end

---@param t_entity_id integer
---@param t_casts_shadows boolean
function mesh_set_casts_shadows(t_entity_id, t_casts_shadows) end

---@param t_entity_id integer
---@param t_mesh_file string
function mesh_set_file(t_entity_id, t_mesh_file) end

---@param t_entity_id integer
---@param t_active boolean
function mesh_set_gpu_instancing_active(t_entity_id, t_active) end

---@param t_entity_id integer
---@param t_index integer
---@param t_material_file string
function mesh_set_material_file(t_entity_id, t_index, t_material_file) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value boolean
---@param t_integer_4 integer
function mesh_set_uniform_bool(t_entity_id, t_uniform_name, t_value, t_integer_4) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value number
---@param t_integer_4 integer
function mesh_set_uniform_float(t_entity_id, t_uniform_name, t_value, t_integer_4) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec2
---@param t_integer_4 integer
function mesh_set_uniform_vec2(t_entity_id, t_uniform_name, t_value, t_integer_4) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec3
---@param t_integer_4 integer
function mesh_set_uniform_vec3(t_entity_id, t_uniform_name, t_value, t_integer_4) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec4
---@param t_integer_4 integer
function mesh_set_uniform_vec4(t_entity_id, t_uniform_name, t_value, t_integer_4) end

---@param t_entity_id integer
---@param t_unique boolean
function mesh_set_unique_material(t_entity_id, t_unique) end

---@param t_entity_id integer
---@param t_visible boolean
function mesh_set_visible(t_entity_id, t_visible) end

-- Module

---@param t_table_1 table
function call_function_handle(t_table_1, ...) end

---@param t_module_name string
---@param t_function_name string
function module_call_function(t_module_name, t_function_name, ...) end

---@param t_module_name string
---@return integer
function module_get(t_module_name) end

---@param t_module_name string
---@param t_function_name string
---@return table
function module_get_function(t_module_name, t_function_name) end

---@param t_module_name string
---@return boolean
function module_get_is_valid(t_module_name) end

-- Music

---@param t_fade_duration number
function music_fade_in(t_fade_duration) end

---@return number
function music_get_duration() end

---@return string
function music_get_fade_state() end

---@return string
function music_get_file_path() end

---@return boolean
function music_get_is_paused() end

---@return boolean
function music_get_is_playing() end

---@return number
function music_get_mix_multiplier() end

---@return number
function music_get_playback_volume() end

---@return number
function music_get_time() end

---@return number
function music_get_volume() end

---@param t_file_path string
---@param t_looping boolean
---@param t_fade_duration number
function music_play(t_file_path, t_looping, t_fade_duration) end

---@param t_multiplier number
function music_set_mix_multiplier(t_multiplier) end

---@param t_paused boolean
function music_set_paused(t_paused) end

---@param t_time_seconds number
function music_set_time(t_time_seconds) end

---@param t_volume number
function music_set_volume(t_volume) end

---@param t_fade_duration number
function music_stop(t_fade_duration) end

-- Particle_system

---@param t_entity_id integer
function particle_system_clear(t_entity_id) end

---@param t_entity_id integer
---@return number
function particle_system_get_culling_distance(t_entity_id) end

---@param t_entity_id integer
---@return number
function particle_system_get_emission_rate(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function particle_system_get_is_playing(t_entity_id) end

---@param t_entity_id integer
---@return number
function particle_system_get_lod_far_distance(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_lod_far_skip(t_entity_id) end

---@param t_entity_id integer
---@return number
function particle_system_get_lod_mid_distance(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_lod_mid_skip(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function particle_system_get_lod_throttling(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function particle_system_get_loop(t_entity_id) end

---@param t_entity_id integer
---@return string
function particle_system_get_material_file(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_max_particles(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_sprite_frame_columns(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_sprite_frame_count(t_entity_id) end

---@param t_entity_id integer
---@return number
function particle_system_get_sprite_frame_rate(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_sprite_frame_rows(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function particle_system_get_sprite_loop(t_entity_id) end

---@param t_entity_id integer
---@return string
function particle_system_get_sprite_mode(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function particle_system_get_sprite_random_start_frame(t_entity_id) end

---@param t_entity_id integer
---@return integer
function particle_system_get_sprite_start_frame(t_entity_id) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return boolean
function particle_system_get_uniform_bool(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return number
function particle_system_get_uniform_float(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
---@param t_uniform_name string
---@return vec3
function particle_system_get_uniform_vec3(t_entity_id, t_uniform_name) end

---@param t_entity_id integer
function particle_system_play(t_entity_id) end

---@param t_entity_id integer
function particle_system_restart(t_entity_id) end

---@param t_entity_id integer
---@param t_distance number
function particle_system_set_culling_distance(t_entity_id, t_distance) end

---@param t_entity_id integer
---@param t_rate number
function particle_system_set_emission_rate(t_entity_id, t_rate) end

---@param t_entity_id integer
---@param t_distance number
function particle_system_set_lod_far_distance(t_entity_id, t_distance) end

---@param t_entity_id integer
---@param t_frames integer
function particle_system_set_lod_far_skip(t_entity_id, t_frames) end

---@param t_entity_id integer
---@param t_distance number
function particle_system_set_lod_mid_distance(t_entity_id, t_distance) end

---@param t_entity_id integer
---@param t_frames integer
function particle_system_set_lod_mid_skip(t_entity_id, t_frames) end

---@param t_entity_id integer
---@param t_enabled boolean
function particle_system_set_lod_throttling(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_loop boolean
function particle_system_set_loop(t_entity_id, t_loop) end

---@param t_entity_id integer
---@param t_material_file string
function particle_system_set_material_file(t_entity_id, t_material_file) end

---@param t_entity_id integer
---@param t_count integer
function particle_system_set_max_particles(t_entity_id, t_count) end

---@param t_entity_id integer
---@param t_columns integer
function particle_system_set_sprite_frame_columns(t_entity_id, t_columns) end

---@param t_entity_id integer
---@param t_frame_count integer
function particle_system_set_sprite_frame_count(t_entity_id, t_frame_count) end

---@param t_entity_id integer
---@param t_frame_rate number
function particle_system_set_sprite_frame_rate(t_entity_id, t_frame_rate) end

---@param t_entity_id integer
---@param t_rows integer
function particle_system_set_sprite_frame_rows(t_entity_id, t_rows) end

---@param t_entity_id integer
---@param t_loop boolean
function particle_system_set_sprite_loop(t_entity_id, t_loop) end

---@param t_entity_id integer
---@param t_mode_name string
function particle_system_set_sprite_mode(t_entity_id, t_mode_name) end

---@param t_entity_id integer
---@param t_random boolean
function particle_system_set_sprite_random_start_frame(t_entity_id, t_random) end

---@param t_entity_id integer
---@param t_start_frame integer
function particle_system_set_sprite_start_frame(t_entity_id, t_start_frame) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value boolean
function particle_system_set_uniform_bool(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value number
function particle_system_set_uniform_float(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
---@param t_uniform_name string
---@param t_value vec3
function particle_system_set_uniform_vec3(t_entity_id, t_uniform_name, t_value) end

---@param t_entity_id integer
function particle_system_stop(t_entity_id) end

-- Pathfinding

---@param t_position vec3
---@return integer
function pathfinding_find_nearest_node(t_position) end

---@param t_start_id integer
---@param t_end_id integer
---@return table
function pathfinding_find_path(t_start_id, t_end_id) end

-- Pathnode

---@param t_entity_id integer
---@param t_target_id integer
function pathnode_add_connection(t_entity_id, t_target_id) end

---@param t_entity_id integer
---@return table
function pathnode_get_connections(t_entity_id) end

---@param t_entity_id integer
---@param t_target_id integer
function pathnode_remove_connection(t_entity_id, t_target_id) end

-- Physics

function physics_activate_all_dynamic_bodies() end

---@param t_from vec3
---@param t_to vec3
---@param t_half_extents vec3
---@param t_table_4 table
---@param t_include_mode boolean
function physics_box_sweep(t_from, t_to, t_half_extents, t_table_4, t_include_mode) end

---@param t_from vec3
---@param t_to vec3
---@param t_radius number
---@param t_height number
---@param t_table_5 table
---@param t_include_mode boolean
function physics_capsule_sweep(t_from, t_to, t_radius, t_height, t_table_5, t_include_mode) end

---@param t_entity_id integer
---@return integer
function physics_get_body_type(t_entity_id) end

---@return vec3
function physics_get_gravity() end

---@param t_from vec3
---@param t_to vec3
---@param t_table_3 table
---@param t_include_mode boolean
function physics_raycast(t_from, t_to, t_table_3, t_include_mode) end

function physics_reset_gravity() end

---@param t_entity_id integer
---@param t_body_type integer
function physics_set_body_type(t_entity_id, t_body_type) end

---@param t_gravity vec3
function physics_set_gravity(t_gravity) end

---@param t_from vec3
---@param t_to vec3
---@param t_radius number
---@param t_table_4 table
---@param t_include_mode boolean
function physics_sphere_sweep(t_from, t_to, t_radius, t_table_4, t_include_mode) end

-- Physics_body

---@param t_entity_id integer
---@param t_shape_type integer
---@param t_size vec3
---@param t_offset vec3
---@param t_rotation vec3
function physics_body_add_collision_shape(t_entity_id, t_shape_type, t_size, t_offset, t_rotation) end

---@param t_entity_id integer
function physics_body_clear_collision_shapes(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_collision_callback_filter_character(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_collision_callback_filter_dynamic(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_collision_callback_filter_kinematic(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_collision_callback_filter_static(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_collision_callbacks_enabled(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_body_get_collision_layer(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_body_get_collision_mask(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_body_get_collision_shape_count(t_entity_id) end

---@param t_entity_id integer
---@param t_shape_index integer
---@return vec3
function physics_body_get_collision_shape_offset(t_entity_id, t_shape_index) end

---@param t_entity_id integer
---@param t_shape_index integer
---@return vec3
function physics_body_get_collision_shape_rotation(t_entity_id, t_shape_index) end

---@param t_entity_id integer
---@param t_shape_index integer
---@return vec3
function physics_body_get_collision_shape_size(t_entity_id, t_shape_index) end

---@param t_entity_id integer
---@param t_shape_index integer
---@return integer
function physics_body_get_collision_shape_type(t_entity_id, t_shape_index) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_debug_draw_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_trigger_callbacks_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_body_get_use_ccd(t_entity_id) end

---@param t_entity_id integer
---@param t_shape_index integer
function physics_body_remove_collision_shape(t_entity_id, t_shape_index) end

---@param t_entity_id integer
---@param t_filter_static boolean
---@param t_filter_kinematic boolean
---@param t_filter_dynamic boolean
---@param t_boolean_5 boolean
function physics_body_set_collision_callback_body_type_filter(t_entity_id, t_filter_static, t_filter_kinematic, t_filter_dynamic, t_boolean_5) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_collision_callback_filter_character(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_collision_callback_filter_dynamic(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_collision_callback_filter_kinematic(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_collision_callback_filter_static(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_collision_callbacks_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_layer integer
function physics_body_set_collision_layer(t_entity_id, t_layer) end

---@param t_entity_id integer
---@param t_mask integer
function physics_body_set_collision_mask(t_entity_id, t_mask) end

---@param t_entity_id integer
---@param t_shape_index integer
---@param t_offset vec3
function physics_body_set_collision_shape_offset(t_entity_id, t_shape_index, t_offset) end

---@param t_entity_id integer
---@param t_shape_index integer
---@param t_rotation vec3
function physics_body_set_collision_shape_rotation(t_entity_id, t_shape_index, t_rotation) end

---@param t_entity_id integer
---@param t_shape_index integer
---@param t_size vec3
function physics_body_set_collision_shape_size(t_entity_id, t_shape_index, t_size) end

---@param t_entity_id integer
---@param t_shape_index integer
---@param t_shape_type integer
function physics_body_set_collision_shape_type(t_entity_id, t_shape_index, t_shape_type) end

---@param t_entity_id integer
---@param t_debug_draw boolean
function physics_body_set_debug_draw_enabled(t_entity_id, t_debug_draw) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_trigger_callbacks_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_body_set_use_ccd(t_entity_id, t_enabled) end

---@param t_entity_id integer
function physics_body_warp_to_transform(t_entity_id) end

-- Physics_constraint

---@param t_entity_id integer
---@return vec3
function physics_constraint_get_anchor_1(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function physics_constraint_get_anchor_2(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function physics_constraint_get_axis(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_constraint_get_body_a_entity_id(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_constraint_get_body_b_entity_id(t_entity_id) end

---@param t_entity_id integer
---@return number
function physics_constraint_get_break_force(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_breakable(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_collide_connected(t_entity_id) end

---@param t_entity_id integer
---@return integer
function physics_constraint_get_constraint_type(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_enabled(t_entity_id) end

---@param t_entity_id integer
---@return number
function physics_constraint_get_friction(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_is_broken(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_is_created(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function physics_constraint_get_limits_enabled(t_entity_id) end

---@param t_entity_id integer
---@return number
function physics_constraint_get_limits_max(t_entity_id) end

---@param t_entity_id integer
---@return number
function physics_constraint_get_limits_min(t_entity_id) end

---@param t_entity_id integer
function physics_constraint_recreate(t_entity_id) end

---@param t_entity_id integer
---@param t_anchor vec3
function physics_constraint_set_anchor_1(t_entity_id, t_anchor) end

---@param t_entity_id integer
---@param t_anchor vec3
function physics_constraint_set_anchor_2(t_entity_id, t_anchor) end

---@param t_entity_id integer
---@param t_axis vec3
function physics_constraint_set_axis(t_entity_id, t_axis) end

---@param t_entity_id integer
---@param t_body_a_entity_id integer
function physics_constraint_set_body_a_entity_id(t_entity_id, t_body_a_entity_id) end

---@param t_entity_id integer
---@param t_body_b_entity_id integer
function physics_constraint_set_body_b_entity_id(t_entity_id, t_body_b_entity_id) end

---@param t_entity_id integer
---@param t_break_force number
function physics_constraint_set_break_force(t_entity_id, t_break_force) end

---@param t_entity_id integer
---@param t_breakable boolean
function physics_constraint_set_breakable(t_entity_id, t_breakable) end

---@param t_entity_id integer
---@param t_collide_connected boolean
function physics_constraint_set_collide_connected(t_entity_id, t_collide_connected) end

---@param t_entity_id integer
---@param t_constraint_type integer
function physics_constraint_set_constraint_type(t_entity_id, t_constraint_type) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_constraint_set_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_friction number
function physics_constraint_set_friction(t_entity_id, t_friction) end

---@param t_entity_id integer
---@param t_enabled boolean
function physics_constraint_set_limits_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_limits_max number
function physics_constraint_set_limits_max(t_entity_id, t_limits_max) end

---@param t_entity_id integer
---@param t_limits_min number
function physics_constraint_set_limits_min(t_entity_id, t_limits_min) end

-- Platform

---@param t_url string
---@return boolean
function platform_open_url(t_url) end

-- Print

---@param t_message string
function print_debug(t_message) end

---@param t_message string
function print_error(t_message) end

---@param t_message string
function print_info(t_message) end

---@param t_message string
function print_warning(t_message) end

-- Quat

---@param t_w number
---@param t_x number
---@param t_y number
---@param t_z number
---@return quat
function quat(t_w, t_x, t_y, t_z) end

---@param t_quat quat
---@return quat
function quat_conjugate(t_quat) end

---@param t_a quat
---@param t_b quat
---@return number
function quat_dot(t_a, t_b) end

---@param t_axis vec3
---@param t_angle number
---@return quat
function quat_from_axis_angle(t_axis, t_angle) end

---@param t_euler vec3
---@return quat
function quat_from_euler(t_euler) end

---@param t_direction vec3
---@param t_up vec3
---@return quat
function quat_from_look_at(t_direction, t_up) end

---@return quat
function quat_identity() end

---@param t_quat quat
---@return quat
function quat_inverse(t_quat) end

---@param t_quat quat
---@return number
function quat_length(t_quat) end

---@param t_a quat
---@param t_b quat
---@return quat
function quat_mul(t_a, t_b) end

---@param t_quat quat
---@return quat
function quat_normalize(t_quat) end

---@param t_quat quat
---@param t_vec vec3
---@return vec3
function quat_rotate_vec3(t_quat, t_vec) end

---@param t_a quat
---@param t_b quat
---@param t_t number
---@return quat
function quat_slerp(t_a, t_b, t_t) end

---@param t_quat quat
---@return table
function quat_to_axis_angle(t_quat) end

---@param t_quat quat
---@return vec3
function quat_to_euler(t_quat) end

---@param t_quat quat
---@return mat3
function quat_to_mat3(t_quat) end

---@param t_quat quat
---@return mat4
function quat_to_mat4(t_quat) end

-- Renderer

function renderer_clear_wind_noise_texture_file() end

---@return number
function renderer_get_auto_exposure_bias() end

---@return number
function renderer_get_auto_exposure_center_weight() end

---@return number
function renderer_get_auto_exposure_ev_max() end

---@return number
function renderer_get_auto_exposure_ev_min() end

---@return number
function renderer_get_auto_exposure_key() end

---@return number
function renderer_get_auto_exposure_speed_down() end

---@return number
function renderer_get_auto_exposure_speed_up() end

---@return number
function renderer_get_bloom_blur_radius() end

---@return number
function renderer_get_bloom_intensity() end

---@return number
function renderer_get_bloom_knee() end

---@return number
function renderer_get_bloom_threshold() end

---@return number
function renderer_get_current_exposure_ev100() end

---@param t_pass_index integer
---@return vec3
function renderer_get_custom_post_process_color(t_pass_index) end

---@param t_pass_index integer
---@return number
function renderer_get_custom_post_process_intensity(t_pass_index) end

---@param t_pass_index integer
---@return vec4
function renderer_get_custom_post_process_params(t_pass_index) end

---@return integer
function renderer_get_custom_post_process_pass_count() end

---@param t_pass_index integer
---@return string
function renderer_get_custom_post_process_shader_file(t_pass_index) end

---@param t_pass_index integer
---@return string
function renderer_get_custom_post_process_texture_file(t_pass_index) end

---@return integer
function renderer_get_debug_view_mode() end

---@return number
function renderer_get_distance_culling_distance() end

---@return number
function renderer_get_distant_world_darken_end() end

---@return number
function renderer_get_distant_world_darken_factor() end

---@return number
function renderer_get_distant_world_darken_start() end

---@return number
function renderer_get_exposure_ev100() end

---@return number
function renderer_get_fog_absorption() end

---@return number
function renderer_get_fog_cloud_altitude_origin() end

---@return number
function renderer_get_fog_cloud_base_scale() end

---@return number
function renderer_get_fog_cloud_detail_scale() end

---@return number
function renderer_get_fog_cloud_detail_wind_speed() end

---@return number
function renderer_get_fog_cloud_max_multiplier() end

---@return number
function renderer_get_fog_cloud_min_multiplier() end

---@return number
function renderer_get_fog_cloud_vertical_warp() end

---@return number
function renderer_get_fog_cloud_wind_speed() end

---@return vec3
function renderer_get_fog_color() end

---@return number
function renderer_get_fog_density() end

---@return number
function renderer_get_fog_luminance() end

---@return boolean
function renderer_get_fog_luminance_synced_to_sky() end

---@return number
function renderer_get_fog_sky_intensity() end

---@return number
function renderer_get_fog_start_distance() end

---@return number
function renderer_get_fog_volumetric_ambient_strength() end

---@return number
function renderer_get_fog_volumetric_phase_g() end

---@return vec3
function renderer_get_fog_volumetric_scattering_color() end

---@return number
function renderer_get_fog_volumetric_scattering_strength() end

---@return number
function renderer_get_fog_volumetric_sky_scatter_strength() end

---@return number
function renderer_get_fog_volumetric_sun_visibility_min() end

---@return number
function renderer_get_gamma() end

---@return number
function renderer_get_global_wetness_intensity() end

---@return boolean
function renderer_get_has_wind_noise_texture() end

---@return number
function renderer_get_image_trail_intensity() end

---@return boolean
function renderer_get_is_auto_exposure_active() end

---@return boolean
function renderer_get_is_bloom_active() end

---@return boolean
function renderer_get_is_color_correction_active() end

---@param t_pass_index integer
---@return boolean
function renderer_get_is_custom_post_process_active(t_pass_index) end

---@return boolean
function renderer_get_is_distant_world_darken_active() end

---@return boolean
function renderer_get_is_fog_active() end

---@return boolean
function renderer_get_is_fog_affect_sky() end

---@return boolean
function renderer_get_is_fog_end_clamp_active() end

---@return boolean
function renderer_get_is_fog_volumetric_active() end

---@return boolean
function renderer_get_is_fog_wind_texture_active() end

---@return boolean
function renderer_get_is_fxaa_active() end

---@return boolean
function renderer_get_is_local_light_shadows_active() end

---@return boolean
function renderer_get_is_local_light_shadows_distance_culling_active() end

---@return boolean
function renderer_get_is_local_lights_culling_active() end

---@return boolean
function renderer_get_is_local_lights_distance_culling_active() end

---@return boolean
function renderer_get_is_local_lights_frustum_culling_active() end

---@return boolean
function renderer_get_is_sky_active() end

---@return boolean
function renderer_get_is_sky_ibl_active() end

---@return boolean
function renderer_get_is_ssao_active() end

---@return boolean
function renderer_get_is_ssao_globally_enabled() end

---@return boolean
function renderer_get_is_ssao_runtime_active() end

---@return boolean
function renderer_get_is_ssr_active() end

---@return boolean
function renderer_get_is_ssr_globally_enabled() end

---@return boolean
function renderer_get_is_ssr_runtime_active() end

---@return boolean
function renderer_get_is_sunlight_active() end

---@return boolean
function renderer_get_is_sunlight_shadow_active() end

---@return boolean
function renderer_get_is_wind_active() end

---@return number
function renderer_get_local_light_shadows_fade_range() end

---@return number
function renderer_get_local_light_shadows_max_distance() end

---@return number
function renderer_get_local_lights_distance_culling_fade_range() end

---@return number
function renderer_get_local_lights_distance_culling_max_distance() end

---@return boolean
function renderer_get_ortho_mode() end

function renderer_get_radial_blur_center() end

---@return number
function renderer_get_radial_blur_intensity() end

---@return integer
function renderer_get_radial_blur_samples() end

---@return number
function renderer_get_render_scale() end

---@return vec3
function renderer_get_screen_fade_color() end

---@return number
function renderer_get_screen_fade_intensity() end

---@return number
function renderer_get_sky_ambient_lux() end

---@return number
function renderer_get_sky_brightness() end

---@return vec3
function renderer_get_sky_color() end

---@return number
function renderer_get_sky_contrast() end

---@return number
function renderer_get_sky_diffuse_ibl_intensity() end

---@return number
function renderer_get_sky_fill_luminance_nits() end

---@return boolean
function renderer_get_sky_ibl_apply_fog() end

---@return number
function renderer_get_sky_rotation() end

---@return number
function renderer_get_sky_specular_ibl_intensity() end

---@return string
function renderer_get_sky_texture_file() end

---@return number
function renderer_get_ssao_bias() end

---@return integer
function renderer_get_ssao_blur_size() end

---@return integer
function renderer_get_ssao_quality() end

---@return number
function renderer_get_ssao_radius() end

---@return number
function renderer_get_ssao_strength() end

---@return number
function renderer_get_ssr_edge_fade() end

---@return integer
function renderer_get_ssr_max_steps() end

---@return integer
function renderer_get_ssr_quality() end

---@return integer
function renderer_get_ssr_reflection_source_mode() end

---@return vec3
function renderer_get_ssr_reflection_static_color() end

---@return number
function renderer_get_ssr_step_size() end

---@return number
function renderer_get_ssr_strength() end

---@return number
function renderer_get_ssr_thickness() end

---@return vec3
function renderer_get_sunlight_color() end

---@return vec3
function renderer_get_sunlight_direction() end

---@return number
function renderer_get_sunlight_lux() end

---@return number
function renderer_get_sunlight_shadow_bias() end

---@return number
function renderer_get_sunlight_shadow_blur() end

---@return number
function renderer_get_sunlight_shadow_distance() end

---@return number
function renderer_get_sunlight_shadow_normal_bias() end

---@return number
function renderer_get_sunlight_specular_intensity() end

---@return number
function renderer_get_sunlight_temperature_k() end

---@return number
function renderer_get_tonemap_brightness() end

---@return vec3
function renderer_get_tonemap_color_highlights() end

---@return vec3
function renderer_get_tonemap_color_midtones() end

---@return vec3
function renderer_get_tonemap_color_shadows() end

---@return number
function renderer_get_tonemap_contrast() end

---@return number
function renderer_get_tonemap_highlight_range() end

---@return number
function renderer_get_tonemap_saturation() end

---@return number
function renderer_get_tonemap_shadow_range() end

function renderer_get_wind_direction() end

---@return string
function renderer_get_wind_noise_texture_file() end

---@return number
function renderer_get_wind_speed() end

---@param t_active boolean
function renderer_set_auto_exposure_active(t_active) end

---@param t_bias number
function renderer_set_auto_exposure_bias(t_bias) end

---@param t_weight number
function renderer_set_auto_exposure_center_weight(t_weight) end

---@param t_ev_max number
function renderer_set_auto_exposure_ev_max(t_ev_max) end

---@param t_ev_min number
function renderer_set_auto_exposure_ev_min(t_ev_min) end

---@param t_key number
function renderer_set_auto_exposure_key(t_key) end

function renderer_set_auto_exposure_snap() end

---@param t_speed number
function renderer_set_auto_exposure_speed_down(t_speed) end

---@param t_speed number
function renderer_set_auto_exposure_speed_up(t_speed) end

---@param t_active boolean
function renderer_set_bloom_active(t_active) end

---@param t_radius number
function renderer_set_bloom_blur_radius(t_radius) end

---@param t_intensity number
function renderer_set_bloom_intensity(t_intensity) end

---@param t_knee number
function renderer_set_bloom_knee(t_knee) end

---@param t_threshold number
function renderer_set_bloom_threshold(t_threshold) end

---@param t_active boolean
function renderer_set_color_correction_active(t_active) end

---@param t_pass_index integer
---@param t_active boolean
function renderer_set_custom_post_process_active(t_pass_index, t_active) end

---@param t_pass_index integer
---@param t_color vec3
function renderer_set_custom_post_process_color(t_pass_index, t_color) end

---@param t_pass_index integer
---@param t_intensity number
function renderer_set_custom_post_process_intensity(t_pass_index, t_intensity) end

---@param t_pass_index integer
---@param t_params vec4
function renderer_set_custom_post_process_params(t_pass_index, t_params) end

---@param t_pass_index integer
---@param t_file_path string
function renderer_set_custom_post_process_shader_file(t_pass_index, t_file_path) end

---@param t_pass_index integer
---@param t_file_path string
function renderer_set_custom_post_process_texture_file(t_pass_index, t_file_path) end

---@param t_mode integer
function renderer_set_debug_view_mode(t_mode) end

---@param t_distance number
function renderer_set_distance_culling_distance(t_distance) end

---@param t_active boolean
function renderer_set_distant_world_darken_active(t_active) end

---@param t_end number
function renderer_set_distant_world_darken_end(t_end) end

---@param t_factor number
function renderer_set_distant_world_darken_factor(t_factor) end

---@param t_start number
function renderer_set_distant_world_darken_start(t_start) end

---@param t_ev100 number
function renderer_set_exposure_ev100(t_ev100) end

---@param t_absorption number
function renderer_set_fog_absorption(t_absorption) end

---@param t_active boolean
function renderer_set_fog_active(t_active) end

---@param t_affect boolean
function renderer_set_fog_affect_sky(t_affect) end

---@param t_value number
function renderer_set_fog_cloud_altitude_origin(t_value) end

---@param t_value number
function renderer_set_fog_cloud_base_scale(t_value) end

---@param t_value number
function renderer_set_fog_cloud_detail_scale(t_value) end

---@param t_value number
function renderer_set_fog_cloud_detail_wind_speed(t_value) end

---@param t_value number
function renderer_set_fog_cloud_max_multiplier(t_value) end

---@param t_value number
function renderer_set_fog_cloud_min_multiplier(t_value) end

---@param t_value number
function renderer_set_fog_cloud_vertical_warp(t_value) end

---@param t_value number
function renderer_set_fog_cloud_wind_speed(t_value) end

---@param t_color vec3
function renderer_set_fog_color(t_color) end

---@param t_density number
function renderer_set_fog_density(t_density) end

---@param t_active boolean
function renderer_set_fog_end_clamp_active(t_active) end

---@param t_luminance number
function renderer_set_fog_luminance(t_luminance) end

---@param t_synced boolean
function renderer_set_fog_luminance_synced_to_sky(t_synced) end

---@param t_intensity number
function renderer_set_fog_sky_intensity(t_intensity) end

---@param t_distance number
function renderer_set_fog_start_distance(t_distance) end

---@param t_active boolean
function renderer_set_fog_volumetric_active(t_active) end

---@param t_strength number
function renderer_set_fog_volumetric_ambient_strength(t_strength) end

---@param t_phase_g number
function renderer_set_fog_volumetric_phase_g(t_phase_g) end

---@param t_color vec3
function renderer_set_fog_volumetric_scattering_color(t_color) end

---@param t_strength number
function renderer_set_fog_volumetric_scattering_strength(t_strength) end

---@param t_strength number
function renderer_set_fog_volumetric_sky_scatter_strength(t_strength) end

---@param t_visibility number
function renderer_set_fog_volumetric_sun_visibility_min(t_visibility) end

---@param t_active boolean
function renderer_set_fog_wind_texture_active(t_active) end

---@param t_active boolean
function renderer_set_fxaa_active(t_active) end

---@param t_gamma number
function renderer_set_gamma(t_gamma) end

---@param t_intensity number
function renderer_set_global_wetness_intensity(t_intensity) end

---@param t_intensity number
function renderer_set_image_trail_intensity(t_intensity) end

---@param t_active boolean
function renderer_set_local_light_shadows_active(t_active) end

---@param t_active boolean
function renderer_set_local_light_shadows_distance_culling_active(t_active) end

---@param t_fade_range number
function renderer_set_local_light_shadows_fade_range(t_fade_range) end

---@param t_distance number
function renderer_set_local_light_shadows_max_distance(t_distance) end

---@param t_active boolean
function renderer_set_local_lights_culling_active(t_active) end

---@param t_active boolean
function renderer_set_local_lights_distance_culling_active(t_active) end

---@param t_fade_range number
function renderer_set_local_lights_distance_culling_fade_range(t_fade_range) end

---@param t_distance number
function renderer_set_local_lights_distance_culling_max_distance(t_distance) end

---@param t_active boolean
function renderer_set_local_lights_frustum_culling_active(t_active) end

---@param t_active boolean
function renderer_set_ortho_mode(t_active) end

---@param t_center vec2
function renderer_set_radial_blur_center(t_center) end

---@param t_intensity number
function renderer_set_radial_blur_intensity(t_intensity) end

function renderer_set_radial_blur_samples() end

---@param t_scale number
function renderer_set_render_scale(t_scale) end

---@param t_color vec3
function renderer_set_screen_fade_color(t_color) end

---@param t_intensity number
function renderer_set_screen_fade_intensity(t_intensity) end

---@param t_active boolean
function renderer_set_sky_active(t_active) end

---@param t_ambient_lux number
function renderer_set_sky_ambient_lux(t_ambient_lux) end

---@param t_brightness number
function renderer_set_sky_brightness(t_brightness) end

---@param t_color vec3
function renderer_set_sky_color(t_color) end

---@param t_contrast number
function renderer_set_sky_contrast(t_contrast) end

---@param t_intensity number
function renderer_set_sky_diffuse_ibl_intensity(t_intensity) end

---@param t_active boolean
function renderer_set_sky_ibl_active(t_active) end

---@param t_apply_fog boolean
function renderer_set_sky_ibl_apply_fog(t_apply_fog) end

---@param t_rotation number
function renderer_set_sky_rotation(t_rotation) end

---@param t_intensity number
function renderer_set_sky_specular_ibl_intensity(t_intensity) end

---@param t_file_path string
function renderer_set_sky_texture_file(t_file_path) end

---@param t_active boolean
function renderer_set_ssao_active(t_active) end

---@param t_bias number
function renderer_set_ssao_bias(t_bias) end

---@param t_blur_size integer
function renderer_set_ssao_blur_size(t_blur_size) end

---@param t_quality integer
function renderer_set_ssao_quality(t_quality) end

---@param t_radius number
function renderer_set_ssao_radius(t_radius) end

---@param t_strength number
function renderer_set_ssao_strength(t_strength) end

---@param t_active boolean
function renderer_set_ssr_active(t_active) end

---@param t_edge_fade number
function renderer_set_ssr_edge_fade(t_edge_fade) end

---@param t_max_steps integer
function renderer_set_ssr_max_steps(t_max_steps) end

---@param t_quality integer
function renderer_set_ssr_quality(t_quality) end

---@param t_mode integer
function renderer_set_ssr_reflection_source_mode(t_mode) end

---@param t_color vec3
function renderer_set_ssr_reflection_static_color(t_color) end

---@param t_step_size number
function renderer_set_ssr_step_size(t_step_size) end

---@param t_strength number
function renderer_set_ssr_strength(t_strength) end

---@param t_thickness number
function renderer_set_ssr_thickness(t_thickness) end

---@param t_active boolean
function renderer_set_sunlight_active(t_active) end

---@param t_color vec3
function renderer_set_sunlight_color(t_color) end

---@param t_direction vec3
function renderer_set_sunlight_direction(t_direction) end

---@param t_lux number
function renderer_set_sunlight_lux(t_lux) end

---@param t_active boolean
function renderer_set_sunlight_shadow_active(t_active) end

---@param t_bias number
function renderer_set_sunlight_shadow_bias(t_bias) end

---@param t_blur number
function renderer_set_sunlight_shadow_blur(t_blur) end

---@param t_distance number
function renderer_set_sunlight_shadow_distance(t_distance) end

---@param t_normal_bias number
function renderer_set_sunlight_shadow_normal_bias(t_normal_bias) end

---@param t_intensity number
function renderer_set_sunlight_specular_intensity(t_intensity) end

---@param t_temperature_k number
function renderer_set_sunlight_temperature_k(t_temperature_k) end

---@param t_brightness number
function renderer_set_tonemap_brightness(t_brightness) end

---@param t_color vec3
function renderer_set_tonemap_color_highlights(t_color) end

---@param t_color vec3
function renderer_set_tonemap_color_midtones(t_color) end

---@param t_color vec3
function renderer_set_tonemap_color_shadows(t_color) end

---@param t_contrast number
function renderer_set_tonemap_contrast(t_contrast) end

---@param t_range number
function renderer_set_tonemap_highlight_range(t_range) end

---@param t_saturation number
function renderer_set_tonemap_saturation(t_saturation) end

---@param t_range number
function renderer_set_tonemap_shadow_range(t_range) end

---@param t_active boolean
function renderer_set_wind_active(t_active) end

---@param t_direction vec2
function renderer_set_wind_direction(t_direction) end

---@param t_file_path string
function renderer_set_wind_noise_texture_file(t_file_path) end

---@param t_speed number
function renderer_set_wind_speed(t_speed) end

function renderer_sync_sky_fill_luminance() end

-- Script

---@param t_entity_id integer
---@param t_function_name string
---@return boolean
function script_call_function(t_entity_id, t_function_name) end

---@param t_entity_id integer
---@return string
function script_get_file_path(t_entity_id) end

---@param t_entity_id integer
---@param t_param_name string
---@return boolean
function script_get_has_parameter(t_entity_id, t_param_name) end

---@param t_entity_id integer
---@param t_param_name string
---@return string
function script_get_parameter(t_entity_id, t_param_name) end

---@param t_entity_id integer
---@return boolean
function script_reload(t_entity_id) end

---@param t_entity_id integer
---@param t_file_path string
function script_set_file_path(t_entity_id, t_file_path) end

---@param t_entity_id integer
---@param t_param_name string
---@param t_param_value string
function script_set_parameter(t_entity_id, t_param_name, t_param_value) end

-- Set

---@param t_name string
---@param t_value boolean|string|number
function set_global(t_name, t_value) end

-- Settings

function settings_apply_loaded() end

---@return number
function settings_get_ambient_volume() end

---@return integer
function settings_get_anisotropic_filter_level() end

---@return table
function settings_get_available_monitors() end

---@return table
function settings_get_available_resolutions() end

---@param t_section string
---@param t_key string
---@param t_default_value boolean
---@return boolean
function settings_get_bool(t_section, t_key, t_default_value) end

---@return string
function settings_get_default_world() end

---@return boolean
function settings_get_dev_mode_active() end

---@param t_section string
---@param t_key string
---@param t_default_value number?
---@return number
function settings_get_float(t_section, t_key, t_default_value) end

---@return boolean
function settings_get_fxaa_active() end

---@return string
function settings_get_game_title() end

---@return number
function settings_get_gamma() end

---@return boolean
function settings_get_global_distance_culling_active() end

---@return boolean
function settings_get_global_frustum_culling_active() end

---@return boolean
function settings_get_global_local_light_shadows_active() end

---@param t_section string
---@param t_key string
---@param t_default_value integer?
---@return integer
function settings_get_int(t_section, t_key, t_default_value) end

---@return boolean
function settings_get_is_reverb_active() end

---@return boolean
function settings_get_local_light_shadows_distance_culling_active() end

---@return number
function settings_get_local_light_shadows_fade_range() end

---@return number
function settings_get_local_light_shadows_max_distance() end

---@return boolean
function settings_get_local_lights_culling_active() end

---@return boolean
function settings_get_local_lights_distance_culling_active() end

---@return number
function settings_get_local_lights_distance_culling_fade_range() end

---@return number
function settings_get_local_lights_distance_culling_max_distance() end

---@return boolean
function settings_get_local_lights_frustum_culling_active() end

---@return number
function settings_get_master_volume() end

---@return integer
function settings_get_monitor_count() end

---@return integer
function settings_get_monitor_index() end

---@return number
function settings_get_music_volume() end

---@return number
function settings_get_render_scale() end

function settings_get_resolution() end

---@return integer
function settings_get_reverb_quality() end

---@return number
function settings_get_sfx_volume() end

---@return integer
function settings_get_shadow_map_quality() end

---@return integer
function settings_get_ssao_quality() end

---@return integer
function settings_get_ssgi_quality() end

---@return integer
function settings_get_ssr_quality() end

---@param t_section string
---@param t_key string
---@param t_default_value string?
---@return string
function settings_get_string(t_section, t_key, t_default_value) end

---@return number
function settings_get_ui_scale() end

---@return number
function settings_get_ui_volume() end

---@return string
function settings_get_user_ini_path() end

---@return number
function settings_get_voice_volume() end

---@return integer
function settings_get_vsync_mode() end

---@return integer
function settings_get_window_mode() end

---@return boolean
function settings_reset_to_defaults() end

---@return boolean
function settings_save() end

---@param t_volume number
function settings_set_ambient_volume(t_volume) end

---@param t_integer_1 integer
function settings_set_anisotropic_filter_level(t_integer_1) end

---@param t_section string
---@param t_key string
---@param t_value boolean
function settings_set_bool(t_section, t_key, t_value) end

---@param t_section string
---@param t_key string
---@param t_value number
function settings_set_float(t_section, t_key, t_value) end

---@param t_active boolean
function settings_set_fxaa_active(t_active) end

---@param t_gamma number
function settings_set_gamma(t_gamma) end

---@param t_active boolean
function settings_set_global_distance_culling_active(t_active) end

---@param t_active boolean
function settings_set_global_frustum_culling_active(t_active) end

---@param t_active boolean
function settings_set_global_local_light_shadows_active(t_active) end

---@param t_section string
---@param t_key string
---@param t_value integer
function settings_set_int(t_section, t_key, t_value) end

---@param t_active boolean
function settings_set_is_reverb_active(t_active) end

---@param t_active boolean
function settings_set_local_light_shadows_distance_culling_active(t_active) end

---@param t_fade_range number
function settings_set_local_light_shadows_fade_range(t_fade_range) end

---@param t_distance number
function settings_set_local_light_shadows_max_distance(t_distance) end

---@param t_active boolean
function settings_set_local_lights_culling_active(t_active) end

---@param t_active boolean
function settings_set_local_lights_distance_culling_active(t_active) end

---@param t_fade_range number
function settings_set_local_lights_distance_culling_fade_range(t_fade_range) end

---@param t_distance number
function settings_set_local_lights_distance_culling_max_distance(t_distance) end

---@param t_active boolean
function settings_set_local_lights_frustum_culling_active(t_active) end

---@param t_volume number
function settings_set_master_volume(t_volume) end

---@param t_monitor_index integer
---@return boolean
function settings_set_monitor_index(t_monitor_index) end

---@param t_volume number
function settings_set_music_volume(t_volume) end

---@param t_scale number
function settings_set_render_scale(t_scale) end

---@param t_width integer
---@param t_height integer
---@return boolean
function settings_set_resolution(t_width, t_height) end

---@param t_integer_1 integer
function settings_set_reverb_quality(t_integer_1) end

---@param t_volume number
function settings_set_sfx_volume(t_volume) end

---@param t_integer_1 integer
function settings_set_shadow_map_quality(t_integer_1) end

---@param t_integer_1 integer
function settings_set_ssao_quality(t_integer_1) end

---@param t_integer_1 integer
function settings_set_ssgi_quality(t_integer_1) end

---@param t_integer_1 integer
function settings_set_ssr_quality(t_integer_1) end

---@param t_section string
---@param t_key string
---@param t_value string
function settings_set_string(t_section, t_key, t_value) end

---@param t_scale number
function settings_set_ui_scale(t_scale) end

---@param t_volume number
function settings_set_ui_volume(t_volume) end

---@param t_volume number
function settings_set_voice_volume(t_volume) end

---@param t_integer_1 integer
function settings_set_vsync_mode(t_integer_1) end

---@param t_integer_1 integer
function settings_set_window_mode(t_integer_1) end

-- Skeletal_mesh

---@param t_entity_id integer
---@return table
function skeletal_get_socket_names(t_entity_id) end

---@param t_entity_id integer
---@param t_socket_name string
---@return vec3
function skeletal_get_socket_world_position(t_entity_id, t_socket_name) end

---@param t_entity_id integer
---@param t_socket_name string
---@return vec3
function skeletal_get_socket_world_rotation(t_entity_id, t_socket_name) end

-- Sound

---@param t_entity_id integer
---@param t_file_path string
function sound_add_file(t_entity_id, t_file_path) end

---@param t_entity_id integer
function sound_clear_files(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_air_absorption_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return integer
function sound_get_air_absorption_filter_type(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_air_absorption_inner_radius(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_air_absorption_outer_radius(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_base_gain(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_base_pitch(t_entity_id) end

---@param t_entity_id integer
---@return integer
function sound_get_category(t_entity_id) end

---@param t_category integer
---@return number
function sound_get_category_mix_multiplier(t_category) end

---@param t_integer_1 integer
---@return number
function sound_get_category_volume(t_integer_1) end

---@param t_entity_id integer
---@return number
function sound_get_duration(t_entity_id) end

---@param t_entity_id integer
---@param t_index integer
---@return string
function sound_get_file_at_index(t_entity_id, t_index) end

---@param t_entity_id integer
---@return string
function sound_get_file_path(t_entity_id) end

---@param t_entity_id integer
---@return integer
function sound_get_files_count(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_full_spatialization_at(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_gain(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_gain_randomization_max(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_gain_randomization_min(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_inner_radius(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_affected_by_listener_sound_zones(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_air_absorption_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_gain_randomization_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_looping(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_pitch_randomization_enabled(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_playing(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_is_spatial(t_entity_id) end

---@return number
function sound_get_master_volume() end

---@param t_entity_id integer
---@return number
function sound_get_outer_radius(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_pan(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_pitch(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_pitch_randomization_max(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_pitch_randomization_min(t_entity_id) end

---@param t_entity_id integer
---@return integer
function sound_get_play_mode(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_get_play_on_start(t_entity_id) end

---@return integer
function sound_get_reverb_quality() end

---@param t_entity_id integer
---@return number
function sound_get_zone_gain_multiplier(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_low_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_damping(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_high_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_level(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_low_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_predelay_ms(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_room_size(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_get_zone_reverb_width(t_entity_id) end

---@param t_entity_id integer
function sound_pause(t_entity_id) end

---@param t_entity_id integer
---@param t_fade_seconds number
function sound_play(t_entity_id, t_fade_seconds) end

---@param t_entity_id integer
---@param t_index integer
function sound_remove_file_at_index(t_entity_id, t_index) end

---@param t_entity_id integer
---@param t_affected boolean
function sound_set_affected_by_listener_sound_zones(t_entity_id, t_affected) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_set_air_absorption_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_enabled boolean
function sound_set_air_absorption_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_filter_type integer
function sound_set_air_absorption_filter_type(t_entity_id, t_filter_type) end

---@param t_entity_id integer
---@param t_radius number
function sound_set_air_absorption_inner_radius(t_entity_id, t_radius) end

---@param t_entity_id integer
---@param t_radius number
function sound_set_air_absorption_outer_radius(t_entity_id, t_radius) end

---@param t_entity_id integer
---@param t_category integer
function sound_set_category(t_entity_id, t_category) end

---@param t_category integer
---@param t_multiplier number
function sound_set_category_mix_multiplier(t_category, t_multiplier) end

---@param t_category integer
---@param t_volume number
function sound_set_category_volume(t_category, t_volume) end

---@param t_entity_id integer
---@param t_file_path string
function sound_set_file(t_entity_id, t_file_path) end

---@param t_entity_id integer
---@param t_distance number
function sound_set_full_spatialization_at(t_entity_id, t_distance) end

---@param t_entity_id integer
---@param t_gain number
function sound_set_gain(t_entity_id, t_gain) end

---@param t_entity_id integer
---@param t_enabled boolean
function sound_set_gain_randomization_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_min_gain number
---@param t_max_gain number
function sound_set_gain_randomization_range(t_entity_id, t_min_gain, t_max_gain) end

---@param t_entity_id integer
---@param t_radius number
function sound_set_inner_radius(t_entity_id, t_radius) end

---@param t_entity_id integer
---@param t_looping boolean
function sound_set_looping(t_entity_id, t_looping) end

---@param t_number_1 number
function sound_set_master_volume(t_number_1) end

---@param t_entity_id integer
---@param t_radius number
function sound_set_outer_radius(t_entity_id, t_radius) end

---@param t_entity_id integer
---@param t_pan number
function sound_set_pan(t_entity_id, t_pan) end

---@param t_entity_id integer
---@param t_pitch number
function sound_set_pitch(t_entity_id, t_pitch) end

---@param t_entity_id integer
---@param t_enabled boolean
function sound_set_pitch_randomization_enabled(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_min_pitch number
---@param t_max_pitch number
function sound_set_pitch_randomization_range(t_entity_id, t_min_pitch, t_max_pitch) end

---@param t_entity_id integer
---@param t_mode integer
function sound_set_play_mode(t_entity_id, t_mode) end

---@param t_entity_id integer
---@param t_play_on_start boolean
function sound_set_play_on_start(t_entity_id, t_play_on_start) end

---@param t_integer_1 integer
function sound_set_reverb_quality(t_integer_1) end

---@param t_entity_id integer
---@param t_spatial boolean
function sound_set_spatial(t_entity_id, t_spatial) end

---@param t_entity_id integer
---@param t_gain_multiplier number
function sound_set_zone_gain_multiplier(t_entity_id, t_gain_multiplier) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_set_zone_low_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_damping number
function sound_set_zone_reverb_damping(t_entity_id, t_damping) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_set_zone_reverb_high_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_reverb_level number
function sound_set_zone_reverb_level(t_entity_id, t_reverb_level) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_set_zone_reverb_low_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_predelay_ms number
function sound_set_zone_reverb_predelay_ms(t_entity_id, t_predelay_ms) end

---@param t_entity_id integer
---@param t_room_size number
function sound_set_zone_reverb_room_size(t_entity_id, t_room_size) end

---@param t_entity_id integer
---@param t_width number
function sound_set_zone_reverb_width(t_entity_id, t_width) end

---@param t_entity_id integer
---@param t_fade_seconds number
function sound_stop(t_entity_id, t_fade_seconds) end

-- Sound_zone

---@param t_entity_id integer
---@return number
function sound_zone_get_external_gain_multiplier(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_external_low_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_external_reverb_level(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_fade_duration(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_internal_gain_multiplier(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_internal_low_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_internal_reverb_level(t_entity_id) end

---@param t_entity_id integer
---@return integer
function sound_zone_get_priority(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_damping(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_high_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_low_pass_cutoff_hz(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_predelay_ms(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_room_size(t_entity_id) end

---@param t_entity_id integer
---@return number
function sound_zone_get_reverb_width(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function sound_zone_get_show_debug_box(t_entity_id) end

---@param t_entity_id integer
---@param t_gain_multiplier number
function sound_zone_set_external_gain_multiplier(t_entity_id, t_gain_multiplier) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_zone_set_external_low_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_reverb_level number
function sound_zone_set_external_reverb_level(t_entity_id, t_reverb_level) end

---@param t_entity_id integer
---@param t_fade_duration number
function sound_zone_set_fade_duration(t_entity_id, t_fade_duration) end

---@param t_entity_id integer
---@param t_gain_multiplier number
function sound_zone_set_internal_gain_multiplier(t_entity_id, t_gain_multiplier) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_zone_set_internal_low_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_reverb_level number
function sound_zone_set_internal_reverb_level(t_entity_id, t_reverb_level) end

---@param t_entity_id integer
---@param t_priority integer
function sound_zone_set_priority(t_entity_id, t_priority) end

---@param t_entity_id integer
---@param t_damping number
function sound_zone_set_reverb_damping(t_entity_id, t_damping) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_zone_set_reverb_high_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_cutoff_hz number
function sound_zone_set_reverb_low_pass_cutoff_hz(t_entity_id, t_cutoff_hz) end

---@param t_entity_id integer
---@param t_predelay_ms number
function sound_zone_set_reverb_predelay_ms(t_entity_id, t_predelay_ms) end

---@param t_entity_id integer
---@param t_room_size number
function sound_zone_set_reverb_room_size(t_entity_id, t_room_size) end

---@param t_entity_id integer
---@param t_width number
function sound_zone_set_reverb_width(t_entity_id, t_width) end

---@param t_entity_id integer
---@param t_show_debug_box boolean
function sound_zone_set_show_debug_box(t_entity_id, t_show_debug_box) end

-- Soundscape_zone

---@param t_entity_id integer
---@return number
function soundscape_zone_get_fade_duration(t_entity_id) end

---@param t_entity_id integer
---@return integer
function soundscape_zone_get_priority(t_entity_id) end

---@param t_entity_id integer
function soundscape_zone_get_profile(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function soundscape_zone_get_show_debug_box(t_entity_id) end

---@param t_entity_id integer
---@param t_fade_duration number
function soundscape_zone_set_fade_duration(t_entity_id, t_fade_duration) end

---@param t_entity_id integer
---@param t_priority integer
function soundscape_zone_set_priority(t_entity_id, t_priority) end

---@param t_entity_id integer
function soundscape_zone_set_profile(t_entity_id) end

---@param t_entity_id integer
---@param t_show_debug_box boolean
function soundscape_zone_set_show_debug_box(t_entity_id, t_show_debug_box) end

-- Surface

---@param t_entity_id integer
---@param t_world_position vec3
---@param t_world_normal vec3
---@param t_hit_triangle_index integer
---@param t_mesh_local_position vec3
function surface_get_at(t_entity_id, t_world_position, t_world_normal, t_hit_triangle_index, t_mesh_local_position) end

---@param t_vertex_color vec4
---@return integer
function surface_get_dominant_vertex_blend_layer(t_vertex_color) end

---@param t_from vec3
---@param t_to vec3
---@param t_table_3 table
---@param t_include_mode boolean
function surface_get_from_raycast(t_from, t_to, t_table_3, t_include_mode) end

-- Text_mesh

---@param t_entity_id integer
---@return boolean
function text_mesh_get_billboard(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function text_mesh_get_editor_only(t_entity_id) end

---@param t_entity_id integer
---@return string
function text_mesh_get_font_id(t_entity_id) end

---@param t_entity_id integer
---@return number
function text_mesh_get_font_pixel_size(t_entity_id) end

---@param t_entity_id integer
---@return string
function text_mesh_get_text(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function text_mesh_get_text_color(t_entity_id) end

---@param t_entity_id integer
---@return boolean
function text_mesh_get_visible(t_entity_id) end

---@param t_entity_id integer
---@return number
function text_mesh_get_world_height(t_entity_id) end

---@param t_entity_id integer
---@param t_billboard boolean
function text_mesh_set_billboard_active(t_entity_id, t_billboard) end

---@param t_entity_id integer
---@param t_editor_only boolean
function text_mesh_set_editor_only(t_entity_id, t_editor_only) end

---@param t_entity_id integer
---@param t_font_id string
function text_mesh_set_font_id(t_entity_id, t_font_id) end

---@param t_entity_id integer
---@param t_font_pixel_size number
function text_mesh_set_font_pixel_size(t_entity_id, t_font_pixel_size) end

---@param t_entity_id integer
---@param t_text string
function text_mesh_set_text(t_entity_id, t_text) end

---@param t_entity_id integer
---@param t_color vec3
function text_mesh_set_text_color(t_entity_id, t_color) end

---@param t_entity_id integer
---@param t_visible boolean
function text_mesh_set_visible(t_entity_id, t_visible) end

---@param t_entity_id integer
---@param t_world_height number
function text_mesh_set_world_height(t_entity_id, t_world_height) end

-- Timer

---@return number
function timer_get_time_scale() end

---@param t_scale number
function timer_set_time_scale(t_scale) end

-- Transform

---@param t_entity_id integer
---@return vec3
function transform_get_local_forward(t_entity_id) end

---@param t_entity_id integer
---@return number
function transform_get_local_matrix(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_local_position(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_local_right(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_local_rotation(t_entity_id) end

---@param t_entity_id integer
---@return quat
function transform_get_local_rotation_quat(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_local_scale(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_local_up(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_forward(t_entity_id) end

---@param t_entity_id integer
---@return number
function transform_get_world_matrix(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_position(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_right(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_rotation(t_entity_id) end

---@param t_entity_id integer
---@return quat
function transform_get_world_rotation_quat(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_scale(t_entity_id) end

---@param t_entity_id integer
---@return vec3
function transform_get_world_up(t_entity_id) end

---@param t_entity_id integer
---@param t_local_direction vec3
---@return vec3
function transform_local_to_world_direction(t_entity_id, t_local_direction) end

---@param t_entity_id integer
---@param t_local_point vec3
---@return vec3
function transform_local_to_world_point(t_entity_id, t_local_point) end

---@param t_entity_id integer
---@param t_target vec3
---@param t_up vec3
function transform_look_at_local(t_entity_id, t_target, t_up) end

---@param t_entity_id integer
---@param t_target vec3
---@param t_up vec3
function transform_look_at_world(t_entity_id, t_target, t_up) end

---@param t_entity_id integer
---@return boolean
function transform_remove_parent(t_entity_id) end

---@param t_entity_id integer
---@param t_enabled boolean
function transform_set_interpolation_active(t_entity_id, t_enabled) end

---@param t_entity_id integer
---@param t_value number
function transform_set_local_matrix(t_entity_id, t_value) end

---@param t_entity_id integer
---@param t_position vec3
function transform_set_local_position(t_entity_id, t_position) end

---@param t_entity_id integer
---@param t_rotation vec3
function transform_set_local_rotation(t_entity_id, t_rotation) end

---@param t_entity_id integer
---@param t_rotation quat
function transform_set_local_rotation_quat(t_entity_id, t_rotation) end

---@param t_entity_id integer
---@param t_scale vec3
function transform_set_local_scale(t_entity_id, t_scale) end

---@param t_entity_id integer
---@param t_parent_id integer
---@return boolean
function transform_set_parent(t_entity_id, t_parent_id) end

---@param t_entity_id integer
---@param t_parent_id integer
---@return boolean
function transform_set_parent_preserve_world(t_entity_id, t_parent_id) end

---@param t_entity_id integer
---@param t_position vec3
function transform_set_world_position(t_entity_id, t_position) end

---@param t_entity_id integer
---@param t_rotation vec3
function transform_set_world_rotation(t_entity_id, t_rotation) end

---@param t_entity_id integer
---@param t_quat quat
function transform_set_world_rotation_quat(t_entity_id, t_quat) end

---@param t_entity_id integer
---@param t_scale vec3
function transform_set_world_scale(t_entity_id, t_scale) end

---@param t_entity_id integer
---@param t_world_direction vec3
---@return vec3
function transform_world_to_local_direction(t_entity_id, t_world_direction) end

---@param t_entity_id integer
---@param t_world_point vec3
---@return vec3
function transform_world_to_local_point(t_entity_id, t_world_point) end

-- Vec2

---@param t_x number
---@param t_y number
---@return vec2
function vec2(t_x, t_y) end

---@param t_a vec2
---@param t_b vec2
---@return vec2
function vec2_add(t_a, t_b) end

---@param t_a vec2
---@param t_b vec2
---@return number
function vec2_distance(t_a, t_b) end

---@param t_vec vec2
---@param t_scalar number|vec2
---@return vec2
function vec2_div(t_vec, t_scalar) end

---@param t_a vec2
---@param t_b vec2
---@return number
function vec2_dot(t_a, t_b) end

---@param t_vec vec2
---@return number
function vec2_length(t_vec) end

---@param t_vec vec2
---@return number
function vec2_length_squared(t_vec) end

---@param t_a vec2
---@param t_b vec2
---@param t_t number
---@return vec2
function vec2_lerp(t_a, t_b, t_t) end

---@param t_vec vec2
---@param t_scalar number|vec2
---@return vec2
function vec2_mul(t_vec, t_scalar) end

---@param t_vec vec2
---@return vec2
function vec2_normalize(t_vec) end

---@param t_a vec2
---@param t_b vec2
---@return vec2
function vec2_sub(t_a, t_b) end

-- Vec3

---@param t_x number
---@param t_y number
---@param t_z number
---@return vec3
function vec3(t_x, t_y, t_z) end

---@param t_a vec3
---@param t_b vec3
---@return vec3
function vec3_add(t_a, t_b) end

---@param t_a vec3
---@param t_b vec3
---@return vec3
function vec3_cross(t_a, t_b) end

---@param t_a vec3
---@param t_b vec3
---@return number
function vec3_distance(t_a, t_b) end

---@param t_vec vec3
---@param t_scalar number|vec3
---@return vec3
function vec3_div(t_vec, t_scalar) end

---@param t_a vec3
---@param t_b vec3
---@return number
function vec3_dot(t_a, t_b) end

---@param t_vec vec3
---@return number
function vec3_length(t_vec) end

---@param t_vec vec3
---@return number
function vec3_length_squared(t_vec) end

---@param t_a vec3
---@param t_b vec3
---@param t_t number
---@return vec3
function vec3_lerp(t_a, t_b, t_t) end

---@param t_vec vec3
---@param t_scalar number|vec3
---@return vec3
function vec3_mul(t_vec, t_scalar) end

---@param t_vec vec3
---@return vec3
function vec3_normalize(t_vec) end

---@param t_incident vec3
---@param t_normal vec3
---@return vec3
function vec3_reflect(t_incident, t_normal) end

---@param t_incident vec3
---@param t_normal vec3
---@param t_eta number
---@return vec3
function vec3_refract(t_incident, t_normal, t_eta) end

---@param t_a vec3
---@param t_b vec3
---@return vec3
function vec3_sub(t_a, t_b) end

-- Vec4

---@param t_x number
---@param t_y number
---@param t_z number
---@param t_w number
---@return vec4
function vec4(t_x, t_y, t_z, t_w) end

---@param t_a vec4
---@param t_b vec4
---@return vec4
function vec4_add(t_a, t_b) end

---@param t_a vec4
---@param t_b vec4
---@return number
function vec4_distance(t_a, t_b) end

---@param t_vec vec4
---@param t_scalar number|vec4
---@return vec4
function vec4_div(t_vec, t_scalar) end

---@param t_a vec4
---@param t_b vec4
---@return number
function vec4_dot(t_a, t_b) end

---@param t_vec vec4
---@return number
function vec4_length(t_vec) end

---@param t_vec vec4
---@return number
function vec4_length_squared(t_vec) end

---@param t_a vec4
---@param t_b vec4
---@param t_t number
---@return vec4
function vec4_lerp(t_a, t_b, t_t) end

---@param t_vec vec4
---@param t_scalar number|vec4
---@return vec4
function vec4_mul(t_vec, t_scalar) end

---@param t_vec vec4
---@return vec4
function vec4_normalize(t_vec) end

---@param t_a vec4
---@param t_b vec4
---@return vec4
function vec4_sub(t_a, t_b) end

-- World

---@param t_message string
function world_broadcast_message(t_message) end

---@param t_entity_id integer
---@param t_function_name string
function world_call_entity_script_function(t_entity_id, t_function_name) end

---@param t_function_name string
function world_call_script_function(t_function_name) end

---@param t_entity_id integer
---@return integer
function world_clone_entity(t_entity_id) end

---@param t_name string?
---@return integer
function world_create_entity(t_name) end

---@param t_pool_name string
---@param t_initial_capacity integer
---@param t_max_capacity integer
function world_create_entity_pool(t_pool_name, t_initial_capacity, t_max_capacity) end

---@param t_entity_id integer
---@param t_pool_name string
function world_despawn_entity(t_entity_id, t_pool_name) end

---@param t_entity_id integer
---@return boolean
function world_destroy_entity(t_entity_id) end

---@return integer
function world_get_current_camera() end

---@return string
function world_get_current_world_file_path() end

---@return table
function world_get_entities() end

---@param t_name_pattern string
---@return table
function world_get_entities_by_name(t_name_pattern) end

---@param t_tag string
---@return table
function world_get_entities_by_tag(t_tag) end

---@param t_component_type string
---@return table
function world_get_entities_with_component(t_component_type) end

---@param t_entity_hierarchy_path string
---@return integer
function world_get_entity_by_hierarchy_path(t_entity_hierarchy_path) end

---@param t_entity_id integer
---@return integer
function world_get_entity_by_id(t_entity_id) end

---@param t_entity_name string
---@return integer
function world_get_entity_by_name(t_entity_name) end

---@return integer
function world_get_entity_count() end

---@param t_entity_id integer
---@return string
function world_get_entity_hierarchy_path(t_entity_id) end

---@param t_function_name string
---@return table
function world_get_function(t_function_name) end

---@param t_param_name string
---@return boolean
function world_get_has_script_parameter(t_param_name) end

---@return boolean
function world_get_is_loading() end

---@param t_param_name string
---@return integer
function world_get_script_parameter(t_param_name) end

---@param t_file_path string
---@param t_skip_preload_overlay boolean
---@return boolean
function world_load_from_file(t_file_path, t_skip_preload_overlay) end

---@param t_entity_id integer
---@return boolean
function world_set_current_camera(t_entity_id) end

---@param t_param_name string
---@param t_str_value string|boolean|number
function world_set_script_parameter(t_param_name, t_str_value) end

---@param t_pool_name string
---@param t_entity_name string
---@return integer
function world_spawn_entity(t_pool_name, t_entity_name) end

-- World_soundscape

---@return integer
function world_soundscape_get_active_zone() end

---@return boolean
function world_soundscape_get_is_paused() end

function world_soundscape_get_profile() end

function world_soundscape_notify_profile_changed() end

---@param t_fade_seconds number
function world_soundscape_reload_active_profile(t_fade_seconds) end

---@param t_paused boolean
function world_soundscape_set_paused(t_paused) end

function world_soundscape_set_profile() end

-- World_soundzone

---@return number
function world_soundzone_get_fade_duration() end

---@return number
function world_soundzone_get_gain_multiplier() end

---@return number
function world_soundzone_get_low_pass_cutoff_hz() end

---@return number
function world_soundzone_get_reverb_damping() end

---@return number
function world_soundzone_get_reverb_high_pass_cutoff_hz() end

---@return number
function world_soundzone_get_reverb_level() end

---@return number
function world_soundzone_get_reverb_low_pass_cutoff_hz() end

---@return number
function world_soundzone_get_reverb_predelay_ms() end

---@return number
function world_soundzone_get_reverb_room_size() end

---@return number
function world_soundzone_get_reverb_width() end

function world_soundzone_reset() end

---@param t_number_1 number
function world_soundzone_set_fade_duration(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_gain_multiplier(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_low_pass_cutoff_hz(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_damping(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_high_pass_cutoff_hz(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_level(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_low_pass_cutoff_hz(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_predelay_ms(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_room_size(t_number_1) end

---@param t_number_1 number
function world_soundzone_set_reverb_width(t_number_1) end

