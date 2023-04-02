if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Setting PATH for Python 3.9
# The original version is saved in /Users/zyz/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.9/bin" "$PATH"

# Setting PATH for Python 3.9
# The original version is saved in /Users/zyz/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.9/bin" "$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/zyz/opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<
