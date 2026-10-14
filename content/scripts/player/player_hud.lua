local PlayerHUD = {}

------------------------------------------------
-- DEPENDENCIES
------------------------------------------------

local UiWidgets = dofile("../content/scripts/shared/ui_widgets.lua")
local Colors = dofile("../content/scripts/shared/colors.lua")

------------------------------------------------
-- SETTINGS
------------------------------------------------

local CROSSHAIR_TEXTURE = "../content/textures/demo_content/gui/hud/crosshair_interact_default_simple.dds"
local CROSSHAIR_SIZE = 0.035
local CROSSHAIR_COLOR_DEFAULT = Colors.get_with_alpha(Colors.WHITE, 0.55)
local CROSSHAIR_COLOR_INTERACT = vec4(0.2, 1.0, 0.25, 0.95)

local INTERACT_PROMPT_BG_COLOR = vec4(0.08, 0.08, 0.10, 0.78)
local INTERACT_PROMPT_BG_PADDING = 0.009
local INTERACT_PROMPT_BG_ROUNDING = 0.006
local INTERACT_PROMPT_FONT_SIZE = 0.016
local INTERACT_PROMPT_TEXT_COLOR = Colors.get_with_alpha(Colors.WHITE, 0.95)
local INTERACT_PROMPT_GAP = 0.009
local INTERACT_PROMPT_BELOW_CROSSHAIR = 0.022
local INTERACT_INPUT_KEY_MIN_SIZE = 0.03
local INTERACT_INPUT_KEY_DEFAULT = "[ERROR] No Key-Binding" -- Just so we know if binding failed. 

------------------------------------------------
-- PROPERTIES
------------------------------------------------

local m_aiming_at_interactable = false
local m_interact_label = ""
local m_interact_input_key = INTERACT_INPUT_KEY_DEFAULT
------------------------------------------------
-- LIFECYCLE
------------------------------------------------

function PlayerHUD.on_process(t_delta_time)
    -- Reset the aiming at interactable and label.
    m_aiming_at_interactable = false
    m_interact_label = ""
    m_interact_input_key = INTERACT_INPUT_KEY_DEFAULT

    -- Get the player entity ID.
    local player_id = entity_get_parent(entity_id)
    if not entity_get_is_valid(player_id) then
        return
    end

    -- Get the interaction script entity ID.
    local interaction_id = entity_get_child_by_name(player_id, "interaction")
    if not entity_get_is_valid(interaction_id) then
        return
    end

    -- Get the current interaction target entity ID.
    local target_id = world_call_entity_script_function(interaction_id, "get_current_interaction_target_entity_id")
    if not entity_get_is_valid(target_id) then
        return
    end

    -- Get the interact label.
    m_aiming_at_interactable = true
    m_interact_label = world_call_entity_script_function(interaction_id, "get_current_interact_label")
    if type(m_interact_label) ~= "string" or m_interact_label == "" then
        m_interact_label = "Interact"
    end

    -- Get the input key.
    local input_key = world_call_entity_script_function(interaction_id, "get_interact_input_display")
    if type(input_key) == "string" and input_key ~= "" then
        m_interact_input_key = input_key
    end
end

------------------------------------------------

