# .bash_profile

# get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# check if the dotfiles are out of date
if [ 0 -ne 0 ]; then
    pushd ~/dotfiles > /dev/null
    DOTFILES_LOCAL=$(git rev-parse master)
    DOTFILES_REMOTE=$(git rev-parse origin/master)
    DOTFILES_BASE=$(git merge-base master origin/master)

    if [ $DOTFILES_LOCAL = $DOTFILES_REMOTE ]; then
        echo "Dotfiles... [ OK ]"
    elif [ $DOTFILES_LOCAL = $DOTFILES_BASE ]; then
        echo "Dotfiles... [PULL]"
    elif [ $DOTFILES_REMOTE = $DOTFILES_BASE ]; then
        echo "Dotfiles... [PUSH]"
    else
        echo "Dotfiles... [DIVERGED]"
    fi

    popd > /dev/null
fi
