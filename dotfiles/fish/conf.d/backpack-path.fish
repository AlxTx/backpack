# Make Backpack available after a Shell or Everything installation.
if test -d "$HOME/.local/bin"; and not contains -- "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end
