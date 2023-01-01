#!/bin/bash

WINDOW=$(wmctrl -l | grep Minecraft | cut -d ' ' -f 1)

XOFFSET=110
YOFFSET=40


while true; do
	rm /tmp/minecraft*.png
	echo get minecraft\'s geometry
	GEOMETRY=$(xdotool getwindowgeometry $WINDOW)
	POS=$(echo $GEOMETRY | cut -d ' ' -f 4)
	X=$(echo $POS | cut -d, -f1)
	Y=$(echo $POS | cut -d, -f2)
	SIZE=$(echo $GEOMETRY | rev | cut -d ' ' -f 1 | rev)
	W=$(echo $SIZE | cut -dx -f1)
	H=$(echo $SIZE | cut -dx -f2)
	CX=$(( X+(W/2) ))
	CY=$(( Y+(H/2) ))
	echo $GEOMETRY
	HAS=""
	for ENCH_INDEX in {2..3}; do
		rm /tmp/minecraft*.png
		echo "move the mouse into place"
		xdotool mousemove $(( $CX-110 )) $(( $CY - YOFFSET*ENCH_INDEX ))
		sleep 0.3s
		echo take a screenshot of minecraft
		scrot -a $X,$Y,$W,$H /tmp/minecraft.png
		echo make the screenshot textish
		convert -threshold 50% /tmp/minecraft.png /tmp/minecraft.png
		convert /tmp/minecraft.png -channel RGB -negate /tmp/minecraft.png
		echo running ocr on the screenshot
		TEXT=$(tesseract --oem 1 -l eng /tmp/minecraft.png - | sed s/ﬁ/A/g)
		HAS="$HAS\n$TEXT"
	done
	echo $HAS
	echo "checking against goals"
	cat ./goals.txt | while read GOAL; do
		if echo $HAS | grep -i "$GOAL"; then
			curl -d "Found $GOAL!" ntfy.sh/willow-funky-minecraft-ocr-boy
			exit 0
		fi
	done
	echo "resetting villager"
	xdotool mousemove $CX $(( Y + H - 30 ))
	xdotool click 1
	xdotool key Escape
	sleep 0.5s
	for i in {0..40}; do
	xdotool mousemove_relative 0 10
	sleep 0.1s
	done
	xdotool mousedown 1
	sleep 5s
	xdotool mouseup 1
	sleep 1s
	xdotool keydown w
	sleep 0.2s
	xdotool keyup w
	sleep 0.2s
	xdotool keydown s
	sleep 1s
	xdotool keyup s
	sleep 1s
	xdotool click 3
	for i in {0..39}; do
	xdotool mousemove_relative 0 -10
	sleep 0.1s
	done
	sleep 2s
	xdotool click 3
done

