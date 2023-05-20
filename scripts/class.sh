#!/usr/bin/env sh
past_classes="iml fp algo a3 ode dsd" 
past_ids="$past_classes"

classes="idbs no do na aa pc ca2 topo"
always="pers poly rust" # poly from polygl0ts
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
		# "iml")
		# 	tmux new-session -ds "$id" -c "$HOME/uni/IML Introduction to Machine Learning/"
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	tmux split-window -t "$id" -l 4 -v "ipython -i $HOME/git/dotfiles/scripts/science-env.py"
		# 	tmux send-keys C-l
		# 	;;
		# "fp")
		# 	tmux new-session -ds "$id" -c "$HOME/uni/FP Functional Programming/Notes"
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	tmux split-window -t "$id" -l 4 -v "scala3-repl"
		# 	;;
		# "pc")
		# 	setup_default $id
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	tmux split-window -t "$id" -l 4 -v "scala3-repl"
		# 	;;
		# "algo")
		# 	tmux new-session -ds "$id" -c "$HOME/uni/ALGO Algorithms/Notes"
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	;;
		# "aa")
		# 	setup_default $id
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	;;
		# "a3")
		# 	tmux new-session -ds "$id" -c "$HOME/uni/A3 Analysis III" "julia --banner=no -i $HOME/git/dotfiles/scripts/science-env.jl"
		# 	tmux send-keys C-l
		# 	;;
		# "ode"|"edo")
		# 	id="ode"
		# 	tmux new-session -ds "$id" -c "$HOME/uni/ODE Ordinary Differential Equations/Summaries"
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	;;
		# "dsd")
		# 	tmux new-session -ds "$id" -c "$HOME/uni/DSD Digital System Design/"
		# 	tmux send-keys -t "$id" nvim \ . Enter
		# 	;;
		# "airsync")
		# 	id="airsync"
		# 	tmux new-session -ds "$id" -c "$HOME/Work/Airsync/"
		# 	;;
		# "rust")
		# 	id="rust"
		# 	tmux new-session -ds "$id" -c "$HOME/Desktop/Projects/Rust"
		# 	;;
		"poly"|"polygl0ts"|"ctf")
			workdir=`[ "$id" = "ctf" ] && echo $CTF || echo  "$HOME/Desktop/Universidad/polygl0ts/"`
			id="poly"
			tmux new-session -ds "$id" -c "$workdir"
			;;
		"personal")
			tmux new-session -ds "$id" -c "$HOME"
			;;
		"ms")
			local workdir="$HOME/Desktop/Projects/Lua/GeneralizedMinesweeper"
			tmux new-session -ds "$id" -c "$workdir/src"
			tmux send-keys -t "$id:0" nvim \   . Enter
			tmux split-window -h -t "$id" -c "$workdir/spec"
			tmux send-keys -t "$id" nvim \ . Enter
			tmux split-window -v -t "$id" -c "$workdir" -l 1 "while true; do clear && busted; read; done"
			;;
		"lua2mc")
		 	tmux new-session -ds "$id" -c "$HOME/git/lua2mc"
			;;
		"ecal")
		 	tmux new-session -ds "$id" -c "$HOME/uni/Ecuaciones Algebraicas/"
			;;
		"ia")
		 	tmux new-session -ds "$id" -c "$HOME/uni/Inteligencia artificial/"
			;;
		"redes")
		 	tmux new-session -ds "$id" -c "$HOME/uni/Redes/"
			;;
		"so")
		 	tmux new-session -ds "$id" -c "$HOME/uni/Sistemas operativos/"
			;;
		"ucppm")
			tmux new-session -ds "$id" -c "$HOME/pcomp/"
			;;
		*)
			echo "Couldn't find a recipe for $id"
			setup_default $id
			;;
	esac
}
setup_subject(){
	local id="$1"
	local dir="$(get_dir_from_prefix "$HOME/uni" $id)"
	tmux new-session -ds "$id" -c "$dir"
}
setup_default(){
	local id="$1"
	tmux new-session -ds "$id" -c "$dir"
}
get_dir_from_prefix(){
	local parent_dir="$1"
	local prefix="$(echo $2 | tr 'a-z' 'A-Z')"
	local dirname="$(ls $parent_dir | grep -E "^$prefix")"
	local result="$parent_dir/$dirname"
	echo $result
}
main(){
	case "$1" in
		"--all")
			for id in `echo $ids`; do
				echo "Setting up $id"
				create_session "$id" 2>/dev/null || echo "Setting up $id failed"
			done
			;;
		"--destroy")
			for  id  in `echo $all_ids`; do
				delete_session "$id" 2>/dev/null && echo "Destroyed $id"
			done
			;;
		*)
			"Creating session $1"
			create_session "$1" 2>/dev/null
			tmux attach-session -t "$1"
			;;
	esac
}
main $@
