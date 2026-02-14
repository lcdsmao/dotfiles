---@type Wezterm
local wezterm = require("wezterm")

---@type Config
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono",   weight = "Regular" },
  { family = "Apple Color Emoji" },
})
config.font_size = 12.0

-- Color scheme
config.color_scheme = "dogrun"

-- Window appearance
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.98
config.macos_window_background_blur = 8
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

config.adjust_window_size_when_changing_font_size = false

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
  { key = 's', mods = 'CMD|SUPER', action = wezterm.action.QuickSelect },
  { key = 'j', mods = 'CMD|SUPER', action = wezterm.action.ActivateWindowRelative(1) },
  { key = 'k', mods = 'CMD|SUPER', action = wezterm.action.ActivateWindowRelative(-1) },
  { key = 'h', mods = 'CMD|SUPER', action = wezterm.action.Nop }, -- Disable mac os hide ke:
}

-- Window startup behavior
wezterm.on("gui-startup", function(cmd)
  local args = cmd or {}

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

  -- This runs after Zsh initialization completes and environment variables are set
  pane:send_text('if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then exec tmux -u new-session -A -s main; fi\n')
end)

-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Popup launcher configuration
local POPUP_CONFIG = {
  -- Size ratios
  width_ratio = 0.6,             -- 60% of terminal width
  height_ratio = 0.9,            -- 90% of terminal height (bottom-half mode)
  fullscreen_height_ratio = 0.8, -- 80% of terminal height (fullscreen mode)

  -- Positioning
  fullscreen_threshold = 0.6, -- >60% screen height = fullscreen
  top_padding_ratio = 0.04,   -- 4% of screen height padding

  -- Bounds
  screen_margin = 20, -- Pixel margin when clamping
}

-- Generic popup launcher function
-- Spawns a command in a new positioned window
local function popup_launch(window, pane, value)
  wezterm.log_info("=== popup_launch called ===")
  wezterm.log_info("Input value: " .. tostring(value))

  -- Parse value: "command,cwd" or just "cwd"
  local command, cwd
  local comma_pos = string.find(value, ",")

  if comma_pos then
    command = string.sub(value, 1, comma_pos - 1)
    cwd = string.sub(value, comma_pos + 1)
  else
    command = "zsh" -- Default command
    cwd = value
  end

  wezterm.log_info("Parsed command: " .. tostring(command))
  wezterm.log_info("Parsed cwd: " .. tostring(cwd))

  -- Expand relative paths
  if cwd == "." or cwd == "" then
    cwd = wezterm.home_dir
  elseif string.sub(cwd, 1, 1) ~= "/" then
    cwd = wezterm.home_dir .. "/" .. cwd
  end

  -- Get GUI window and dimensions
  local gui_window = window
  if not gui_window then
    return
  end

  local main_dims = gui_window:get_dimensions()
  if not main_dims then
    return
  end

  -- Extract pixel dimensions
  local main_pixel_width = main_dims.pixel_width
  local main_pixel_height = main_dims.pixel_height

  if not main_pixel_width or not main_pixel_height then
    return
  end

  -- Get character dimensions from the pane
  local tab = pane:tab()
  local tab_size = tab:get_size()
  local main_cols = tab_size.cols
  local main_rows = tab_size.rows

  -- Calculate actual character dimensions
  local char_width = main_pixel_width / main_cols
  local char_height = main_pixel_height / main_rows

  -- Get screen dimensions
  local screens = wezterm.gui.screens()
  local active_screen = screens.active
  local screen_x = active_screen.x
  local screen_y = active_screen.y
  local screen_width = active_screen.width
  local screen_height = active_screen.height

  -- Detect if wezterm is fullscreen
  local is_fullscreen = main_pixel_height > (screen_height * POPUP_CONFIG.fullscreen_threshold)

  -- Calculate window size
  local window_cols = math.floor(main_cols * POPUP_CONFIG.width_ratio)
  local window_rows = is_fullscreen
      and math.floor(screen_height / char_height * POPUP_CONFIG.fullscreen_height_ratio)
      or math.floor((screen_height / char_height - main_rows) * POPUP_CONFIG.height_ratio)

  -- Calculate pixel dimensions
  local window_width_px = math.floor(window_cols * char_width)
  local window_height_px = math.floor(window_rows * char_height)

  -- Clamp to screen bounds if necessary
  if window_width_px > screen_width then
    window_width_px = screen_width
    window_cols = math.floor(window_width_px / char_width)
  end

  if window_height_px > screen_height then
    window_height_px = screen_height - POPUP_CONFIG.screen_margin
    window_rows = math.floor(window_height_px / char_height)
  end

  -- Helper function to center horizontally
  local function center_x(width_px)
    return screen_x + math.floor((screen_width - width_px) / 2)
  end

  -- Calculate position based on mode
  local x_position = center_x(window_width_px)
  local y_position

  if is_fullscreen then
    -- Fullscreen mode: center vertically
    y_position = screen_y + math.floor((screen_height - window_height_px) / 2)
  else
    -- Bottom-half mode: top with padding
    local top_padding = math.floor(screen_height * POPUP_CONFIG.top_padding_ratio)
    y_position = screen_y + top_padding
  end

  -- Spawn popup window
  wezterm.mux.spawn_window({
    args = { "zsh", "-li", "-c", command },
    cwd = cwd,
    position = {
      x = x_position,
      y = y_position,
      origin = "ScreenCoordinateSystem",
    },
    width = window_cols,
    height = window_rows,
  })
end

-- Popup launcher handler: listen for user-var and spawn window
wezterm.on("user-var-changed", function(window, pane, name, value)
  if name == "popup_launch" then
    popup_launch(window, pane, value)
  end
end)

return config
