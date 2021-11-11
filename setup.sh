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
DATA_DIR_NAME="data"
SAVED_DIRECTORIES="Desktop Documents Downloads Music Pictures Videos"

REQUIRED_PKGS="stow git curl"
BASIC_PKGS="tmux neovim git unrar mpv pandoc tldr gdb fzf"
EXTRA_PKGS="obs gimp yad flameshot translate-shell ranger rofi feh"

# Giving information
goal_msg(){ printf "\e[33;1m[GOAL]\e[m %s\n" "$@"; }
verbose_msg(){ echo $@; }
print_err (){ printf "\e[31;1m[ERROR]\e[m %s\n" "$@" >&2; }

# Getting information
get_display_server(){
	loginctl show-session $(loginctl | grep $(whoami) | cut -d" " -f6) -p Type | cut -d= -f2
}
get_distro_id(){
	head -n1 /etc/*-release | grep NAME | sed -s "s/NAME=//g;s/\!//g;s/\"//g"
}
get_shell(){
	basename $SHELL
}
get_shell_RC(){
	case "$(get_shell)" in
		"zsh")
			rc_shell="$HOME/.zshrc"
			;;
		"bash")
			rc_shell="$HOME/.bashrc"
			;;
		*)
			print_err "Couldn't recognize shell. Using .bashrc"
			rc_shell="$HOME/.bashrc" # Default
			return 1
			;;
	esac
	echo $rc_shell
}

# Program installation
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

		local distro_id="$(get_distro_id)"
		verbose_msg "Detected distribution: $distro_id"

		case $distro_id in
			"Pop_OS" | "Ubuntu" | *"Kali"*)
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
			"Fedora")
				sudo dnf upgrade
				sudo dnf install -y "$@"
				;;
			*)
				print_err "Sorry, \"$distro_id\" isn't supported yet"
				;;
			# TODO: Add more possibilities
		esac
	else
		print_err "Only linux is suppported right now"
		exit 1
	fi

}


install_script(){
	# install_script {script-name}̣̣̣̣ [executable-name]
	if which $2 >/dev/null 2>&1; then
		verbose_msg "Executable $2 found in path"
	else
		local script_pathname="$DOTFILES_DIR/scripts/$1" 

		[ -f "$script_pathname" ] || return 1

		chmod +x "$script_pathname"

		mkdir -p "$HOME/.local/bin"
		ln -s "$script_pathname" "$HOME/.local/bin/$([ -z $2 ] && echo $1 || echo $2)"
	fi
}

# Main function
setup(){
	# Main function. 
	# It takes one argument, the type of
	# setup to execute.

	cd $HOME
	dependencies "$REQUIRED_PKGS"
	case $1 in
		"init")
			goal_msg "Configuring setup command..."
			#-# Things I need for this script to work #-#

			# Make sure my `dotfiles` repo was clonned locally
			goal_msg "Cloning dotfiles repo locally from github"
			if [ ! -d "$DOTFILES_DIR" ]; then
				mkdir -p "$GIT_DIR" 
				cd  "$GIT_DIR"

				[ -d "$HOME/.ssh" ] \
					&& git clone "git@github.com:ayhon/dotfiles.git" "$DOTFILES_DIR"

				if [ ! -d "$DOTFILES_DIR" ]; then
					print_err "Coudn't clone dotfiles via ssh. Using https"

					git clone "https://github.com/ayhon/dotfiles" "$DOTFILES_DIR"
					git remote set-url origin "git@github.com:ayhon/dotfiles.git" --push
					goal_msg "Creating .ssh directory and needed files (Import your ssh keys later)"

					mkdir "$HOME/.ssh"
					chmod 700 "$HOME/.ssh"

					touch "$HOME/.ssh/authorized_keys"
					chmod 600 "$HOME/.ssh/authorized_keys"

					touch "$HOME/.ssh/config"
					chmod 600 "$HOME/.ssh/config"
				fi
			else
				verbose_msg "Dotfiles repository found locally"
				goal_msg "Pulling new changes from repository"
				git pull
			fi

			goal_msg "Installing script"
			install_script "../setup.sh" $CMD_NAME

			;;

		"vim")
			goal_msg "Configuring vim..."
			dependencies "vim"
			stow -Svd $DOTFILES_DIR -t $HOME vim
			[ -f "~/.vim/autoload/plug.vim" ] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
				    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			;;

		"nvim")
			goal_msg "Configuring nvim..."
			setup "vim"
			dependencies "neovim"
			stow -Svd $DOTFILES_DIR -t $HOME nvim

			goal_msg "Setting up vim-plug for neovim"
			[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ] \
				|| curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
				--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
			goal_msg "Setting up packer for neovim"
			git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 				~/.local/share/nvim/site/pack/packer/start/packer.nvim

			goal_msg "Enable vim UltiSnips snippets from within nvim"
			local vim_ultisnips_dir="$DOTFILES_DIR/vim/.vim/UltiSnips" 
			local nvim_ultisnips_dir="$DOTFILES_DIR/nvim/.config/nvim/UltiSnips"
			[ -d "$nvim_ultisnips_dir" ] && rmdir "$nvim_ultisnips_dir"
			ln -s "$vim_ultisnips_dir" "$nvim_ultisnips_dir"

			goal_msg "Enable after syntax files from vim"
			local vim_after_syntax_dir="$DOTFILES_DIR/vim/.vim/after/syntax/" 
			local nvim_after_syntax_dir="$DOTFILES_DIR/nvim/.config/nvim/after/syntax"
			[ -d "$nvim_after_syntax_dir" ] && rmdir "$nvim_after_syntax_dir"
			mkdir -p "$(dirname $nvim_after_syntax_dir)"
			ln -s "$vim_after_syntax_dir" "$nvim_after_syntax_dir"
			;;

		"tmux")
			goal_msg "Configuring tmux..."
			dependencies "tmux"
			stow -Svd $DOTFILES_DIR -t $HOME tmux
			;;

		"basic")
			goal_msg "Configuring basic..."
			dependencies "$BASIC_PKGS"
			;;

		"extra")
			goal_msg "Configuring extra..."
			dependencies "$BASIC_PKGS"
			dependencies "$EXTRA_PKGS"
			;;

		"data")
			goal_msg "Configuring data..."

			goal_msg "Finding (or creating) $DATA_DIR_NAME"
			local data_dir="$HOME/.local/share/$DATA_DIR_NAME"
			if [ ! -d $data_dir ]; then
				verbose_msg "$data_dir is not a directory"
				for saved_dir in $SAVED_DIRECTORIES; do
					mkdir -p "$data_dir/$saved_dir"
				done
			fi

			goal_msg "Creating symlinks "
			stow -Svd "$HOME/.local/share" -t "$HOME" "$DATA_DIR_NAME"

			;;

		"test")
			# ensure_root
			# dependencies R python3 python whaaaaat
			# print_err "End of testing"
			echo "$@"
			;;

		"decay")
			goal_msg "Configuring decay..." 
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

		"colors")
			echo 'for i in {0..9}; do 	
				echo -e \"\e[3${i}mThis is 3$i\e[m";
			done' >> $(get_shell_RC)
			;;

		"gdrive")
			dependencies "rclone"
			print_err "fzf autocompletion still under construction"
			return 1
			install_script "sync_drive.sh"

			# TODO:
			# - Extract argument info (Either `local` or `remote`)
			# - Use sane defaults (For local a new folder, for remote nothing)
			# - Setup a crontab or entr process to autoupdate (Look into)
			if [ $# -gt 2 ]; then 
				command_option="$(echo $2 | cut -d= -f1 | sed 's/^-*//g')"
				if [ $command_option == "target" ]; then
					gdrive_local_directory="$(echo $2 | cut -d= -f2)"

					rclone config

					print_err "Target not finished yet"
					
				else
					print_err "Unrecognized option \"$command_option\""
				fi
			else
				print_err "Provide a --target=DIRECTORY to the gdrive targets"
			fi
			;;
		"fzf")
			goal_msg "Configuring fzf"
			dependencies "fzf ripgrep"

			goal_msg "Configuring fzf keybindings"
			local keybindings_dir="/usr/share/fzf/shell/key-bindings.$(get_shell)"
 	 		if [ -f  "$keybindings_dir" ]; then
				echo "source $keybindings_dir" >> $(get_shell_RC)
			fi

			goal_msg "Using ripgrep for fzf instead of find"
			echo "export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob \"!.git/*\"'" >> $(get_shell_RC)

			goal_msg "Configuring fzf autocompletion"
			;;
		"keymapper")
			print_err "fzf autocompletion still under construction"
			return 1

			dependencies "pip python3-setuptools python3-devel"

			goal_msg "Downloading program"
			sudo pip install git+https://github.com/sezanzeb/key-mapper.git

			goal_msg "Enabling key-mapper.service"
			sudo systemctl enable --now key-mapper
			;;

		"ssh")
			print_err "Not implemented"
			return 1

			eval "$(ssh-agent -s)"
			ssh-add "$HOME/.ssh/ub_slab"
			;;

		"wezterm")
			dependencies "curl jq" # TODO: Consider doing this without depending on `jq`
			local bin_name="wezterm"

			if ! which $bin_name >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/$bin_name" ]; then
				local id=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest \
					| jq ".. | .tag_name" 2>/dev/null)
				local location="https://github.com/wez/wezterm/releases/download/$id/WezTerm-$id-Ubuntu16.04.AppImage"

				curl -LO "$location" -o "$HOME/.local/bin/$bin_name"
				chmod +x "$HOME/.local/bin/$bin_name"
			fi

			goal_msg "Configuring wezterm..."
			stow -Svd $DOTFILES_DIR -t $HOME wezterm
			;;

		*)
			print_err "Option not recognized: \"$1\""
			usage
			exit 1
			;;
	esac
}
usage(){
	cat <<EOF
Usage:
  $SCRIPT_NAME [options] [target]

Options:
  -h --help             Show this help message
  -lv --load-variables  Exit after loading variables

Targets:
  init    - Basic conditions 
  basic   - Install basic utilities
  extra   - Install extra packages
  vim     - Setup vim config
  nvim    - Setup nvim config
  decay   - Setup a decaying directory
  fzf     - Setup fzf with shortcuts
  wezterm - Setup wezterm
EOF
}
is_argument(){
	case $1 in
		"-"*) true;;
		*) false;;
	esac
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
				args="$1"
				while [ $# -ge 2 ] && is_argument "$2" ; do
					args="$args $2"
					shift
				done
				setup $args
				;;
		esac
		shift
	done
	exit 0
}

main "$@"

