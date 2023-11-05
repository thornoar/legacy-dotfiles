#! /bin/sh

xset -dmps
setterm -blank 0 -powerdown 0
xset s off

xset r rate 200 30

unclutter -idle 2.0&
keynav&
