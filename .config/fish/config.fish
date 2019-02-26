# record start time
set -l ctrlc_env_start (date '+%s')

# check if we need to update the cache
set -l ctrlc_platform (uname)
if test "$ctrlc_platform" = "Linux"
	set ctrlc_last_boot (date -d (last reboot | head -n 1 | sed -e 's/ \+/ /g' | cut -d ' ' -f5-8) '+%s')
else if test "$ctrlc_platform" = "Darwin"
	set ctrlc_last_boot (date -d (last reboot | head -n 1 | sed -e 's/ \+/ /g' | cut -d ' ' -f3-6) '+%s')
else
	# force an update every time
	echo "$ctrlc_platform unknown platform"
	set ctrlc_last_boot (date '%+s')
end

if ! set -q ctrlc_env_cache
	set -U ctrlc_env_cache 0
end

if test "$ctrlc_last_boot" -gt "$ctrlc_env_cache"
	set ctrlc_env_update "$ctrlc_last_boot"
	set -U ctrlc_env_cache "$ctrlc_last_boot"
end

# detect preferred editor
if set -q ctrlc_env_update
	set -e EDITOR

	set -l editors vim nano vi
	for editor in $editors
		if which $editor > /dev/null ^&1
			set -U EDITOR $editor
			break
		end
	end
end

# configure git settings
if test ! -f ~/.gitconfig
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "root.ctrlc@gmail.com"
    git config --global push.default simple
    git config --global color.ui auto
end

# detect python tools
if set -q ctrlc_env_update
	set -e ctrlc_python
	set -e ctrlc_pip

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
			set -U ctrlc_python $binaries[1]
			set -U ctrlc_pip $binaries[2]
			break
		end
	end
end

# user binaries
if test -d "$HOME/bin"
    set -x PATH $PATH $HOME/bin
end

# local binaries
if test -d "$HOME/.local/bin"
    set -x PATH $PATH $HOME/.local/bin
end

# virtualfish
if set -q ctrlc_env_update
	set -e ctrlc_enable_virtualfish
	set -e ctrlc_virtualfish_config

	if set -q ctrlc_python ctrlc_pip
	    if eval $ctrlc_pip show virtualfish > /dev/null
		set -U ctrlc_enable_virtualfish "$ctrlc_last_boot"
		set -U ctrlc_virtualfish_config (eval $ctrlc_python -m virtualfish)
	    end
	end
end

if set -q ctrlc_enable_virtualfish
	eval $ctrlc_virtualfish_config
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

# powerline prompt
if set -q ctrlc_env_update
	set -e ctrlc_enable_powerline
	set -e ctrlc_powerline_root 

	if set -q ctrlc_python ctrlc_pip
	    if eval $ctrlc_pip show powerline-status > /dev/null
		set -U ctrlc_enable_powerline "$ctrlc_last_boot"
		set -U ctrlc_powerline_root (eval $ctrlc_pip show powerline-status | awk '$1 == "Location:" { print $2; }')
	    end
	end
end

if set -q ctrlc_enable_powerline
	# start the daemon in the background
	powerline-daemon -q

	# configure the prompt
	set fish_function_path $fish_function_path "$ctrlc_powerline_root/powerline/bindings/fish"
	powerline-setup
end

# record end time and display total load time
set -l ctrlc_env_end (date '+%s')
set -l ctrlc_env_delta (math "$ctrlc_env_end" - "$ctrlc_env_start")
echo "env load time $ctrlc_env_delta seconds"
