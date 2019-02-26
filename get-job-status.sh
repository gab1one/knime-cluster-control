#! /bin/bash

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# arguments
JOB_ID=0
OUT_FILE=""

while getopts ":j:o:" opt; do
    case "$opt" in
    \?)
        echo "Usage: -j job id -o outputfile"
        exit 1
        ;;
    j)  JOB_ID=$OPTARG
        ;;
    o)  OUT_FILE=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

if [ $JOB_ID -lt 1 ]; then
    echo "Illegal argument: Need to specify a valid job id!"
    exit 1
fi

if [ -z $OUT_FILE ]; then
    echo "Illegal argument: Need to specify an output file!"
    exit 1;
fi


#create output file
sacct -j $JOB_ID --format State | tail -n +3 > $OUT_FILE

# add " around lines to sattisfy the csv auto detetion
sed -i 's/.*/\"&\"/' $OUT_FILE