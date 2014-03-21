#!/bin/bash

# script to recursively tag these files as from waffles.fm

USAGE="id3-setwaffles.sh path"

if [ $# -ne 1 ]; then
	echo $USAGE
	exit
fi

if [ -f "$1" ]; then
	eyeD3 --set-url-frame="WOAF:http://waffles.fm" "$FILENAME"
elif [ -d "$1" ]; then
	IFS="$(echo -en "\n\r")"
	for FILENAME in $(find "$1" -iname "*.mp3")
	do
		eyeD3 --set-url-frame="WOAF:http://waffles.fm" "$FILENAME"
	done
fi

