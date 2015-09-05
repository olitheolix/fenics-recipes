#!/bin/bash

export SLEPC_DIR=$PWD
export PETSC_DIR=$PREFIX

# The configure script requires Python2 to build the make files -
# Python 3 will not work.
# 
# To build an Anaconda package for Python 3 anyway, we need to call the
# PETSc configure script with Python2. After the configure script
# generated the make files, Python is not longer necessary (neither
# for building nor at run-time).
# 
# Calling Python 2 this way is a hack. It will reliably work in an
# Anaconda2 container, though.
/opt/conda/bin/python configure --prefix=$PREFIX
make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX
make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
