local open_wezterm = function()
  local appName = "WezTerm"
  local app = hs.application.get(appName)

  if app == nil or app:isHidden() or not (app:isFrontmost()) then
    hs.application.launchOrFocus(appName)
  else
    app:hide()
  end
end

local wezterm_hotkey = hs.hotkey.new({ "cmd", "alt", "ctrl", "shift" }, "f", open_wezterm)

local sync_wezterm_hotkey = function()
  if hs.application.get("Ghostty") ~= nil then
    wezterm_hotkey:disable()
  else
    wezterm_hotkey:enable()
  end
end

hs.application.watcher.new(function(app_name, event_type, _)
  if app_name == "Ghostty" then
    sync_wezterm_hotkey()
  end
end):start()

sync_wezterm_hotkey()
