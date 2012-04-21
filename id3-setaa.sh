#!/bin/bash

# script to recursively set album artist in a directory

USAGE="id3-setaa.sh path [albumartist]"

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
	echo $USAGE
	exit
fi

# store albumartist if supplied
if [ $# -eq 2 ]; then
	AA="$2"
fi

function setaa() {
	# if albumartist not supplied, use the artist field
	if [ -z "$AA" ]; then
		AA=$(eyeD3 "$1" | awk '/artist/ {print $5}')
		echo "Using $AA as AlbumArtist"
	fi
	eyeD3 --set-text-frame="TPE2:$AA" "$1"
}

if [ -f "$1" ]; then
	setaa "$1"
elif [ -d "$1" ]; then
	IFS="$(echo -en "\n\r")"
	for FILENAME in $(find "$1" -iname "*.mp3")
	do
		setaa "$FILENAME"
	done
fi


