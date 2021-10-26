#!/usr/bin/env sh
get_battery_percentage(){
	upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | sed 's/^\s*//g;s/\s\+/ /g;s/%$//g' | cut -d" " -f2
}

full="  "
almost_full="  "
half="  "
almost_empty="  "
empty="  "

bg_color="#222222"
best="#00ff00"
good="#cfff00"
meh="#ffdf00"
bad="#ff7f00"
worst="#ff0000"

ptg="$(get_battery_percentage)"
  if [ $ptg -lt 10 ]; then
	echo "#[fg=$worst, bg=$bg_color] $empty"
elif [ $ptg -lt 20 ]; then
	echo "#[fg=$worst, bg=$bg_color] $almost_empty"
elif [ $ptg -lt 30 ]; then
	echo "#[fg=$bad, bg=$bg_color] $almost_empty"
elif [ $ptg -lt 40 ]; then
	echo "#[fg=$bad, bg=$bg_color] $almost_empty"
elif [ $ptg -lt 50 ]; then
	echo "#[fg=$meh, bg=$bg_color] $half"
elif [ $ptg -lt 60 ]; then
	echo "#[fg=$meh, bg=$bg_color] $half"
elif [ $ptg -lt 70 ]; then
	echo "#[fg=$good, bg=$bg_color] $half"
elif [ $ptg -lt 80 ]; then
	echo "#[fg=$good, bg=$bg_color] $almost_full"
elif [ $ptg -lt 90 ]; then
	echo "#[fg=$best, bg=$bg_color] $almost_full"
else
	echo "#[fg=$best, bg=$bg_color] $full"
fi
