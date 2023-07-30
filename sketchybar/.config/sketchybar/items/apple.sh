#!/bin/bash

POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

apple_logo=(
	icon=$APPLE
	icon.font="$FONT:Black:16.0"
	icon.color=$GREEN
	padding_right=15
	label.drawing=off
	click_script="$POPUP_CLICK_SCRIPT"
	popup.height=35
)

apple_prefs=(
	icon=$PREFERENCES
	label="Preferences"
	click_script="open -a 'System Preferences'; $POPUP_OFF"
)

apple_activity=(
	icon=$ACTIVITY
	label="Activity"
	click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
	icon=$LOCK
	label="Lock Screen"
	click_script="pmset displaysleepnow; $POPUP_OFF"
)

apple_logout=(
	icon=$LOGOUT
	icon.padding_left=7
	label="Logout"
	background.color=0x00000000
	background.height=30
	background.drawing=on
	click_script="osascript -e 'tell application \
              \"System Events\" to keystroke \"q\" \
                using {command down,shift down}';
                $POPUP_OFF"
)

apple_sleep=(
	icon=$SLEEP
	icon.padding_left=5
	background.color=0x00000000
	background.height=30
	background.drawing=on
	label="Sleep"
	click_script="osascript -e 'tell app \"System Events\" to sleep'; $POPUP_OFF"
)

sketchybar --add item apple.logo left \
	--set apple.logo "${apple_logo[@]}" \
	\
	--add item apple.prefs popup.apple.logo \
	--set apple.prefs "${apple_prefs[@]}" \
	\
	--add item apple.activity popup.apple.logo \
	--set apple.activity "${apple_activity[@]}" \
	\
	--add item apple.sleep popup.apple.logo \
	--set apple.sleep "${apple_sleep[@]}" \
	\
	--add item apple.lock popup.apple.logo \
	--set apple.lock "${apple_lock[@]}" \
	\
	--add item apple.logout popup.apple.logo \
	--set apple.logout "${apple_logout[@]}"
