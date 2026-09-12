# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#case $- in
#    *i*) ;;
#      *) return;;
#esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Monokai 256-color palette (bash prompt escaping)
MK_GREEN='\[\e[1;38;5;148m\]'   # #A6E22E
MK_PINK='\[\e[1;38;5;197m\]'    # #F92672
MK_CYAN='\[\e[1;38;5;81m\]'     # #66D9EF
MK_ORANGE='\[\e[1;38;5;208m\]'  # #FD971F
MK_PURPLE='\[\e[1;38;5;141m\]'  # #AE81FF
MK_YELLOW='\[\e[1;38;5;185m\]'  # #E6DB74
MK_RESET='\[\e[0m\]'

_prompt_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    echo " ${branch}"
}

PS1="\${debian_chroot:+(\$debian_chroot)}${MK_PINK}\\u${MK_RESET}@${MK_CYAN}\\h${MK_RESET}:${MK_ORANGE}\\W${MK_RESET}${MK_PURPLE}\$(_prompt_git_branch)${MK_RESET} ${MK_YELLOW}\\\$${MK_RESET} "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export TERM=screen-256color

# Monokai-tinted man pages
export LESS_TERMCAP_mb=$'\e[1;38;5;197m'   # begin blink    — pink
export LESS_TERMCAP_md=$'\e[1;38;5;148m'   # begin bold     — green
export LESS_TERMCAP_me=$'\e[0m'            # reset bold/blink
export LESS_TERMCAP_so=$'\e[1;38;5;185m'   # standout       — yellow
export LESS_TERMCAP_se=$'\e[0m'            # end standout
export LESS_TERMCAP_us=$'\e[1;38;5;81m'    # underline      — cyan
export LESS_TERMCAP_ue=$'\e[0m'            # end underline

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='clear && ls -hal'
alias la='ls -A'
alias l='ls -CF'

alias github="cd $HOME/Documents/github"
alias status="git status"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
export HF_HOME=/data/huggingface
export PATH="$HOME/.local/bin:$PATH"

if [ -f "$HOME/.venv/bin/activate" ]; then
    source "$HOME/.venv/bin/activate"
fi
