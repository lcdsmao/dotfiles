if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env" ]]; then
    . "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env"
elif [[ -f "$HOME/.vite-plus/env" ]]; then
    . "$HOME/.vite-plus/env"
else
    echo "Please install Vite+ by following the instructions at https://viteplus.dev"
fi
