#!/bin/bash
PUNCHSIZE=10000 #lines
THRESHOLD=20000 # only punch a hole when file is larger than this many lines
PUNCHFILE=/mnt/ramdisk/logfile # this is the file to punch holes in
STATEFILE=/mnt/ramdisk/punched #this records where the hole punching is up to
while true
do
    LINES="`wc -l $PUNCHFILE | cut -d' ' -f1`"
    if [ "$LINES" -gt "$THRESHOLD" ];
    then
        # we'd rather not cut a file in half
        BYTES=`dd if=$PUNCHFILE of=/dev/stdout | head -n $PUNCHSIZE | wc -c`
        PUNCHED=`cat $STATEFILE`
        if [ -z "$PUNCHED" ]
        then
            PUNCHED=0
        fi
        echo "Punching hole in log file (lines $LINES) at $PUNCHED for $BYTES bytes"
        TOTAL=`echo $PUNCHED + $BYTES | bc`
        fallocate -p -o 0 -l $TOTAL $PUNCHFILE
        echo $TOTAL > $STATEFILE
    else
        echo "Sleeping as there are only $LINES lines at the moment (lt $THRESHOLD)"
        sleep 1
    fi
done
