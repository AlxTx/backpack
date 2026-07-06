function wakey
    set -l root "$BACKPACK_ROOT"
    if test -z "$root"
        printf 'BACKPACK_ROOT is not set\n' >&2
        return 1
    end

    "$root/tools/wakey/wakey" $argv
end
