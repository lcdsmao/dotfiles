local function split_input_args(input)
  local args = {}
  for arg in input:gmatch("[^ ]+") do
    table.insert(args, arg)
  end
  return args
end

local function filter_completion_items(items, arg_lead)
  if arg_lead == "" then
    return items
  end

  local matches = {}
  for _, item in ipairs(items) do
    if item:find(arg_lead, 1, true) == 1 then
      table.insert(matches, item)
    end
  end
  return matches
end

local fd_completion_items = {
  "--hidden",
  "--no-ignore",
  "--follow",
  "--exclude",
  "-E",
  "--type",
  "-t",
  "--extension",
  "-e",
  "--max-depth",
  "--search-path",
}

local rg_completion_items = {
  "--hidden",
  "--no-ignore",
  "--glob",
  "-g",
  "--iglob",
  "--type",
  "-t",
  "--type-not",
  "-T",
  "--max-depth",
  "--smart-case",
  "--ignore-case",
  "--fixed-strings",
  "-F",
}

_G.telescope_prompt_completion = _G.telescope_prompt_completion or {}
_G.telescope_prompt_completion.fd = function(arg_lead)
  return filter_completion_items(fd_completion_items, arg_lead)
end
_G.telescope_prompt_completion.rg = function(arg_lead)
  return filter_completion_items(rg_completion_items, arg_lead)
end

local function remap_picker_with_prompt(prompt_text, completion, apply_input)
  return function(prompt_bufnr)
    local current_text = require("telescope.actions.state").get_current_line()

    vim.ui.input({ prompt = prompt_text, completion = completion }, function(input)
      if input == nil then
        return
      end

      local args = split_input_args(input)
      require("telescope.actions").close(prompt_bufnr)
      apply_input(current_text, args)
    end)
  end
end

local function git_merge_base_files()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")
  local previewers = require("telescope.previewers")
  local putils = require("telescope.previewers.utils")

  -- Detect main branch
  local main_branch = nil
  for _, branch in ipairs({ "main", "master", "trunk", "default" }) do
    vim.fn.system("git rev-parse --verify --quiet " .. branch)
    if vim.v.shell_error == 0 then
      main_branch = branch
      break
    end
  end
  if not main_branch then
    vim.notify("No main branch found", vim.log.levels.ERROR)
    return
  end

  -- Get merge-base between current HEAD and main
  local merge_base = vim.trim(vim.fn.system({ "git", "merge-base", "HEAD", main_branch }))
  if vim.v.shell_error ~= 0 or merge_base == "" then
    vim.notify("Could not determine merge-base with " .. main_branch, vim.log.levels.ERROR)
    return
  end

  local opts = {}
  opts.entry_maker = make_entry.gen_from_file(opts)

  pickers
    .new(opts, {
      prompt_title = "Changed files (vs " .. main_branch .. " merge-base)",
      finder = finders.new_oneshot_job({ "git", "--no-pager", "diff", "--name-only", "--relative", merge_base }, opts),
      sorter = conf.file_sorter(opts),
      previewer = previewers.new_buffer_previewer({
        title = "Diff vs " .. main_branch .. " merge-base",
        get_buffer_by_name = function(_, entry)
          return entry.value
        end,
        define_preview = function(self, entry)
          putils.job_maker({ "git", "--no-pager", "diff", merge_base, "--", entry.value }, self.state.bufnr, {
            value = entry.value,
            bufname = self.state.bufname,
            callback = function(bufnr)
              if vim.api.nvim_buf_is_valid(bufnr) then
                putils.regex_highlighter(bufnr, "diff")
              end
            end,
          })
        end,
      }),
    })
    :find()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      {
        "<leader>ft",
        "<cmd>Telescope<cr>",
        desc = "Telescope",
      },
      {
        "<leader>ff",
        "<cmd>Telescope find_files<cr>",
        desc = "Find files",
      },
      {
        "<leader>fg",
        "<cmd>Telescope git_status<cr>",
        desc = "Show git status",
      },
      {
        "<leader>fG",
        git_merge_base_files,
        desc = "Changed files vs main merge-base",
      },
      {
        "<leader>fr",
        "<cmd>Telescope live_grep<cr>",
        desc = "Live grep",
      },
      {
        "<leader>fs",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "Fuzzy find in current buffer",
      },
      {
        "<leader>fb",
        "<cmd>Telescope buffers<cr>",
        desc = "Find buffers",
      },
      {
        "<leader>fp",
        "<cmd>Telescope resume<cr>",
        desc = "Resume last search",
      },
      {
        "<leader>fo",
        "<cmd>Telescope oldfiles only_cwd=true<cr>",
        desc = "List old files",
      },
      {
        "<leader>fh",
        "<cmd>Telescope help_tags<cr>",
        desc = "Help tags",
      },
    },
    opts = {
      defaults = {
        wrap_results = true,
        layout_strategy = "flex",
        layout_config = {
          flex = {
            flip_columns = 240,
          },
          horizontal = {
            width = 0.9,
            preview_width = 0.6,
          },
          vertical = {
            preview_height = 0.6,
            preview_cutoff = 0,
            mirror = false,
          },
        },
        mappings = {
          i = {
            ["<C-q>"] = require("telescope.actions").smart_send_to_qflist + require("telescope.actions").open_qflist,
            ["<C-n>"] = require("telescope.actions").cycle_history_next,
            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
          },
        },
        path_display = {
          "filename_first",
          shorten = {
            len = 1,
            exclude = { -3, -2, -1, 1 },
          },
        },
      },
      pickers = {
        find_files = {
          mappings = {
            i = {
              ["<C-f>"] = remap_picker_with_prompt(
                "Enter fd parameters (e.g., --hidden -E .git): ",
                "customlist,v:lua.telescope_prompt_completion.fd",
                function(current_text, args)
                  local opts = {
                    default_text = current_text,
                  }

                  if #args > 0 then
                    opts.find_command = { "fd", "--type", "f" }
                    for _, arg in ipairs(args) do
                      table.insert(opts.find_command, arg)
                    end
                  end

                  require("telescope.builtin").find_files(opts)
                end
              ),
            },
          },
        },
        live_grep = {
          mappings = {
            i = {
              ["<C-f>"] = remap_picker_with_prompt(
                "Enter rg parameters (e.g., -t lua, --glob *.rs): ",
                "customlist,v:lua.telescope_prompt_completion.rg",
                function(current_text, args)
                  require("telescope.builtin").live_grep({
                    default_text = current_text,
                    additional_args = function()
                      return args
                    end,
                  })
                end
              ),
            },
          },
        },
      },
      extensions = {
        coc = {
          prefer_locations = true,
          push_cursor_on_edit = true,
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "coc")
      require("telescope").load_extension("fzf")

      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(args)
          -- Enable line numbers
          vim.wo.number = true
          -- Enable line wrapping
          vim.wo.wrap = true
        end,
      })
    end,
  },
}
