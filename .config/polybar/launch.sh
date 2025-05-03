#!/bin/sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar using config from dotfiles
polybar -c ~/dotfiles/.config/polybar/config.ini top &

echo "Polybar launched..."