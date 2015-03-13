# aliases
alias tmux "tmux -2"

# configure git settings
if test ! -f ~/.gitconfig
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
end

# automatically locate and use the first git configuration file in the
# directory tree starting from the current working directory
function --on-variable PWD auto_gitconfig
    set -l CHECK $PWD
    while test -n "$CHECK"
        if test -f "$CHECK/.git/config"
            set -g GIT_CONFIG "$CHECK/.git/config"
            return
        end

        if test -f "$CHECK/.gitconfig"
            set -g GIT_CONFIG "$CHECK/.gitconfig"
            return
        end

        set -l CHECK (dirname $CHECK)
        if test $CHECK = "/"
            break
        end
    end

    set -g -e GIT_CONFIG
end

# virtualfish
source $HOME/.config/fish/virtualfish/virtual.fish

# brew
if which brew >/dev/null
    set -x ARCHFLAGS "-arch x86_64"
    set PATH (brew --prefix)/bin (brew --prefix)/sbin $PATH
end

# golang
set GOPATH $HOME/go
if test -d "$GOPATH/bin"
    set PATH $PATH $GOPATH/bin
end

# boot2docker
if which boot2docker >/dev/null
    if boot2docker status | grep running >/dev/null
        boot2docker shellinit | source -
    end
end

# user binaries
set PATH $PATH $HOME/bin

# prompt
function fish_prompt --description 'Write out the prompt'
    # resolve hostname
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
    end

    # resolve normal color
    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    # display virtualenv
    if set -q VIRTUAL_ENV
        echo -n -s (set_color cyan) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
    end

    # display user, hostname, and current directory
    switch $USER
    case root
        if not set -q __fish_prompt_cwd
            if set -q fish_color_cwd_root
                set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
            else
                set -g __fish_prompt_cwd (set_color $fish_color_cwd)
            end
        end

        echo -n -s "$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" '# '

    case '*'
        if not set -q __fish_prompt_cwd
            set -g __fish_prompt_cwd (set_color $fish_color_cwd)
        end

        echo -n -s "$USER" @ "$__fish_prompt_hostname" ' ' "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" '> '

    end
end
