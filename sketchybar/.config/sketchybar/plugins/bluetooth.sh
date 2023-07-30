#!/bin/sh

STATE=$(blueutil -p)
if [ $STATE = 0 ]; then
	LABEL=
else
	LABEL=
fi

sketchybar --set $NAME label="$LABEL"
