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

# The following construct simply calls make until it either compiles
# successfully, or has failed 10 times. This somewhat peculiar
# approach is not necessary when I build bets in a Docker container on
# my local computer, but when I build the exact same container on an
# AWS instance then the compilation often (but not always) fails. The
# output suggests there may be a file system race condition during
# compilation (PETSc builds itself with multiple threads by default).
# As a workaround, I will simply attempt to call the 'make' command
# several times. This appears to fix it.
i="1"
until make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX
do
  sleep 0.5
  i=$[$i+1]
  if [ $i -gt 5 ]; then
      exit 1
  fi
done
echo "It took $i attempts to compile PETSc"

make SLEPC_DIR=$PWD PETSC_DIR=$PREFIX install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
