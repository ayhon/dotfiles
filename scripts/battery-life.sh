#!/usr/bin/env sh
for_tmux=false
show_percentage=false

full="  "
almost_full="  "
half="  "
almost_empty="  "
empty="  "
charging_icon="  "

bg_color="#222222"
best="#00ff00"
good="#cfff00"
meh="#ffdf00"
bad="#ff7f00"
worst="#ff0000"
charging_color="#7df9ff"

get_battery_percentage(){
	upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | sed 's/^\s*//g;s/\s\+/ /g;s/%$//g' | cut -d" " -f2
}
get_battery_state(){
	upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | sed 's/^\s*//g;s/\s\+/ /g;s/%$//g' | cut -d" " -f2
}
get_battery_icon(){
	local ptg="$(get_battery_percentage)"
	local state="$(get_battery_state)"
	if [ $state == "charging" ]; then
		echo "$charging_icon"
	elif [ $ptg -lt 10 ]; then
		echo "$empty"
	elif [ $ptg -lt 20 ]; then
		echo "$almost_empty"
	elif [ $ptg -lt 30 ]; then
		echo "$almost_empty"
	elif [ $ptg -lt 40 ]; then
		echo "$almost_empty"
	elif [ $ptg -lt 50 ]; then
		echo "$half"
	elif [ $ptg -lt 60 ]; then
		echo "$half"
	elif [ $ptg -lt 70 ]; then
		echo "$half"
	elif [ $ptg -lt 80 ]; then
		echo "$almost_full"
	elif [ $ptg -lt 90 ]; then
		echo "$almost_full"
	else
		echo "$full"
	fi
}
get_battery_fg(){
	local ptg="$(get_battery_percentage)"
	local state="$(get_battery_state)"
	if [ $state != "discharging" ]; then
		echo "$charging_color"
	elif [ $ptg -lt 10 ]; then
		echo "$worst"
	elif [ $ptg -lt 20 ]; then
		echo "$worst"
	elif [ $ptg -lt 30 ]; then
		echo "$bad"
	elif [ $ptg -lt 40 ]; then
		echo "$bad"
	elif [ $ptg -lt 50 ]; then
		echo "$meh"
	elif [ $ptg -lt 60 ]; then
		echo "$meh"
	elif [ $ptg -lt 70 ]; then
		echo "$good"
	elif [ $ptg -lt 80 ]; then
		echo "$good"
	elif [ $ptg -lt 90 ]; then
		echo "$best"
	else
		echo "$best"
	fi
}
get_style(){
	echo "#[fg=$1, bg=$(test -z $2 && echo $bg_color || echo $2 )]"
}
get_battery_life(){
	local state="$(get_battery_state)"
	local icon="$(get_battery_icon)"
	local fg="$(get_battery_fg)"
	local ptg="$($show_percentage && echo $(get_battery_percentage)%)"
	local style="$($for_tmux && get_style $fg)"
	echo "$style $icon$ptg"
}
handle_arguments(){
	while [ $# -gt 0 ]; do
		case $1 in
			"--tmux"|"-t")
				for_tmux=true
				;;
			"--percentage"|"-p")
				show_percentage=true
				;;
		esac
		shift
done
}
main(){ 
	handle_arguments $@
	get_battery_life
}
main $@


