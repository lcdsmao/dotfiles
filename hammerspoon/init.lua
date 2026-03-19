local WEZTERM_BUNDLE_ID = "com.github.wez.wezterm"
local WEZTERM_SYNC_INTERVAL = 0.05
local WEZTERM_SYNC_MAX_ATTEMPTS = 40

local wezterm_sync_timer = nil

local function launch_wezterm()
  hs.application.launchOrFocusByBundleID(WEZTERM_BUNDLE_ID)
end

local function app_ready(app)
  if not app then
    return false
  end

  if app:isHidden() then
    return false
  end
  return app:mainWindow() ~= nil
end

local function stop_wezterm_sync_timer()
  if wezterm_sync_timer then
    wezterm_sync_timer:stop()
    wezterm_sync_timer = nil
  end
end

local function run_aerospace(command)
  local bin = "/opt/homebrew/bin/aerospace"
  if not hs.fs.attributes(bin) then
    bin = "aerospace"
  end

  local output, status = hs.execute(bin .. " " .. command)
  if not status then
    return nil
  end
  return output
end

local function first_line(output)
  if not output then
    return nil
  end

  local line = output:match("[^\n]+") or ""
  if line == "" then
    return nil
  end

  return line
end

local function focused_monitor_id()
  return first_line(run_aerospace("list-monitors --focused --format '%{monitor-id}'"))
end

local function focused_workspace()
  local monitor_id = focused_monitor_id()
  if not monitor_id then
    return nil
  end

  return first_line(run_aerospace("list-workspaces --monitor " .. monitor_id .. " --visible --format '%{workspace}'"))
end

local function window_info_for_bundle(bundle_id)
  local output = run_aerospace(
    "list-windows --monitor all --app-bundle-id "
      .. bundle_id
      .. " --format '%{window-id} %{workspace} %{window-layout}'"
  )
  local line = first_line(output)
  if not line then
    return nil
  end

  local window_id, workspace, layout = line:match("^(%S+)%s+(%S+)%s+(%S+)$")
  if not window_id or window_id == "" then
    return nil
  end

  return {
    window_id = window_id,
    workspace = workspace,
    layout = layout,
  }
end

local function schedule_wezterm_workspace_sync(window_id, workspace)
  local attempts = 0

  stop_wezterm_sync_timer()
  wezterm_sync_timer = hs.timer.doEvery(WEZTERM_SYNC_INTERVAL, function()
    attempts = attempts + 1

    local app = hs.application.get(WEZTERM_BUNDLE_ID)
    if app_ready(app) then
      stop_wezterm_sync_timer()
      run_aerospace(
        "move-node-to-workspace --focus-follows-window --window-id " .. window_id .. " " .. workspace
      )
      run_aerospace("workspace " .. workspace)
      return
    end

    if attempts >= WEZTERM_SYNC_MAX_ATTEMPTS then
      stop_wezterm_sync_timer()
    end
  end)
end

local function sync_wezterm_workspace(app, workspace)
  if not app or not workspace then
    return
  end

  local info = window_info_for_bundle(WEZTERM_BUNDLE_ID)
  if not info then
    return
  end

  if info.workspace ~= workspace then
    if app:isHidden() then
      launch_wezterm()
      schedule_wezterm_workspace_sync(info.window_id, workspace)
    else
      run_aerospace("move-node-to-workspace --focus-follows-window --window-id " .. info.window_id .. " " .. workspace)
    end
  elseif app:isFrontmost() and info.layout == "floating" then
    app:hide()
  else
    launch_wezterm()
  end
end

local open_wezterm = function()
  local target_workspace = focused_workspace()
  local app = hs.application.get(WEZTERM_BUNDLE_ID)

  if not target_workspace then
    if app == nil or app:isHidden() or not app:isFrontmost() then
      launch_wezterm()
    else
      app:hide()
    end
    return
  end

  if app == nil then
    launch_wezterm()
    return
  end

  sync_wezterm_workspace(app, target_workspace)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "f", open_wezterm)
