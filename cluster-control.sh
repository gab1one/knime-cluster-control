#! /bin/bash

# KNIME Slurm cluster control script 

# Slurm meta options
#SBATCH --output=knime-exec-job-%j-out.txt
#SBATCH --error=knime-exec-job-%j-err.txt

missing_job_id(){
     echo "Illegal argument: Need to specify a valid job id with -j [id] !"
     exit 1
}

missing_output_file(){
    echo "Illegal argument: Need to specify an output file with -o [file] !"
    exit 1;
}

not_enough_nodes(){
    echo "Illegal argument: Need to specify at least one node with -n [numNodes]!"
    exit 1
}

get_job_status() {
    local jobID=$1
    local outFile=$2

    if [ $jobID -lt 1 ]; then
        missing_job_id
    fi

    if [ -z $OUT_FILE ]; then
        missing_output_file
    fi

    #create output file
    sacct -j $jobID --format State | tail -n +3 > $outFile

    # add " around lines to sattisfy the csv auto detetion
    sed -i 's/.*/\"&\"/' $outFile
}

internal_batch_workers(){
    local numNodes=$1

    if [ $numNodes -lt 1 ]; then
        not_enough_nodes
    fi

    srun -n $numNodes ./start-worker.sh
}

setup_workers(){
    local numNodes=$1
    local outFile=$2

    if [ $numNodes -lt 1 ]; then
        not_enough_nodes
    fi

    if [ -z $outFile ]; then
        missing_output_file
    fi   

    # create output file
    echo "job-id" > $outFile

    # enque executor start job
    sbatch -n $numNodes ./cluster-control.sh internal_batch_workers -n $numNodes | cut -d ' ' -f 4 >> $outFile
}

stop_workers(){
    local jobID=$1
    local outFile=$2

    if [ $jobID -lt 1 ]; then
        missing_job_id
    fi

    if [ -z $outFile ]; then
        missing_output_file
    fi   

    echo "scancel output" > $outFile

    # cancel the nodes
    scancel -v --hurry $jobID >> $outFile 2>&1>&1

    # add " around lines to sattisfy the csv auto detetion
    sed -i 's/.*/\"&\"/' $outFile

    # wait for cancellation to succeed
    # sleep 5s

    # cleanup the working directories
    rm -rf knime-exec-job-$jobID*
}

# arguments

JOB_ID=-1
OUT_FILE=""
NUM_NODES=0

OPTIND=2        # Reset in case getopts has been used previously in the shell.
while getopts ":j:o:n:" opt; do
    case "$opt" in
    \?)
        echo "Usage: Command [options]"
        exit 1
        ;;
    j)  JOB_ID=$OPTARG
        ;;
    o)  OUT_FILE=$OPTARG
        ;;
    n) NUM_NODES=$OPTARG
        ;;
    esac
done

if [ -z $1 ]; then
    echo "No control command given, use one of [setup, status, stop]!"
    exit 1
## Call the function set by the user
# public options
elif [ $1 = "status" ]; then
    get_job_status $JOB_ID $OUT_FILE
elif [ $1 = "setup" ]; then
    setup_workers $NUM_NODES $OUT_FILE
elif [ $1 = "stop" ]; then
    stop_workers $JOB_ID $OUT_FILE
# Internal options
elif [ $1 = "internal_batch_workers" ]; then
    batch_workers $NUM_NODES
else 
    echo $1 " is not a valid argument, use one of [setup, status, stop]!"
    exit 1
fi


