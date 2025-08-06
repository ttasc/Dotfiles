#!/bin/sh

# Profile file, runs on login. Environmental variables are set here.

### Path
if [ -d "$HOME/.bin" ]; then
    export PATH="${HOME}/.bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$(find ~/.local/bin -type d | paste -sd ':' -)"
fi

### Default programs:
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="librewolf"

### ~/ Clean-up:
export XDG_CURRENT_DESKTOP="dwm"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export HISTFILE="$XDG_DATA_HOME/history"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"

### Go
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export PATH="$GOPATH/bin:$PATH"
### Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
### Java (java 21 as default)
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

### "bat" as manpager
export MANROFFOPT='-c'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

### Input method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

### Other settings:
export SUDO_ASKPASS="$HOME/.local/bin/voidrice/dmpass"
export QT_QPA_PLATFORMTHEME="gtk2"        # Have QT use gtk2 theme.
export MOZ_USE_XINPUT2=1                  # Mozilla smooth scrolling/touchpads.
export AWT_TOOLKIT="MToolkit wmname LG3D" # May have to install wmname
export _JAVA_AWT_WM_NONREPARENTING=1      # Fix for Java applications in dwm
export LIBVA_DRIVER_NAME="nvidia"         # Configure NVIDIA VA-API

# Start graphical server on user's current tty if not already running.
[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"
