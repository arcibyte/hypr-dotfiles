# === OH MY ZSH SETUP ===
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

# Plugins
plugins=(
  git
  sudo
  z
  extract
  colored-man-pages
  command-not-found
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  archlinux
  systemd
)

source $ZSH/oh-my-zsh.sh

# === STARSHIP ===
eval "$(starship init zsh)"

# === ENVIRONMENT VARIABLES ===
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='firefox'
export TERM='kitty'
export TERMINAL='kitty'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# === HISTORY ===
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# === COMPLETIONS ===
autoload -U compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# === KEYBINDINGS ===
bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# === ALIASES ===
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -altr'

alias pacman='sudo pacman'
alias pac='sudo pacman -S'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -R'
alias pacs='pacman -Ss'
alias pacq='pacman -Q'

alias y='yay'
alias ys='yay -S'
alias yu='yay -Syu'

alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gs='git status'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'

alias vim='nvim'
alias vi='nvim'

alias icat='kitty +kitten icat'
alias d='kitty +kitten diff'
alias ssh='kitty +kitten ssh'

alias ll='exa -la --icons --git'
alias tree='exa --tree --icons'
alias cat='bat'
alias top='btop'
alias htop='btop'

# === USEFUL FUNCTIONS ===
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# === SPECIFIC CONFIGS ===
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# === INTEGRATIONS ===
if command -v fzf >/dev/null 2>&1; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# === HYPRLAND SPECIFIC ===
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export GDK_BACKEND=wayland,x11
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
fi
