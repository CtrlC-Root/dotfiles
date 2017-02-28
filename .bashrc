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

# gpg agent
if which gpg-agent &>/dev/null; then
    if [ -z "${GPG_AGENT_INFO+x}" ]; then
        eval (gpg-agent --daemon)
    fi
fi

# powerline status, but do I want this?
#powerline-daemon -q
#POWERLINE_BASH_CONTINUATION=1
#POWERLINE_BASH_SELECT=1
#source $POWERLINE_STATUS_ROOT/powerline/bindings/bash/powerline.sh
