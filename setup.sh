#!/bin/bash

echo 'export PATH=$DIR/bin:$PATH' >> $HOME/.bashrc

sudo cp -r ood-app /var/www/ood/apps/sys/fbl

sudo scp -r singularity-image gpu01:/mnt/nvme/node04/bionet/fruitflybrain+fbl+latest
