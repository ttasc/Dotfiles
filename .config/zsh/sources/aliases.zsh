### Workflow config
alias reconfig='pwd=$PWD; cd $HOME/GitRepos/ttasc/Dotfiles && stow --no-folding -v -R -t ~ .; cd $pwd'
alias slmake='sudo make install;make clean;git clean -fd'
slpush(){ git push https://github.com/ttasc/$1 my$1:master; }

### Nvidia Optimus (Envycontrol)
alias ncard="sudo envycontrol -s nvidia"
alias icard="sudo envycontrol -s integrated"
alias hcard="sudo envycontrol -s hybrid"
alias qcard="envycontrol --query"

### Git
alias gst="git status"
alias gaa="git add ."
alias gco="git commit -m"
alias push="git push"
alias pull="git pull"
alias clone="git clone"
retag() {
    git tag -d "$1"               && \
    git push --delete origin "$1" && \
    git tag "$1"                  && \
    git push origin "$1"
}

### ls
alias ls="ls -h --color=always"
alias ll="ls -l --group-directories-first"
alias la="ls -al --group-directories-first"
alias lt="ls -alt"
alias lS="ls -alS"

### Navigation
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

### Confirm before overwriting something
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -vI"

### Verbose
alias mkdir="mkdir -pv"
alias rmdir="rmdir -v"

### Get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

### CPU/GPU frequency monitoring
alias cpufreq='watch grep \"cpu MHz\" /proc/cpuinfo'
alias gpufreq="watch -n0.1 nvidia-smi"

### Colorize commands when possible
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias diff="diff --color=auto"
alias ip="ip -color=auto"

### Nvim
alias vi="nvim"
alias suvi="sudoedit"

### Feh
alias feh="feh --scale-down --auto-zoom"

### Convert to PDF
alias doctopdf="libreoffice --headless --convert-to pdf:writer_pdf_Export"

### Translate by translate-shell
alias vtrans="trans -shell -brief :vi"
alias etrans="trans -shell -brief :en"
alias tovi="trans -brief :vi"
alias toen="trans -brief :en"

### Funny
alias parrot="curl parrot.live"
alias weather="curl wttr.in"

### Pacman + fzf
alias checkup="checkup; pkill -36 dwmbar"
alias pacQi="pacman -Qq | fzf --preview 'pacman -Qil {}' --preview-window nohidden --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
alias pacSi="pacman -Slq | fzf --preview 'pacman -Si {}' --preview-window nohidden --layout=reverse"
alias pacS="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' --preview-window nohidden | xargs -ro sudo pacman -S"
alias pacR="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' --preview-window nohidden | xargs -ro sudo pacman -Rns"
alias pacRu="pacman -Qtdq | sudo pacman -Rns -"
paclsdeps() {
    LC_ALL=C pacman -Qi "$1" | awk -F'[:<=>]' '/^Depends/ {print $2}' | xargs -n1 | sort -u
}
paclsfiles() {
    pacman -Qlq "$1" | grep -v '/$' | xargs -r du -h | sort -h
}

### Drives handle
alias lsblk="lsblk -po 'uuid,name,type,size,label,mountpoint,fstype'"
alias mount='sudo mount -o uid="$(id -u)",gid="$(id -g)"'
alias umount="sudo umount -l"
eject() {
    echo 1 | sudo tee /sys/block/"$1"/device/delete >/dev/null
}

### Phones handle
alias lsphone="simple-mtpfs -l"
alias mphone="simple-mtpfs -o allow_other --device"
alias uphone="fusermount -u"
