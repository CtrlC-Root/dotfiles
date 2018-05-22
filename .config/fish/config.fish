# configure git settings
if test ! -f ~/.gitconfig
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
end

# detect python tools
set -l python_tools 'python3 pip3' 'python2 pip2' 'python pip'
for tools in $python_tools
	# locate toolset binaries
	set -l binaries
	for binary in (echo $tools | tr ' ' '\n')
		if which $binary > /dev/null ^&1
			set binaries $binaries $binary
		end
	end

	# use this toolset if all binaries are available
	if test (count $binaries) -ge 2
		set ctrlc_python $binaries[1]
		set ctrlc_pip $binaries[2]
		break
	end
end

# virtualfish
if set -q ctrlc_python ctrlc_pip
    if eval $ctrlc_pip list | grep virtualfish > /dev/null
        eval (eval $ctrlc_python -m virtualfish)
    end
end

# brew
if which brew > /dev/null ^&1
    set -x ARCHFLAGS "-arch x86_64"
    set -x PATH (brew --prefix)/bin (brew --prefix)/sbin $PATH
    set -x HOMEBREW_NO_ANALYTICS 1
end

# golang
set -x GOPATH $HOME/go
if test -d "$GOPATH/bin"
    set -x PATH $PATH $GOPATH/bin
end

# user binaries
if test -d "$HOME/bin"
    set -x PATH $PATH $HOME/bin
end

# powerline prompt
if set -q ctrlc_python ctrlc_pip
    if eval $ctrlc_pip list | grep powerline-status > /dev/null
        # start the daemon in the background
        powerline-daemon -q

        # configure the prompt
        set POWERLINE_STATUS_ROOT (eval $ctrlc_pip show powerline-status | awk '$1 == "Location:" { print $2; }')
        set fish_function_path $fish_function_path "$POWERLINE_STATUS_ROOT/powerline/bindings/fish"
        powerline-setup
    end
end
