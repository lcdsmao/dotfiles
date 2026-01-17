local wezterm = require("wezterm")

return {
  color_scheme = "dogrun",
  font = wezterm.font("JetBrains Mono", { weight = "Regular" }),
  font_size = 12.0,
  line_height = 1.0,
  initial_rows = 30,
  initial_cols = 120,
  -- Window appearance
  window_decorations = "RESIZE",
  window_background_opacity = 0.9,
  macos_window_background_blur = 20,
  window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
  },
  window_background_gradient = {
    colors = { "#222433" },
  },
  scrollback_lines = 1000,
  enable_scroll_bar = false,
  tab_bar_at_bottom = false,
  -- Tab bar appearance
  show_tabs_in_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = true,
  show_new_tab_button_in_tab_bar = false,
  colors = {
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
  },
  -- Bell settings
  audible_bell = "Disabled",
  visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = "CursorColor",
  },
}
