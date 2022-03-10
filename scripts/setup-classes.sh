#!/usr/bin/env sh
past_classes="iml fp algo a3 ode dsd" 
past_ids="$past_classes"

classes="idbs no do na aa pc ca2 topo"
always="personal ms polygl0ts airsync"
ids="$always $classes"
all_ids="$ids $past_ids"
delete_session(){
	local id="$1"
	[ -n "$id" ] && tmux kill-session -t "$id"
}
create_session(){
	local id="$1"
	# Check for valid ID and substract the `if ! tmux has-session ...` out of the case statement
	[ -n "$id" ] && ! tmux has-session -t "$id" 2> /dev/null && case $id in
		"iml")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/IML Introduction to Machine Learning/"
			tmux send-keys -t "$id" nvim \ . Enter
			tmux split-window -t "$id" -l 4 -v "ipython -i $HOME/git/dotfiles/scripts/science-env.py"
			tmux send-keys C-l
			;;
		"fp")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/FP Functional Programming/Notes"
			tmux send-keys -t "$id" nvim \ . Enter
			tmux split-window -t "$id" -l 4 -v "scala3-repl"
			;;
		"pc")
			setup_default $id
			tmux send-keys -t "$id" nvim \ . Enter
			tmux split-window -t "$id" -l 4 -v "scala3-repl"
			;;
		"algo")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/ALGO Algorithms/Notes"
			tmux send-keys -t "$id" nvim \ . Enter
			;;
		"aa")
			setup_default $id
			tmux send-keys -t "$id" nvim \ . Enter
			;;
		"a3")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/A3 Analysis III" "julia --banner=no -i $HOME/git/dotfiles/scripts/science-env.jl"
			tmux send-keys C-l
			;;
		"ode"|"edo")
			id="ode"
			tmux new-session -ds "$id" -c "/home/ayhon/uni/ODE Ordinary Differential Equations/Summaries"
			tmux send-keys -t "$id" nvim \ . Enter
			;;
		"dsd")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/DSD Digital System Design/"
			tmux send-keys -t "$id" nvim \ . Enter
			;;
		"polygl0ts"|"ctf")
			id="polygl0ts"
			tmux new-session -ds "$id" -c "/home/ayhon/git/polygl0ts/"
			;;
		"personal")
			tmux new-session -ds "$id" -c "/home/ayhon"
			;;
		"ms")
			local workdir="/home/ayhon/Desktop/Projects/Lua/GeneralizedMinesweeper"
			tmux new-session -ds "$id" -c "$workdir/src"
			tmux send-keys -t "$id:0" nvim \   . Enter
			tmux split-window -h -t "$id" -c "$workdir/spec"
			tmux send-keys -t "$id" nvim \ . Enter
			tmux split-window -v -t "$id" -c "$workdir" -l 1 "while true; do clear && busted; read; done"
			;;
		"airsync"|"work")
			id="airsync"
			tmux new-session -ds "$id" -c "/home/ayhon/Work/Airsync/"
			;;
		*)
			setup_default $id
			tmux send-keys -t "$id" nvim \ . Enter
			;;
	esac
}
setup_default(){
	local id="$1"
	local dir="$(get_dir_from_prefix '/home/ayhon/uni' $id)"
	tmux new-session -ds "$id" -c "$dir"
}
get_dir_from_prefix(){
	local parent_dir="$1"
	local prefix="$(echo $2 | tr 'a-z' 'A-Z')"
	local dirname="$(ls $parent_dir | grep -E "^$prefix")"
	local result="$parent_dir/$dirname"
	echo $result
}

case "$1" in
	"")
		for id in `echo $ids`; do
			echo "Setting up $id"
			create_session "$id" 2>/dev/null || echo "Setting up $id failed"
		done
		;;
	"destroy")
		for  id  in `echo $all_ids`; do
			delete_session "$id" 2>/dev/null && echo "Destroyed $id"
		done
		;;
	"setup")
		create_session "$2" 2>/dev/null
		;;
	*)
		echo "Unrecognized option"
		exit 1
		;;
esac

ids=""
