#!/system/bin/sh

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

# ------------------------------------------------------------------
# Configure Patch
# ------------------------------------------------------------------
ZRAM_DEVICE="/dev/block/zram0"
ZRAM_SYSFS="/sys/block/zram0"

# ------------------------------------------------------------------
# Configure Props
# ------------------------------------------------------------------
PROP_NANDSWAP_SWITCH="persist.sys.oplus.nandswap"  # Master enable/disable switch
PROP_SWAPSIZE="persist.sys.oplus.nandswap.swapsize"  # User-selected swap size
PROP_ERROR_CODE_STORAGE="persist.sys.oplus.nandswap.err"  # Stores error codes
PROP_ZRAM_STATUS="persist.sys.oplus.nandswap.condition"  # ZRAM initialization status

# ------------------------------------------------------------------
# Configuration Parameters
# ------------------------------------------------------------------
COMP_ALGORITHM="lz4"  # Compression algorithm for ZRAM
LOG_TAG="NANDSWAP"    # Tag for system logs

# ------------------------------------------------------------------
# Error Codes
# ------------------------------------------------------------------
# 1005: Failed to set disksize (disksize file not found)
# 1006: Failed to mkswap on $ZRAM_DEVICE
# 1007: Failed to swapon $ZRAM_DEVICE

# ------------------------------------------------------------------
# Logging Function (also outputs to logcat for debugging)
# ------------------------------------------------------------------
function log_kmsg() {
    # Writes messages to kernel log and Android system log
    echo "<6>$LOG_TAG: $1" > /dev/kmsg  # Kernel ring buffer (priority 6 = info)
    log -p i -t "$LOG_TAG" "$1" 2>/dev/null || true  # Android logcat (priority i = info)
}

# ------------------------------------------------------------------
# Sets error code property and marks ZRAM status as true (indicating completion with error)
# ------------------------------------------------------------------
function set_error()
{
    setprop $PROP_ERROR_CODE_STORAGE $1  # Store error code
    setprop $PROP_ZRAM_STATUS true       # Mark initialization as complete
}

# ------------------------------------------------------------------
# Configures ZRAM device parameters
# ------------------------------------------------------------------
function zram_configuration()
{
    log_kmsg "Setting compression algorithm: $COMP_ALGORITHM"
    echo $COMP_ALGORITHM > $ZRAM_SYSFS/comp_algorithm  # Set compression algorithm
    
    # Verify disksize interface exists
    if [ -f $ZRAM_SYSFS/disksize ]; then
        # Determine swap size based on system property
        if [[ "$(getprop "$PROP_SWAPSIZE")" == "4" ]]; then
            SWAP_SIZE=4096
        elif [[ "$(getprop "$PROP_SWAPSIZE")" == "6" ]]; then
            SWAP_SIZE=6144
        elif [[ "$(getprop "$PROP_SWAPSIZE")" == "8" ]]; then
            SWAP_SIZE=8192
        elif [[ "$(getprop "$PROP_SWAPSIZE")" == "12" ]]; then
            SWAP_SIZE=12288
        elif [[ "$(getprop "$PROP_SWAPSIZE")" == "16" ]]; then
            SWAP_SIZE=16384
        else
            SWAP_SIZE=4096  # Default to 4GB if no valid size
        fi
        
        log_kmsg "Swap size: ${SWAP_SIZE} MB (prop: $(getprop "$PROP_SWAPSIZE"))"
        echo "${SWAP_SIZE}M" > $ZRAM_SYSFS/disksize  # Set disk size
    else
        set_error 1005  # disksize interface missing
    fi
}

# ------------------------------------------------------------------
# Initializes and activates swap space on ZRAM device
# ------------------------------------------------------------------
function initial_swap()
{
    log_kmsg "Enabling ZRAM swap on $ZRAM_DEVICE"
    if ! mkswap $ZRAM_DEVICE; then  # Format as swap space
        set_error 1006  # mkswap failed
    fi
    
    log_kmsg "Activating ZRAM swap on $ZRAM_DEVICE"
    if ! swapon $ZRAM_DEVICE; then  # Enable swap device
        set_error 1007  # swapon failed
    fi
    log_kmsg "ZRAM swap activated successfully"
}

# ------------------------------------------------------------------
# Main execution flow
# ------------------------------------------------------------------
function main()
{
    # Check if ZRAM feature is enabled in system properties
    if [ "$(getprop $PROP_NANDSWAP_SWITCH)" == "true" ]; then
        log_kmsg "Starting ZRAM configuration"
        zram_configuration   # Configure ZRAM parameters
        initial_swap        # Initialize and activate swap
        log_kmsg "ZRAM configuration completed"
    else
        log_kmsg "ZRAM swap disabled by system property"
    fi
}

# ------------------------------------------------------------------
# Entry point - execute main function
# ------------------------------------------------------------------
main