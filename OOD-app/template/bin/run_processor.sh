#!/bin/bash

CONDA_ROOT=/home/ffbo/miniconda
CROSSBAR_ENV=crossbar
FFBO_DIR=/home/ffbo/ffbo

. $CONDA_ROOT/etc/profile.d/conda.sh

conda activate $CROSSBAR_ENV
cd $FFBO_DIR/ffbo.neuronlp
git checkout js/NeuroNLP.js
sleep 2
cd $FFBO_DIR/ffbo.processor
python config.py
cd components
crossbar start --config docker_config.json
