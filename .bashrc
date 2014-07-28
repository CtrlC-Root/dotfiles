# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# configure git user name and email
git config --global user.name "Alexandru Barbur"
git config --global user.email "root.ctrlc@gmail.com"

# enable python virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# user binaries
export PATH=$PATH:$HOME/bin
