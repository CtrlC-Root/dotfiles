# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# configure git settings
if [ ! -f ~/.gitconfig ]; then
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
fi

# virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# brew
if which brew &>/dev/null; then
    export ARCHFLAGS="-arch x86_64"
    export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH
fi

# golang
export GOPATH=$HOME/go
if [ -d "${GOPATH}/bin" ]; then
    export PATH=$PATH:$GOPATH/bin
fi

# user binaries
if [ -d "$HOME/bin" ]; then
    export PATH=$PATH:$HOME/bin
fi
