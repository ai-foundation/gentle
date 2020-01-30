#!/bin/bash

# Prepare Kaldi
cd kaldi/tools
make clean
make
./extras/install_mkl.sh
cd ../src
# make clean (sometimes helpful after upgrading upstream?)
./configure --static --static-math=yes --static-fst=yes --use-cuda=no
make depend
cd ../../
