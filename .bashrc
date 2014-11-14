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

# python virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# golang
export GOPATH=$HOME/go
if [ -d "${GOPATH}/bin" ]; then
    export PATH=$PATH:$GOPATH/bin
fi

# user binaries
export PATH=$PATH:$HOME/bin
