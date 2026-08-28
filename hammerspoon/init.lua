-- Input source switching
local input_source_ids = {
  chinese = "com.apple.inputmethod.SCIM.ITABC",
  japanese = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
  english = "com.apple.keylayout.ABC",
}

local switch_input_source = function(source_id)
  if not hs.keycodes.currentSourceID(source_id) then
    hs.alert.show("Input source unavailable")
  end
end

hs.hotkey.bind({ "ctrl", "shift", "alt" }, "c", function()
  switch_input_source(input_source_ids.chinese)
end)

hs.hotkey.bind({ "ctrl", "shift", "alt" }, "j", function()
  switch_input_source(input_source_ids.japanese)
end)

hs.hotkey.bind({ "ctrl", "shift", "alt" }, "e", function()
  switch_input_source(input_source_ids.english)
end)

-- WezTerm toggle
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

-- Disable the WezTerm hotkey while Ghostty is running
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
