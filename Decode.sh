RAW_INPUT_FILE = $1
DECODED_OUTPUT_FOLDER = $2

echo 'Creating individual wave files'
CHANNEL=$TRACKS
while [ "$CHANNEL" -ge 1 ]
do
    FILENAME="track$CHANNEL.wav"
    sox --type raw --bits 32 --channels $TRACKS --encoding signed-integer --rate 48000 --endian little $RAW_INPUT_FILE "$DECODED_OUTPUT_FOLDER/$FILENAME" remix $CHANNEL
    echo "$FILENAME done!"
    CHANNEL=$(($CHANNEL - 1))
done
echo 'All files created'