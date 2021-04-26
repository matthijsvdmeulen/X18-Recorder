#!/bin/bash

# Script to extract individual .wav files from the giant block of raw data

# Assign passed arguments to variables
RAW_INPUT_FILE=$1
DECODED_OUTPUT_FOLDER=$2

echo 'Creating individual wave files'

# Assign channel variable to given number of tracks (look this up in your Autorecord.sh)
TRACKS=18
CHANNEL=$TRACKS

# loop through all tracks and export them using sox
for (( i=1; i<=$TRACKS; i++ ))
do
    FILENAME="track$i.wav"
    sox --type raw --bits 32 --channels $TRACKS --encoding signed-integer --rate 48000 --endian little $RAW_INPUT_FILE "$DECODED_OUTPUT_FOLDER/$FILENAME" remix $i
    echo "$FILENAME done!"
done
echo 'All files created'
