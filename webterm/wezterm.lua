-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Regular" },
  { family = "Apple Color Emoji" },
})
config.font_size = 12.0

-- Color scheme
config.color_scheme = "dogrun"

-- Window appearance
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.line_height = 1.0

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.window_background_gradient = {
  colors = { "#222433" },
}

config.initial_cols = 240
config.initial_rows = 60

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

-- Key bindings
config.keys = {
  {
    key = "Enter",
    mods = "CMD|SUPER",
    action = wezterm.action_callback(function(window, pane)
      local screens = wezterm.gui.screens()
      local active_screen = screens.active

      local current_size = window:get_dimensions()
      local full_width = active_screen.width
      local full_height = active_screen.height
      local half_height = math.floor(full_height / 2)

      -- Check if current height is approximately half (within 10% tolerance)
      local is_half = math.abs(current_size.pixel_height - half_height) < (full_height * 0.1)

      if is_half then
        -- Toggle to full height
        window:set_inner_size(full_width, full_height)
        window:set_position(active_screen.x, active_screen.y)
      else
        -- Toggle to half height
        window:set_inner_size(full_width, half_height)
        window:set_position(active_screen.x, active_screen.y + half_height)
      end
    end),
  },
}

-- Window startup behavior
wezterm.on("gui-startup", function(cmd)
  -- Start tmux for the first window/tab only
  local args = cmd or {}
  if not args.args then
    args.args = { "/bin/zsh", "-l", "-c",
      "if command -v tmux &> /dev/null && [ -z \"$TMUX\" ]; then exec tmux new-session -A -s main; else exec $SHELL; fi" }
  end

  local tab, pane, window = wezterm.mux.spawn_window(args)
  local gui_window = window:gui_window()

  -- Get the active screen info
  local screens = wezterm.gui.screens()
  local active_screen = screens.active

  -- Calculate dimensions for full width and half height
  local full_width = active_screen.width
  local half_height = math.floor(active_screen.height / 2)

  -- Position at bottom half of screen
  local x_position = active_screen.x
  local y_position = active_screen.y + half_height

  -- Set the size and position
  gui_window:set_inner_size(full_width, half_height)
  gui_window:set_position(x_position, y_position)
end)

return config
