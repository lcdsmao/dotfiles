-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 12.0

-- Color scheme
config.color_scheme = "dogrun"

-- Window sizing
config.initial_rows = 30
config.initial_cols = 120

-- Window appearance
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.line_height = 1.0

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.window_background_gradient = {
  colors = { "#222433" },
}

-- Scrollback
config.scrollback_lines = 1000
config.enable_scroll_bar = false

-- Tab bar appearance
config.tab_bar_at_bottom = false
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
    active_tab = {
      bg_color = "none",
      fg_color = "#6272a4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "none",
      fg_color = "#9ea3c0",
      intensity = "Normal",
    },
  },
}

-- Bell settings
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

return config
