PS1="\$ "
export TERM=screen-256color
export PATH=/usr/local/go/bin/go:/opt/homebrew/opt/ruby@3.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/keith/.gem/ruby/3.0.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/opt/homebrew/opt/ruby@3.0/bin:
alias github="cd /Users/keith/Documents/github"
alias status="git status"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init - --no-rehash zsh)"

# bun completions
[ -s "/Users/keith/.bun/_bun" ] && source "/Users/keith/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

pip() {
    uv pip "$@"
}
