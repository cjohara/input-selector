#!/usr/bin/env bash

# This is a wrapper for ddc/ci cli tools that supports switching multiple display inputs at once.
#
# Prerequisites
#   ddcctl (https://github.com/kfix/ddcctl)
#   m1ddc (https://github.com/waydabber/m1ddc)
#
# Usage
#   ./ddc.sh <DISPLAY_NUMBER:INPUT_SOURCE>...
#
# So to switch display 1 to DP1, display 2 to HDMI2, and display 3 to USB-C
#   ./ddc.sh 1:15 2:17 3:27


# Ensure dependency library paths are available
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# TODO: detect apple silicon (https://stackoverflow.com/questions/65259300/detect-apple-silicon-from-command-line)
# and use m1ddc (https://github.com/waydabber/m1ddc) in that case.
if (command -v ddcctl)&>/dev/null; then
	COMMAND_ARGS=("$@")

	for ARG in "${COMMAND_ARGS[@]}"; do
		DISPLAY_NUMBER=${ARG%%:*}
		INPUT_SOURCE=${ARG#*:}

		ddcctl -d $DISPLAY_NUMBER -i $INPUT_SOURCE&>/dev/null
	done
else
	echo "ddcctl isn't installed, please install"
fi
