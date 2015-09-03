#!/bin/bash

export LIBRARY_PATH=$PREFIX/lib

# The configure script requires Python2 to build the make files -
# Python 3 will not work, but it is possible to build this package for
# Python 3 as well.
# 
# To this, we need to *always* call the configure script with Python2.
# Once it has generated the make files the package requires no Python
# at all (neither for building it, nor during runtime).
# 
# Calling Python 2 this way a hack. It will reliably work in an
# Anaconda2 container, though.
/opt/conda/bin/python configure \
  --prefix=$PREFIX \
  --with-blas-lapack-dir=$LIBRARY_PATH \
  --download-suitesparse \
  --with-shared-libraries
make
make install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
