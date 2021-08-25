#!/bin/bash

FFBO_DIR=/home/ffbo/ffbo
ORIENTDB_ROOT=/home/ffbo/orientdb

#tmux new-session -d -s "db" $FFBO_DIR/bin/run_database.sh
eval $FFBO_DIR/bin/run_database.sh &
export DB_PID=$!

#tmux new-session -d -s "processor" $FFBO_DIR/bin/run_processor.sh
#export PROCESSOR_PID=$(grab_pid $FFBO_DIR/bin/run_processor.sh)
eval $FFBO_DIR/bin/run_processor.sh &
export PROCESSOR_PID=$!

sleep 20
if [ -d "$ORIENTDB_ROOT/databases/hemibrain" ]
then
    #tmux new-session -d -s "nlp_hemibrain" $FFBO_DIR/bin/run_nlp.sh -a hemibrain
    #tmux new-session -d -s "neuroarch_hemibrain" $FFBO_DIR/bin/run_neuroarch.sh -b hemibrain
    #export NLP_HEMIBRAIN_PID=$(grab_pid $FFBO_DIR/bin/run_nlp.sh -a hemibrain)
    #export NA_HEMIBRAIN_PID=$(grab_pid $FFBO_DIR/bin/run_neuroarch.sh -b hemibrain)
    eval $FFBO_DIR/bin/run_nlp.sh -a hemibrain &
    export NLP_HEMIBRAIN_PID=$!
    eval $FFBO_DIR/bin/run_neuroarch.sh -b hemibrain &
    export NA_HEMIBRAIN_PID=$!
fi

if [ -d "$ORIENTDB_ROOT/databases/flycircuit" ]
then
    #tmux new-session -d -s "nlp_flycircuit" $FFBO_DIR/bin/run_nlp.sh -a flycircuit
    #tmux new-session -d -s "neuroarch_flycircuit" $FFBO_DIR/bin/run_neuroarch.sh -b flycircuit
    #export NLP_FLYCIRCUIT_PID=$(grab_pid $FFBO_DIR/bin/run_nlp.sh -a flycircuit)
    #export NA_FLYCIRCUIT_PID=$(grab_pid $FFBO_DIR/bin/run_neuroarch.sh -b flycircuit)
    eval $FFBO_DIR/bin/run_nlp.sh -a flycircuit &
    export NLP_FLYCIRCUIT_PID=$!
    eval $FFBO_DIR/bin/run_neuroarch.sh -b flycircuit &
    export NA_FLYCIRCUIT_PID=$!
fi

if [ -d "$ORIENTDB_ROOT/databases/l1em" ]
then
    #tmux new-session -d -s "nlp_l1em" $FFBO_DIR/bin/run_nlp.sh -a l1em
    #tmux new-session -d -s "neuroarch_l1em" $FFBO_DIR/bin/run_neuroarch.sh -b l1em
    #export NLP_L1EM_PID=$(grab_pid $FFBO_DIR/bin/run_nlp.sh -a l1em)
    #export NA_L1EM_PID=$(grab_pid $FFBO_DIR/bin/run_neuroarch -b l1em)
    eval $FFBO_DIR/bin/run_nlp.sh -a l1em &
    export NLP_L1EM_PID=$!
    eval $FFBO_DIR/bin/run_neuroarch.sh -b l1em &
    export NA_L1EM_PID=$!
fi

if [ -d "$ORIENTDB_ROOT/databases/medulla" ]
then
    #tmux new-session -d -s "nlp_medulla" $FFBO_DIR/bin/run_nlp.sh -a medulla
    #tmux new-session -d -s "neuroarch_medulla" $FFBO_DIR/bin/run_neuroarch.sh -b medulla
    #export NLP_MEDULLA_PID=$(grab_pid $FFBO_DIR/bin/run_nlp.sh -a medulla)
    #export NA_MEDULLA_PID=$(grab_pid $FFBO_DIR/bin/run_neuroarch.sh -b medulla)
    eval $FFBO_DIR/bin/run_nlp.sh -a medulla &
    export NLP_MEDULLA_PID=$!
    eval $FFBO_DIR/bin/run_neuroarch.sh -b medulla &
    export NA_MEDULLA_PID=$!
fi

#tmux new-session -d -s "neurokernel" $FFBO_DIR/bin/run_neurokernel.sh
#export NEUROKERNEL_PID=$(grab_pid $FFBO_DIR/bin/run_neurokernel.sh)
eval $FFBO_DIR/bin/run_neurokernel.sh
export NEUROKERNEL_PID=$!

echo "Servers started. Check tmux sessions for status. To shutdown, run $FFBO_DIR/bin/shutdown.sh"

cd $FFBODIR

# Starting FlyBrainLab
$FFBO_DIR/bin/run_fbl.sh

$FFBO_DIR/bin/shutdown.sh
