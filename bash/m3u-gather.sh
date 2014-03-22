#!/bin/bash

usage="m3u-gather.sh [-d mp3-directory] [-p m3u-playlist] [-o output-path]"

# script to gather all MP3s in an M3U playlist

OUTPATH="$(pwd)"

while getopts "d:p:o:" options
do
	case $options in
		d ) MP3PATH="$OPTARG";;
		p ) M3UPATH="$OPTARG";;
		o ) OUTPATH="$OPTARG";;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

# find MP3 collection base directory
if [ -z "$MP3PATH" ] && [ -z "$MUSIC_DIR" ]; then
	echo "You must define a MUSIC_DIR env var, or supply the -d parameter"
	exit 1
elif [ ! -z "$MUSIC_DIR" ]; then
	MP3PATH=$MUSIC_DIR
fi

echo "Will copy MP3s from $MP3PATH"

# use current directory if no M3U supplied
PWD=$(pwd)
if [ -z "$M3UPATH" ]; then
	M3UPATH=$PWD
fi

# attempt to find an M3U
if [ -d "$M3UPATH" ]; then
	echo "Searching for m3u in $M3UPATH"

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

# check M3U exists if supplied
if [ ! -f "$M3UPATH" ]; then
	echo "M3U not found"
	exit
fi

echo "Using $M3UPATH"

# create output directory if required
if [ "$PWD" != "$OUTPATH" ] && [ ! -d "$OUTPATH" ]; then
	mkdir "$OUTPATH"
fi

# copy all MP3s from playlist into output dir
for FILENAME in $(cat "$M3UPATH")
do
	if [ -f "$MP3PATH/$FILENAME" ]; then
		echo "Gathering $(basename "$FILENAME").."
		cp "$MP3PATH/$FILENAME" "$OUTPATH"
	else
		echo "MISSING: $(basename $FILENAME)"
	fi
done

# create a new playlist
m3u-create.sh "$OUTPATH"

