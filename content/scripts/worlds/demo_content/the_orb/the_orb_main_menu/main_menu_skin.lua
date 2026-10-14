local MainMenuSkin = {}

----------------------------------------------------
-- DEPENDENCIES
----------------------------------------------------

local Colors = dofile("../content/scripts/shared/colors.lua")

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------

-- Core Colors.
MainMenuSkin.COLOR_CREAM = vec4(0.94, 0.90, 0.82, 1.0)
MainMenuSkin.COLOR_MUTED = vec4(0.66, 0.60, 0.52, 1.0)
MainMenuSkin.COLOR_EMBER = vec4(0.78, 0.46, 0.24, 1.0)
MainMenuSkin.COLOR_EMBER_BRIGHT = vec4(0.90, 0.58, 0.30, 1.0)
MainMenuSkin.COLOR_NIGHT = vec4(0.07, 0.08, 0.10, 1.0)
MainMenuSkin.COLOR_BUTTON = vec4(0.13, 0.12, 0.11, 1.0)
MainMenuSkin.COLOR_BUTTON_HOVER = vec4(0.22, 0.16, 0.12, 1.0)
MainMenuSkin.COLOR_BUTTON_PRESSED = vec4(0.10, 0.08, 0.07, 1.0)

-- Widget Styles.
MainMenuSkin.WIDGET_STYLE_IDLE = { color = MainMenuSkin.COLOR_BUTTON }
MainMenuSkin.WIDGET_STYLE_HOVER = { color = MainMenuSkin.COLOR_BUTTON_HOVER }
MainMenuSkin.WIDGET_STYLE_PRESSED = { color = MainMenuSkin.COLOR_BUTTON_PRESSED }
MainMenuSkin.WIDGET_STYLE_FOCUSED = { color = MainMenuSkin.COLOR_EMBER }

-- Paper button. 
-- Slice covers the rounded alpha corner on the 128px source for scaling.
-- 12px insets keep corner patches on the rounded alpha so that only the center stretches.
MainMenuSkin.BUTTON_TEXTURE_PAPER = "../content/graphics/demo_content/paper_button.png"
MainMenuSkin.BUTTON_SLICE_PAPER = { left = 12.0, top = 12.0, right = 12.0, bottom = 12.0 }
MainMenuSkin.BUTTON_TEXT_COLOR = vec4(0.16, 0.10, 0.07, 1.0)

-- Font ids as defined in ../content/config/fonts.ini.

-- Menu title.
MainMenuSkin.MENU_TITLE_FONT_ID = "marcellus_40"
MainMenuSkin.MENU_TITLE_FONT_SIZE = 40.0

-- Menu subtitle.
MainMenuSkin.MENU_SUBTITLE_TEXT = "Detis Engine Tech Demo"
MainMenuSkin.MENU_SUBTITLE_FONT_ID = "marcellus_40"
MainMenuSkin.MENU_SUBTITLE_FONT_SIZE = 24.0

-- Engine version label. 
MainMenuSkin.ENGINE_VERSION_FONT_ID = "marcellus_20"
MainMenuSkin.ENGINE_VERSION_FONT_SIZE = 20.0
MainMenuSkin.ENGINE_VERSION_MARGIN = 28.0

-- Menu button.
MainMenuSkin.MENU_BUTTON_FONT_SIZE = 20.0

-- Menu footer buttons.
MainMenuSkin.MENU_FOOTER_BUTTON_HEIGHT = 44.0
MainMenuSkin.MENU_FOOTER_BUTTON_GAP = 8.0
MainMenuSkin.MENU_FOOTER_BUTTON_FONT_SIZE = 16.0

MainMenuSkin.COMMUNITY_LINKS = {
    { label = "Discord", url = "https://discord.gg/dmkJtA4Wf7" },
    { label = "Website", url = "https://detissoftworks.com" },
}

-- 
MainMenuSkin.MENU_SECTION_FONT_SIZE = 20.0
MainMenuSkin.MENU_CONTROLS_HEADER_FONT_SIZE = 30.0
MainMenuSkin.MENU_CONTROLS_SHORTCUT_FONT_SIZE = 22.0
MainMenuSkin.MENU_ROW_FONT_SIZE = 15.0

-- Checkbox
MainMenuSkin.MENU_CHECKBOX_FONT_SIZE = 16.0

-- Modal.
MainMenuSkin.MENU_MODAL_TITLE_FONT_SIZE = 20.0
MainMenuSkin.MENU_MODAL_MESSAGE_FONT_SIZE = 15.0
MainMenuSkin.MENU_MODAL_BUTTON_FONT_SIZE = 18.0

