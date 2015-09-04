#!/bin/bash

export SLEPC_DIR=$PWD
export PETSC_DIR=$PREFIX

./configure --prefix=$PREFIX
make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX
make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
