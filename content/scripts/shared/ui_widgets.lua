local UiWidgets = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local Colors = dofile("../content/scripts/shared/colors.lua")

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

UiWidgets.CANVAS_INTERACTIVE = GuiWindowFlags.NO_MOVE
UiWidgets.CANVAS_OVERLAY =
    GuiWindowFlags.NO_MOVE +
    GuiWindowFlags.NO_INPUTS +
    GuiWindowFlags.NO_NAV +
    GuiWindowFlags.NO_FOCUS_ON_APPEARING

local DEFAULT_CORNER_ROUNDING = 4.0
local DEFAULT_CHECKBOX_SIZE = 22.0
local DEFAULT_SLIDER_HEIGHT = 28.0
local DEFAULT_SLIDER_TRACK_HEIGHT = 8.0
local DEFAULT_SLIDER_THUMB_SIZE = 18.0
local DEFAULT_TOOLTIP_PADDING = 10.0
local DEFAULT_TOOLTIP_OFFSET_X = 16.0
local DEFAULT_TOOLTIP_OFFSET_Y = 20.0
local DEFAULT_TOOLTIP_WIDGET_GAP = 6.0
local DEFAULT_TOGGLE_WIDTH = 44.0
local DEFAULT_TOGGLE_HEIGHT = 24.0
local DEFAULT_SPINNER_BUTTON_SIZE = 28.0
local DEFAULT_ROW_HEIGHT = 32.0
local DEFAULT_TEXT_INPUT_HEIGHT = 32.0
local DEFAULT_TAB_HEIGHT = 38.0
local DEFAULT_COMBO_ITEM_HEIGHT = 28.0
local COMBO_CARET_DOWN = "\xEF\x81\xB8"
local COMBO_CARET_UP = "\xEF\x81\xB7"
local COMBO_CARET_FONT_ID = "imgui_default"
local COMBO_CARET_FONT_SCALE = 0.82
local CHECKBOX_LABEL_GAP = 10.0
local LABEL_ROW_GAP = 12.0

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

local m_open_combo_id = ""      -- The id of the currently open combo box.
local m_combo_release_id = ""   -- Closed this frame. Cleared on the next menu canvas so later widgets still ignore the press.
local m_deferred_combo_popup_state = nil
local m_scroll_child_open = false
local m_transform_stack = {}    -- The stack of transform states for positioning widgets in a container.
local m_layout_stack = {}       -- The stack of layout states for positioning widgets in a grid or stack.

----------------------------------------------------
-- HELPERS
----------------------------------------------------

local function get_is_local_layout_active()
    -- Return true if there is a transform or layout stack.
    return #m_transform_stack > 0 or #m_layout_stack > 0
end

----------------------------------------------------

local function get_active_container()
    -- Return the top transform state from the stack.
    local count = #m_transform_stack
    if count == 0 then
        return nil
    end
    return m_transform_stack[count]
end

----------------------------------------------------

local function get_scale_or_default(t_scale)
    if t_scale == nil then
        return vec2(1.0, 1.0)
    end

    return t_scale
end

----------------------------------------------------

local function get_local_to_absolute_position(t_local_pos)
    -- Return the position in absolute space.
    local transform = get_active_container()
    if not transform then
        return t_local_pos
    end
    return vec2(
        transform.world_ox + t_local_pos.x * transform.world_sx,
        transform.world_oy + t_local_pos.y * transform.world_sy)
end

----------------------------------------------------

local function get_local_to_absolute_size(t_local_size)
    -- Return the size in absolute space.
    local transform = get_active_container()
    if not transform then
        return t_local_size
    end
    return vec2(
        t_local_size.x * transform.world_sx,
        t_local_size.y * transform.world_sy)
end

----------------------------------------------------

local function get_next_widget_position()
    -- Return the next item origin in local space.
    local layout_count = #m_layout_stack
    if layout_count > 0 then
        local layout = m_layout_stack[layout_count]
        return vec2(layout.cursor_x, layout.cursor_y)
    end

    -- Return the next item origin in the active container.
    local transform = get_active_container()
    if transform then
        return vec2(transform.cursor_x, transform.cursor_y)
    end

    -- No local layout or active container.
    print_error("[UiWidgets] get_next_widget_position called with no local layout.")
    return vec2(0.0, 0.0)
end

----------------------------------------------------

local function get_mouse_in_active_space()
    local mouse_pos = input_get_mouse_position()

    -- Return the mouse position in design space.
    if gui_get_is_design_space_active() then
        return gui_get_screen_to_design_position(mouse_pos)
    end

    -- Return the mouse position in global space.
    return mouse_pos
end

----------------------------------------------------

local function advance_next_widget_position(t_size)
    local layout_count = #m_layout_stack
    if layout_count > 0 then
        local layout = m_layout_stack[layout_count]

        -- Grid steps by cell size. Widget's unscaled size is ignored.
        if layout.kind == "grid" then
            layout.index = layout.index + 1
            local col = layout.index % layout.columns
            local row = math.floor(layout.index / layout.columns)
            layout.cursor_x = layout.start_x + col * (layout.cell_w + layout.gap)
            layout.cursor_y = layout.start_y + row * (layout.cell_h + layout.gap)
            local rows = math.floor((layout.index + layout.columns - 1) / layout.columns)
            if rows < 1 then
                rows = 1
            end
            layout.used_w = layout.columns * layout.cell_w + (layout.columns - 1) * layout.gap
            layout.used_h = rows * layout.cell_h + (rows - 1) * layout.gap
            return
        end

        -- vbox
        if layout.kind == "vbox" then
            if layout.used_w < t_size.x then
                layout.used_w = t_size.x
            end
            layout.cursor_y = layout.cursor_y + t_size.y + layout.gap
            layout.used_h = layout.cursor_y - layout.start_y - layout.gap
            layout.cursor_x = layout.start_x
            return
        end

        -- hbox.
        if layout.used_h < t_size.y then
            layout.used_h = t_size.y
        end
        layout.cursor_x = layout.cursor_x + t_size.x + layout.gap
        layout.used_w = layout.cursor_x - layout.start_x - layout.gap
        layout.cursor_y = layout.start_y
        return
    end

    -- If no layout, advance the active container as a vertical stack.
    local transform = get_active_container()
    if transform then
        transform.cursor_x = 0.0
        transform.cursor_y = transform.cursor_y + t_size.y
    end
end

----------------------------------------------------

local function get_widget_rectangle(t_size, t_reserve_and_advance)
    -- x, y, w, h for rectangle.
    if get_is_local_layout_active() then
        local next_widget_position = get_next_widget_position()
        local widget_pos = get_local_to_absolute_position(next_widget_position)
        local widget_size = get_local_to_absolute_size(t_size)
        gui_set_cursor_screen_pos(widget_pos)
        if t_reserve_and_advance then
            gui_dummy(widget_size)
            advance_next_widget_position(t_size)
        end
        return vec4(widget_pos.x, widget_pos.y, widget_size.x, widget_size.y)
    end

    if t_reserve_and_advance then
        gui_dummy(t_size)
        local widget_pos = gui_get_item_rect_min()
        return vec4(widget_pos.x, widget_pos.y, t_size.x, t_size.y)
    end

    local widget_pos = gui_get_cursor_screen_pos()
    return vec4(widget_pos.x, widget_pos.y, t_size.x, t_size.y)
end

----------------------------------------------------

local function draw_widget_surface(t_style, t_rectangle, t_corner_rounding)
    if not t_style then
        return
    end

    local surface_pos = vec2(t_rectangle.x, t_rectangle.y)
    local surface_size = vec2(t_rectangle.z, t_rectangle.w)

    -- Select the right drawing method.

    -- Sliced texture.
    if t_style.texture and t_style.slice then
        local slice = t_style.slice
        gui_draw_image_sliced(
            t_style.texture,
            surface_pos,
            surface_size,
            slice.left,
            slice.top,
            slice.right,
            slice.bottom,
            t_style.color)
        return
    end

    -- Atlas region.
    if t_style.texture and t_style.uv_min and t_style.uv_max then
        gui_draw_image_region(
            t_style.texture,
            surface_pos,
            surface_size,
            t_style.uv_min,
            t_style.uv_max,
            t_style.color)
        return
    end

    -- Texture.
    if t_style.texture then
        gui_draw_image(
            t_style.texture,
            surface_pos,
            surface_size,
            t_style.color)
        return
    end

    -- Color. Opaque fills keep scroll content hidden. Partial alpha is allowed for overlays.
    if t_style.color then
        gui_draw_rect_rounded(
            surface_pos,
            surface_size,
            t_corner_rounding or DEFAULT_CORNER_ROUNDING,
            t_style.color)
    end
end

----------------------------------------------------

local function get_widget_state_style(t_idle, t_hover, t_pressed, t_focused, t_hovered, t_held, t_focused_now)
    -- Held and pressed.
    if t_held and t_pressed then
        return t_pressed
    end

    -- Focused.
    if t_focused_now and t_focused then
        return t_focused
    end

    -- Hover.
    if t_hovered and t_hover then
        return t_hover
    end

    -- Idle default.
    return t_idle
end

----------------------------------------------------

local function get_is_widget_interaction_active(t_state)
    return t_state.hovered or t_state.held or t_state.focused_now
end

----------------------------------------------------

