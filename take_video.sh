#!/bin/bash
# prevent rpicam-vid from running concurrently
lock="fetch.lock"
while [ -f "$lock" ]
do
  echo "Another instance of $0 is running, waiting 5 seconds..."
  sleep 5
done
touch $lock
trap "rm $lock" EXIT # if the script ends for any reason, remove lock

# write video
curr_time=$(date +"%FT%T")
rpicam-vid -t 600000 --width 1920 --height 1080 --save-pts ${curr_time}_pts.txt -o ${curr_time}_raw.h264
mv ${curr_time}_pts.txt ${curr_time}_raw.h264 CompleteVideos
rm $lock

# convert to .mkv, clean up, and send to server
cd CompleteVideos
if [ -z "$SSH_AUTH_SOCK" ]
then
  export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
fi
mkvmerge -o ${curr_time}.mkv --timecodes 0:${curr_time}_pts.txt ${curr_time}_raw.h264
rm ${curr_time}_pts.txt && rm ${curr_time}_raw.h264
rsync --progress --remove-source-files ./${curr_time}.mkv pi@<pi_camera_ip>:/media/pi/c64ba661-973c-419d-a700-b42681257bd4
