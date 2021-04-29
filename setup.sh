#!/bin/bash
# Setup script

GIT_DIR="$HOME/git"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

BASIC_PKGS="tmux nvim git unrar mpv pandoc tldr gdb feh"
EXTRA_PKGS="obs glimpse yad flameshot translate-shell ranger rofi"

# Function definition
dependencies(){
	missing_dep=""
	for dep in $@; do
		which $dep > /dev/null 2>&1 || missing_dep="$missing_dep $dep"
	done
	if [ -n "$missing_dep" ]; then 
		# print_err "Missing dependencies:$missing_dep"
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
		distro_id="$(head -n1 /etc/*-release | grep NAME)"
		distro_id="$(echo $distro_id | sed -s "s/NAME=//g;s/\!//g;s/\"//g")"
		echo $distro_id
		case $distro_id in
			"Pop_OS" | "Ubuntu")
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
					*)
						print_error "Couldn't recognize shell"
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
			[ -f "~/.vim/autoload/plug.vim"] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
				    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;
		"nvim")
			stow -Sd ~/git/dotfiles/ -t ~ nvim
			[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ] \ || curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \ 
				--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;
		"basic")
			dependencies "$BASIC_PKGS"
			;;
		"extra")
			dependencies "$EXTRA_PKGS"
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
