#!/bin/bash

# Called from /etc/rc.local

# Variables
RECORDING_DRIVE="/media/JMUSB3"
SCRIPT_HOME="/home/pi/X18-Recorder"

SOUND_DEVICE="X18XR18" # X18XR18 for X air series, XUSB for X32
TRACKS=18
ROUTER_IP="192.168.18.254"

RECORDING_FOLDER="$RECORDING_DRIVE/XR18"
LOG_FOLDER="$SCRIPT_HOME/logs"
LOGFILE="$LOG_FOLDER/Recording.log"

# Trap the termination of the script by the user or kill command
trap interrupt_or_terminate SIGINT SIGTERM

# Function to run when terminating to stop the recording daemon
interrupt_or_terminate() {
    kill -TERM $RECORD_PID 2>&1 > /dev/null
    exit
}

# Create logging folder if it doesn't exist
# Add empty line to logfile, or create logfile if it doesn't exist
[ -d "$LOG_FOLDER" ] || mkdir $LOG_FOLDER
echo >> $LOGFILE
echo Starting system >> $LOGFILE

# Let the system settle down a bit
sleep 60

# Start Recording daemon
# Don't wait for this script to end (the '&' at the end)
$SCRIPT_HOME/Record.sh $RECORDING_FOLDER $SOUND_DEVICE $TRACKS >> $LOGFILE 2>&1 &

# Save the PID of the detached script
RECORD_PID=$!

# Log all process PID's and start with the current date
echo $(date) >> $LOGFILE
echo 'Started Recording deamon:' >> $LOGFILE
echo "Deamon PID: $$" >> $LOGFILE
echo "Record PID: $RECORD_PID" >> $LOGFILE

# Check for router and XR18
TIMEOUT=10
COUNT=0

# Are we consistently on battery?
# If yes, exit the loop (and thus the script) to allow the calling script to clean up and shutdown
# Loop until COUNT is greater than or equal to (-ge) TIMEOUT
until [ $COUNT -ge $TIMEOUT ]
do

    # Look for the router, which isn't backed up
    # Send 1 probe (-c 1) for the router,
    # and timeout after 1 second (-W 1) to keep the script moving
    if ping -c 1 -W 1 $ROUTER_IP > /dev/null 2>&1
    then

        # That network node is present, which means
        # we're not on battery, so reset the count
        COUNT=0

        # we only need to sleep here because ping delays already if not found
        sleep 1

    # Look for XR18, which isn't backed up either
    # use grep to filter the output of arecord -L, returns 0 (true) if found
    elif arecord -L | grep CARD=$SOUND_DEVICE > /dev/null
    then

        # XR18 is present, which means
        # we're not on battery, so reset the count
        COUNT=0

    else

        # Router and XR18 are not present, which means
        # we are on battery, so increment the count
        COUNT=$(($COUNT+1))

    fi
done

# Log time offline
echo "Consistently on battery for $COUNT seconds." >> $LOGFILE

# Terminate running recording
echo 'Shutting down!' >> "$LOGFILE"
kill $RECORD_PID > /dev/null 2>&1

# Wait for encoding to wave files
wait

# "Push the power button"
echo 'Graceful shutdown complete, turning off system' >> $LOGFILE
shutdown -h now >> $LOGFILE
