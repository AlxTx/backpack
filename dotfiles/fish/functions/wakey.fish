function wakey
    set -l root "$BACKPACK_ROOT"
    if test -z "$root"
        set root "$HOME/perso/backpack"
    end

    "$root/tools/wakey/wakey" $argv
end
