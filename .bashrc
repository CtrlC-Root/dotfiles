# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# configure git user name and email
if [ ! -f ~/.gitconfig ]; then
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global color.ui auto
fi

# enable python virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# user binaries
export PATH=$PATH:$HOME/bin
