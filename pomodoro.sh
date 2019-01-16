#!/bin/bash
WORK_TIME=$((SECONDS+1500))
BREAK_TIME=300

# create fifo pipe
PIPE=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
mkfifo $PIPE

# attach a filedescriptor to this pipe
exec 3<> $PIPE

# add handler to manage process shutdown
function on_exit() {
    echo "quit" >&3
    rm -f $PIPE
}
trap on_exit EXIT

# run yad and tell it to read its stdin from the file descriptor
yad --notification --kill-parent --listen \
    --image="player_play" --text="Init"  <&3 &

function countdown {
    LIFE_TIME=$(expr $SECONDS + $2)

    while [ $SECONDS -lt $LIFE_TIME ];
    do
        TIME_LEFT=$(date -d@$(expr $LIFE_TIME - $SECONDS) -u +%H:%M:%S)
        echo "tooltip:$3\nTime left: $TIME_LEFT" >&$1
        sleep 1
    done
}

while true; do
    echo "icon:player_play" >&3
    $(countdown 3 $WORK_TIME "Work Hard!")
    echo "icon:player_stop" >&3
    $(countdown 3 $BREAK_TIME "Time Break!")
done
