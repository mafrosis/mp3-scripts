#!/bin/bash

usage="id3-autotag.sh [-c compilation] [-f force] [-e eac] [filename]"

# script to auto tag mp3's from filename

MODE="album"
FORCE=0
EAC=0

while getopts "cfe" options
do
	case $options in
		c ) MODE="compilation";;
		f ) FORCE=1;;
		e ) EAC=1;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done
shift $((OPTIND-1))

# first extract the current directory name
PWD=$(pwd)
DIR=$(basename "$PWD")

echo $DIR

ARTIST=${DIR%% - *}
ALBUMARTIST=$ARTIST
YEAR=${DIR#* - }
YEAR=${YEAR%% - *}
ALBUM=${DIR##* - }

# clean (Disc 1) etc from album
if [ ! -z "$(echo "$ALBUM" | grep "(Disc ")" ]; then
	ALBUM=${ALBUM%% (*}
fi

# get total track count
TTRCK=$(find "$(pwd)" -iname "*.mp3" | wc -l)

GENRE_LIST=$(eyeD3 --list-genres)
IMAGE_LIST=$(eyeD3 --list-image-types)


function tag {
	NAME=${1##*/}
	TRCK=${NAME%% - *}

	# extract track num and title from each file
	if [ $MODE == "compilation" ]
	then
		ARTIST=${1% - *}
		ARTIST=${ARTIST##* - }
		TITLE=${NAME##* - }
		TITLE=${TITLE%.*}
	else
		TITLE=${NAME##* - }
		TITLE=${TITLE%.*}
	fi


	# attempt to extract the genre
	GENRE=$(eyeD3 "$1" | awk '/genre/ {print $4}')
	if [ -z "$GENRE" ]; then
		GENRE=$(eyeD3 "$1" | awk '/genre/ {print $3}')	# pos 3, if no track num set
	fi

	# validate genre
	if [ ! -z "$GENRE" ]; then
		GENRE_EXISTS=$(echo $GENRE_LIST | grep " $GENRE ")
		if [ -z "$GENRE_EXISTS" ]; then
			GENRE=""
		fi
	fi

	
	ADDIMAGE=0

	# process folder.jpg images
	if [ -f "$(pwd)/folder.jpg" ]; then
		# extract an existing image
		eyeD3 --write-images="$(pwd)" "$1"
		IMG_NAME=$(find . -name "FRONT_COVER*" -printf "%f")
		
		if [ ! -z "$IMG_NAME" ]; then
			EXI_HEIGHT=$(identify -format "%h" "$IMG_NAME")
			NEW_HEIGHT=$(identify -format "%h" "$(pwd)/folder.jpg")
		
			# compare folder.jpg to FRONT_COVER
			if [ $EXI_HEIGHT -lt $NEW_HEIGHT ]; then
				ADDIMAGE=1
			elif [ $EXI_HEIGHT -gt $NEW_HEIGHT ]; then
				mv "folder.jpg" "folder.bak.jpg"
				mv "$IMG_NAME" "folder.jpg"
			fi
			rm "$IMG_NAME"
		else
			ADDIMAGE=1
		fi
	else
		# attempt extract existing image into folder.jpg
		IMG_SIZE=$(eyeD3 "$1" | awk '/^FRONT_COVER/ {print $4}')
		if [ ! -z "$IMG_SIZE" ]; then
			eyeD3 --write-images="$(pwd)" "$1"
			IMG_NAME=$(find . -name "FRONT_COVER*" -printf "%f")
			if [ ! -z "$IMG_NAME" ]; then
				mv "$IMG_NAME" "folder.jpg"
			else
				rm -f "*.jpg"
			fi
		fi
	fi


	# force removal of existing tag
	if [ $FORCE -eq 1 ]; then
		eyeD3 --remove-all "$1"
	else
		# check if the tag is broken
		ERR=$(eyeD3 "$1" 2>&1 | grep ascii)
		if [ ! -z "$ERR" ]; then
			# remove the existing tag completely
			eyeD3 --remove-all "$1"
		fi
	fi

	# only change year on an album
	if [ $MODE == "compilation" ]
	then
		eyeD3 --to-v2.4 "$1"
		eyeD3 --set-encoding=utf8 -a "$ARTIST" -A "$ALBUM" -t "$TITLE" -n "$TRCK" -N "$TTRCK" -G "$GENRE" --set-text-frame="TPE2:$ALBUMARTIST" --set-text-frame="TCMP:1" --no-tagging-time-frame "$1"
	else
		eyeD3 --to-v2.4 "$1"
		eyeD3 --set-encoding=utf8 -a "$ARTIST" -A "$ALBUM" -t "$TITLE" -n "$TRCK" -N "$TTRCK" -Y "$YEAR" -G "$GENRE" --set-text-frame="TPE2:$ALBUMARTIST" --no-tagging-time-frame "$1"
	fi

	# set Ripping Tool user text frame to EAC
	if [ $EAC -eq 1 ]; then
		eyeD3 --set-user-text-frame="Ripping Tool":"EAC" "$1"
	fi

	# inject an image if available
	if [ $ADDIMAGE -eq 1 ]; then
		eyeD3 --add-image="folder.jpg":"FRONT_COVER" "$1"
	fi
}


if [ -f "$1" ]; then
	tag "$1"
else
	IFS="$(echo -en "\n\r")"

	for FILENAME in $(find "$PWD" -maxdepth 1 -iname "*.mp3")
	do
		tag "$FILENAME"
	done
fi

