local WEZTERM_BUNDLE_ID = "com.github.wez.wezterm"

local function launch_wezterm()
  hs.application.launchOrFocusByBundleID(WEZTERM_BUNDLE_ID)
end

local function app_ready(app)
  if app:isHidden() then
    return false
  end
  return app:mainWindow() ~= nil
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
  local output =
    run_aerospace("list-windows --monitor all --app-bundle-id " .. bundle_id .. " --format '%{window-id} %{workspace}'")
  local line = first_line(output)
  if not line then
    return nil
  end

  local window_id, workspace = line:match("^(%S+)%s+(%S+)$")
  if not window_id or window_id == "" then
    return nil
  end

  return {
    window_id = window_id,
    workspace = workspace,
  }
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
    launch_wezterm()
    hs.timer.waitUntil(function()
      return app_ready(app)
    end, function()
      run_aerospace("move-node-to-workspace --focus-follows-window --window-id " .. info.window_id .. " " .. workspace)
      run_aerospace("workspace " .. workspace)
    end, 0.05)
  elseif app:isFrontmost() then
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
