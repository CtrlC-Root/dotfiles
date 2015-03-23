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
if which brew >/dev/null; then
    export ARCHFLAGS="-arch x86_64"
    export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH
fi

# rbenv
if which rbenv >/dev/null; then
    eval "$(rbenv init -)"
fi

# golang
export GOPATH=$HOME/go
if [ -d "${GOPATH}/bin" ]; then
    export PATH=$PATH:$GOPATH/bin
fi

# boot2docker
#if which boot2docker >/dev/null; then
#    if boot2docker status | grep running >/dev/null; then
#        eval "$(boot2docker shellinit)"
#    fi
#fi

# user binaries
export PATH=$PATH:$HOME/bin
