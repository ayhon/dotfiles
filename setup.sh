#!/bin/bash
# Setup script

GIT_DIR="$HOME/git"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="$(basename $0)"
DOTFILES_DIR="$GIT_DIR/dotfiles"
CMD_NAME="setup"

BASIC_PKGS="tmux nvim git unrar mpv pandoc tldr gdb feh"
EXTRA_PKGS="obs gimp yad flameshot translate-shell ranger rofi"

# Function definition
goal_msg(){ printf "\e[33;1m[GOAL]\e[m %s\n" "$@"; }
verbose_msg(){ echo $@; }

dependencies(){
	local missing_dep=""

	# Find which dependencies aren't installed
	for dep in $@; do
		which $dep > /dev/null 2>&1 || missing_dep="$missing_dep $dep"
	done

	# Install not-found dependencies
	if [ -n "$missing_dep" ]; then 
		# print_err "Missing dependencies:$missing_dep"
		inst $missing_dep
	fi
}

ensure_root(){
	# Makes sure the user has root permissions
	if [[ "$EUID" != 0 ]]; then
		sudo -k
		if sudo true; then
			verbose_msg "Thanks for signing in"
		else
			print_err "Wrong password"
		fi
	fi
}
inst(){
	# System agnostic installer
	goal_msg "Installing $@"

	#elif [[ "$OSTYPE" == "darwin" ]]; then
	#elif [[ "$OSTYPE" == "cygwin" ]]; then
	if [[ "$OSTYPE" == "linux"* ]]; then
		ensure_root

		distro_id="$(head -n1 /etc/*-release | grep NAME)"
		distro_id="$(echo $distro_id | sed -s "s/NAME=//g;s/\!//g;s/\"//g")"
		verbose_msg "Detected distribution: $distro_id"

		case $distro_id in
			"Pop_OS" | "Ubuntu")
				sudo apt update && sudo apt upgrade
				sudo apt install "$@"
				;;
			"Arch Linux")
				sudo pacman -Syyuu
				sudo pacman -S "$@"
				;;
			"openSUSE"*)
				sudo zypper ref
				sudo zypper up -y
				sudo zypper in -y "$@"
				;;
				# TODO: Add more possibilities
			esac
		else
			print_err "Only linux is suppported right now, used $distro_id"
	fi

}
setup(){
	# Main function. 
	# It takes one argument, the type of
	# setup to execute.

	cd $HOME
	dependencies stow git
	case $1 in
		"init")
			#-# Things I need for this script to work #-#

			# Make sure my `dotfiles` repo was clonned locally
			if [ ! -d "$DOTFILES_DIR" ]; then
				mkdir -p "$GIT_DIR" 
				cd  "$GIT_DIR"
				git clone "git@github.com:ayhon/dotfiles.git" || \
					print_err "Coudn't clone dotfiles"
			fi

			# Make a `.bin` directory to store my scripts.
			# Also, add it to my PATH
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
						print_err "Couldn't recognize shell"
						;;
				esac
				echo "export PATH=\"\$PATH:\$HOME/.bin\"" >> $rc_shell
			fi

			# Make sure this script is executable
			if [ ! -x "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
				chown +x "$SCRIPT_DIR/$SCRIPT_NAME"
			fi

			# Make sure this script is found in path
			if [ ! -L "$HOME/.bin/$CMD_NAME" ];then
				ln -s "$SCRIPT_DIR/$SCRIPT_NAME" "$HOME/.bin/$CMD_NAME"
			fi
			;;

		"vim")
			stow -Sd $DOTFILES_DIR -t $HOME vim
			[ -f "~/.vim/autoload/plug.vim"] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;

		"nvim")
			stow -Sd $DOTFILES_DIR -t $HOME nvim
			[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ] \ || curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;

		"tmux")
			stow -Sd $DOTFILES_DIR -t $HOME tmux
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
			usage
			exit 1
			;;
	esac
}

# Error handling
print_err (){
	printf "\e[31;1m[ERROR]\e[m %s\n" "$@" >&2
	exit 1
}

usage(){
	cat <<EOF
Usage:
  $SCRIPT_NAME [options] [target]

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
	# echo $SCRIPT_DIR
	# echo $0
	# exit 0
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

