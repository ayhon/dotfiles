#!/bin/bash

# script to sync Google Drive with local folder using rclone
# modified from initial version that used rsync and a usb disk
# by default will write log to home directory with name sinc_gdrive_log.txt
# check also exclusion list
# usage:
#
# $ sinc_gdrive.sh [command] {local folder} {remote folder}
#
# command:
# PUSH to push changes to cloud (from local to Google Drive)
# PULL to pull changes from cloud (from Google Drive to local)
# no command runs the script in dry-run mode to preview changes in both directions
# 
# (C) AAdM 2016-2018

time_start=$(date +"%Y/%m/%d %H:%M:%S")
time_start_sec=$(date +%s)

LOGFILE=$HOME/sinc_gdrive_log.txt

textwhi(){
	echo $@
}
textred(){
	echo -e "\e[31m$@\n\e[m"
}
textcya(){
	echo -e "\e[36m$@\n\e[m"
}

if [ "$1" == "PUSH" ]; then
	shift
	textred "$time_start [sinc_gdrive.sh] PUSH $1 >> $2"
	echo "$time_start [sinc_gdrive.sh] PUSH $1 >> $2" >> $LOGFILE
	rclone sync "$1" gdrive:/"$2" --drive-skip-gdocs --update --transfers=20 --checksum -v --stats=0 --log-file=$LOGFILE --exclude={~*,._**,.git/,__pycache__/}

elif [ "$1" == "PULL" ]; then
	shift
	textred "$time_start [sinc_gdrive.sh] PULL $1 << $2"
	echo "$time_start [sinc_gdrive.sh] PULL $1 << $2" >> $LOGFILE
	rclone sync gdrive:/"$2"  "$1" --drive-skip-gdocs --update --transfers=20 --checksum -v --stats=0 --log-file=$LOGFILE --exclude={~*,._**,.git/,__pycache__/}

else
	textcya "$time_start [sinc_gdrive.sh DRY-RUN] PUSH $1 >> 2"
	rclone sync "$1" gdrive:"$2" --drive-skip-gdocs --update --transfers=20 --checksum --dry-run --exclude={~*,._**,.git/,__pycache__/}
	textcya "$time_start [sinc_gdrive.sh DRY-RUN] PULL $1 << $2"
	rclone sync gdrive:"$2" "$1" --drive-skip-gdocs --update --transfers=20 --checksum --dry-run --exclude={~*,._**,.git/,__pycache__/}
fi

time_end=$(date +"%Y/%m/%d %H:%M:%S")
time_end_sec=$(date +%s)
stat_time=$((time_end_sec - time_start_sec))
if [ $stat_time -lt 60 ]; then
	stat_time="$stat_time seconds"
elif [ $stat_time -lt 3600 ]; then
	stat_time="$((stat_time / 60)) minutes and $((stat_time % 60)) seconds"
else
	stat_time="$((stat_time / 3600)) hours and $(((stat_time % 3600) / 60)) minutes"
fi

textwhi "$time_end [sinc_gdrive.sh] elapsed time: $stat_time"
