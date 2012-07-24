#!/bin/bash

usage="m3u-fix.sh [-d mp3-directory] [-p m3u-playlist]"

# script to find awol mp3s in an m3u

while getopts "d:p:" options
do
	case $options in
		d ) MP3PATH="$OPTARG";;
		p ) M3UPATH="$OPTARG";;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done
shift $((OPTIND-1))

# set Input Field Separator to newline
IFS="$(echo -en '\n\r')"

# search for an m3u in the current directory if one isn't supplied
PWD=$(pwd)
if [ -z "$M3UPATH" ]; then
	M3UPATH=$PWD
fi

# find MP3 collection base directory
if [ -z "$MP3PATH" ] && [ -z "$MUSIC_DIR" ]; then
	echo "You must define a MUSIC_DIR env var, or supply the -d parameter"
	exit 1
elif [ ! -z "$MUSIC_DIR" ]; then
	MP3PATH=$MUSIC_DIR
fi

# attempt to find an M3U
if [ -d "$M3UPATH" ]; then
	for FILENAME in $(find "$M3UPATH" -maxdepth 1 -iname "*.m3u" | sort -n)
	do
		echo "Use $FILENAME? [y/N]"
		read y
		if [ "$y" = "y" ]; then
			M3UPATH=$FILENAME
			break
		fi
	done
fi

# check all playlist files exist
for MP3 in $(cat "$M3UPATH" | awk '!/#/ {print}')
do
	if [ ! -f "$MP3" ]; then
		# create a searchable string from the MP3 filename
		FILE=$(basename "$MP3")
		echo "$FILE not found"
		SEARCH=$(echo "$FILE" | sed 's/[ -]/*/g' | sed 's/\.mp3/*mp3/g')
		i=1

		# attempt to find missing file
		IFS=""
		FOUND=$(find "$MP3PATH" -iname "$SEARCH" -type f)

		# print list of choices
		if [ ! -z "$FOUND" ]; then
			i=1
			echo "Options:"
			IFS="$(echo -en '\n\r')"
			for RES in $FOUND
			do
				echo "[$i] $RES"
				let i++
			done
			
			read n
			if [ ! -z "$n" ]; then
				# santize paths for sed (fwd-slash, space)
				MP3=$(echo "$MP3" | sed 's/\//\\\//g' | sed 's/ /\\ /g')
				RES=$(echo "$RES" | sed 's/\//\\\//g' | sed 's/ /\\ /g')

				sed -i "s/$MP3/$RES/" "$M3UPATH"
				echo "Fixed"
			fi
		else
			echo "No possible options found"
		fi
	fi
done

