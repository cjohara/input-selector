#!/usr/bin/env bash

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
