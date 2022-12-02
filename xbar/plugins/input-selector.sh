#!/usr/bin/env bash

# <xbar.title>Input Selector</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.dependencies></xbar.dependencies>

EDID_DECODE="/usr/local/sbin/edid-decode"
PLISTBUDDY="/usr/libexec/PlistBuddy -c"
PLIST="/Library/Preferences/com.apple.windowserver.plist"
DDC="$HOME/Repositories/input-selector/shell/ddc.sh"
WAKE_ON_LAN="/usr/local/bin/wakeonlan"
ICON="iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAABYlAAAWJQFJUiTwAAABTklEQVRYhcWXYW3DMBCF36r+XyCUQcdgHoOOQSEUQiCEwcZgFFwGKYNCyBDc9CRn8qxovfhs50mVmsjx+3I+ny9PIoIttQ/eBwBnAK4RiwcwAJgYgROAr42C8E4A0rxuBHAlQJwEN4alsmkH4Ph7JX/lyFP552LHXeW3fSgLAHfNGELaHIDmH2EtvQUiF2CI/psgcgFYsL6LQBgy/kVEpmQXjSLSPXiu2C4YS0SCZ0Hp02iGcJqiVqsOEOJTM7AWAJel1wzkErwZjLrwps+JuQs5ogLwBnNvMV8CuCgfns2P0b3V5jNA3Atot08Rcyo3CWOjbHNqrxizpHO4d7KYWwAQINjM3g1zmOuAyZxKI9CiNT/EF2xKxySjW+q2S5qL1hrmTzMXJdWSuoxmY/rnNLyHEu61zUcv69Vr5t68LdfWAYbsunJu1Rbd9vMcwA9gv4kWfY+BIgAAAABJRU5ErkJggg=="

# Variables
COMMAND_ARGS_INPUT_PC=""
COMMAND_ARGS_INPUT_HUDL=""
COMMAND_ARGS_INPUT_MBP=""

function get_display_information() {
    DISPLAY_SERIAL_NUMBER=$1
    KEY=$2

    NEWLINE=$'\n'
    REGEX_KEY="Display Product Name"
    if [[ $KEY == 'manufacturer' ]]; then
        REGEX_KEY="Manufacturer"
    fi

    REGEX="$REGEX_KEY: [\']*([^\'$NEWLINE]+)"

    for EDID in $(ioreg -lw0 | grep '<00ffffffffffff' | sed -E "/^.*<(.*)>/s//\1/"); do
        DECODED=$($EDID_DECODE <<< $EDID)

        if [[ "$DECODED" =~ "Serial Number: $DISPLAY_SERIAL_NUMBER" ]]; then
            if [[ "$DECODED" =~ $REGEX ]]; then
                echo "${BASH_REMATCH[1]}"
            fi

            break
        fi
    done
}

function create_display_submenus() {
    i=0
    while true ; do
        $PLISTBUDDY "Print :DisplayAnyUserSets:0:$i:DisplayID" $PLIST >/dev/null 2>/dev/null
        if [ $? -ne 0 ]; then
          break
        fi

        DISPLAY_NUMBER=$(($i + 1))
        DISPLAY_ID=$($PLISTBUDDY "Print :DisplayAnyUserSets:0:$i:DisplayID" $PLIST)
        DISPLAY_SERIAL_NUMBER=$($PLISTBUDDY "Print :DisplayAnyUserSets:0:$i:DisplaySerialNumber" $PLIST)
        DISPLAY_NAME=$(get_display_information $DISPLAY_SERIAL_NUMBER name)
        DISPLAY_MANUFACTURER=$(get_display_information $DISPLAY_SERIAL_NUMBER manufacturer)

        INPUT_PC=15
        INPUT_HUDL=16
        INPUT_MBP=6
        if [[ "$DISPLAY_MANUFACTURER" == 'SAM' ]]; then
            INPUT_PC=15
            INPUT_HUDL=5
            INPUT_MBP=6
        fi

        COMMAND_ARGS_INPUT_PC="$COMMAND_ARGS_INPUT_PC param$(($i + 1))='$DISPLAY_NUMBER:$INPUT_PC'"
        COMMAND_ARGS_INPUT_HUDL="$COMMAND_ARGS_INPUT_HUDL param$(($i + 1))='$DISPLAY_NUMBER:$INPUT_HUDL'"
        COMMAND_ARGS_INPUT_MBP="$COMMAND_ARGS_INPUT_MBP param$(($i + 1))='$DISPLAY_NUMBER:$INPUT_MBP'"

        echo "${DISPLAY_NAME}"
        echo "--Gaming PC | shell=${DDC} param1='$DISPLAY_NUMBER:$INPUT_PC' terminal=false refresh=false"
        echo "--Hudl MacBook Pro | shell=${DDC} param1='$DISPLAY_NUMBER:$INPUT_HUDL' terminal=false refresh=false"
        echo "--MacBook Pro | shell=${DDC} param1='$DISPLAY_NUMBER:$INPUT_MBP' terminal=false refresh=false"
        i=$(($i + 1))
    done

    for DISPLAY in ${DISPLAYS[0]}; do
        echo "${DISPLAY[@]}"
    done
}

function create_all_submenu() {
    echo "---"
    echo "All"

    echo "--Gaming PC | shell=${DDC} ${COMMAND_ARGS_INPUT_PC} terminal=false refresh=false"
    echo "--Hudl MacBook Pro | shell=${DDC} ${COMMAND_ARGS_INPUT_HUDL} terminal=false refresh=false"
    echo "--MacBook Pro | shell=${DDC} ${COMMAND_ARGS_INPUT_MBP} terminal=false refresh=false"
}

function create_wake_submenu() {
	echo "---"
	echo "Wake"

	echo "--Gaming PC | shell=${WAKE_ON_LAN} param1='00:D8:61:C5:84:74' terminal=true refresh=false"
}

function create_menu() {
    echo "| image=${ICON}"
    echo "---"

    create_display_submenus
    create_all_submenu
		create_wake_submenu
}

create_menu
