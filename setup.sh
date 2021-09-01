#!/bin/bash
# Setup script

# TODO:
#  - Only ask for password once (e.g. in 'setup nvim')
#  - Fix output of global_msg in `inst()`

GIT_DIR="$HOME/git"
DECAY_DIR="$HOME/Decay"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DOTFILES_DIR="$GIT_DIR/dotfiles"
CMD_NAME="setup"

REQUIRED_PKGS="stow git curl"
BASIC_PKGS="tmux neovim git unrar mpv pandoc tldr gdb feh"
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
			exit 1
		fi
	fi
}
inst(){
	# System agnostic installer
	goal_msg "Installing" $@

	#elif [[ "$OSTYPE" == "darwin" ]]; then
	#elif [[ "$OSTYPE" == "cygwin" ]]; then
	if [[ "$OSTYPE" == "linux"* ]]; then
		ensure_root

		distro_id="$(head -n1 /etc/*-release | grep NAME)"
		distro_id="$(echo $distro_id | sed -s "s/NAME=//g;s/\!//g;s/\"//g")"
		verbose_msg "Detected distribution: $distro_id"

		case $distro_id in
			"Pop_OS" | "Ubuntu")
				sudo apt-get update -y 
				sudo apt-get upgrade -y
				sudo apt-get install -y "$@"
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
		print_err "Only linux is suppported right now"
		exit 1
	fi

}
setup(){
	# Main function. 
	# It takes one argument, the type of
	# setup to execute.

	cd $HOME
	dependencies "$REQUIRED_PKGS"
	case $1 in
		"init")
			#-# Things I need for this script to work #-#

			# Make sure my `dotfiles` repo was clonned locally
			goal_msg "Cloning dotfiles repo locally from github"
			if [ ! -d "$DOTFILES_DIR" ]; then
				mkdir -p "$GIT_DIR" 
				cd  "$GIT_DIR"
				git clone "git@github.com:ayhon/dotfiles.git" || \
					print_err "Coudn't clone dotfiles via ssh. Using https" && \
					git clone "https://github.com/ayhon/dotfiles"
			fi

			goal_msg "Making a .bin directory to store script"
			# Also, add it to my PATH
			if [ ! -d "$HOME/.bin" ]; then
				mkdir "$HOME/.bin"
				local rc_shell="$HOME/.bashrc"
				verbose_msg "Found RC file of shell in $rc_shell"
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

				# # Reload the shell rc
				# goal_msg "Trying to reload $rc_shell"
				# source $rc_shell
			fi

			goal_msg "Making sure $CMD_NAME is executable" 
			if [ ! -x "$DOTFILES_DIR/setup.sh" ]; then
				chmod +x "$DOTFILES_DIR/setup.sh"
			fi

			# Make sure this script is found in path
			goal_msg "Making sure this script if reachable by PATH"
			if [ ! -L "$HOME/.bin/$CMD_NAME" ];then
				ln -s "$DOTFILES_DIR/setup.sh" "$HOME/.bin/$CMD_NAME"
			fi

			;;

		"vim")
			dependencies "vim"
			stow -Sd $DOTFILES_DIR -t $HOME vim
			[ -f "~/.vim/autoload/plug.vim"] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
				    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;

		"nvim")
			setup "vim"
			dependencies "neovim"
			stow -Sd $DOTFILES_DIR -t $HOME nvim
			[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ] \
				|| curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
				--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;

		"tmux")
			dependencies "tmux"
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

		"decay")
			goal_msg "Making decay directory"
			mkdir -p "$DECAY_DIR"

			# Set up directory for the icons of the notifications
			goal_msg "Setting icons in icons directory"
			decay_icons_dir="$HOME/.local/share/icons/decay-script"
			mkdir -p "$decay_icons_dir"
			ln -s "$DOTFILES_DIR/decay/clock.svg" "$decay_icons_dir/clock.svg" 2>/dev/null
			ln -s "$DOTFILES_DIR/decay/trash.svg" "$decay_icons_dir/trash.svg" 2>/dev/null

			# Add entry to crontab
			goal_msg "Installing script in crontab"
			(crontab -l; echo -e "0 0 * * 7 sh $DOTFILES_DIR/decay/decay-script.sh '$DECAY_DIR'\n ") | crontab -
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
}

usage(){
	cat <<EOF
Usage:
  $SCRIPT_NAME [options] [target]

Options:
  -h --help             Show this help message
  -lv --load-variables  Exit after loading variables

Targets:
  init   - Basic conditions 
  basic  - Install basic utilities
  extra  - Install extra packages
  vim    - Setup vim config
  nvim   - Setup nvim config
  decay  - Setup a decaying directory
EOF
}
main(){
	# echo $SCRIPT_DIR
	# echo $0
	# exit 0
	setup "init"
	while [ $# -gt 0 ]; do
		case $1 in
			"-lv"|"--load-variables")
				exit 0
				;;

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