local function begin_widget_interaction(t_state, t_size)
    if t_state.id == nil or t_state.id == "" then
        print_error("[UiWidgets] widget id is required.")
        t_state.clicked = false
        t_state.hovered = false
        t_state.held = false
        t_state.focused_now = false
        t_state.rectangle = vec4(0.0, 0.0, 0.0, 0.0)
        return
    end

    -- Validate the size.
    if t_size.x <= 0.0 or t_size.y <= 0.0 then
        print_error("[UiWidgets] widget '" .. tostring(t_state.id) .. "' has non-positive size.")
        t_state.clicked = false
        t_state.hovered = false
        t_state.held = false
        t_state.focused_now = false
        t_state.rectangle = vec4(0.0, 0.0, 0.0, 0.0)
        return
    end

    -- Init state.
    local widget_pos = vec2(0.0, 0.0)
    local widget_size = t_size
    local clicked = false
    local hovered = false
    local held = false

    -- Calculate the widget rectangle.
    -- Use the local cursor and container scale.
    if get_is_local_layout_active() then
        local next_widget_position = get_next_widget_position()
        local widget_scale = get_scale_or_default(t_state.scale)
        local pivot_x = 0.0
        local pivot_y = 0.0

        -- Use the pivot if provided.
        if t_state.pivot then
            pivot_x = t_state.pivot.x
            pivot_y = t_state.pivot.y
        end

        -- Calculate the local position and size.
        local local_pos = vec2(
            next_widget_position.x + pivot_x * t_size.x * (1.0 - widget_scale.x),
            next_widget_position.y + pivot_y * t_size.y * (1.0 - widget_scale.y))
        local local_size = t_size * widget_scale

        -- Convert the local position and size to absolute space.
        widget_pos = get_local_to_absolute_position(local_pos)
        widget_size = get_local_to_absolute_size(local_size)
        gui_set_cursor_screen_pos(widget_pos)
        -- Open combo lists use gui_get_menu_nav_step_y. ImGui nav must stay off.
        local enable_nav = m_open_combo_id == ""
        clicked, hovered, held = gui_invisible_button(t_state.id, widget_size, enable_nav)
        advance_next_widget_position(t_size)
    -- Otherwise, use the global cursor and default scale.
    else
        local enable_nav = m_open_combo_id == ""
        clicked, hovered, held = gui_invisible_button(t_state.id, t_size, enable_nav)
        widget_pos = gui_get_item_rect_min()
        widget_size = gui_get_item_rect_size()
    end

    -- An open combo owns the frame. Background widgets cannot take the press.
    if m_open_combo_id ~= "" and t_state.id ~= m_open_combo_id then
        clicked = false
        hovered = false
        held = false
    end

    -- Update the widget state.
    local focused = gui_get_is_item_focused()
    t_state.clicked = clicked
    t_state.hovered = hovered
    t_state.held = held
    t_state.focused_now = focused
    t_state.rectangle = vec4(widget_pos.x, widget_pos.y, widget_size.x, widget_size.y)
end

----------------------------------------------------

local function grow_widget_rectangle(t_state, t_rectangle)
    -- If empty, set the rectangle to the new one.
    if t_state.rectangle.z <= 0.0 then
        t_state.rectangle = t_rectangle
        return
    end

    -- Otherwise, grow the current rectangle to include the new one.
    local current = t_state.rectangle
    local min_x = math.min(current.x, t_rectangle.x)
    local min_y = math.min(current.y, t_rectangle.y)
    local max_x = math.max(current.x + current.z, t_rectangle.x + t_rectangle.z)
    local max_y = math.max(current.y + current.w, t_rectangle.y + t_rectangle.w)
    t_state.rectangle = vec4(min_x, min_y, max_x - min_x, max_y - min_y)
end

----------------------------------------------------

local function get_is_point_inside_rectangle(t_point, t_rectangle)
    if t_point.x < t_rectangle.x then
        return false
    end
    if t_point.y < t_rectangle.y then
        return false
    end
    if t_point.x > t_rectangle.x + t_rectangle.z then
        return false
    end
    if t_point.y > t_rectangle.y + t_rectangle.w then
        return false
    end
    return true
end

----------------------------------------------------

local function close_combo(t_state)
    -- Keep m_open_combo_id until the next canvas so widgets drawn after this
    -- close still ignore the press that dismissed the list.
    t_state.open = false
    t_state.popup_anchor_valid = false
    if m_open_combo_id == t_state.id then
        m_combo_release_id = t_state.id
    end
    if m_deferred_combo_popup_state == t_state then
        m_deferred_combo_popup_state = nil
    end
end

----------------------------------------------------

local function get_combo_list_rectangle(t_state, t_widget_pos, t_widget_size)
    local option_h = t_state.item_height * (t_widget_size.y / t_state.height)
    return vec4(
        t_widget_pos.x,
        t_widget_pos.y + t_widget_size.y,
        t_widget_size.x,
        option_h * #t_state.options)
end

----------------------------------------------------

local function apply_combo_selection(t_state, t_index)
    if t_state.selected ~= t_index then
        t_state.selected = t_index
        t_state.changed = true
        if t_state.apply_fn then
            t_state.apply_fn(t_state.selected - 1)
        end
    end
    t_state.highlight = t_index
end

----------------------------------------------------

local function get_combo_label_color(t_state, t_surface_style)
    if t_surface_style == t_state.idle or t_surface_style == t_state.popup then
        return t_state.text_color
    end
    if t_state.text_color_on_accent then
        return t_state.text_color_on_accent
    end
    return t_state.text_color
end

----------------------------------------------------

local function get_combo_field_activate_pressed(t_state)
    if t_state.clicked then
        return true
    end
    if input_get_is_last_input_device_mouse() then
        return false
    end
    if not gui_get_is_ui_nav_activate_pressed() then
        return false
    end
    if m_open_combo_id == t_state.id and t_state.open then
        return true
    end
    if t_state.focused_now then
        return true
    end
    return false
end

----------------------------------------------------

local function draw_combo_popup_window(t_state)
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)
    local option_count = #t_state.options
    local option_h = t_state.item_height * (widget_size.y / t_state.height)
    local font_size = t_state.font_size * (widget_size.y / t_state.height)
    local pad = 10.0 * (widget_size.x / t_state.width)
    local popup_flags =
        GuiWindowFlags.NO_TITLE_BAR +
        GuiWindowFlags.NO_RESIZE +
        GuiWindowFlags.NO_MOVE +
        GuiWindowFlags.NO_COLLAPSE +
        GuiWindowFlags.NO_SAVED_SETTINGS +
        GuiWindowFlags.NO_BACKGROUND +
        GuiWindowFlags.NO_SCROLLBAR +
        GuiWindowFlags.NO_NAV
    if gui_set_next_window_focus ~= nil then
        gui_set_next_window_focus()
    end
    gui_push_style_var_vec2(GuiStyleVar.WINDOW_PADDING, vec2(0.0, 0.0))
    gui_push_style_var_vec2(GuiStyleVar.ITEM_SPACING, vec2(0.0, 0.0))
    gui_set_next_window_pos(vec2(widget_pos.x, widget_pos.y + widget_size.y))
    gui_set_next_window_size(vec2(widget_size.x, option_h * option_count))
    local option_clicked_any = false
    local popup_began = false
    if gui_begin_window(t_state.id .. "_popup", popup_flags) then
        popup_began = true
        draw_widget_surface(
            t_state.popup,
            vec4(widget_pos.x, widget_pos.y + widget_size.y, widget_size.x, option_h * option_count),
            t_state.corner_rounding)

        for i = 1, option_count do
            local option_id = string.format("%s_option_%d", t_state.id, i)
            local option_clicked, option_hovered, option_held = gui_invisible_button(
                option_id,
                vec2(widget_size.x, option_h),
                false)
            local option_pos = gui_get_item_rect_min()
            local option_style = t_state.popup
            if option_held and t_state.pressed then
                option_style = t_state.pressed
            elseif input_get_is_last_input_device_mouse() and option_hovered and t_state.popup_hover then
                option_style = t_state.popup_hover
            elseif t_state.highlight == i then
                if t_state.focused then
                    option_style = t_state.focused
                elseif t_state.popup_hover then
                    option_style = t_state.popup_hover
                end
            end
            draw_widget_surface(
                option_style,
                vec4(option_pos.x, option_pos.y, widget_size.x, option_h),
                t_state.corner_rounding)

            local option_label = t_state.options[i]
            local option_text_size = gui_get_text_size(option_label, font_size, t_state.font_id)
            local option_text_y = option_pos.y + (option_h - option_text_size.y) * 0.5
            gui_draw_text(
                option_label,
                vec2(option_pos.x + pad, option_text_y),
                font_size,
                get_combo_label_color(t_state, option_style),
                t_state.font_id)

            if option_clicked then
                option_clicked_any = true
                apply_combo_selection(t_state, i)
                close_combo(t_state)
            end
        end
    end
    if popup_began then
        gui_end_window()
    end
    gui_pop_style_var(2)

    if t_state.open and not option_clicked_any then
        if input_get_is_last_input_device_mouse() and input_get_mouse_action_pressed_event("select") then
            local mouse_pos = get_mouse_in_active_space()
            local list_rectangle = get_combo_list_rectangle(t_state, widget_pos, widget_size)
            local on_field = get_is_point_inside_rectangle(mouse_pos, t_state.rectangle)
            local on_list = get_is_point_inside_rectangle(mouse_pos, list_rectangle)
            if not on_field and not on_list then
                close_combo(t_state)
            end
        end
    end

    if t_state.open then
        t_state.popup_anchor_x = widget_pos.x
        t_state.popup_anchor_y = widget_pos.y
        t_state.popup_anchor_valid = true
    else
        t_state.popup_anchor_valid = false
    end

    return option_clicked_any
end

----------------------------------------------------

local function apply_spinner_step(t_state, t_direction)
    local next_value = t_state.value + t_state.step * t_direction
    if next_value < t_state.min_value then
        next_value = t_state.min_value
    end
    if next_value > t_state.max_value then
        next_value = t_state.max_value
    end
    if next_value ~= t_state.value then
        t_state.value = next_value
        t_state.changed = true
    end
end

----------------------------------------------------

