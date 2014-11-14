# aliases
alias tmux "tmux -2"

# configure git settings
if test ! -f ~/.gitconfig
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
end

# golang
set GOPATH $HOME/go
if test -d "$GOPATH/bin"
    set PATH $PATH $GOPATH/bin
end

# user binaries
set PATH $PATH $HOME/bin
