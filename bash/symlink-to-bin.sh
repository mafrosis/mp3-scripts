#! /bin/bash

PWD=$(pwd)
IFS="$(echo -en "\n\r")"

for FILENAME in $(find . -maxdepth 1 -name "*.sh" -printf "%f\n")
do
	if [ "$FILENAME" != "symlink-to-bin.sh" ]; then
		ln -fs -t "$HOME/bin" "$FILENAME" "$PWD/$FILENAME"
	fi
done
