# Server-side code
This script copies `.mkv` footage from the Pi and deletes it from the Pi once copied over.

**get_video.sh**
```bash
#!/bin/bash
if [ -z "$SSH_AUTH_SOCK" ]
then
  export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
fi
rsync --progress --remove-source-files -u pi@<remote_ip>:~/PorchFootage/*.mkv .
```

**cron**
```bash
5 * * * * cd /home/mgraca/Workspace/detecting-baddies && ./get_video.sh > error.txt 2>&1
```
# Client-side code (Pi)
This script tells the Pi to take a one hour video in 1080p along with timestamps. The script then merges the two into one `.mkv` file, then deletes the `.h264` and timestamp file.

**take_video.sh**
```bash
#!/bin/bash
# prevent rpicam-vid commands from overlapping
LOCK="fetch.lock"
while [ -f "$LOCK" ]
do
	echo "Another instance of $0 is running, waiting 5 seconds..."
  sleep 5
done
touch $LOCK  # create lock
trap "rm $LOCK" EXIT # if the script ends for any reason, remove lock

# write video
current_time=$(date +"%FT%T")
rpicam-vid -t 600000 --width 1920 --height 1080 --save-pts ${current_time}_pts.txt -o ${current_time}_raw.h264

# convert to .mkv, then clean up
mkvmerge -o ${current_time}.mkv --timecodes 0:${current_time}_pts.txt ${current_time}_raw.h264
rm ${current_time}_pts.txt && rm ${current_time}_raw.h264
```

**cron**
```bash
0 * * * * cd /home/pi/PorchFootage && ./take_video.sh > error.txt 2>&1
```
