#!/bin/bash

onColor="%{F#78a090}" # Orange
offColor="%{F#D08770}" # Orange

awk_program='\
BEGIN {default_found=0;}

/^[\t ]*\*/ {default_found=1;}

/^[\t ]*name:/ {
    if (default_found) {
        name=$2;
        gsub("[<>]", "", name);
    }
}

/^[\t ]*muted:/ {
    if (default_found) {
        if ($2=="yes") {
            mute=0;
            icon="microphone-sensitivity-medium";
            status="muted"
        } else {
            mute=1;
            icon="microphone-sensitivity-muted";
            status="unmuted"
        }
        system("echo " status ":" name)
        exit;
    }
}

/^[\t ]*index:/{if (default_found) exit;}'

mic_info=$(pacmd list-sources | awk "$awk_program")

if [ $# -eq 0 ]; then
  # current_default=$(pactl info | grep -i "default source" | cut -f2 -d':' | tr -d ' ')
  # echo "Default: $current_default"
  status=$(echo "$mic_info" | cut -d':' -f1)
  color="$onColor"
  if [ "$status" = "muted" ]; then
    color="$offColor"
  fi
  echo "$color"
fi

if [ "$1" = "toggle" ]; then
  status=$(echo "$mic_info" | cut -d':' -f1)
  source=$(echo "$mic_info" | cut -d':' -f2)
  mute=0
  if [ "$status" = "unmuted" ]; then
    mute=1
    aplay ~/.config/polybar/mic-effects-down.wav &
  else
    aplay ~/.config/polybar/mic-effects-up.wav &
  fi
  pacmd set-source-mute "$source" "$mute"
fi
