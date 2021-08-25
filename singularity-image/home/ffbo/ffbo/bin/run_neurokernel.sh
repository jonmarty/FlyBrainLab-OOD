#!/bin/bash
CONDA_ROOT=/home/ffbo/miniconda
FFBO_ENV=ffbo
FFBO_DIR=/home/ffbo/ffbo

. $CONDA_ROOT/etc/profile.d/conda.sh
conda activate $FFBO_ENV
cd $FFBO_DIR/nk_tmp
python $FFBO_DIR/ffbo.neurokernel_component/neurokernel_component/neurokernel_component.py
