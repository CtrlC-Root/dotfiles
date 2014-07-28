# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# python virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# user binaries
export PATH=$PATH:$HOME/bin
