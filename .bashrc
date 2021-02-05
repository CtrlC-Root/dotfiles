# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# detect preferred editor
EDITORS='vim nano vi'
for EDITOR in $EDITORS; do
	if which "${EDITOR}" &>/dev/null; then
		export EDITOR
		break
	fi
done

# configure git settings
if [ ! -f ~/.gitconfig ]; then
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
fi

# user binaries
if [ -d "$HOME/bin" ]; then
    export PATH=$PATH:$HOME/bin
fi

# local binaries
if [ -d "$HOME/.local/bin" ]; then
    export PATH=$PATH:$HOME/.local/bin
fi

# virtualenvwrapper
if [ -x "/usr/bin/virtualenvwrapper.sh" ]; then
    . /usr/bin/virtualenvwrapper.sh
fi

# brew
if which brew &>/dev/null; then
    export ARCHFLAGS="-arch x86_64"
    export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# golang
export GOPATH=$HOME/go
if [ -d "${GOPATH}/bin" ]; then
    export PATH=$PATH:$GOPATH/bin
fi

# gpg
if which gpg &>/dev/null; then
    # https://stackoverflow.com/a/41054093
    export GPG_TTY=$(tty)
fi

# powerline status, but do I want this?
#powerline-daemon -q
#POWERLINE_BASH_CONTINUATION=1
#POWERLINE_BASH_SELECT=1
#source $POWERLINE_STATUS_ROOT/powerline/bindings/bash/powerline.sh
