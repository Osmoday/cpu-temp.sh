#!/bin/bash

tempQueue=()
declare -i queueIndex=0
declare -i readLen=0

for f in /sys/class/hwmon/hwmon2/temp*_input ; do
    readLen=$readLen+1
done

while true 
do
    sleep 2
    if [ $queueIndex -ge 3150 ]; then
        queueIndex=0
    fi
#     echo "${#tempQueue[@]}"
    for f in /sys/class/hwmon/hwmon2/temp*_input ; do
        tempQueue[$queueIndex]="$(cat $f)"
#         echo "Check: "${tempQueue[$queueIndex]}
        queueIndex=$queueIndex+1
    done
    declare -i sum=$(IFS=+; echo "$((${tempQueue[*]}))")
    declare -i avgTemp=$sum/${#tempQueue[@]}
    printf "\033c"
    clear && echo -en "\e[3J"
    echo "Average cpu temperature: "${avgTemp:0:2}"."${avgTemp:2:3}
done
