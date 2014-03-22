#!/bin/bash

# script to recursively set EAC as ripping tool

USAGE="id3-seteac.sh path"

if [ $# -ne 1 ]; then
	echo $USAGE
	exit
fi

if [ -f "$1" ]; then
	eyeD3 --set-user-text-frame="Ripping Tool":"EAC" "$1"
elif [ -d "$1" ]; then
	IFS="$(echo -en "\n\r")"
	for FILENAME in $(find "$1" -iname "*.mp3")
	do
		eyeD3 --set-user-text-frame="Ripping Tool:EAC" "$FILENAME"
	done
fi

