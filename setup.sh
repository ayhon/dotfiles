#!/bin/bash
# Setup script

GIT_DIR="$HOME/git"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Function definition
dependencies(){
	missing_dep=""
	for dep in $@; do
		which $dep > /dev/null 2>&1 || missing_dep="$missing_dep $dep"
	done
	if [ -n "$missing_dep" ]; then 
		print_err "Missing dependencies:$missing_dep"
		inst $missing_dep
	fi
}
ensure_root(){
	if [[ "$EUID" != 0 ]]; then
		sudo -k
		if sudo true; then
			echo "Thanks for signing in"
		else
			print_err "Wrong password"
		fi
	fi
}
inst(){
	#elif [[ "$OSTYPE" == "darwin" ]]; then
	#elif [[ "$OSTYPE" == "cygwin" ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		ensure_root
		distro_id="$(head -1 /etc/*-release | grep NAME | sed 's/NAME=//g')"
		case distro_id in
			"Pop!_OS" | "Ubuntu")
				sudo apt update && sudo apt upgrade
				sudo apt install "$@"
				;;
			"Arch Linux")
				sudo pacman -Syyuu
				sudo pacman -S "$@"
				;;
			# TODO: Add more possibilities
		esac
	else
		print_err "Only linux is suppported right now"
	fi

}
setup(){
	cd $HOME
	dependencies stow git
	case $1 in
		"init")
			#-# Things I need for this script #-#
			if [ ! -d "$GIT_DIR/dotfiles" ]; then
				mkdir -p "$GIT_DIR" 
				cd  "$GIT_DIR"
				git clone "git@github.com:ayhon/dotfiles.git" || \
					print_err "Coudn't clone dotfiles"
			fi
			if [ ! -d "$HOME/.bin" ]; then
				mkdir "$HOME/.bin"
				rc_shell="$HOME/.bashrc"
				case "$(basename $SHELL)" in
					"zsh")
						rc_shell="$HOME/.zshrc"
						;;
					"bash")
						rc_shell="$HOME/.bashrc"
						;;
				esac
				echo "export PATH=\"\$PATH:\$HOME/.bin\"" >> $rc_shell
			fi
			if [ ! -L "$HOME/.bin/setup" ];then
				ln -s "$GIT_DIR/dotfiles/setup.sh" "$HOME/.bin/setup"
			fi
			;;
		"vim")
			stow -Sd ~/git/dotfiles/ -t ~ vim
			;;
		"nvim")
			stow -Sd ~/git/dotfiles/ -t ~ nvim
			;;
		"basic")
			dependencies tmux nvim git
			;;
		"extra")
			dependencies obs-studio gimp yad flameshot
			;;
		"test")
			ensure_root
			dependencies R python3 python whaaaaat
			print_err "End of testing"
			;;
		*)
			error_exit
			;;
	esac
}

# Error handling
error_exit(){
	usage
	exit 1
}
print_err (){
	printf "\e[31;1m[ERROR]\e[m %s\n" "$@" >&2
	exit 1
}

usage(){
	cat <<EOF
Usage:
  $(basename $0) [options] [target]

Options:
  -h --help         Show this help message

Targets:
  init   - Basic conditions 
  basic  - Install basic utilities
  extra  - Install extra packages
  vim    - Setup vim config
  nvim   - Setup nvim config
EOF
}
main(){
	setup "init"
	while [ $# -gt 0 ]; do
		case $1 in
			"-h"|"--help")
				usage
				exit 0
				;;
			*)
				setup $1
				;;
		esac
		shift
	done
	exit 0
}

main "$@"
