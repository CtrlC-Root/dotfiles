# utilities
function ctrlc_last_boot --description "Detect last boot as unix time"
  switch (uname)
  case "Linux"
    set last_boot (last reboot | head -n 1 | sed -e 's/ \+/ /g' | cut -d ' ' -f5-8)
    set unix_time (date -d $last_boot '+%s')

  case "Darwin"
    set last_boot (last reboot | head -n 1 | sed -e 's/  */ /g' | cut -d ' ' -f3-6)
    set unix_time (date -jf '%a %b %d %H:%M' '+%s' $last_boot)

  case "*"
    set unix_time 0
  end

  echo $unix_time
end

function ctrlc_detect_binaries --description "Detect first set of available binaries"
  for binary_group in $argv
    set -l binaries (echo $binary_group | string split " ")
    set -l found

    for binary in $binaries
      if which $binary > /dev/null 2>&1
        set found $found $binary
      end
    end

    if test (count $found) -eq (count $binaries)
      echo $binary_group | string split " "
      return 0
    end
  end

  return 1
end

function ctrlc_require_binaries --description "Ensure binaries are available"
  for binary in $argv
    if not which $binary > /dev/null 2>&1
      printf "binary $binary is not available" >&2
      return 1
    end
  end
end

function ctrlc_require_vars --description "Ensure variables are set"
  for variable in $argv
    if not set -q $variable
      printf "$variable is not set" >&2
      return 1
    end
  end
end

function ctrlc_append_unique --description "Append a value to a list if not present"
  argparse 'n/variable=' 'v/value=' -- $argv; or return

  if not contains $_flag_value $$_flag_variable
    set $_flag_variable $$_flag_variable $_flag_value
  end
end

function ctrlc_prepend_unique --description "Prepend a value to a list if not present"
  argparse 'n/variable=' 'v/value=' -- $argv; or return

  if not contains $_flag_value $$_flag_variable
    set $_flag_variable $_flag_value $$_flag_variable
  end
end

# environment configuration
function ctrlc_config_bin
  argparse 'f/force' -- $argv; or return

  set -l bin_paths "$HOME/bin" "$HOME/.local/bin"
  for bin_path in $bin_paths
    if test -d $bin_path
      ctrlc_append_unique -n 'PATH' -v $bin_path
    end
  end
end

function ctrlc_config_editor
  argparse 'f/force' -- $argv; or return

  if set -q EDITOR && not set -q _flag_force
    return 0
  end

  set -g -x EDITOR (ctrlc_detect_binaries vim nano vi)
end

function ctrlc_config_brew --description "Homebrew"
  argparse 'f/force' -- $argv; or return

  if not set -q ctrlc_brew_prefix || set -q _flag_force
    ctrlc_require_binaries 'brew'; or return

    set -g ctrlc_brew_prefix (brew --prefix)
  end

  set -g -x ARCHFLAGS "-arch x86_64"
  set -g -x HOMEBREW_NO_ANALYTICS 1
  ctrlc_prepend_unique -n 'PATH' -v "$ctrlc_brew_prefix/bin"
  ctrlc_prepend_unique -n 'PATH' -v "$ctrlc_brew_prefix/sbin"
end

function ctrlc_config_git
  argparse 'f/force' -- $argv; or return

  # TODO: test on ~/.gitconfig or individual settings?
  git config --global user.name "Alexandru Barbur"
  git config --global user.email "alex@ctrlc.name"
  git config --global push.default simple
  git config --global color.ui auto
end

function ctrlc_config_gpg
  argparse 'f/force' -- $argv; or return

  # https://stackoverflow.com/a/41054093
  set -g -x GPG_TTY (tty)
end

function ctrlc_config_python
  argparse 'f/force' -- $argv; or return

  if set -q ctrlc_python && set -q ctrlc_pip && not set -q _flag_force
    return 0
  end

  set -l python_tools (ctrlc_detect_binaries 'python3 pip3' 'python pip'); or return
  set -g ctrlc_python $python_tools[1]
  set -g ctrlc_pip $python_tools[2]
end

function ctrlc_config_virtualfish
  argparse 'f/force' -- $argv; or return

  # configure virtualfish
  if not set -q ctrlc_virtualfish_config || set -q _flag_force
    ctrlc_require_vars 'ctrlc_python' 'ctrlc_pip'; or return

    set -l pip_package ($ctrlc_pip show virtualfish); or return
    set -g ctrlc_virtualfish_config ($ctrlc_python -m virtualfish)
  end

  # initialize virtualfish
  eval $ctrlc_virtualfish_config
end

function ctrlc_config_powerline
  argparse 'f/force' -- $argv; or return

  # configure powerline
  if not set -q ctrlc_powerline_root || set -q _flag_force
    ctrlc_require_vars 'ctrlc_python' 'ctrlc_pip'; or return
    ctrlc_require_binaries 'powerline-daemon'; or return

    # detect package install root
    set -l pip_package ($ctrlc_pip show powerline-status); or return
    set -g ctrlc_powerline_root (echo $pip_package[8] | string sub -s 11)
  end

  # start the powerline daemon
  if not pgrep -f powerline-daemon > /dev/null
    powerline-daemon -q
  end

  # initialize powerline
  set -l powerline_bindings "$ctrlc_powerline_root/powerline/bindings/fish"
  ctrlc_append_unique -n 'fish_function_path' -v $powerline_bindings
  powerline-setup
end

function ctrlc_config
  # corner case: non-interactive shell
  if not status --is-interactive
    ctrlc_config_bin $argv; or return
    return 0
  end

  # determine available and enabled modules
  set -g ctrlc_modules 'bin' 'editor' 'gpg' 'brew' 'python' 'virtualfish' 'powerline'
  if not set -q ctrlc_modules_enabled
    set -g ctrlc_modules_enabled $ctrlc_modules
  end

  # record start time
  set start_time (date '+%s')
  printf "ENV:"

  # configure modules
  for module in $ctrlc_modules
    if contains $module $ctrlc_modules_enabled
      printf " +$module"

      set -l module_function "ctrlc_config_$module"
      eval $module_function $argv; or return
    else
      printf " -$module"
    end
  end

  # record end time and display total load time in seconds
  set end_time (date '+%s')
  set load_time (math $end_time - $start_time)
  printf " $load_time""s\n"
end

# initialize the shell
ctrlc_config
