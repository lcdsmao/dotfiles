# AGENTS.md - Developer Guidelines for Dotfiles Repository

This document provides conventions and commands for AI coding agents working in this personal dotfiles repository.

## Repository Overview

This is a cross-platform dotfiles repository that manages development environment configuration using [dotbot](https://github.com/anishathalye/dotbot). It includes configurations for:
- Shell (Zsh with Oh-My-Zsh and Antigen)
- Editors (Neovim with lazy.nvim, Vim, IntelliJ IDEA with IdeaVim)
- Terminal multiplexer (tmux)
- Development tools (Android, iOS, Python, Flutter, Kotlin, Java)
- AI CLI integrations (OpenCode, Copilot, Claude, etc.)

## Build, Test, and Lint Commands

### Installation and Setup

```bash
./install                      # Bootstrap entire dotfiles setup (uses dotbot)
brew bundle                    # Install/update Homebrew packages from Brewfile
```

### Linting

```bash
shellcheck scripts/*.sh        # Lint shell scripts for common errors
shellcheck scripts/**/*.sh     # Lint all nested shell scripts
shfmt -d .                     # Check shell script formatting (2-space indent)
shfmt -w scripts/              # Auto-format shell scripts
```

### Testing

This repository has no application tests (dotfiles don't require testing). The dotbot submodule contains Python tests, but they're not run during normal usage.

## Code Style Guidelines

### General Principles

- **Indentation**: 2 spaces for ALL languages (Bash, Zsh, Lua, Vim, YAML)
- **Line endings**: LF (Unix-style)
- **Trailing whitespace**: Remove it
- **Final newline**: Always include
- **Encoding**: UTF-8
- **Simplicity**: Prioritize readable, maintainable code over clever one-liners

### Shell Scripts (.sh, .bash)

**File headers:**
```bash
#!/usr/bin/env bash
```

**Style:**
- Use `#!/usr/bin/env bash` for portability (preferred) or `#!/bin/bash`
- 2-space indentation (NOT tabs)
- UPPERCASE for constants/environment variables: `CACHE_DIR`, `SCRIPT_DIR`
- lowercase for local variables: `cli`, `resume`
- Always quote variables: `"$VAR"` not `$VAR`
- Use `${VAR}` for clarity when adjacent to other text
- Default values: `${VAR:-default}`
- Use `set -e` at script start for strict error handling when appropriate

**Functions:**
```bash
function_name() {
  local var="value"
  echo "Descriptive output"
}
```

**Conditionals:**
```bash
if [ -f "$FILE" ]; then
  echo "File exists"
fi

if command -v "$tool" >/dev/null 2>&1; then
  echo "$tool is installed"
fi
```

**Arrays:**
```bash
ALL_ITEMS=("item1" "item2" "item3")
for item in "${ALL_ITEMS[@]}"; do
  echo "$item"
done
```

### Zsh Plugins (.zsh)

**No shebang** - these files are sourced, not executed.

**Style:**
- 2-space indentation
- Use `function name() { }` syntax
- Environment variables: `export VAR="value"`
- Aliases: `alias short='long command'`
- Check command existence: `type command &> /dev/null`

**Example:**
```zsh
# FZF Configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

function fp() {
  local file=$(fzf --preview 'bat --color=always {}')
  [ -n "$file" ] && nvim "$file"
}

alias f='fzf'
```

### Lua (Neovim Configuration)

**Style:**
- 2-space indentation
- Use `local` for all variables unless global is required
- Module pattern: return table of configuration
- Comments: `--` for single-line, no multi-line comments needed

**Plugin specifications (lazy.nvim):**
```lua
return {
  {
    "plugin/name",
    dependencies = { "dependency/name" },
    keys = {
      { "<leader>key", "<cmd>Command<cr>", desc = "Description" },
    },
    opts = {
      setting = true,
    },
    config = function()
      -- Setup code here
    end,
  },
}
```

**Options:**
```lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
```

### Vim Script (.vim, .vimrc)

**Style:**
- 2-space indentation
- Comments: `"` for comments
- Leader key: Space (`let mapleader = " "`)
- Use `noremap` for non-recursive mappings

```vim
" Comment describing section
let mapleader = " "

set number
set clipboard+=unnamed

noremap <leader>w :w<cr>
noremap <leader>q :q<cr>
```

### YAML Configuration

**Style:**
- 2-space indentation
- Use `-` for lists
- Quotes for strings with special characters
- Comments: `#`

```yaml
- defaults:
    link:
      relink: true

- link:
    ~/.vimrc: vimrc
    ~/.zshrc: zshrc
```

## Naming Conventions

### Files and Directories

- **Shell scripts**: `kebab-case.sh` (e.g., `tmux-ai-cli.sh`)
- **Zsh plugins**: `lowercase.zsh` (e.g., `fzf.zsh`, `android.zsh`)
- **Lua modules**: `lowercase.lua` (e.g., `options.lua`, `keymaps.lua`)
- **Config files**: Match application name (e.g., `vimrc`, `zshrc`, `tmux.conf`)

### Variables

- **Shell constants**: `UPPER_SNAKE_CASE` (e.g., `CACHE_DIR`, `ALL_CLIS`)
- **Shell variables**: `lower_snake_case` (e.g., `ai_cli`, `temp_file`)
- **Lua variables**: `snake_case` (e.g., `local opt`, `user_config`)
- **Functions**: `snake_case` (e.g., `adb_select_device`, `mac_requirement`)

## Error Handling

### Shell Scripts

**Check command existence:**
```bash
if ! command -v tool >/dev/null 2>&1; then
  echo "Error: tool is not installed"
  exit 1
fi
```

**Check file existence:**
```bash
if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE"
  exit 1
fi
```

**Fail fast with set -e:**
```bash
#!/usr/bin/env bash
set -e  # Exit on any error
```

**Fallback to shell:**
```bash
if [ -n "$CLI" ]; then
  exec "$CLI"
else
  exec "$SHELL"  # Always quote $SHELL
fi
```

## Git Workflow

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type: short description

Longer explanation if needed (optional)
```

**Types:**
- `feat:` - New feature or capability
- `fix:` - Bug fix
- `refactor:` - Code restructuring without behavior change
- `chore:` - Maintenance tasks, dependency updates
- `docs:` - Documentation changes
- `style:` - Code style/formatting changes (not CSS)
- `perf:` - Performance improvements

**Examples:**
```
feat: add opencode to AI CLI selector
fix: quote path variables to handle spaces
refactor: extract tmux AI CLI selector into separate file
chore: update brew dependencies
```

### Branch Strategy

- `master` - Main branch (stable)
- No formal branch naming convention (personal repo)

### Before Committing

1. Test the changes manually (no automated tests)
2. Run shellcheck if modifying shell scripts: `shellcheck scripts/*.sh`
3. Verify commit message follows conventional format
4. Keep commits focused and atomic

## Common Patterns

### XDG Base Directory Specification

Use standard cache/config directories:
```bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
```

### Script Directory Detection

For scripts that reference other files:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/other-script.sh"
```

### FZF Integration

Preview files with bat:
```bash
fzf --preview 'bat --color=always {}'
```

### Tmux Integration

Create panes with specific commands:
```bash
tmux split-window -h -l 50% -c "$CURRENT_PATH" "command"
```

## Important Notes

- **Modular Zsh**: All `.zsh` files in `zshplugins/` are auto-sourced
- **Lazy.nvim**: Neovim plugins use lazy loading via `keys`, `ft`, `cmd`, `event`
- **Homebrew**: Add new tools to `Brewfile`, not manual install scripts
- **Symlinks**: Use `install.conf.yaml` for dotfile linking, not manual ln
- **Path quoting**: Always quote paths to handle spaces: `"$SCRIPT_DIR/file.sh"`
- **Portable shebangs**: Use `#!/usr/bin/env bash` not `#!/bin/bash`

## Resources

- [Dotbot Documentation](https://github.com/anishathalye/dotbot)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis tool
