#! /bin/bash

PWD=$(pwd)
IFS="$(echo -en "\n\r")"

for FILENAME in $(find . -maxdepth 1 -name "*.sh" -printf "%f\n")
do
	ln -fs -t "$HOME/bin" "$FILENAME" "$PWD/$FILENAME"
done