function PlayerHUD.on_draw(_t_delta_time)
    if not gui_begin_screen_canvas("player_hud", UiWidgets.CANVAS_OVERLAY) then
        return
    end

    -- Convert screen normalized sizes to pixels.
    local ui_size = gui_get_layout_size()
    local crosshair_size = gui_get_normalized_to_uniform_size(CROSSHAIR_SIZE)
    local prompt_gap_below = gui_get_normalized_to_pixels(INTERACT_PROMPT_BELOW_CROSSHAIR)
    local prompt_pad = gui_get_normalized_to_pixels(INTERACT_PROMPT_BG_PADDING)
    local prompt_rounding = gui_get_normalized_to_pixels(INTERACT_PROMPT_BG_ROUNDING)
    local prompt_font_size = gui_get_normalized_to_pixels(INTERACT_PROMPT_FONT_SIZE)
    local prompt_gap = gui_get_normalized_to_pixels(INTERACT_PROMPT_GAP)
    local input_key_min_size = gui_get_normalized_to_pixels(INTERACT_INPUT_KEY_MIN_SIZE)

    -- Draw the crosshair at screen center.
    local crosshair_pos = gui_get_anchored_rect(vec2(0.0, 0.0),     -- position of the crosshair anchor
                                                ui_size,            -- size of the UI canvas
                                                vec2(0.5, 0.5),     -- anchor point
                                                vec2(0.5, 0.5),     -- pivot point
                                                vec2(0.5, 0.5),     -- alignment
                                                crosshair_size)     -- size of the crosshair

    -- Change color when aiming at an interactable object.
    local color = CROSSHAIR_COLOR_DEFAULT
    if m_aiming_at_interactable then
        color = CROSSHAIR_COLOR_INTERACT
    end

    -- Draw crosshair.
    gui_draw_image(CROSSHAIR_TEXTURE, crosshair_pos, crosshair_size, color)

    -- Check if the player is not aiming at an interactable or the label is empty.
    if not m_aiming_at_interactable or m_interact_label == "" then
        gui_end_screen_canvas()
        return
    end

    -- Calculate the label and input key sizes.
    local label_size = gui_get_text_size(m_interact_label, prompt_font_size)
    local input_key_size = gui_get_text_size(m_interact_input_key, prompt_font_size)
    local input_key_box = math.max(input_key_min_size,
                                    input_key_size.x + prompt_pad * 2.0,
                                    input_key_size.y + prompt_pad * 2.0)

    -- Calculate the label and input key box sizes.
    local label_box_w = label_size.x + prompt_pad * 2.0
    local label_box_h = label_size.y + prompt_pad * 2.0
    
    local row_height = math.max(label_box_h, input_key_box)
    local total_width = label_box_w + prompt_gap + input_key_box
    local row_size = vec2(total_width, row_height)

    -- Place the prompt row under the crosshair.
    local row_pos = gui_get_anchored_rect(vec2(0.0, 0.0),
                                            ui_size,
                                            vec2(0.5, 0.5),
                                            vec2(0.5, 0.5),
                                            vec2(0.5, 0.0),
                                            row_size,
                                            vec2(0.0, crosshair_size.y * 0.5 + prompt_gap_below))

    local label_bg_pos = gui_get_aligned_position(row_pos,
                                                    row_size,
                                                    vec2(label_box_w, label_box_h),
                                                    GuiAlignH.LEFT,
                                                    GuiAlignV.MIDDLE)
    
    local input_key_bg_pos = gui_get_aligned_position(row_pos,
                                                        row_size,
                                                        vec2(input_key_box, input_key_box),
                                                        GuiAlignH.RIGHT,
                                                        GuiAlignV.MIDDLE)

    -- Draw the label chrome and text.
    gui_draw_rect_rounded(label_bg_pos, 
                            vec2(label_box_w, label_box_h), 
                            prompt_rounding, 
                            INTERACT_PROMPT_BG_COLOR)
    
    gui_draw_text_aligned(m_interact_label,
                            label_bg_pos,
                            vec2(label_box_w, label_box_h),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            prompt_font_size,
                            INTERACT_PROMPT_TEXT_COLOR)

    -- Draw the input key chrome and text.
    gui_draw_rect_rounded(input_key_bg_pos, 
                            vec2(input_key_box, input_key_box), 
                            prompt_rounding, 
                            INTERACT_PROMPT_BG_COLOR)
    
    gui_draw_text_aligned(m_interact_input_key,
                            input_key_bg_pos,
                            vec2(input_key_box, input_key_box),
                            GuiAlignH.CENTER,
                            GuiAlignV.MIDDLE,
                            prompt_font_size,
                            INTERACT_PROMPT_TEXT_COLOR)

    gui_end_screen_canvas()
end

------------------------------------------------

function PlayerHUD.on_shutdown()
    -- Reset the properties.
    m_aiming_at_interactable = false
    m_interact_label = ""
    m_interact_input_key = "No Key"
end

------------------------------------------------

return PlayerHUD
