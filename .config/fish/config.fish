# aliases
alias tmux "tmux -2"

# configure git settings
if test ! -f ~/.gitconfig
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
end

# virtualfish
if which pip > /dev/null ^&1
    if pip list | grep virtualfish > /dev/null
        eval (python -m virtualfish)
    end
end

# brew
if which brew > /dev/null ^&1
    set -x ARCHFLAGS "-arch x86_64"
    set -x PATH (brew --prefix)/bin (brew --prefix)/sbin $PATH
end

# golang
set -x GOPATH $HOME/go
if test -d "$GOPATH/bin"
    set -x PATH $PATH $GOPATH/bin
end

# user binaries
if test -d "$HOME/bin"
    set -x PATH $PATH $HOME/bin
end

# powerline prompt
if which pip > /dev/null ^&1
    if pip list | grep powerline-status > /dev/null
        # start the daemon in the background
        powerline-daemon -q

        # configure the prompt
        set POWERLINE_STATUS_ROOT (pip show powerline-status | awk '$1 == "Location:" { print $2; }')
        set fish_function_path $fish_function_path "$POWERLINE_STATUS_ROOT/powerline/bindings/fish"
        powerline-setup
    end
end
