#!/bin/bash

# script to recursively set genre

USAGE="id3-setgenre.sh genre path"

if [ $# -ne 2 ]; then
	echo $USAGE
	exit 1
fi

GENRE_LIST=$(eyeD3 --list-genres)
	
# validate genre
GENRE_EXISTS=$(echo $GENRE_LIST | grep " $1 ")
if [ -z "$GENRE_EXISTS" ]; then
	echo "Invalid genre"
	exit 2
fi

if [ -f "$2" ]; then
	eyeD3 --genre="$GENRE" "$2"
elif [ -d "$2" ]; then
	IFS="$(echo -en "\n\r")"
	for FILENAME in $(find "$2" -iname "*.mp3")
	do
		eyeD3 --genre="$1" "$FILENAME"
	done
fi
