# utilities
function ctrlc_last_boot --description "Detect last boot as unix time"
  switch (uname)
  case "Linux"
    # alpine linux does not have usable utmp or wtmp files
    # https://serverfault.com/a/1050097
    if uname -v | grep 'Alpine' > /dev/null 2>&1
        set uptime_seconds (cat /proc/uptime | cut -d' ' -f1 | cut -d'.' -f1)
        set current_seconds (date '+%s')
        set unix_time (math "$current_seconds - $uptime_seconds")
    else
        set last_boot (last reboot | head -n 1 | sed -e 's/ \+/ /g' | cut -d ' ' -f5-8)
        set unix_time (date -d $last_boot '+%s')
    end

  case "Darwin"
    set last_boot (last reboot | head -n 1 | sed -e 's/  */ /g' | cut -d ' ' -f3-6)
    set unix_time (date -jf '%a %b %d %H:%M:%S' '+%s' $last_boot":00")

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

function ctrlc_remove_all --description "Remove all matching values from a list"
  argparse 'n/variable=' 'v/value=' -- $argv; or return

  while contains $_flag_value $$_flag_variable
    set -l index (contains -i $_flag_value $$_flag_variable)
    set -e "$_flag_variable"["$index"]
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

  set -U -x EDITOR (ctrlc_detect_binaries vim nano vi)
end

function ctrlc_config_brew --description "Homebrew"
  argparse 'f/force' -- $argv; or return

  if not set -q ctrlc_brew_prefix || set -q _flag_force
    ctrlc_require_binaries 'brew'; or return

    set -U ctrlc_brew_prefix (brew --prefix)
    set -U -x ARCHFLAGS "-arch x86_64"
    set -U -x HOMEBREW_NO_ANALYTICS 1
    set -U -x HOMEBREW_NO_AUTO_UPDATE 1
  end

  ctrlc_prepend_unique -n 'PATH' -v "$ctrlc_brew_prefix/bin"
  ctrlc_prepend_unique -n 'PATH' -v "$ctrlc_brew_prefix/sbin"
end

function ctrlc_config_git
  argparse 'f/force' -- $argv; or return

  if not test -d "$HOME/.gitconfig" || set -q _flag_force
    git config --global user.name "Alexandru Barbur"
    git config --global user.email "alex@ctrlc.name"
    git config --global push.default simple
    git config --global pull.rebase false
    git config --global color.ui auto
  end
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
  set -U ctrlc_python $python_tools[1]
  set -U ctrlc_pip $python_tools[2]
end

function ctrlc_config_virtualfish
  argparse 'f/force' -- $argv; or return

  # configure virtualfish
  if not set -q ctrlc_virtualfish || set -q _flag_force
    ctrlc_require_vars 'ctrlc_python' 'ctrlc_pip'; or return

    set -l pip_package ($ctrlc_pip show virtualfish 2> /dev/null); or return
    set -l vf_version (echo $pip_package[2] | string sub -s 10)
    set -l vf_root (echo $pip_package[8] | string sub -s 11)
    set -U ctrlc_virtualfish $vf_version $ctrlc_python $vf_root
  end

  # initialize virtualfish
  set -g VIRTUALFISH_VERSION $ctrlc_virtualfish[1]
  set -g VIRTUALFISH_PYTHON_EXEC (which $ctrlc_virtualfish[2])
  source "$ctrlc_virtualfish[3]/virtualfish/virtual.fish"
  emit virtualfish_did_setup_plugins
end

function ctrlc_config_powerline
  argparse 'f/force' -- $argv; or return

  # configure powerline
  if not set -q ctrlc_powerline_root || set -q _flag_force
    ctrlc_require_vars 'ctrlc_python' 'ctrlc_pip'; or return
    ctrlc_require_binaries 'powerline-daemon'; or return

    # detect package install root
    set -l pip_package ($ctrlc_pip show powerline-status 2> /dev/null); or return
    set -U ctrlc_powerline_root (echo $pip_package[8] | string sub -s 11)
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

function ctrlc_module_enable
  argparse 'm/module=' -- $argv; or return

  if not contains $_flag_module $ctrlc_modules
    printf "module $_flag_module is not valid" >&2
    return 1
  end

  ctrlc_append_unique -n ctrlc_modules_enabled -v $_flag_module
end

function ctrlc_module_disable
  argparse 'm/module=' -- $argv; or return

  if not contains $_flag_module $ctrlc_modules
    printf "module $_flag_module is not valid" >&2
    return 1
  end

  ctrlc_remove_all -n ctrlc_modules_enabled -v $_flag_module
end

function ctrlc_config
  argparse -i 'd/detect' -- $argv; or return

  # corner case: non-interactive shell
  if not status --is-interactive
    ctrlc_config_bin $argv; or return
    return 0
  end

  # determine available and enabled modules
  set -g ctrlc_modules 'bin' 'editor' 'brew' 'git' 'gpg' 'python' 'virtualfish' 'powerline'
  if not set -q ctrlc_modules_enabled || set -q _flag_detect
    set -U ctrlc_modules_enabled $ctrlc_modules
  end

  # record start time
  set start_time (date '+%s')
  printf "ENV:"

  # configure modules
  for module in $ctrlc_modules
    if contains $module $ctrlc_modules_enabled
      printf " +$module"

      set -l module_function "ctrlc_config_$module"

      eval $module_function $argv > /dev/null 2>&1
      or ctrlc_module_disable -m $module && printf (set_color red)"!"(set_color normal)
    else
      printf (set_color brblack)" -$module"(set_color normal)
    end
  end

  # record end time and display total load time in seconds
  set end_time (date '+%s')
  set load_time (math $end_time - $start_time)
  printf " $load_time""s\n"
end

# initialize the shell
if not set -q ctrlc_module_cache
  set -U ctrlc_module_cache 0
end

set -l last_boot (ctrlc_last_boot)
if test $last_boot -gt $ctrlc_module_cache
  printf (set_color green)"FB "(set_color normal)
  ctrlc_config -f && set -U ctrlc_module_cache $last_boot
else
  ctrlc_config
end
