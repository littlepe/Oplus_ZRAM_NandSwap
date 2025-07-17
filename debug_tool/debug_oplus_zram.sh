#!/usr/bin/bash

# Oplus_ZRAM_NandSwap - Android NAND Swap Partition Management Tool
# Copyright (C) 2025  littlepe
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Contact: GitHub @littlepe | [Project Homepage](https://github.com/littlepe/Oplus_ZRAM_NandSwap)

# Property name used to store the latest error code reported by Oplus NAND swap
PROP_ERROR_CODE_STORAGE="persist.sys.oplus.nandswap.err"
# Path to the zram block device we are debugging
ZRAM_DEVICE="/dev/block/zram0"

# Make sure the 'adb' command is available in the current environment
if ! command -v adb >/dev/null 2>&1; then
    echo "Adb command not found"
    exit 1
fi

# Display currently connected ADB devices
echo "Checking ADB devices..."
ADB_DEVICES=$(adb devices | awk 'NR>1 {print $1}')
if [ -z "$ADB_DEVICES" ]; then
    echo "Connected ADB devices not found, make sure :"
    echo "•   USB debugging is turned on on the phone"
    echo "•   RSA fingerprint of the current computer has been authorized"
    echo "•   Cable/wireless connection is normal"
    exit 1
fi

clear
echo "Detected ADB devices: $ADB_DEVICES"
echo " "
echo "Debug Oplus Zram"
echo "[1] View related logs"
echo "[2] See Error Codes and Their Meanings"

# Ask the user to choose an action
read -p "Select Action: " options

case $options in
    1)
        # Stream logcat in real-time and filter lines containing 'NANDSWAP' (case-insensitive)
        echo "Grabbing logcat (Ctrl C to exit)..."
        adb logcat | grep -i "NANDSWAP"
        ;;
    2)
        # Retrieve the last error code stored in the system property
        ERROR_CODE=$(adb shell getprop "$PROP_ERROR_CODE_STORAGE")
        echo "Error codes: $ERROR_CODE"

        # Map known numeric error codes to human-readable messages
        case "$ERROR_CODE" in
            1005) echo "1005: Failed to set disksize (disksize file not found)" ;;
            1006) echo "1006: Failed to mkswap on $ZRAM_DEVICE" ;;
            1007) echo "1007: Failed to swapon $ZRAM_DEVICE" ;;
            "")   echo "Error code not read (error may not have occurred yet or the attribute does not exist)" ;;
            *)    echo "Undefined error codes: $ERROR_CODE" ;;
        esac
        ;;
    *)
        echo "Typing error"
        exit 1
        ;;
esac