-- Credits
MainMenuSkin.DEMO_CREDITS_TITLE = "Credits"
MainMenuSkin.DEMO_CREDITS_SUBTITLE = ""
MainMenuSkin.MENU_LABEL_FONT_ID = "marcellus_20"
MainMenuSkin.MENU_ROW_LABEL_FONT_ID = "marcellus_15"
MainMenuSkin.CREDITS_TITLE_FONT_ID = "marcellus_40"
MainMenuSkin.CREDITS_TITLE_FONT_SIZE = 40.0
MainMenuSkin.CREDITS_SECTION_FONT_ID = "marcellus_24"
MainMenuSkin.CREDITS_SECTION_FONT_SIZE = 24.0
MainMenuSkin.CREDITS_BODY_FONT_ID = "marcellus_20"
MainMenuSkin.CREDITS_BODY_FONT_SIZE = 20.0

-- Button styles.

-- Idle
MainMenuSkin.STYLE_BUTTON_IDLE = {
    texture = MainMenuSkin.BUTTON_TEXTURE_PAPER,
    slice = MainMenuSkin.BUTTON_SLICE_PAPER,
    color = Colors.WHITE,
}
-- Hover
MainMenuSkin.STYLE_BUTTON_HOVER = {
    texture = MainMenuSkin.BUTTON_TEXTURE_PAPER,
    slice = MainMenuSkin.BUTTON_SLICE_PAPER,
    color = vec4(1.0, 0.94, 0.86, 1.0),
}
-- Pressed
MainMenuSkin.STYLE_BUTTON_PRESSED = {
    texture = MainMenuSkin.BUTTON_TEXTURE_PAPER,
    slice = MainMenuSkin.BUTTON_SLICE_PAPER,
    color = vec4(0.72, 0.66, 0.55, 1.0),
}
-- Focused
MainMenuSkin.STYLE_BUTTON_FOCUSED = {
    texture = MainMenuSkin.BUTTON_TEXTURE_PAPER,
    slice = MainMenuSkin.BUTTON_SLICE_PAPER,
    color = vec4(1.0, 0.82, 0.62, 1.0),
}

-- Left strip menu contiaier. 
-- Right slice keeps the torn alpha edge on the world side.
-- Height comes from the design canvas at draw time.
MainMenuSkin.COLUMN_CONTAINER_TEXTURE = "../content/graphics/demo_content/left_column_menu_container.png"
MainMenuSkin.COLUMN_CONTAINER_SLICE = { left = 4.0, top = 8.0, right = 26.0, bottom = 8.0 }
MainMenuSkin.STYLE_PANEL = {
    texture = MainMenuSkin.COLUMN_CONTAINER_TEXTURE,
    slice = MainMenuSkin.COLUMN_CONTAINER_SLICE,
    color = Colors.WHITE,
}

MainMenuSkin.STYLE_FILL = { color = MainMenuSkin.COLOR_EMBER }

-- Slider styles.
MainMenuSkin.SLIDER_VALUE_COLOR = vec4(0.72, 0.68, 0.62, 1.0)
MainMenuSkin.SLIDER_VALUE_STYLE = { color = MainMenuSkin.SLIDER_VALUE_COLOR }
MainMenuSkin.SLIDER_STYLE_THUMB = { color = MainMenuSkin.COLOR_MUTED }
MainMenuSkin.SLIDER_STYLE_THUMB_HOVER = { color = MainMenuSkin.COLOR_EMBER_BRIGHT }

-- Separator line style.
MainMenuSkin.STYLE_SEPARATOR = { color = MainMenuSkin.COLOR_EMBER }

-- Panel layout settings.
MainMenuSkin.PANEL_WIDTH = 483.0
MainMenuSkin.PANEL_PADDING_LEFT = 32.0
MainMenuSkin.PANEL_PADDING_RIGHT = 83.0
MainMenuSkin.PANEL_PADDING_BOTTOM = 26.0

-- No panel rounding.
MainMenuSkin.PANEL_CORNER_ROUNDING = 0.0

-- Header band height so the top section of the menu has a consistent height.
MainMenuSkin.HEADER_BAND_HEIGHT = 156.0

-- Content width.
MainMenuSkin.CONTENT_WIDTH = MainMenuSkin.PANEL_WIDTH - MainMenuSkin.PANEL_PADDING_LEFT - MainMenuSkin.PANEL_PADDING_RIGHT
MainMenuSkin.SCROLL_GUTTER = 34.0
MainMenuSkin.SCROLL_CONTENT_WIDTH = MainMenuSkin.CONTENT_WIDTH - MainMenuSkin.SCROLL_GUTTER

-- General label settings
MainMenuSkin.LABEL_WIDTH = 150.0
MainMenuSkin.LABEL_ROW_GAP = 12.0

-- Compo
MainMenuSkin.COMPO_WIDTH = MainMenuSkin.SCROLL_CONTENT_WIDTH - MainMenuSkin.LABEL_WIDTH - MainMenuSkin.LABEL_ROW_GAP

-- Button
MainMenuSkin.BUTTON_HEIGHT = 52.0
MainMenuSkin.MENU_BUTTON_WIDTH = 280.0

-- Back button gap
MainMenuSkin.MENU_BACK_BUTTON_GAP = 20.0 -- gap between the menu and the back button

-- Layout row height
MainMenuSkin.ROW_HEIGHT = 34.0

----------------------------------------------------

return MainMenuSkin
