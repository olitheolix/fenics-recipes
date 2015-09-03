#!/bin/bash

export INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

export AMD_DIR=$SP_DIR/petsc
export BLAS_DIR=$LIBRARY_PATH
export UMFPACK_DIR=$SP_DIR/petsc

# Dolfin requires the build directory be different from the source
# directory.
mkdir build
cd build

# Specify installation- and library paths to ensure cmake uses the
# Anaconda environment instead of the system environment. Also
# explicitly disable all libraries that we have not installed in the
# container.
cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INCLUDE_PATH=$INCLUDE_PATH \
  -DCMAKE_LIBRARY_PATH=$LIBRARY_PATH \
  -DPYTHON_EXECUTABLE=`which python` \
  -DDOLFIN_ENABLE_VTK:BOOL=OFF \
  -DDOLFIN_ENABLE_TRILINOS:BOOL=OFF \
  -DDOLFIN_ENABLE_PASTIX:BOOL=OFF \
  -DDOLFIN_ENABLE_PARMETIS:BOOL=OFF \
  -DDOLFIN_ENABLE_HDF5:BOOL=OFF

# Limit compilation to 4 threads; otherwise it goes haywire on my
# machine (8 cores 16GB RAM).
if [ $CPU_COUNT -gt 4 ] ; then
    CPU_COUNT=4
fi

make -j$CPU_COUNT install
