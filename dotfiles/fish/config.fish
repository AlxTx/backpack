# Portable Fish config managed by backpack.

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx BACKPACK_ROOT "$HOME/perso/backpack"
set -gx WORKSPACE "$HOME/Dev"

alias @backpack='cd "$BACKPACK_ROOT" && nvim'
alias @opencodeconfig='cd "$BACKPACK_ROOT/cockpit/opencode" && nvim'
alias @fishconfig='cd "$BACKPACK_ROOT/dotfiles/fish" && nvim'
alias @nvimconfig='cd "$BACKPACK_ROOT/dotfiles/nvim" && nvim'
alias @karabinerconfig='cd "$BACKPACK_ROOT/dotfiles/karabiner" && nvim'

if status is-interactive; and test -d "$WORKSPACE"
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
