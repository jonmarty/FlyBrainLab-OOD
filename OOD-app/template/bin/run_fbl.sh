#!/bin/bash

CONDA_ROOT=/home/ffbo/miniconda
FFBO_ENV=ffbo
FFBO_DIR=/home/ffbo/ffbo
CONFIG_FILE=/home/ffbo/.ffbo/config/config.py

. $CONDA_ROOT/etc/profile.d/conda.sh
conda activate $FFBO_ENV
cd $FFBO_DIR
jupyter lab --notebook-dir=/userdir --config="${CONFIG_FILE}"
