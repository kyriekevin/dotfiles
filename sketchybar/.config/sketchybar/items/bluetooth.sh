BLUETOOTH_CLICK_SCRIPT="open /System/Library/PreferencePanes/Bluetooth.prefPane"

sketchybar --add item bluetooth right \
	--set bluetooth update_freq=10 \
	icon= \
	icon.padding_left=4 \
	icon.padding_right=4 \
	icon.color=0xff7aa2f7 \
	label.font.family="$ICON_FONT_FAMILY" \
	label.font.style=$ICON_FONT_STYLE \
	label.font.size=$ICON_FONT_SIZE \
	label.color=0xff7aa2f7 \
	background.color=$BACKGROUND_COLOR \
	background.height=$BACKGROUND_HEIGHT \
	background.corner_radius=$BACKGROUND_CORNER_RADIUS \
	background.padding_right=3 \
	script="$PLUGIN_DIR/bluetooth.sh" \
	click_script="$BLUETOOTH_CLICK_SCRIPT"
