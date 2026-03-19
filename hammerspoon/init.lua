local WEZTERM_BUNDLE_ID = "com.github.wez.wezterm"
local WEZTERM_SYNC_INTERVAL = 0.05
local WEZTERM_SYNC_MAX_ATTEMPTS = 40
local AEROSPACE_TASK_TIMEOUT = 2

local AEROSPACE_BIN = "/opt/homebrew/bin/aerospace"
local AEROSPACE_FALLBACK_BIN = "/usr/bin/env"

local wezterm_request_id = 0
local wezterm_sync_timer = nil
local aerospace_task_id = 0
local aerospace_tasks = {}

if not hs.fs.attributes(AEROSPACE_BIN) then
  AEROSPACE_BIN = AEROSPACE_FALLBACK_BIN
end

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

local function next_wezterm_request_id()
  wezterm_request_id = wezterm_request_id + 1
  return wezterm_request_id
end

local function stop_wezterm_sync_timer()
  if wezterm_sync_timer then
    wezterm_sync_timer:stop()
    wezterm_sync_timer = nil
  end
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

local function cleanup_aerospace_task(task_id)
  local state = aerospace_tasks[task_id]
  if not state then
    return
  end

  if state.timeout_timer then
    state.timeout_timer:stop()
  end

  aerospace_tasks[task_id] = nil
end

local function run_aerospace(args, on_done)
  aerospace_task_id = aerospace_task_id + 1

  local task_id = aerospace_task_id
  local task = nil
  local finished = false
  local task_args = args

  if AEROSPACE_BIN == AEROSPACE_FALLBACK_BIN then
    task_args = { "aerospace" }
    for _, arg in ipairs(args) do
      table.insert(task_args, arg)
    end
  end

  task = hs.task.new(AEROSPACE_BIN, function(exit_code, std_out, std_err)
    if finished then
      return
    end

    finished = true
    cleanup_aerospace_task(task_id)

    if on_done then
      if exit_code == 0 then
        on_done(std_out, nil)
      else
        on_done(nil, std_err)
      end
    end
  end, task_args)

  if not task then
    if on_done then
      on_done(nil, "failed to create aerospace task")
    end
    return nil
  end

  local timeout_timer = hs.timer.doAfter(AEROSPACE_TASK_TIMEOUT, function()
    if finished then
      return
    end

    finished = true
    task:terminate()
    cleanup_aerospace_task(task_id)

    if on_done then
      on_done(nil, "aerospace task timed out")
    end
  end)

  aerospace_tasks[task_id] = {
    task = task,
    timeout_timer = timeout_timer,
  }

  if not task:start() then
    cleanup_aerospace_task(task_id)
    if on_done then
      on_done(nil, "failed to start aerospace task")
    end
    return nil
  end

  return task
end

local function focused_workspace(on_done)
  run_aerospace({ "list-monitors", "--focused", "--format", "%{monitor-id}" }, function(output)
    local monitor_id = first_line(output)
    if not monitor_id then
      on_done(nil)
      return
    end

    run_aerospace({
      "list-workspaces",
      "--monitor",
      monitor_id,
      "--visible",
      "--format",
      "%{workspace}",
    }, function(workspace_output)
      on_done(first_line(workspace_output))
    end)
  end)
end

local function window_info_for_bundle(bundle_id, on_done)
  run_aerospace({
    "list-windows",
    "--monitor",
    "all",
    "--app-bundle-id",
    bundle_id,
    "--format",
    "%{window-id} %{workspace} %{window-layout}",
  }, function(output)
    local line = first_line(output)
    if not line then
      on_done(nil)
      return
    end

    local window_id, workspace, layout = line:match("^(%S+)%s+(%S+)%s+(%S+)$")
    if not window_id or window_id == "" then
      on_done(nil)
      return
    end

    on_done({
      window_id = window_id,
      workspace = workspace,
      layout = layout,
    })
  end)
end

local function move_window_to_workspace(window_id, workspace, on_done)
  run_aerospace({
    "move-node-to-workspace",
    "--focus-follows-window",
    "--window-id",
    window_id,
    workspace,
  }, function(_, _)
    if on_done then
      on_done()
    end
  end)
end

local function focus_workspace(workspace, on_done)
  run_aerospace({ "workspace", workspace }, function(_, _)
    if on_done then
      on_done()
    end
  end)
end

local function schedule_wezterm_workspace_sync(request_id, window_id, workspace)
  local attempts = 0

  stop_wezterm_sync_timer()
  wezterm_sync_timer = hs.timer.doEvery(WEZTERM_SYNC_INTERVAL, function()
    attempts = attempts + 1

    if request_id ~= wezterm_request_id then
      stop_wezterm_sync_timer()
      return
    end

    local app = hs.application.get(WEZTERM_BUNDLE_ID)
    if app_ready(app) then
      stop_wezterm_sync_timer()
      move_window_to_workspace(window_id, workspace, function()
        if request_id ~= wezterm_request_id then
          return
        end

        focus_workspace(workspace)
      end)
      return
    end

    if attempts >= WEZTERM_SYNC_MAX_ATTEMPTS then
      stop_wezterm_sync_timer()
    end
  end)
end

local function sync_wezterm_workspace(request_id, app, workspace)
  if request_id ~= wezterm_request_id or not app or not workspace then
    return
  end

  window_info_for_bundle(WEZTERM_BUNDLE_ID, function(info)
    if request_id ~= wezterm_request_id or not info then
      return
    end

    if info.workspace ~= workspace then
      if app:isHidden() then
        launch_wezterm()
        schedule_wezterm_workspace_sync(request_id, info.window_id, workspace)
      else
        move_window_to_workspace(info.window_id, workspace)
      end
    elseif app:isFrontmost() and info.layout == "floating" then
      app:hide()
    else
      launch_wezterm()
    end
  end)
end

local open_wezterm = function()
  local request_id = next_wezterm_request_id()

  focused_workspace(function(target_workspace)
    local app = hs.application.get(WEZTERM_BUNDLE_ID)
    if request_id ~= wezterm_request_id then
      return
    end

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

    sync_wezterm_workspace(request_id, app, target_workspace)
  end)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "f", open_wezterm)
