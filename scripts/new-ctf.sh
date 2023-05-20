#!/bin/bash
# It's meant to be sourced, not run, because of the cd at the end
create-ctf(){
	local name="$1"
	if [ -z "$name" ]; then
		echo -e "Give me the CTF's directory name"
		read -p "> " name || echo "..."
		create-ctf $name
		name=""
	fi
	if [ -n "$name" ]; then
		local ctf_dir="$HOME/Desktop/Universidad/polygl0ts/$name"
		mkdir -p "$ctf_dir"
		echo "Created $ctf_dir"

		mkdir -p "$HOME/.local/info"
		echo "$ctf_dir" > "$HOME/.local/info/ctf-directory"
		echo "Updated current ctf in .local/info/ctf-directory"

		export CTF="$ctf_dir"
		echo "Exported ctf dir"
		echo "Best of luck!"
		cd $CTF
	else 
		echo "It's still empty"
	fi
}
create-ctf $1
cd $CTF
