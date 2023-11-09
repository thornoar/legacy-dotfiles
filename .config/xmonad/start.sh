#! /bin/sh

picom &
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"

xset -dmps
setterm -blank 0 -powerdown 0
xset s off

xset r rate 200 30

unclutter -idle 0.5 &
keynav &

feh --randomize --bg-fill /home/ramak/Wallpapers

transmission-daemon --download-dir "/home/ramak/media/Films"
