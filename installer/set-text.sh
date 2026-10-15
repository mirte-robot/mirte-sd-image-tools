#!/bin/bash

TEXT=$1
# write text to /root/text.txt
echo "$TEXT" >/root/text.txt

# start mirte_screen_arm64 if it is not running
if ! pgrep -f mirte_screen_arm64; then
	# start mirte_screen_arm64 in background with text.txt as input and refresh rate of 1 second
	/root/mirte_screen_arm64 -f /root/text.txt -t 1 &
fi
