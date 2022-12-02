#!/usr/bin/env bash

# <xbar.title>Input Selector</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.dependencies></xbar.dependencies>

EDID_DECODE="/usr/local/sbin/edid-decode"
PLISTBUDDY="/usr/libexec/PlistBuddy -c"
PLIST="/Library/Preferences/com.apple.windowserver.plist"
DDC="$HOME/Repositories/input-selector/shell/ddc.sh"

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

function create_menu() {
    echo "Displays"
    echo "---"

    create_display_submenus
    create_all_submenu
}

create_menu
