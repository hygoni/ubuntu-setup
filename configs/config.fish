if status is-interactive
    # Commands to run in interactive sessions can go here
end

function csdef
    set results (cscope -dL -1 $argv[1])
    if test (count $results) -eq 0
        echo "Symbol not found."
        return 1
    end

    set selection (printf '%s\n' $results | fzf --ansi --prompt="Select definition > ")
    if test -z "$selection"
        echo "No selection."
        return 1
    end

    set file (echo $selection | awk '{print $1}')
    set line (echo $selection | awk '{print $3}')

    vim +$line $file
end

function csref
    set results (cscope -dL -3 $argv[1])
    if test (count $results) -eq 0
        echo "No references found."
        return 1
    end

    set selection (printf '%s\n' $results | fzf --ansi --prompt="Select reference > ")
    if test -z "$selection"
        echo "No selection."
        return 1
    end

    set file (echo $selection | awk '{print $1}')
    set line (echo $selection | awk '{print $3}')

    vim +$line $file
end

function grepvim
    if test (count $argv) -eq 0
        echo "Usage: grepvim <pattern>"
        return 1
    end

    set tempfile (mktemp /tmp/grepvim.XXXXXX)

    git grep -n --no-color $argv | sed 's/^/.\//' > $tempfile

    if test (wc -l < $tempfile) -eq 0
        echo "No matches found."
        rm $tempfile
        return 1
    end

    command vim -q $tempfile </dev/tty > /dev/tty
end

