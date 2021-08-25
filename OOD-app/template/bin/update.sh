#!/bin/bash

CONDA_ROOT=/home/ffbo/miniconda
CROSSBAR_ENV=crossbar
NLP_ENV=ffbo_legacy
FFBO_ENV=ffbo
FFBO_DIR=/home/ffbo/ffbo

. $CONDA_ROOT/etc/profile.d/conda.sh
conda activate $NLP_ENV

python -m pip install --upgrade git+https://github.com/fruitflybrain/ffbo.neuroarch_nlp.git

cd $FFBO_DIR/ffbo.nlp_component
git pull
python -m pip install -e .

conda deactivate
conda activate $CROSSBAR_ENV

cd $FFBO_DIR/ffbo.processor
git pull
python -m pip install -e .

conda deactivate
conda activate $FFBO_ENV

cd $FFBO_DIR/ffbo.neuroarch_component
git pull
python -m pip install -e .

cd $FFBO_DIR/ffbo.neurokernel_component
git pull
python -m pip install -e .

python -m pip install --upgrade neuroarch neurokernel neurodriver git+https://github.com/flybrainlab/Neuroballad.git flybrainlab[full] neuromynerva

conda deactivate

cd $FFBO_DIR/Tutorials
git pull
