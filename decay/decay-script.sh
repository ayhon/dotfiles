# Given a path to a directory, deletes files older than a month
# The directory must exist

# Variables
decaying_directory="$1"
icons_dir="$HOME/.local/share/icons/decay-script"
state_tmp_file="/tmp/decaying-state"
trash_dir_name="decaying-files"

# Make sure the decaying directory exists
[ -d "$decaying_directory" ] \
	|| echo "The decaying directory doesn't exist!" \
	|| exit 1 

# Make sure the icons directory exists
[ -d "$decaying_directory" ] \
	|| echo "The icons directory doesn't exist!" \
	|| exit 1 

# Move to the decaying directory
cd $decaying_directory

# Create the directory to move files to delete to
trash_dir="/tmp/$trash_dir_name"
mkdir -p $trash_dir

# Fill state_tmp_file with the information of the files in "Decaying"
ls -l | grep -E "(.* ){8}.*" > $state_tmp_file

# Get today's information
this_month="$(date +%b)"
this_day="$(date +%d)"
last_month="$(date +%b -d 'last month')"

# Process files
while read file_info; do
	# Get file information
	file_name="$(echo $file_info | cut -d" " -f 9)"
	month="$(echo $file_info | cut -d" " -f 6)"
	day="$(echo $file_info | cut -d" " -f 7)"

	if [ "$month" != "$this_month" ]; then 
		# The file wasn't created this month

		if [ "$month" = "$last_month" ]; then
			if [ "$day" -lt "$this_day" ]; then
				# The file was created the past month and that day is less than today
				# A month has passed
				mv "$file_name" "$trash_dir/$file_name"
				deleted="true"
			fi
		else # A month has passed for sure
			mv "$file_name" "$trash_dir/$file_name"
			deleted="true"
		fi
	fi
done < $state_tmp_file

if [ -n "$deleted" ]; then
	icon="$icons_dir/trash.svg"
	title="Decaying files were deleted"
	details="The files older than a month were moved to $trash_dir for deletion"
else
	icon="$icons_dir/clock.svg"
	title="No files were deleted"
	details="No files older than a month were found in the folder Decaying, so no files were deleted"
fi
notify-send -t 500 --icon "$icon" "$title" "$details"
