#!/bin/bash

# SLURM specific meta commands, to route error messages
#SBATCH --output=knime-exec-job-%j-out.txt
#SBATCH --error=knime-exec-job-%j-err.txt

# get options from input arguments

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# arguments
NUM_NODES=0

while getopts ":n:" opt; do
    case "$opt" in
    \?)
        echo "Usage: -n number of nodes"
        exit 1
        ;;
    n)  NUM_NODES=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

if [ $NUM_NODES -lt 1 ]; then
    echo "Illegal argument: Need to specify at least one node!"
    exit 1
fi

# start executors
srun -n $NUM_NODES ./start-worker.sh