local function draw_widget_choice_row(t_state, t_labels, t_id_prefix, t_item_width, t_item_height, t_horizontal)
    local count = #t_labels

    -- Reset interaction flags.
    t_state.changed = false
    t_state.hovered = false
    t_state.focused_now = false
    t_state.rectangle = vec4(0.0, 0.0, 0.0, 0.0)

    -- Use an hbox for horizontal choices.
    local opened_hbox = false
    if t_horizontal and get_is_local_layout_active() then
        UiWidgets.hbox_begin(0.0)
        opened_hbox = true
    end

    -- Draw each choice.
    for i = 1, count do
        local item_id = string.format("%s_%s_%d", t_state.id, t_id_prefix, i)
        local item_widget = {
            id = item_id,
            scale = t_state.scale,
            pivot = t_state.pivot,
        }

        -- Capture click hit-testing for the choice rectangle.
        begin_widget_interaction(item_widget, vec2(t_item_width, t_item_height))
        local widget_pos = vec2(item_widget.rectangle.x, item_widget.rectangle.y)
        local widget_size = vec2(item_widget.rectangle.z, item_widget.rectangle.w)

        -- Bubble hover up to the parent state.
        if item_widget.hovered then
            t_state.hovered = true
        end
        -- Bubble focus up to the parent state.
        if item_widget.focused_now then
            t_state.focused_now = true
        end
        -- Grow the parent rectangle to include the child rectangle.
        grow_widget_rectangle(t_state, item_widget.rectangle)

        -- Pick chrome.
        local is_selected = t_state.selected == i
        local style = t_state.idle
        if item_widget.held and t_state.pressed then
            style = t_state.pressed
        elseif item_widget.focused_now and t_state.focused then
            style = t_state.focused
        elseif item_widget.focused_now and t_state.selected_style then
            style = t_state.selected_style
        elseif item_widget.hovered and t_state.hover then
            style = t_state.hover
        elseif is_selected and t_state.selected_style and get_is_widget_interaction_active(item_widget) then
            style = t_state.selected_style
        end
        -- Draw the choice chrome.
        draw_widget_surface(style, item_widget.rectangle, t_state.corner_rounding)

        -- Center the choice label.
        local label = t_labels[i]
        local font_size = t_state.font_size * (widget_size.y / t_item_height)
        gui_draw_text_aligned(
            label,
            widget_pos,
            widget_size,
            GuiAlignH.CENTER,
            GuiAlignV.MIDDLE,
            font_size,
            t_state.text_color,
            t_state.font_id)

        -- Handle selection change.
        if item_widget.clicked and t_state.selected ~= i then
            t_state.selected = i
            t_state.changed = true
        end

        -- Advance to the next choice.
        if t_horizontal and i < count and not opened_hbox then
            gui_same_line()
        end
    end

    -- Close the hbox.
    if opened_hbox then
        UiWidgets.hbox_end()
    end

    -- Return whether the selection changed.
    return t_state.changed
end

----------------------------------------------------

local function draw_widget_spinner_side_button(t_state, t_id_suffix, t_label, t_button_size)
    -- Create a side button state.
    local button_id = t_state.id .. t_id_suffix
    local side_widget = {
        id = button_id,
        scale = t_state.scale,
        pivot = t_state.pivot,
    }

    -- Capture click hit-testing for the button rectangle.
    begin_widget_interaction(side_widget, vec2(t_button_size, t_state.height))
    local widget_pos = vec2(side_widget.rectangle.x, side_widget.rectangle.y)
    local widget_size = vec2(side_widget.rectangle.z, side_widget.rectangle.w)

    -- Handle navigation.
    local nav_changed, nav_value = gui_apply_focused_step_tweak(
        t_state.value,
        t_state.min_value,
        t_state.max_value,
        t_state.step)
    if nav_changed then
        t_state.value = nav_value
        t_state.changed = true
    end

    -- Bubble up to the parent state.
    if side_widget.hovered then
        t_state.hovered = true
    end
    -- Bubble focus up to the parent state.
    if side_widget.focused_now then
        t_state.focused_now = true
    end
    -- Grow the parent rectangle to include the child rectangle.
    grow_widget_rectangle(t_state, side_widget.rectangle)

    -- Pick chrome.
    local style = get_widget_state_style(
        t_state.idle,
        t_state.hover,
        t_state.pressed,
        t_state.focused,
        side_widget.hovered,
        side_widget.held,
        side_widget.focused_now)
    -- Draw the side button chrome.
    draw_widget_surface(style, side_widget.rectangle, t_state.corner_rounding)

    -- Draw the label.
    local font_size = t_state.font_size * (widget_size.y / t_state.height)
    gui_draw_text_aligned(
        t_label,
        widget_pos,
        widget_size,
        GuiAlignH.CENTER,
        GuiAlignV.MIDDLE,
        font_size,
        t_state.text_color,
        t_state.font_id)

    -- Return whether the button was clicked.
    return side_widget.clicked
end

----------------------------------------------------

local function layout_begin(t_kind, t_gap, t_columns, t_cell_size)
    -- Get the current cursor position.
    local layout_origin = gui_get_cursor_screen_pos()
    -- If local layout is active, use the next widget position.
    if get_is_local_layout_active() then
        layout_origin = get_next_widget_position()
    end

    -- Calculate the cell size.
    local cell_w = 0.0 
    local cell_h = 0.0
    if t_cell_size then
        cell_w = t_cell_size.x
        cell_h = t_cell_size.y
    end

    -- Push the layout state.
    m_layout_stack[#m_layout_stack + 1] = {
        kind = t_kind,
        start_x = layout_origin.x,
        start_y = layout_origin.y,
        cursor_x = layout_origin.x,
        cursor_y = layout_origin.y,
        gap = t_gap or 0.0,
        columns = t_columns or 1,
        cell_w = cell_w,
        cell_h = cell_h,
        index = 0,
        used_w = 0.0,
        used_h = 0.0,
    }
end

----------------------------------------------------

local function layout_end()
    -- Pop the layout state.
    local count = #m_layout_stack
    if count == 0 then
        print_error("[UiWidgets] layout_end called with an empty stack.")
        return
    end

    -- Get the layout state.
    local layout = m_layout_stack[count]
    m_layout_stack[count] = nil

    -- If local layout is active, advance the cursor.
    if get_is_local_layout_active() then
        if layout.used_w > 0.0 or layout.used_h > 0.0 then
            advance_next_widget_position(vec2(layout.used_w, layout.used_h))
        end
        return
    end

    -- Set the cursor position.
    if layout.kind == "hbox" then
        gui_set_cursor_screen_pos(vec2(layout.start_x + layout.used_w, layout.start_y))
    else
        gui_set_cursor_screen_pos(vec2(layout.start_x, layout.start_y + layout.used_h))
    end
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------

--- Create a new button state.
--- @param t_def button definition
--- @return button state
function UiWidgets.new_button(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height,
        label = t_def.label or "",
        font_size = t_def.font_size or 14,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        scale = t_def.scale or vec2(1.0, 1.0),
        pivot = t_def.pivot or vec2(0.5, 0.5),
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        clicked = false,
        hovered = false,
        held = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a button.
--- @param t_state button state
--- @return whether the button was clicked
function UiWidgets.button(t_state)
    -- Capture click hit-testing for the button rect.
    begin_widget_interaction(t_state, vec2(t_state.width, t_state.height))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)

    -- Pick chrome from idle / hover / pressed / focused.
    local style = get_widget_state_style(
        t_state.idle,
        t_state.hover,
        t_state.pressed,
        t_state.focused,
        t_state.hovered,
        t_state.held,
        t_state.focused_now)
    draw_widget_surface(style, t_state.rectangle, t_state.corner_rounding)

    -- Center the label in the button.
    if t_state.label ~= "" then
        local font_size = t_state.font_size * (widget_size.y / t_state.height)
        gui_draw_text_aligned(
            t_state.label,
            widget_pos,
            widget_size,
            GuiAlignH.CENTER,
            GuiAlignV.MIDDLE,
            font_size,
            t_state.text_color,
            t_state.font_id)
    end

    return t_state.clicked
end

----------------------------------------------------

--- Draw a panel.
--- @param t_pos position
--- @param t_size size
--- @param t_style style
--- @param t_corner_rounding corner rounding
function UiWidgets.panel(t_pos, t_size, t_style, t_corner_rounding)
    local widget_pos = t_pos
    local widget_size = t_size

    -- Inside a layout box or container, sit on the cursor and advance like other widgets.
    if get_is_local_layout_active() then
        local next_widget_position = get_next_widget_position()
        widget_pos = get_local_to_absolute_position(next_widget_position + t_pos)
        widget_size = get_local_to_absolute_size(t_size)
        gui_set_cursor_screen_pos(widget_pos)
        gui_dummy(widget_size)
        advance_next_widget_position(t_size)
    end

    draw_widget_surface(
        t_style,
        vec4(widget_pos.x, widget_pos.y, widget_size.x, widget_size.y),
        t_corner_rounding or DEFAULT_CORNER_ROUNDING)
end

----------------------------------------------------

--- Draw a separator.
--- @param t_size size
--- @param t_style style
function UiWidgets.separator(t_size, t_style)
    local widget_rectangle = get_widget_rectangle(t_size, true)
    draw_widget_surface(t_style, widget_rectangle, 0.0)
end

----------------------------------------------------

