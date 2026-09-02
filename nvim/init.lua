-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")

-- Setup lazy.nvim
require("config.lazy")

-- Load miscellaneous configurations
require("config.cheatsheet")

-- A workaround for a redraw issue when using lazy.nvim with herdr
local function sync_herdr_columns()
  local pane_id = vim.env.HERDR_PANE_ID
  if not pane_id then
    return
  end

  vim.system({ "herdr", "pane", "layout", "--current" }, { text = true }, function(result)
    if result.code ~= 0 then
      return
    end

    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok then
      return
    end

    local layout = data.result and data.result.layout

    if not layout then
      return
    end

    for _, pane in ipairs(layout.panes or {}) do
      if pane.pane_id == pane_id then
        local pane_width = pane.rect.width
        local layout_width = layout.area.width

        -- No split: Herdr reports the correct terminal width.
        if pane_width >= layout_width then
          return
        end

        -- Split pane: account for Herdr's border columns.
        local columns = pane_width - 2

        vim.schedule(function()
          vim.o.columns = columns
          vim.fn.system("kill -WINCH " .. vim.fn.getpid())
        end)

        return
      end
    end
  end)
end

if vim.env.HERDR_PANE_ID then
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.defer_fn(sync_herdr_columns, 500)
    end,
  })
end
