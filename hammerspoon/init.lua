local open_wezterm = function()
  local appName = "WezTerm"
  local app = hs.application.get(appName)

  if app == nil or app:isHidden() or not (app:isFrontmost()) then
    hs.application.launchOrFocus(appName)
  else
    app:hide()
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "f", open_wezterm)
