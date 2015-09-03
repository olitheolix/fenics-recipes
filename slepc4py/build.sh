#!/bin/bash

export PETSC_DIR=$PREFIX
export SLEPC_DIR=$PREFIX
python setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
