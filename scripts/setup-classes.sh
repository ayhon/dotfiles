#!/usr/bin/env sh
ids="iml fp algo a3 ode dsd polygl0ts personal"
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
			tmux send-keys -s "$id" nvim  . Enter
			tmux split-window -t "$id" -l 4 -v "ipython -i $HOME/git/dotfiles/scripts/science-env.py"
			tmux send-keys C-l
			;;
		"fp")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/FP Functional Programming/Notes"
			tmux send-keys -s "$id" nvim  . Enter
			tmux split-window -t "$id" -l 4 -v "scala3-repl"
			;;
		"algo")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/ALGO Algorithms/Notes"
			tmux send-keys -s "$id" nvim  . Enter
			;;
		"a3")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/A3 Analysis III" "ipython -i $HOME/git/dotfiles/scripts/science-env.py"
			tmux send-keys C-l
			;;
		"ode"|"edo")
			id="ode"
			tmux new-session -ds "$id" -c "/home/ayhon/uni/ODE Ordinary Differential Equations/Summaries"
			tmux send-keys -s "$id" nvim  . Enter
			;;
		"dsd")
			tmux new-session -ds "$id" -c "/home/ayhon/uni/DSD Digital System Design/"
			tmux send-keys -s "$id" nvim  . Enter
			;;
		"polygl0ts"|"ctf")
			id="polygl0ts"
			tmux new-session -ds "$id" -c "/home/ayhon/git/polygl0ts/"
			;;
		"personal")
			tmux new-session -ds "$id" -c "/home/ayhon"
			;;
	esac
}

case "$1" in
	"")
		for id in `echo $ids`; do
			echo "Setting up $id"
			create_session "$id" 2>/dev/null
		done
		;;
	"destroy")
		for  id  in `echo $ids`; do
			echo "Destroying $id"
			delete_session "$id" 2>/dev/null
		done
		;;
	*)
		echo "Unrecognized option"
		exit 1
		;;
esac

ids=""