--- Create a new slot state.
--- @param t_def slot definition
--- @return slot state
function UiWidgets.new_slot(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height,
        icon_texture = t_def.icon_texture or "",
        icon_uv_min = t_def.icon_uv_min,
        icon_uv_max = t_def.icon_uv_max,
        icon_padding = t_def.icon_padding or 6.0,
        stack_text = t_def.stack_text or "",
        font_size = t_def.font_size or 14,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        scale = t_def.scale or vec2(1.0, 1.0),
        pivot = t_def.pivot or vec2(0.5, 0.5),
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        clicked = false,
        hovered = false,
        held = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a slot.
--- @param t_state slot state
--- @return whether the slot was clicked
function UiWidgets.slot(t_state)
    -- Capture click hit-testing for the slot rect.
    begin_widget_interaction(t_state, vec2(t_state.width, t_state.height))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)

    -- Pick chrome from idle / hover / pressed / focused.
    local style = get_widget_state_style(
        t_state.idle,
        t_state.hover,
        t_state.pressed,
        t_state.focused,
        t_state.hovered,
        t_state.held,
        t_state.focused_now)
    draw_widget_surface(style, t_state.rectangle, t_state.corner_rounding)

    -- Draw the padded icon inside the slot.
    if t_state.icon_texture ~= "" then
        local scale_x = widget_size.x / t_state.width
        local scale_y = widget_size.y / t_state.height
        local pad_x = t_state.icon_padding * scale_x
        local pad_y = t_state.icon_padding * scale_y
        local icon_pos = vec2(widget_pos.x + pad_x, widget_pos.y + pad_y)
        local icon_size = vec2(widget_size.x - pad_x * 2.0, widget_size.y - pad_y * 2.0)
        if t_state.icon_uv_min and t_state.icon_uv_max then
            gui_draw_image_region(
                t_state.icon_texture,
                icon_pos,
                icon_size,
                t_state.icon_uv_min,
                t_state.icon_uv_max)
        else
            gui_draw_image(t_state.icon_texture, icon_pos, icon_size)
        end
    end

    -- Draw stack count in the bottom-right corner.
    if t_state.stack_text ~= "" then
        local font_size = t_state.font_size * (widget_size.y / t_state.height)
        local text_size = gui_get_text_size(t_state.stack_text, font_size, t_state.font_id)
        local text_x = widget_pos.x + widget_size.x - text_size.x - 4.0 * (widget_size.x / t_state.width)
        local text_y = widget_pos.y + widget_size.y - text_size.y - 2.0 * (widget_size.y / t_state.height)
        gui_draw_text(t_state.stack_text, vec2(text_x, text_y), font_size, t_state.text_color, t_state.font_id)
    end

    return t_state.clicked
end

----------------------------------------------------

--- Create a new checkbox state.
--- @param t_def checkbox definition
--- @return checkbox state
function UiWidgets.new_checkbox(t_def)
    local size = t_def.size or vec2(DEFAULT_CHECKBOX_SIZE, DEFAULT_CHECKBOX_SIZE)
    return {
        id = t_def.id,
        size = size,
        label = t_def.label or "",
        font_size = t_def.font_size or 14,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or 2.0,
        checked = t_def.checked == true,
        scale = t_def.scale or vec2(1.0, 1.0),
        pivot = t_def.pivot or vec2(0.0, 0.5),
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        check = t_def.check,
        check_idle = t_def.check_idle,
        border_color = t_def.border_color,
        border_thickness = t_def.border_thickness or 2.0,
        clicked = false,
        hovered = false,
        held = false,
        focused_now = false,
        changed = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a checkbox.
--- @param t_state checkbox state
--- @return whether the checkbox was changed
function UiWidgets.checkbox(t_state)
    -- Size the hit rect to the box plus optional label.
    local box = t_state.size
    local label_w = 0.0
    if t_state.label ~= "" then
        label_w = gui_get_text_size(t_state.label, t_state.font_size, t_state.font_id).x + CHECKBOX_LABEL_GAP
    end
    local total_w = box.x + label_w
    local total_h = math.max(box.y, t_state.font_size)

    -- Capture click hit-testing for the full checkbox row.
    begin_widget_interaction(t_state, vec2(total_w, total_h))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)

    -- Toggle checked state on click.
    t_state.changed = false
    if t_state.clicked then
        t_state.checked = not t_state.checked
        t_state.changed = true
    end

    -- Pick chrome from idle / hover / pressed / focused.
    local style = get_widget_state_style(
        t_state.idle,
        t_state.hover,
        t_state.pressed,
        t_state.focused,
        t_state.hovered,
        t_state.held,
        t_state.focused_now)
    local scale_x = widget_size.x / total_w
    local scale_y = widget_size.y / total_h
    local box_w = box.x * scale_x
    local box_h = box.y * scale_y
    local box_y = widget_pos.y + (widget_size.y - box_h) * 0.5

    -- Hollow frame. Border stays cream until hover, focus, or press.
    if t_state.border_color then
        local border_draw_color = t_state.border_color
        if get_is_widget_interaction_active(t_state) and style and style.color then
            border_draw_color = style.color
        end
        local border = t_state.border_thickness * scale_y
        gui_draw_rect(vec2(widget_pos.x, box_y), vec2(box_w, border), border_draw_color)
        gui_draw_rect(vec2(widget_pos.x, box_y + box_h - border), vec2(box_w, border), border_draw_color)
        gui_draw_rect(vec2(widget_pos.x, box_y), vec2(border, box_h), border_draw_color)
        gui_draw_rect(vec2(widget_pos.x + box_w - border, box_y), vec2(border, box_h), border_draw_color)
    else
        draw_widget_surface(
            style,
            vec4(widget_pos.x, box_y, box_w, box_h),
            t_state.corner_rounding)
    end

    -- Inner fill when checked. Idle chrome until hover, focus, or press, then accent.
    if t_state.checked and (t_state.check or t_state.check_idle) then
        local pad_scale = 0.22
        if t_state.border_color then
            pad_scale = 0.30
        end
        local pad = box_w * pad_scale
        local check_style = t_state.check_idle
        if not check_style and t_state.border_color then
            check_style = { color = t_state.border_color }
        end
        if get_is_widget_interaction_active(t_state) and t_state.check then
            check_style = t_state.check
        end
        draw_widget_surface(
            check_style,
            vec4(widget_pos.x + pad, box_y + pad, box_w - pad * 2.0, box_h - pad * 2.0),
            t_state.corner_rounding)
    end

    -- Draw the optional side label.
    if t_state.label ~= "" then
        local font_size = t_state.font_size * scale_y
        local text_y = widget_pos.y + (widget_size.y - font_size) * 0.5
        gui_draw_text(
            t_state.label,
            vec2(widget_pos.x + box_w + CHECKBOX_LABEL_GAP * scale_x, text_y),
            font_size,
            t_state.text_color,
            t_state.font_id)
    end

    return t_state.changed
end

----------------------------------------------------

--- Create a new slider state.
--- @param t_def slider definition
--- @return slider state
function UiWidgets.new_slider(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height or DEFAULT_SLIDER_HEIGHT,
        track_height = t_def.track_height or DEFAULT_SLIDER_TRACK_HEIGHT,
        thumb_size = t_def.thumb_size or DEFAULT_SLIDER_THUMB_SIZE,
        value = t_def.value or 0.0,
        min_value = t_def.min_value or 0.0,
        max_value = t_def.max_value or 1.0,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        scale = t_def.scale or vec2(1.0, 1.0),
        pivot = t_def.pivot or vec2(0.5, 0.5),
        track = t_def.track,
        fill = t_def.fill,
        fill_active = t_def.fill_active,
        thumb_idle = t_def.thumb_idle,
        thumb_hover = t_def.thumb_hover,
        thumb_pressed = t_def.thumb_pressed,
        thumb_focused = t_def.thumb_focused,
        clicked = false,
        hovered = false,
        held = false,
        focused_now = false,
        changed = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a slider.
--- @param t_state slider state
--- @return whether the slider was changed
function UiWidgets.slider(t_state)
    -- Capture drag hit-testing for the full slider rect.
    begin_widget_interaction(t_state, vec2(t_state.width, t_state.height))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)

    -- Value range must be valid; do not invent a fake span.
    local value_span = t_state.max_value - t_state.min_value
    if value_span <= 0.0 then
        print_error("[UiWidgets] slider '" .. tostring(t_state.id) .. "' has max_value <= min_value.")
        t_state.changed = false
        return false
    end

    -- Map mouse X across the track only while the mouse is dragging.
    -- Gamepad or keyboard activate still sets held, and must not snap to the cursor.
    local previous_value = t_state.value
    if t_state.held and input_get_is_mouse_action_pressed("select") then
        local mouse_pos = get_mouse_in_active_space()
        local mouse_x_along_track = math_clamp((mouse_pos.x - widget_pos.x) / widget_size.x, 0.0, 1.0)
        t_state.value = t_state.min_value + mouse_x_along_track * value_span
    end

    -- Step with arrows or the gamepad while focused.
    local nav_changed, nav_value = gui_apply_focused_step_tweak(
        t_state.value,
        t_state.min_value,
        t_state.max_value,
        value_span * 0.05)
    if nav_changed then
        t_state.value = nav_value
    end
    t_state.changed = t_state.value ~= previous_value

    -- Draw the empty track under the filled portion.
    local normalized = math_clamp((t_state.value - t_state.min_value) / value_span, 0.0, 1.0)
    local scale_y = widget_size.y / t_state.height
    local track_h = t_state.track_height * scale_y
    local track_y = widget_pos.y + (widget_size.y - track_h) * 0.5
    draw_widget_surface(
        t_state.track,
        vec4(widget_pos.x, track_y, widget_size.x, track_h),
        t_state.corner_rounding)

    -- Value fill from the start to the thumb. Brighter grey idle, accent when active.
    local fill_width = math.max(track_h, widget_size.x * normalized)
    if t_state.fill or t_state.fill_active then
        local fill_style = t_state.fill
        if t_state.fill_active and get_is_widget_interaction_active(t_state) then
            fill_style = t_state.fill_active
        end
        if fill_style then
            draw_widget_surface(
                fill_style,
                vec4(widget_pos.x, track_y, fill_width, track_h),
                t_state.corner_rounding)
        end
    end

    -- Draw the thumb at the normalized value.
    local thumb_style = get_widget_state_style(
        t_state.thumb_idle,
        t_state.thumb_hover,
        t_state.thumb_pressed,
        t_state.thumb_focused,
        t_state.hovered,
        t_state.held,
        t_state.focused_now)
    local thumb = t_state.thumb_size * scale_y
    local thumb_pos = vec2(
        widget_pos.x + (widget_size.x - thumb) * normalized,
        widget_pos.y + (widget_size.y - thumb) * 0.5)
    draw_widget_surface(thumb_style, vec4(thumb_pos.x, thumb_pos.y, thumb, thumb), thumb * 0.5)

    return t_state.changed
end

----------------------------------------------------

