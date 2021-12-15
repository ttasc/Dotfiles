#!/usr/bin/env bash

# Description: Dmenu script to record video,audio,webcam.
# Dependencies: dmenu, ffmpeg, pulseaudio, alsa, slop (for recording a specific area)

# Usage:
# `$0`: Ask for recording type via dmenu
# `$0 screencast`: Record both audio and screen
# `$0 video`: Record only screen
# `$0 audio`: Record only audio
# `$0 kill`: Kill existing recording
#
# If there is already a running instance, user will be prompted to end it.

killrecording() {
    recpid="$(cat /tmp/recordingpid)"
    # kill with SIGTERM, allowing finishing touches.
    kill -15 "$recpid"
    rm -f /tmp/recordingpid
    # even after SIGTERM, ffmpeg may still run, so SIGKILL it.
    sleep 3
    kill -9 "$recpid"
    exit
}

screencast() {
    ffmpeg -y \
    -f x11grab \
    -framerate 60 \
    -s "$(xdpyinfo | awk '/dimensions/ {print $2;}')" \
    -i "$DISPLAY" \
    -f alsa -i default \
    -r 30 \
    -c:v h264 -crf 0 -preset ultrafast -c:a aac \
    "$HOME/screencast-$(date '+%y%m%d-%H%M-%S').mp4" &
    echo $! > /tmp/recordingpid
}

video() {
    ffmpeg \
    -f x11grab \
    -s "$(xdpyinfo | awk '/dimensions/ {print $2;}')" \
    -i "$DISPLAY" \
    -c:v libx264 -qp 0 -r 30 \
    "$HOME/video-$(date '+%y%m%d-%H%M-%S').mkv" &
    echo $! > /tmp/recordingpid
}

webcamhidef() {
    [[ ! $(ls /dev | grep "video0") ]] && notify-send "Record" "Webcam not found." && exit 1
    ffmpeg \
    -f v4l2 \
    -i /dev/video0 \
    -video_size 1920x1080 \
    "$HOME/webcam-$(date '+%y%m%d-%H%M-%S').mkv" &
    echo $! > /tmp/recordingpid
}

webcam() {
    [[ ! $(ls /dev | grep "video0") ]] && notify-send "Record" "Webcam not found." && exit 1
    ffmpeg \
    -f v4l2 \
    -i /dev/video0 \
    -video_size 640x480 \
    "$HOME/webcam-$(date '+%y%m%d-%H%M-%S').mkv" &
    echo $! > /tmp/recordingpid
}


audio() {
    ffmpeg \
    -f alsa -i default \
    -c:a flac \
    "$HOME/audio-$(date '+%y%m%d-%H%M-%S').flac" &
    echo $! > /tmp/recordingpid
}

askrecording() {
    choice=$(printf "screencast\\nvideo\\nvideo selected\\naudio\\nwebcam\\nwebcam (hi-def)" | dmenu -i -p "Select recording style:")
    case "$choice" in
        screencast) screencast;;
        audio) audio;;
        video) video;;
        *selected) videoselected;;
        webcam) webcam;;
        "webcam (hi-def)") webcamhidef;;
    esac
}

asktoend() {
    response=$(printf "No\\nYes" | dmenu -i -p "Recording still active. End recording?") &&
    [ "$response" = "Yes" ] &&  killrecording
}

videoselected() {
    slop -f "%x %y %w %h" > /tmp/slop
    read -r X Y W H < /tmp/slop
    rm /tmp/slop
    if [[ -z "$X" ]] || [[ -z "$Y" ]] || [[ -z "$W" ]] || [[ -z "$H" ]]; then
        exit 1
    fi
    
    ffmpeg \
    -f x11grab \
    -framerate 60 \
    -video_size "$W"x"$H" \
    -i :0.0+"$X,$Y" \
    -c:v libx264 -qp 0 -r 30 \
    "$HOME/box-$(date '+%y%m%d-%H%M-%S').mkv" &
    echo $! > /tmp/recordingpid
}

case "$1" in
    screencast) screencast;;
    audio) audio;;
    video) video;;
    *selected) videoselected;;
    kill) killrecording;;
    *) ([ -f /tmp/recordingpid ] && asktoend && exit) || askrecording;;
esac
