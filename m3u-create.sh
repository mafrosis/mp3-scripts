#!/bin/bash

usage="m3u-create [-o overwrite] path"

# script to create an M3U playlist of all MP3s in a directory

OVERWRITE=0

while getopts "o" options
do
	case $options in
		o ) OVERWRITE=1;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done

# first extract the current directory name
PWD=$(pwd)
DIR=${PWD##*/}

echo $DIR

# check existing
EXISTS=$(ls | grep m3u)
if [ ! -z "$EXISTS" ] && [ $OVERWRITE -eq 0 ]
then
	echo "Playlist already exists. Do you want to overwrite? [y/N]"
	read OK
	if [ "$OK" == "y" ]; then
		rm *.m3u
	else
		exit
	fi
fi

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $PWD -maxdepth 1 -name "*.mp3" | sort -n)
do
	NAME=${FILENAME##*/}
	echo "$NAME" >> "$DIR.m3u"
done

echo "Created $DIR.m3u"
