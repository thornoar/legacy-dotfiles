#! /bin/sh

picom &
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"

setxkbmap -layout us,ru,de

xset -dmps
setterm -blank 0 -powerdown 0
xset s off

xset r rate 200 30
setxkbmap -option "caps:none"

unclutter -idle 0.5 &
keynav &

feh --randomize --bg-fill $HOME/wallpapers/Japan

transmission-daemon

if [ $LAPTOP ]; then
	xinput --set-prop "ETD2303:00 04F3:3083 Touchpad" "libinput Tapping Enabled" 1
	xinput --set-prop "ETD2303:00 04F3:3083 Touchpad" "libinput Natural Scrolling Enabled" 1
    xmodmap $HOME/.Xmodmap
fi
