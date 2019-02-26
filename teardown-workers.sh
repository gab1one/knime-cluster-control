#!/bin/bash

# get the options from the input arguments

OPTIND=1    # Reset in case getopts has been used previously in the shell.

# arguments
JOB_ID=-1
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
    exit 1;
fi

if [ -z $OUT_FILE ]; then
    echo "Illegal argument: Need to specify an output file!"
    exit 1;
fi


echo "scancel output" > $OUT_FILE

# cancel the nodes
scancel -v --hurry $JOB_ID >> $OUT_FILE 2>&1>&1

# add " around lines to sattisfy the csv auto detetion
sed -i 's/.*/\"&\"/' $OUT_FILE

# wait for cancellation to succeed
# sleep 5s

# cleanup the working directories
rm -rf knime-exec-job-$JOB_ID*
