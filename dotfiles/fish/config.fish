# Portable Fish config managed by backpack.

set -gx EDITOR nvim
set -gx VISUAL nvim

if not set -q BACKPACK_ROOT
    set -l config_file (command realpath (status filename) 2>/dev/null)
    if test -n "$config_file"
        set -gx BACKPACK_ROOT (dirname (dirname (dirname "$config_file")))
    end
end
set -l detected_workspace (command realpath "$HOME/dev" 2>/dev/null)
if test -z "$detected_workspace"; and test -d "$HOME/Dev"
    set detected_workspace (command realpath "$HOME/Dev" 2>/dev/null)
end
if test -n "$detected_workspace"
    set -gx WORKSPACE "$detected_workspace"
else
    set -gx WORKSPACE "$HOME/dev"
end

alias @backpack='cd "$BACKPACK_ROOT" && nvim'
alias @opencodeconfig='cd "$BACKPACK_ROOT/engineering/adapters/opencode" && nvim'
alias @fishconfig='cd "$BACKPACK_ROOT/dotfiles/fish" && nvim'
alias @nvimconfig='cd "$BACKPACK_ROOT/dotfiles/nvim" && nvim'
alias @karabinerconfig='cd "$BACKPACK_ROOT/dotfiles/karabiner" && nvim'

if status is-interactive; and test "$PWD" = "$HOME"; and test -d "$WORKSPACE"
    cd "$WORKSPACE"
end

bind -s ctrl-z 'fg\r'

if type -q starship
    starship init fish | source
end

# Machine/client-specific overrides. This file is intentionally not versioned.
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
