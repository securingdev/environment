# Monokai 256-color palette (zsh prompt escaping)
MK_GREEN=$'%{\e[1;38;5;148m%}'   # #A6E22E
MK_PINK=$'%{\e[1;38;5;197m%}'    # #F92672
MK_CYAN=$'%{\e[1;38;5;81m%}'     # #66D9EF
MK_ORANGE=$'%{\e[1;38;5;208m%}'  # #FD971F
MK_PURPLE=$'%{\e[1;38;5;141m%}'  # #AE81FF
MK_YELLOW=$'%{\e[1;38;5;185m%}'  # #E6DB74
MK_RESET=$'%{\e[0m%}'

_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    echo " ${branch}"
}

setopt PROMPT_SUBST
PROMPT="${MK_PINK}%n${MK_RESET}@${MK_CYAN}%m${MK_RESET}:${MK_ORANGE}%1~${MK_RESET}${MK_PURPLE}\$(_git_branch)${MK_RESET} ${MK_YELLOW}%#${MK_RESET} "

export TERM=screen-256color
export PATH=/usr/local/go/bin/go:/opt/homebrew/opt/ruby@3.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.gem/ruby/3.0.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/opt/homebrew/opt/ruby@3.0/bin:
alias github="cd $HOME/Documents/github"
alias status="git status"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Monokai-tinted man pages
export LESS_TERMCAP_mb=$'\e[1;38;5;197m'   # begin blink    — pink
export LESS_TERMCAP_md=$'\e[1;38;5;148m'   # begin bold     — green
export LESS_TERMCAP_me=$'\e[0m'            # reset bold/blink
export LESS_TERMCAP_so=$'\e[1;38;5;185m'   # standout       — yellow
export LESS_TERMCAP_se=$'\e[0m'            # end standout
export LESS_TERMCAP_us=$'\e[1;38;5;81m'    # underline      — cyan
export LESS_TERMCAP_ue=$'\e[0m'            # end underline

# Colorized ls and grep (macOS-compatible)
alias ls="ls -G"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias ll="clear && ls -Ghal"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init - --no-rehash zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

pip() {
    uv pip "$@"
}
