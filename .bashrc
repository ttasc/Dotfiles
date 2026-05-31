# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

shopt -s histappend # append to the history file, don't overwrite it
HISTCONTROL=ignoredups # don't put duplicate lines in the history.
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # make less more friendly for non-text input files, see lesspipe(1)

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then debian_chroot=$(cat /etc/debian_chroot); fi # set variable identifying the chroot you work in (used in the prompt below)

case "$TERM" in
    xterm-color|*-256color) PS1='${debian_chroot:+($debian_chroot)}\[\033[1m\]\[\033[31m\][\[\033[33m\]\u\[\033[32m\]@\[\033[36m\]\h \[\033[35m\]\w\[\033[31m\]]\[\033[33m\]$?\[\033[37m\]\n\$\[\033[m\] ' ;;
    *) PS1='${debian_chroot:+($debian_chroot)}[\u@\h \w]$?$ ' ;;
esac
# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*) PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1" ;;
esac

set -o vi                           # Enable Vi mode
bind 'TAB:menu-complete'            # Enable Tab completion
bind 'set show-all-if-ambiguous on' # Tab to move through options

eval "$(dircolors -b)" # Enable ls color
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -lA'
alias  l='ls -CF'

### Colorize commands when possible
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias diff="diff --color=auto"
alias ip="ip -color=auto"

### Confirm before overwriting something
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -vI'

### Verbose
alias mkdir="mkdir -pv"
alias rmdir="rmdir -v"

### Get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

### Nvim
alias vi="nvim"
alias suvi="sudoedit"

### Git
alias gst="git status"
alias gaa="git add ."
alias gco="git commit -m"
alias push="git push"
alias pull="git pull"
alias clone="git clone"

### Drives handle
alias lsblk="lsblk -po 'uuid,name,type,size,label,mountpoint,fstype'"
alias mount='sudo mount -o uid="$(id -u)",gid="$(id -g)"'
alias umount="sudo umount -l"
eject() {
    echo 1 | sudo tee /sys/block/"$1"/device/delete >/dev/null
}

up() {
    local d=""
    local limit="$1"

    # Default to limit of 1
    if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
        limit=1
    fi

    for ((i=1;i<=limit;i++)); do
        d="../$d"
    done

    # perform cd. Show error if cd fails
    if ! cd "$d"; then
        echo "Couldn't go up $limit dirs.";
    fi
}
