#! /bin/bash

PLUGIN_DIR="$HOME/.eyeD3/plugins"

# ensure eye3D plugin directory exists
if [ ! -d $PLUGIN_DIR ]; then
	echo "Creating ~/.eyeD3/plugins directory"
	mkdir -p $PLUGIN_DIR
fi

# iterate plugins, symlinking them
for FILENAME in $(find "$(pwd)/plugins" -name "*.py"); do
	NAME=${FILENAME##*/}
	if [ -f "$PLUGIN_DIR/$NAME" ]; then
		echo "Removing existing symlink $NAME"
		rm "$PLUGIN_DIR/$NAME"
	fi
	ln -s "$FILENAME" $PLUGIN_DIR
done
