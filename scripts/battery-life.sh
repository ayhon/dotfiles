#!/usr/bin/env sh
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

get_battery_percentage(){
	upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | sed 's/^\s*//g;s/\s\+/ /g;s/%$//g' | cut -d" " -f2
}
style(){
	echo "#[fg=$1, bg=$(test -z $2 && echo $bg_color || echo $2 )]"
}

ptg="$(get_battery_percentage)"
  if [ $ptg -lt 10 ]; then
	echo "$(style $worst) $empty"
elif [ $ptg -lt 20 ]; then
	echo "$(style $worst) $almost_empty"
elif [ $ptg -lt 30 ]; then
	echo "$(style $bad) $almost_empty"
elif [ $ptg -lt 40 ]; then
	echo "$(style $bad) $almost_empty"
elif [ $ptg -lt 50 ]; then
	echo "$(style $meh) $half"
elif [ $ptg -lt 60 ]; then
	echo "$(style $meh) $half"
elif [ $ptg -lt 70 ]; then
	echo "$(style $good) $half"
elif [ $ptg -lt 80 ]; then
	echo "$(style $good) $almost_full"
elif [ $ptg -lt 90 ]; then
	echo "$(style $best) $almost_full"
else
	echo "$(style $best) $full"
fi
