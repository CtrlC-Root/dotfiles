# .bash_profile

# get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# python virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# user specific environment and startup programs
export PATH=$PATH:$HOME/bin
