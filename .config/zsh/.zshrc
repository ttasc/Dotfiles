### Enable colors and change prompt
autoload -U colors && colors    # Load colors

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats "(%b)"
precmd() { vcs_info }
setopt prompt_subst

PROMPT='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$fg[cyan]%} ${vcs_info_msg_0_}%{$reset_color%}%b'$'\n''%B$%b '
RPROMPT='%(?..%{$fg[red]%}%?)%{$reset_color%}'

setopt autocd       # Automatically cd into typed directory.
stty stop undef     # Disable ctrl-s to freeze terminal.
setopt interactive_comments

### History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.zsh_history
setopt inc_append_history   # Save command to history before it is executed
setopt hist_ignore_all_dups # don't put duplicate lines in the history.

### Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)       # Include hidden files.

### Ignore upper and lowercase when TAB completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

bindkey '^[[P' delete-char
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M visual '^[[P' vi-delete

### Edit line in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^e' edit-command-line

### source aliases, vimode, fzf, plugins
for s in "$ZDOTDIR"/sources/*.zsh; do source "$s"; done

[ -d "$ZDOTDIR/plugins/zsh-autosuggestions" ] \
    && source "$ZDOTDIR"/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/plugins/zsh-autosuggestions"
[ -d "$ZDOTDIR/plugins/zsh-syntax-highlighting" ] \
    && source "$ZDOTDIR"/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZDOTDIR/plugins/zsh-syntax-highlighting"
