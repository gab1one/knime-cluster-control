#!/bin/bash

# get options from input arguments

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# arguments
NUM_NODES=0
OUT_FILE=""

while getopts ":n:o:" opt; do
    case "$opt" in
    \?)
        echo "Usage: -n number of nodes -o outputfile"
        exit 1
        ;;
    n)  NUM_NODES=$OPTARG
        ;;
    o)  OUT_FILE=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

if [ $NUM_NODES -lt 1 ]; then
    echo "Illegal argument: Need to specify at least one node!"
    exit 1
fi

if [ -z $OUT_FILE ]; then
    echo "Illegal argument: Need to specify an output file!"
    exit 1;
fi


# create output file
echo "job-id" > $OUT_FILE

# start executors
sbatch -n $NUM_NODES ./batch-workers.sh -n $NUM_NODES | cut -d ' ' -f 4 >> $OUT_FILE
