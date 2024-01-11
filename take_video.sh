#!/bin/bash
# prevent rpicam-vid command from overlapping 
LOCK="fetch.lock"
while [ -f "$LOCK" ]
do
  echo "Another instance of $0 is running, waiting 5 seconds..."
  sleep 5
done
touch $LOCK 
trap "rm $LOCK" EXIT # if the script ends for any reason, remove lock

# write video
current_time=$(date +"%FT%T")
rpicam-vid -t 600000 --width 1920 --height 1080 --save-pts ${current_time}_pts.txt -o ${current_time}_raw.h264

# convert to .mkv, then clean up
mkvmerge -o $current_time.mkv --timecodes 0:${current_time}_pts.txt ${current_time}_raw.h264
rm ${current_time}_pts.txt && rm ${current_time}_raw.h264

