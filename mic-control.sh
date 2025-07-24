#!/usr/bin/env bash

onColor="%{F#78a090}" # #78a090 Green
offColor="%{F#D08770}" # #D08770 Red

default_mic=$(pactl get-default-source)
mic_muted=$(pactl get-source-mute "$default_mic" | awk '{print $2}')

if [ $# -eq 0 ]; then
  icon=""
  if [ "$mic_muted" = "yes" ]; then
    icon=" "
  fi

  if ps ocommand ${PPID} | grep waybar 2>&1 >/dev/null; then
    class="unmuted"
    if [ "$mic_muted" = "yes" ]; then
      class="muted"
    fi
    cat <<EOC
    { "text": "$icon", "tooltip": "toggle mute", "class": "$class" }
EOC
  else # Probably polybar
    color="${onColor}${icon}"
    echo "$color"
  fi
fi

if [ "$1" = "toggle" ]; then
  mute=0
  if [ "$mic_muted" = "no" ]; then
    mute=1
    aplay ~/.config/polybar/mic-effects-down.wav &
  else
    aplay ~/.config/polybar/mic-effects-up.wav &
  fi
  pactl set-source-mute "$default_mic" "$mute"
fi
