#! /bin/sh

picom --fade-in-step=1 --fade-out-step=1 --fade-delta=0 &
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"

xset -dmps
setterm -blank 0 -powerdown 0
xset s off

xset r rate 200 30

unclutter -idle 2.0 &
keynav &
