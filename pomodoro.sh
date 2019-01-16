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

function iteration {
        echo "icon:player_play" >&3
        notify-send --icon=player_play 'Pomodoro' 'Work Hard!'
        ffplay -nodisp -autoexit ./sounds/work.wav >/dev/null 2>&1 &
        $(countdown 3 $WORK_TIME "Work Hard!")

        echo "icon:player_stop" >&3
        notify-send --icon=player_stop 'Pomodoro' 'Time Break!'
        ffplay -nodisp -autoexit -volume 30 ./sounds/break.wav >/dev/null 2>&1 &
        $(countdown 3 $BREAK_TIME "Time Break!")
}

while true; do
    for i in {1..3};
    do
        iteration
    done
    BREAK_TIME=1800
    iteration
    BREAK_TIME=300
done
