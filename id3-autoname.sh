#!/bin/bash

usage="id3-autoname.sh [-c compilation] [filename]"

# script to name mp3's from tag

MODE="album"

while getopts "c" options
do
	case $options in
		c ) MODE="compilation";;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done
shift $((OPTIND-1))

function rename {
	# handle non-ASCII chars in tag
	NAME=${1##*/}
	ROOT=${1%/*}
	NAME=$(handleUTF8 "$NAME")

	if [ $MODE == "album" ]; then
		eyeD3 --rename="%n - %t" --fs-encoding=utf8 "$ROOT/$NAME"
	else
		eyeD3 --rename="%n - %A - %t" --fs-encoding=utf8 "$ROOT/$NAME"
	fi
}	

function handleUTF8 {
	IFS=" "

	# iterate octal for all chars in string
	for C in $(echo "$1" | hexdump -b)
	do
		ISNUM=$(isnum $C)
		# if it's outside ascii, chuck one
		if [ $ISNUM -eq 1 ] && [ $C -gt 177 ]; then
			echo "The filename '$1' contains non-ASCII characters. Continue, transliterate, abort? [c/t/a]\n" >&2
			read y
			if [ "$y" = "c" ]; then
				OUT="$1"
				break
			elif [ "$y" = "t" ]; then
				OUT="$(echo "$1" | iconv -f utf-8 -t ascii//translit)"
				break
			else
				exit 1
			fi
		else
			OUT="$1"
		fi
	done

	# return input if all's fine
	echo "$OUT"
	IFS="$(echo -en "\n\r")"
}

function isnum() {
	if expr $1 + 1 &> /dev/null ; then
		echo 1
	else
		echo 0
	fi
}


if [ -f "$1" ]; then
	rename "$1"
else
	# set Input Field Separator to newline
	IFS="$(echo -en "\n\r")"

	for FILENAME in $(find "$(pwd)" -maxdepth 1 -iname "*.mp3")
	do
		rename "$FILENAME"
	done
fi