--- Create a new progress state.
--- @param t_def progress definition
--- @return progress state
function UiWidgets.new_progress(t_def)
    return {
        id = t_def.id or "",
        width = t_def.width,
        height = t_def.height,
        value = t_def.value or 0.0,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        bg = t_def.bg,
        fill = t_def.fill,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a progress.
--- @param t_state progress state
function UiWidgets.progress(t_state)
    -- Reserve the space for the progress bar.
    local widget_rectangle = get_widget_rectangle(vec2(t_state.width, t_state.height), true)
    t_state.rectangle = widget_rectangle
    local widget_pos = vec2(widget_rectangle.x, widget_rectangle.y)
    local widget_size = vec2(widget_rectangle.z, widget_rectangle.w)

    local progress = math_clamp(t_state.value, 0.0, 1.0)

    -- Draw the background and progress.
    draw_widget_surface(t_state.bg, widget_rectangle, t_state.corner_rounding)
    if progress > 0.0 then
        draw_widget_surface(
            t_state.fill,
            vec4(widget_pos.x, widget_pos.y, widget_size.x * progress, widget_size.y),
            t_state.corner_rounding)
    end
end

----------------------------------------------------

--- True while this widget should show a tooltip.
--- Mouse uses hover. Gamepad and keyboard use focus.
--- @param t_widget widget state
--- @return whether the tooltip should show
function UiWidgets.get_should_show_tooltip(t_widget)
    -- Mouse uses hover only. 
    -- Focus after a click must not keep the tip.
    if input_get_is_last_input_device_mouse() then
        return t_widget.hovered
    end

    -- Gamepad and keyboard keep the tip on the focused widget.
    return t_widget.focused_now
end

----------------------------------------------------

--- Draw a tooltip.
--- @param t_text tooltip text
--- @param t_def tooltip definition
--- @param t_anchor tooltip anchor
function UiWidgets.tooltip(t_text, t_def, t_anchor)
    -- Skip empty tooltips.
    if t_text == "" then
        return
    end

    -- Measure the padded box from the text size.
    local font_size = t_def.font_size or 14.0
    local font_id = t_def.font_id or ""
    local padding = t_def.padding or DEFAULT_TOOLTIP_PADDING
    local corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING
    local offset_x = t_def.offset_x or DEFAULT_TOOLTIP_OFFSET_X
    local offset_y = t_def.offset_y or DEFAULT_TOOLTIP_OFFSET_Y
    local widget_gap = t_def.widget_gap or DEFAULT_TOOLTIP_WIDGET_GAP
    local text_color = t_def.text_color or Colors.WHITE
    local text_size = gui_get_text_size(t_text, font_size, font_id)
    local tooltip_size = vec2(text_size.x + padding * 2.0, text_size.y + padding * 2.0)

    -- Follow the pointer only while the mouse is the live device.
    -- Gamepad and keyboard sit the tip under the focused widget.
    -- Mouse is always display pixels. Convert when design space is pushed so
    -- gui_draw_* does not letterbox the position a second time.
    local layout = gui_get_layout_size()
    local tooltip_pos = vec2(0.0, 0.0)
    local use_widget_anchor = t_anchor ~= nil and not input_get_is_last_input_device_mouse()
    if use_widget_anchor then
        if t_anchor.rectangle.z <= 0.0 then
            print_error("[UiWidgets] tooltip widget anchor has no rectangle.")
            return
        end
        tooltip_pos = vec2(
            t_anchor.rectangle.x + (t_anchor.rectangle.z - tooltip_size.x) * 0.5,
            t_anchor.rectangle.y + t_anchor.rectangle.w + widget_gap)
        if tooltip_pos.y + tooltip_size.y > layout.y then
            tooltip_pos = vec2(tooltip_pos.x, t_anchor.rectangle.y - tooltip_size.y - widget_gap)
        end
    else
        local mouse_pos = get_mouse_in_active_space()
        tooltip_pos = vec2(mouse_pos.x + offset_x, mouse_pos.y + offset_y)
        if tooltip_pos.x + tooltip_size.x > layout.x then
            tooltip_pos = vec2(layout.x - tooltip_size.x - 4.0, tooltip_pos.y)
        end
        if tooltip_pos.y + tooltip_size.y > layout.y then
            tooltip_pos = vec2(tooltip_pos.x, mouse_pos.y - tooltip_size.y - 8.0)
        end
    end
    if tooltip_pos.x + tooltip_size.x > layout.x then
        tooltip_pos = vec2(layout.x - tooltip_size.x - 4.0, tooltip_pos.y)
    end
    if tooltip_pos.x < 4.0 then
        tooltip_pos = vec2(4.0, tooltip_pos.y)
    end
    if tooltip_pos.y < 4.0 then
        tooltip_pos = vec2(tooltip_pos.x, 4.0)
    end

    local tooltip_rectangle = vec4(tooltip_pos.x, tooltip_pos.y, tooltip_size.x, tooltip_size.y)

    -- Draw above other UI on the foreground list.
    gui_push_foreground_draw()

    -- Draw the border, background, then the label text.
    if t_def.border then
        draw_widget_surface(
            t_def.border,
            vec4(tooltip_rectangle.x - 1.0, tooltip_rectangle.y - 1.0, tooltip_rectangle.z + 2.0, tooltip_rectangle.w + 2.0),
            corner_rounding)
    end
    draw_widget_surface(t_def.bg, tooltip_rectangle, corner_rounding)
    gui_draw_text(
        t_text,
        vec2(tooltip_rectangle.x + padding, tooltip_rectangle.y + padding),
        font_size,
        text_color,
        font_id)
    gui_pop_foreground_draw()
end

----------------------------------------------------

--- Opens a transform parent. Children author in local space.
--- pos, size, pivot, and scale use glm vec2.
--- @param t_def container definition
function UiWidgets.container_begin(t_def)
    if not t_def then
        print_error("[UiWidgets] container_begin requires a def table.")
        return
    end

    local pos = t_def.pos or vec2(0.0, 0.0)
    local size = t_def.size or vec2(0.0, 0.0)
    local pivot = t_def.pivot or vec2(0.0, 0.0)
    local scale = get_scale_or_default(t_def.scale)
    if scale.x == 0.0 or scale.y == 0.0 then
        print_error("[UiWidgets] container_begin scale must be non-zero.")
        return
    end
    if t_def.clip == true then
        if size.x <= 0.0 or size.y <= 0.0 then
            print_error("[UiWidgets] container_begin clip requires a positive size.")
            return
        end
    end

    local parent_ox = 0.0
    local parent_oy = 0.0
    local parent_sx = 1.0
    local parent_sy = 1.0
    local parent = get_active_container()
    if parent then
        parent_ox = parent.world_ox
        parent_oy = parent.world_oy
        parent_sx = parent.world_sx
        parent_sy = parent.world_sy
    else
        -- Root container anchors to the current ImGui cursor.
        local cursor = gui_get_cursor_screen_pos()
        parent_ox = cursor.x
        parent_oy = cursor.y
    end

    -- Scale around pivot in local space, then lift into parent space.
    local pivot_x = pivot.x * size.x
    local pivot_y = pivot.y * size.y
    local world_sx = parent_sx * scale.x
    local world_sy = parent_sy * scale.y
    local world_ox = parent_ox + parent_sx * (pos.x + pivot_x * (1.0 - scale.x))
    local world_oy = parent_oy + parent_sy * (pos.y + pivot_y * (1.0 - scale.y))

    local clip_pushed = false

    m_transform_stack[#m_transform_stack + 1] = {
        world_ox = world_ox,
        world_oy = world_oy,
        world_sx = world_sx,
        world_sy = world_sy,
        size_x = size.x,
        size_y = size.y,
        cursor_x = 0.0,
        cursor_y = 0.0,
        clip = false,
    }

    -- Optional clip to the scaled container rect.
    if t_def.clip == true then
        local clip_pos = get_local_to_absolute_position(vec2(0.0, 0.0))
        local clip_size = get_local_to_absolute_size(size)
        gui_push_clip_rect(clip_pos, clip_pos + clip_size, true)
        clip_pushed = true
    end
    m_transform_stack[#m_transform_stack].clip = clip_pushed

    gui_set_cursor_screen_pos(vec2(world_ox, world_oy))
end

----------------------------------------------------

--- Closes a transform parent.
function UiWidgets.container_end()
    local count = #m_transform_stack
    if count == 0 then
        print_error("[UiWidgets] container_end called with an empty stack.")
        return
    end

    if #m_layout_stack > 0 then
        print_error("[UiWidgets] container_end called while a layout box is still open.")
        return
    end

    local transform = m_transform_stack[count]
    local used_w = transform.size_x
    local used_h = transform.cursor_y
    local world_ox = transform.world_ox
    local world_oy = transform.world_oy
    local world_sy = transform.world_sy
    if transform.clip then
        gui_pop_clip_rect()
    end
    m_transform_stack[count] = nil

    -- Advance the parent placement, or park the ImGui cursor under a root container.
    if get_is_local_layout_active() then
        if used_w < 0.0 then
            used_w = 0.0
        end
        if used_h > 0.0 or used_w > 0.0 then
            advance_next_widget_position(vec2(used_w, used_h))
        end
    else
        gui_set_cursor_screen_pos(vec2(world_ox, world_oy + used_h * world_sy))
    end
end

----------------------------------------------------

--- Opens a vertical layout box.
--- @param t_gap gap
function UiWidgets.vbox_begin(t_gap)
    layout_begin("vbox", t_gap or 0.0, 1, nil)
end

----------------------------------------------------

--- Closes a vertical layout box.
function UiWidgets.vbox_end()
    layout_end()
end

----------------------------------------------------

--- Opens a horizontal layout box.
--- @param t_gap gap
function UiWidgets.hbox_begin(t_gap)
    layout_begin("hbox", t_gap or 0.0, 1, nil)
end

----------------------------------------------------

--- Closes a horizontal layout box.
function UiWidgets.hbox_end()
    layout_end()
end

----------------------------------------------------

--- Opens a grid layout box.
--- @param t_columns columns
--- @param t_cell_size cell size
--- @param t_gap gap
function UiWidgets.grid_begin(t_columns, t_cell_size, t_gap)
    if not t_columns or t_columns < 1 then
        print_error("[UiWidgets] grid_begin requires columns >= 1.")
        return
    end
    if not t_cell_size then
        print_error("[UiWidgets] grid_begin requires a vec2 cell_size.")
        return
    end
    layout_begin("grid", t_gap or 0.0, t_columns, t_cell_size)
end

----------------------------------------------------

--- Closes a grid layout box.
function UiWidgets.grid_end()
    layout_end()
end

----------------------------------------------------

--- Opens a design canvas for menus.
--- Call gui_set_reference_resolution and gui_set_scale_mode once at init
--- for your authored canvas (any size, including portrait).
--- HUD stays outside any canvas and uses gui_get_normalized_to_pixels plus anchors
--- against gui_get_layout_size (see player_hud.lua).
--- @param t_name string
--- @param t_flags integer
--- @return boolean
function UiWidgets.begin_menu_canvas(t_name, t_flags)
    -- Engine owns scale mode + design space. Widgets only compose content.
    -- Drop a combo block from the previous frame before any widget runs.
    if m_combo_release_id ~= "" and m_open_combo_id == m_combo_release_id then
        m_open_combo_id = ""
    end
    m_combo_release_id = ""
    return gui_begin_design_canvas(t_name, t_flags)
end

----------------------------------------------------

--- Closes a menu canvas.
function UiWidgets.end_menu_canvas()
    -- Draw the open list after every other widget so later rows cannot cover it.
    if m_deferred_combo_popup_state then
        draw_combo_popup_window(m_deferred_combo_popup_state)
        m_deferred_combo_popup_state = nil
    end
    gui_end_design_canvas()
end

----------------------------------------------------

--- Whether a combo dropdown is open on the current menu canvas.
--- @return boolean
function UiWidgets.get_is_any_combo_open()
    return m_open_combo_id ~= ""
end

----------------------------------------------------

--- Draw a label.
--- @param t_text label text
--- @param t_font_size font size
--- @param t_text_color text color
--- @param t_font_id font id
function UiWidgets.label(t_text, t_font_size, t_text_color, t_font_id)
    local font_size = t_font_size or 14.0
    local font_id = t_font_id or ""
    local text_color = t_text_color or Colors.WHITE
    local text_size = gui_get_text_size(t_text, font_size, font_id)
    local widget_rectangle = get_widget_rectangle(text_size, true)
    local widget_pos = vec2(widget_rectangle.x, widget_rectangle.y)
    local widget_size = vec2(widget_rectangle.z, widget_rectangle.w)
    local draw_font = font_size
    if text_size.y > 0.0 then
        draw_font = font_size * (widget_size.y / text_size.y)
    end
    gui_draw_text(t_text, widget_pos, draw_font, text_color, font_id)
end

----------------------------------------------------

--- Draw a label row.
--- @param t_label label text
--- @param t_label_width label width
--- @param t_row_height row height
--- @param t_font_size font size
--- @param t_text_color text color
--- @param t_font_id font id
function UiWidgets.label_row(t_label, t_label_width, t_row_height, t_font_size, t_text_color, t_font_id)
    local height = t_row_height or DEFAULT_ROW_HEIGHT
    local font_size = t_font_size or 14.0
    local font_id = t_font_id or ""
    local text_color = t_text_color or Colors.WHITE

    -- Draw the label column, then leave the cursor on the control side.
    if get_is_local_layout_active() then
        local next_widget_position = get_next_widget_position()
        local widget_pos = get_local_to_absolute_position(next_widget_position)
        local widget_size = get_local_to_absolute_size(vec2(t_label_width, height))
        local draw_font = font_size * (widget_size.y / height)
        gui_set_cursor_screen_pos(widget_pos)
        gui_dummy(widget_size)
        gui_draw_text(t_label, vec2(widget_pos.x, widget_pos.y + (widget_size.y - draw_font) * 0.5), draw_font, text_color, font_id)

        -- Stay on this row so the next widget sits in the control column.
        local layout_count = #m_layout_stack
        if layout_count > 0 then
            local layout = m_layout_stack[layout_count]
            if layout.kind == "hbox" or layout.kind == "grid" then
                advance_next_widget_position(vec2(t_label_width, height))
            else
                layout.cursor_x = next_widget_position.x + t_label_width + LABEL_ROW_GAP
                if layout.used_h < height then
                    layout.used_h = height
                end
            end
        else
            local transform = get_active_container()
            if transform then
                transform.cursor_x = next_widget_position.x + t_label_width + LABEL_ROW_GAP
            end
        end
        return
    end

    gui_dummy(vec2(t_label_width, height))
    local rect_min = gui_get_item_rect_min()
    local text_y = rect_min.y + (height - font_size) * 0.5
    gui_draw_text(t_label, vec2(rect_min.x, text_y), font_size, text_color, font_id)
    gui_same_line(0.0, LABEL_ROW_GAP)
end

----------------------------------------------------

--- Create a new tabs state.
--- @param t_def tabs definition
--- @return tabs state
function UiWidgets.new_tabs(t_def)
    return {
        id = t_def.id,
        labels = t_def.labels or {},
        selected = t_def.selected or 1,
        tab_width = t_def.tab_width or 100.0,
        tab_height = t_def.tab_height or DEFAULT_TAB_HEIGHT,
        font_size = t_def.font_size or 16.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused or t_def.selected_style,
        selected_style = t_def.selected_style or t_def.focused,
        changed = false,
        hovered = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw tabs.
--- @param t_state tabs state
--- @return whether the tabs were changed
function UiWidgets.tabs(t_state)
    -- Tabs are a horizontal choice row over the label list.
    return draw_widget_choice_row(
        t_state,
        t_state.labels,
        "tab",
        t_state.tab_width,
        t_state.tab_height,
        true)
end

----------------------------------------------------

--- Create a new radio group state.
--- @param t_def radio group definition
--- @return radio group state
function UiWidgets.new_radio_group(t_def)
    return {
        id = t_def.id,
        options = t_def.options or {},
        selected = t_def.selected or 1,
        horizontal = t_def.horizontal ~= false,
        item_width = t_def.item_width or 90.0,
        item_height = t_def.item_height or DEFAULT_ROW_HEIGHT,
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused or t_def.selected_style,
        selected_style = t_def.selected_style or t_def.focused,
        changed = false,
        hovered = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a radio group.
--- @param t_state radio group state
--- @return whether the radio group was changed
function UiWidgets.radio_group(t_state)
    -- Radios reuse the same choice-row path as tabs.
    return draw_widget_choice_row(
        t_state,
        t_state.options,
        "radio",
        t_state.item_width,
        t_state.item_height,
        t_state.horizontal)
end

----------------------------------------------------

--- Create a new combo state.
--- @param t_def combo definition
--- @return combo state
function UiWidgets.new_combo(t_def)
    return {
        id = t_def.id,
        options = t_def.options or {},
        selected = t_def.selected or 1,
        width = t_def.width,
        height = t_def.height or DEFAULT_ROW_HEIGHT,
        item_height = t_def.item_height or DEFAULT_COMBO_ITEM_HEIGHT,
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        text_color_on_accent = t_def.text_color_on_accent,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        popup = t_def.popup or t_def.idle,
        popup_hover = t_def.popup_hover or t_def.hover,
        show_caret = t_def.show_caret ~= false,
        open = false,
        highlight = t_def.selected or 1,
        changed = false,
        hovered = false,
        clicked = false,
        held = false,
        focused_now = false,
        popup_anchor_x = 0.0,
        popup_anchor_y = 0.0,
        popup_anchor_valid = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a combo.
--- @param t_state combo state
--- @return whether the combo was changed
function UiWidgets.combo(t_state)
    begin_widget_interaction(t_state, vec2(t_state.width, t_state.height))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)
    t_state.changed = false

    -- Handle combo activation and toggling.
    if get_combo_field_activate_pressed(t_state) then
        if t_state.open then
            if not input_get_is_last_input_device_mouse() then
                local option_count = #t_state.options
                if t_state.highlight >= 1 and t_state.highlight <= option_count then
                    apply_combo_selection(t_state, t_state.highlight)
                end
            end
            close_combo(t_state)
        else
            if t_state.on_before_open then
                t_state.on_before_open(t_state)
            end
            t_state.open = true
            t_state.highlight = t_state.selected
            m_open_combo_id = t_state.id
        end
    end
    if t_state.open and m_open_combo_id ~= t_state.id then
        close_combo(t_state)
    end

    -- Close the combo if the popup anchor has moved.
    if t_state.open and t_state.popup_anchor_valid then
        if t_state.popup_anchor_x ~= widget_pos.x or t_state.popup_anchor_y ~= widget_pos.y then
            close_combo(t_state)
        end
    end

    -- Wheel over the background scrolls the parent. 
    if t_state.open then
        if input_get_mouse_wheel_up() or input_get_mouse_wheel_down() then
            local mouse_pos = get_mouse_in_active_space()
            local list_rectangle = get_combo_list_rectangle(t_state, widget_pos, widget_size)
            if not get_is_point_inside_rectangle(mouse_pos, list_rectangle) then
                close_combo(t_state)
            end
        end
    end

    -- Face B closes without changing the current setting.
    if t_state.open and input_get_action_pressed_event("cancel") then
        close_combo(t_state)
    end

    -- D-pad stick and arrows move the highlight on the open list.
    if t_state.open and m_open_combo_id == t_state.id then
        local option_count = #t_state.options
        if t_state.highlight < 1 then
            t_state.highlight = t_state.selected
        end
        if option_count > 0 and t_state.highlight > option_count then
            t_state.highlight = option_count
        end
        local step_y = gui_get_menu_nav_step_y()
        if step_y ~= 0 and option_count > 0 then
            local next_highlight = t_state.highlight + step_y
            if next_highlight < 1 then
                next_highlight = 1
            end
            if next_highlight > option_count then
                next_highlight = option_count
            end
            t_state.highlight = next_highlight
        end
    end

    if not t_state.open then
        t_state.popup_anchor_valid = false
    end

    -- Draw the closed-field chrome.
    local style = get_widget_state_style(
        t_state.idle,
        t_state.hover,
        t_state.pressed,
        t_state.focused,
        t_state.hovered,
        t_state.held,
        t_state.focused_now)
    draw_widget_surface(style, t_state.rectangle, t_state.corner_rounding)

    -- Draw the currently selected option label.
    local selected_label = ""
    if t_state.selected >= 1 and t_state.selected <= #t_state.options then
        selected_label = t_state.options[t_state.selected]
    end
    local font_size = t_state.font_size * (widget_size.y / t_state.height)
    local label_color = get_combo_label_color(t_state, style)
    local text_size = gui_get_text_size(selected_label, font_size, t_state.font_id)
    local text_y = widget_pos.y + (widget_size.y - text_size.y) * 0.5
    local pad = 10.0 * (widget_size.x / t_state.width)
    gui_draw_text(selected_label, vec2(widget_pos.x + pad, text_y), font_size, label_color, t_state.font_id)

    -- Draw the open/closed caret on the right when enabled.
    if t_state.show_caret then
        local caret = COMBO_CARET_DOWN
        if t_state.open then
            caret = COMBO_CARET_UP
        end
        local caret_font_size = font_size * COMBO_CARET_FONT_SCALE
        local caret_size = gui_get_text_size(caret, caret_font_size, COMBO_CARET_FONT_ID)
        local caret_y = widget_pos.y + (widget_size.y - caret_size.y) * 0.5
        gui_draw_text(
            caret,
            vec2(widget_pos.x + widget_size.x - caret_size.x - pad, caret_y),
            caret_font_size,
            label_color,
            COMBO_CARET_FONT_ID)
    end

    if t_state.open then
        m_deferred_combo_popup_state = t_state
    end

    return t_state.changed
end

----------------------------------------------------

--- Begins a scroll area.
--- @param t_id scroll area id
--- @param t_size size
--- @param t_style style
--- @param t_corner_rounding corner rounding
--- @return whether the scroll area was created
function UiWidgets.begin_scroll(t_id, t_size, t_style, t_corner_rounding)
    -- Frame sits behind the child so the paper chrome frames the scroll area.
    local widget_rectangle = get_widget_rectangle(t_size, false)
    local widget_pos = vec2(widget_rectangle.x, widget_rectangle.y)
    local widget_size = vec2(widget_rectangle.z, widget_rectangle.w)
    if t_style then
        draw_widget_surface(t_style, widget_rectangle, t_corner_rounding or DEFAULT_CORNER_ROUNDING)
    end
    if get_is_local_layout_active() then
        advance_next_widget_position(t_size)
    end

    -- Begin the child with no background so the paper frame sits behind it.
    m_scroll_child_open = gui_begin_child(t_id, widget_size, GuiWindowFlags.NO_BACKGROUND)
    return m_scroll_child_open
end

----------------------------------------------------

--- Ends a scroll area.
function UiWidgets.end_scroll()
    if m_scroll_child_open then
        gui_end_child()
        m_scroll_child_open = false
    end
end

----------------------------------------------------

--- Create a new toggle state.
--- @param t_def toggle definition
--- @return toggle state
function UiWidgets.new_toggle(t_def)
    return {
        id = t_def.id,
        width = t_def.width or DEFAULT_TOGGLE_WIDTH,
        height = t_def.height or DEFAULT_TOGGLE_HEIGHT,
        label = t_def.label or "",
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        checked = t_def.checked == true,
        scale = t_def.scale or vec2(1.0, 1.0),
        pivot = t_def.pivot or vec2(0.0, 0.5),
        on_style = t_def.on_style,
        off_style = t_def.off_style or t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        knob = t_def.knob,
        changed = false,
        hovered = false,
        clicked = false,
        held = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a toggle.
--- @param t_state toggle state
--- @return whether the toggle was changed
function UiWidgets.toggle(t_state)
    -- Label width calculation.
    local label_w = 0.0
    if t_state.label ~= "" then
        label_w = gui_get_text_size(t_state.label, t_state.font_size, t_state.font_id).x + CHECKBOX_LABEL_GAP
    end
    local total_w = t_state.width + label_w
    local total_h = math.max(t_state.height, t_state.font_size)

    -- Begin interaction with the toggle widget.
    begin_widget_interaction(t_state, vec2(total_w, total_h))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)
    t_state.changed = false
    if t_state.clicked then
        t_state.checked = not t_state.checked
        t_state.changed = true
    end

    local scale_x = widget_size.x / total_w
    local scale_y = widget_size.y / total_h
    local track_w = t_state.width * scale_x
    local track_h = t_state.height * scale_y

    -- Draw the toggle track and knob.
    local track_y = widget_pos.y + (widget_size.y - track_h) * 0.5
    local track_style = t_state.off_style or t_state.idle
    if t_state.held and t_state.pressed then
        track_style = t_state.pressed
    elseif t_state.focused_now and t_state.focused then
        track_style = t_state.focused
    elseif t_state.hovered and t_state.hover then
        track_style = t_state.hover
    elseif t_state.checked and t_state.on_style and get_is_widget_interaction_active(t_state) then
        track_style = t_state.on_style
    end
    draw_widget_surface(track_style, vec4(widget_pos.x, track_y, track_w, track_h), track_h * 0.5)

    local knob = track_h - 6.0 * scale_y
    local knob_x = widget_pos.x + 3.0 * scale_x
    if t_state.checked then
        knob_x = widget_pos.x + track_w - knob - 3.0 * scale_x
    end
    local knob_y = track_y + 3.0 * scale_y
    draw_widget_surface(t_state.knob, vec4(knob_x, knob_y, knob, knob), knob * 0.5)

    -- Draw the optional side label.
    if t_state.label ~= "" then
        local font_size = t_state.font_size * scale_y
        local text_y = widget_pos.y + (widget_size.y - font_size) * 0.5
        gui_draw_text(
            t_state.label,
            vec2(widget_pos.x + track_w + CHECKBOX_LABEL_GAP * scale_x, text_y),
            font_size,
            t_state.text_color,
            t_state.font_id)
    end

    return t_state.changed
end

----------------------------------------------------

--- Create a new spinner state.
--- @param t_def spinner definition
--- @return spinner state
function UiWidgets.new_spinner(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height or DEFAULT_ROW_HEIGHT,
        button_size = t_def.button_size or DEFAULT_SPINNER_BUTTON_SIZE,
        value = t_def.value or 0.0,
        min_value = t_def.min_value or 0.0,
        max_value = t_def.max_value or 100.0,
        step = t_def.step or 1.0,
        format = t_def.format or "%.0f",
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        value_bg = t_def.value_bg or t_def.idle,
        changed = false,
        hovered = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a spinner.
--- @param t_state spinner state
--- @return whether the spinner was changed
function UiWidgets.spinner(t_state)
    -- Leave room for minus, value plate, and plus.
    local side_button_size = t_state.button_size
    local value_width = t_state.width - side_button_size * 2.0 - 8.0
    if value_width < 40.0 then
        value_width = 40.0
    end
    t_state.changed = false
    t_state.hovered = false
    t_state.focused_now = false
    t_state.rectangle = vec4(0.0, 0.0, 0.0, 0.0)

    -- Keep all three widget parts on one row.
    local opened_hbox = false
    if get_is_local_layout_active() then
        UiWidgets.hbox_begin(4.0)
        opened_hbox = true
    end

    -- Draw the minus side button.
    local minus_clicked = draw_widget_spinner_side_button(t_state, "_minus", "-", side_button_size)

    -- Draw the value between the buttons.
    if not opened_hbox then
        gui_same_line(0.0, 4.0)
    end

    local value_rectangle = get_widget_rectangle(vec2(value_width, t_state.height), true)
    local value_pos = vec2(value_rectangle.x, value_rectangle.y)
    local value_size = vec2(value_rectangle.z, value_rectangle.w)
    grow_widget_rectangle(t_state, value_rectangle)

    draw_widget_surface(t_state.value_bg, value_rectangle, t_state.corner_rounding)
    local font_size = t_state.font_size * (value_size.y / t_state.height)
    local value_label = string.format(t_state.format, t_state.value)
    gui_draw_text_aligned(
        value_label,
        value_pos,
        value_size,
        GuiAlignH.CENTER,
        GuiAlignV.MIDDLE,
        font_size,
        t_state.text_color,
        t_state.font_id)

    -- Draw the plus side button.
    if not opened_hbox then
        gui_same_line(0.0, 4.0)
    end
    local plus_clicked = draw_widget_spinner_side_button(t_state, "_plus", "+", side_button_size)

    if opened_hbox then
        UiWidgets.hbox_end()
    end

    -- Step the value.
    if minus_clicked then
        apply_spinner_step(t_state, -1.0)
    end
    if plus_clicked then
        apply_spinner_step(t_state, 1.0)
    end

    return t_state.changed
end

----------------------------------------------------

--- Create a new text input state.
--- @param t_def text input definition
--- @return text input state
function UiWidgets.new_text_input(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height or DEFAULT_TEXT_INPUT_HEIGHT,
        text = t_def.text or "",
        max_length = t_def.max_length or 128,
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        focused = t_def.focused,
        changed = false,
        hovered = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a text input.
--- @param t_state text input state
--- @return whether the text input was changed
function UiWidgets.text_input(t_state)
    local widget_rectangle = get_widget_rectangle(vec2(t_state.width, t_state.height), false)
    local widget_pos = vec2(widget_rectangle.x, widget_rectangle.y)
    local widget_size = vec2(widget_rectangle.z, widget_rectangle.w)
    t_state.rectangle = widget_rectangle

    -- Style uses last frame's hover/focus so the plate stays under the text.
    local style = t_state.idle
    if t_state.focused_now and t_state.focused then
        style = t_state.focused
    elseif t_state.hovered and t_state.hover then
        style = t_state.hover
    end
    draw_widget_surface(style, t_state.rectangle, t_state.corner_rounding)

    -- Keep ImGui's frame invisible so the skinned widget surface is visible.
    gui_push_style_color(GuiCol.FRAME_BG, Colors.CLEAR)
    gui_push_style_color(GuiCol.FRAME_BG_HOVERED, Colors.CLEAR)
    gui_push_style_color(GuiCol.FRAME_BG_ACTIVE, Colors.CLEAR)
    gui_push_style_color(GuiCol.TEXT, t_state.text_color)

    -- Calculate scaling and padding for the text input within the widget.
    local scale_x = widget_size.x / t_state.width
    local scale_y = widget_size.y / t_state.height
    local pad = 8.0 * scale_x
    local font_size = t_state.font_size * scale_y
    gui_set_cursor_screen_pos(vec2(widget_pos.x + pad, widget_pos.y + (widget_size.y - font_size) * 0.5))
    local changed, text = gui_input_text(t_state.id, t_state.text, widget_size.x - pad * 2.0, t_state.max_length)
    t_state.hovered = gui_get_is_item_hovered()
    t_state.focused_now = gui_get_is_item_focused() or gui_get_is_item_active()
    gui_pop_style_color(4)

    -- Advance the cursor position for the next widget based on the current layout.
    if get_is_local_layout_active() then
        advance_next_widget_position(vec2(t_state.width, t_state.height))
    else
        gui_set_cursor_screen_pos(vec2(widget_pos.x, widget_pos.y + widget_size.y))
    end

    -- Store text when ImGui reports a change.
    t_state.changed = changed
    if changed then
        t_state.text = text
    end
    return t_state.changed
end

----------------------------------------------------

--- Create a new keybind state.
--- @param t_def keybind definition
--- @return keybind state
function UiWidgets.new_keybind(t_def)
    return {
        id = t_def.id,
        width = t_def.width,
        height = t_def.height or DEFAULT_ROW_HEIGHT,
        binding = t_def.binding or "",
        listening = false,
        font_size = t_def.font_size or 14.0,
        font_id = t_def.font_id or "",
        text_color = t_def.text_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or DEFAULT_CORNER_ROUNDING,
        idle = t_def.idle,
        hover = t_def.hover,
        pressed = t_def.pressed,
        focused = t_def.focused,
        listening_style = t_def.listening_style or t_def.focused,
        changed = false,
        hovered = false,
        clicked = false,
        held = false,
        focused_now = false,
        rectangle = vec4(0.0, 0.0, 0.0, 0.0),
    }
end

----------------------------------------------------

--- Draw a keybind.
--- @param t_state keybind state
--- @return whether the keybind was changed
function UiWidgets.keybind(t_state)
    begin_widget_interaction(t_state, vec2(t_state.width, t_state.height))
    local widget_pos = vec2(t_state.rectangle.x, t_state.rectangle.y)
    local widget_size = vec2(t_state.rectangle.z, t_state.rectangle.w)
    t_state.changed = false

    -- Enter listening mode when the keybind is clicked.
    if t_state.clicked then
        t_state.listening = true
    end

    -- Capture the next key press while listening. Escape cancels.
    if t_state.listening then
        local key_name = input_get_just_pressed_key_name()
        if key_name ~= "" then
            if key_name == "Escape" then
                t_state.listening = false
            else
                t_state.binding = key_name
                t_state.listening = false
                t_state.changed = true
            end
        end
    end

    -- Get the current style for the widget based on its state.
    local style = get_widget_state_style(t_state.idle,
                                        t_state.hover,
                                        t_state.pressed,
                                        t_state.focused,
                                        t_state.hovered,
                                        t_state.held,
                                        t_state.focused_now)
    if t_state.listening and t_state.listening_style then
        style = t_state.listening_style
    end
    draw_widget_surface(style, t_state.rectangle, t_state.corner_rounding)

    -- Determine the label to display based on the current binding and listening state.
    local label = t_state.binding
    if t_state.listening then
        label = "Press a key..."
    elseif label == "" then
        label = "Unbound"
    end
    local font_size = t_state.font_size * (widget_size.y / t_state.height)
    gui_draw_text_aligned(
        label,
        widget_pos,
        widget_size,
        GuiAlignH.CENTER,
        GuiAlignV.MIDDLE,
        font_size,
        t_state.text_color,
        t_state.font_id)

    return t_state.changed
end

----------------------------------------------------

--- Create a new modal state.
--- @param t_def modal definition
--- @return modal state
function UiWidgets.new_modal(t_def)
    return {
        id = t_def.id,
        open = t_def.open == true,
        title = t_def.title or "",
        message = t_def.message or "",
        confirm_label = t_def.confirm_label or "Confirm",
        cancel_label = t_def.cancel_label or "Cancel",
        width = t_def.width or 360.0,
        height = t_def.height or 200.0,
        font_size = t_def.font_size or 16.0,
        message_font_size = t_def.message_font_size or 14.0,
        font_id = t_def.font_id or "",
        title_color = t_def.title_color or Colors.WHITE,
        message_color = t_def.message_color or Colors.WHITE,
        corner_rounding = t_def.corner_rounding or 8.0,
        dim = t_def.dim or { color = Colors.get_with_alpha(Colors.BLACK, 0.45) },
        panel = t_def.panel,
        confirm_button = t_def.confirm_button,
        cancel_button = t_def.cancel_button,
        result = "",
        popup_was_open = false,
    }
end

----------------------------------------------------

--- Draw a modal.
--- @param t_state modal state
function UiWidgets.modal(t_state)
    -- Reset the result.
    t_state.result = ""

    -- If the modal is not open, return the result.
    if not t_state.open then
        t_state.popup_was_open = false
        return t_state.result
    end

    local display = gui_get_display_size()
    local popup_name = t_state.id .. "_modal"
    local flags =
        GuiWindowFlags.NO_TITLE_BAR +
        GuiWindowFlags.NO_RESIZE +
        GuiWindowFlags.NO_MOVE +
        GuiWindowFlags.NO_COLLAPSE +
        GuiWindowFlags.NO_SAVED_SETTINGS +
        GuiWindowFlags.NO_BACKGROUND
    local first_open = not t_state.popup_was_open
    local dim_bleed = 2.0

    gui_push_style_var_vec2(GuiStyleVar.WINDOW_PADDING, vec2(0.0, 0.0))
    if first_open then
        gui_open_popup(popup_name)
    end
    gui_set_next_window_pos(vec2(0.0, 0.0))
    gui_set_next_window_size(display)
    if not gui_begin_popup_modal(popup_name, flags) then
        gui_pop_style_var(1)

        -- Escape closes an already-shown popup.
        if t_state.popup_was_open then
            t_state.open = false
            t_state.popup_was_open = false
            t_state.result = "cancel"
        end
        return t_state.result
    end
    t_state.popup_was_open = true

    -- Draw the dim background.
    -- bleed the dim background past the window edges to kill 1px gaps.
    draw_widget_surface(
        t_state.dim,
        vec4(-dim_bleed, -dim_bleed, display.x + dim_bleed * 2.0, display.y + dim_bleed * 2.0),
        0.0)
    gui_push_design_space()
    gui_set_cursor_screen_pos(vec2(0.0, 0.0))
    local layout_size = gui_get_layout_size()

    -- Draw the panel.
    local panel_pos = gui_get_aligned_position(
        vec2(0.0, 0.0),
        layout_size,
        vec2(t_state.width, t_state.height),
        GuiAlignH.CENTER,
        GuiAlignV.MIDDLE)
    local panel_x = panel_pos.x
    local panel_y = panel_pos.y
    draw_widget_surface(
        t_state.panel,
        vec4(panel_pos.x, panel_pos.y, t_state.width, t_state.height),
        t_state.corner_rounding)

    -- Draw the title and message.
    local pad = 24.0
    local content_w = t_state.width - pad * 2.0
    local content_x = panel_x + pad
    gui_draw_text_aligned(
        t_state.title,
        vec2(content_x, panel_y + 20.0),
        vec2(content_w, 32.0),
        GuiAlignH.LEFT,
        GuiAlignV.MIDDLE,
        t_state.font_size,
        t_state.title_color,
        t_state.font_id)
    gui_draw_text_aligned(
        t_state.message,
        vec2(content_x, panel_y + 56.0),
        vec2(content_w, t_state.height - 56.0 - 68.0),
        GuiAlignH.LEFT,
        GuiAlignV.TOP,
        t_state.message_font_size,
        t_state.message_color,
        t_state.font_id)

    -- Draw the buttons centered in the panel.
    local button_y = panel_y + t_state.height - 60.0
    local button_gap = 12.0
    local row_w = 0.0
    if t_state.confirm_button then
        row_w = t_state.confirm_button.width
    end
    if t_state.cancel_button then
        if row_w > 0.0 then
            row_w = row_w + button_gap
        end
        row_w = row_w + t_state.cancel_button.width
    end
    gui_set_cursor_screen_pos(vec2(panel_x + (t_state.width - row_w) * 0.5, button_y))

    -- Draw the confirm button.
    if t_state.confirm_button then
        if UiWidgets.button(t_state.confirm_button) then
            t_state.result = "confirm"
            t_state.open = false
            gui_close_current_popup()
        end
        if first_open then
            gui_set_item_default_focus()
        end
    end

    -- Draw the cancel button.
    if t_state.cancel_button then
        gui_same_line(0.0, button_gap)
        if UiWidgets.button(t_state.cancel_button) then
            t_state.result = "cancel"
            t_state.open = false
            gui_close_current_popup()
        end
    end

    -- Handle the cancel action.
    if input_get_action_pressed_event("cancel") then
        if t_state.cancel_button then
            t_state.result = "cancel"
        else
            t_state.result = "confirm"
        end
        t_state.open = false
        gui_close_current_popup()
    end

    -- End the window.
    gui_pop_design_space()
    gui_end_popup()
    gui_pop_style_var(1)
    return t_state.result
end

----------------------------------------------------

return UiWidgets
