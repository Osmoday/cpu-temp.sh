#!/bin/bash

declare -a tempQueue=()
declare -i queueIndex=0
declare -i OPERATIONS_PER_CYCLE=0
declare -i TIME_FRAME=15
declare -i CUTOFF=3150
declare -i UPDATE_PERIOD=2

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -tf|--time-frame)
#     if [[ $2 =~  ]]   
#     TIME_FRAME="$(($2*$((420/$UPDATE_PERIOD))))"
    TIME_FRAME=$2
    shift # past argument
    shift # past value
    ;;
    -up|--update-period)
    UPDATE_PERIOD="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

for f in /sys/class/hwmon/hwmon2/temp*_input ; do
    OPERATIONS_PER_CYCLE=$OPERATIONS_PER_CYCLE+1
done

NUMERATOR_READS_PER_MINUTE=$((60*$OPERATIONS_PER_CYCLE))
CUTOFF=$(($TIME_FRAME*$NUMERATOR_READS_PER_MINUTE/$UPDATE_PERIOD))

while true 
do
    if [ $queueIndex -ge $CUTOFF ]; then
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
#     echo "Time frame: "$(($CUTOFF*$UPDATE_PERIOD/$NUMERATOR_READS_PER_MINUTE))" minutes"
    echo "Time frame: "$TIME_FRAME" minutes"
    echo "Average cpu temperature: "${avgTemp:0:2}"."${avgTemp:2:3}"°C"
    sleep $UPDATE_PERIOD
done
