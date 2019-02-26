#!/bin/bash

# Setup cluster node specific variables
PREFIX=knime-exec-job-$SLURM_JOB_ID-on-$(hostname)
WORKSPACE=$PREFIX-workspace
CONFIG=$PREFIX-config

# set the executor install location
EXECUTOR_HOME=/home/worker/executor

# set address of rabbitmq server
export KNIME_EXECUTOR_MSGQ=amqp://knime:knime@172.17.0.1/knime

# launch the executor
cd $EXECUTOR_HOME
./knime -nosplash -consolelog \
    -clean \
    -data ~/$WORKSPACE \
    -configuration ~/$CONFIG \
    -application com.knime.enterprise.slave.KNIME_REMOTE_APPLICATION \
    -vmargs \
    -Dosgi.locking=none \
    -Dknime.disable.vmfilelock
