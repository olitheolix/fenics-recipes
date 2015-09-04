# Second of two Dockerfile to build Anaconda packages for FEniCS.
#
# Build instructions:
#   You need to have built the image for Dockerfile_base already. Then
#   run the following command:
#   >> docker build -t fenics -f Dockerfile .
# 
# Author: Oliver Nagy <olitheolix@gmail.com>
FROM fenics_base:latest
MAINTAINER Oliver Nagy <olitheolix@gmail.com>


# -------------------------------------------------------------------------
# Install additional build dependencies; PETSc requires BLAS/LAPACK
# and Dolfin needs Scotch.
# -------------------------------------------------------------------------
RUN apt-get install -y libblas-dev liblapack-dev libptscotch-dev


# -------------------------------------------------------------------------
# Build the packages from the recipes.
# -------------------------------------------------------------------------
WORKDIR /tmp/fenics-recipes

# Build Eigen3 and SWIG from our own recipes. The reason is that the
# default SWIG in Anaconda is too old and the Eigen3 library is
# currently only available via other channels.
RUN conda build eigen3 swig --python 2.7 --python 3.4 --no-test

# Build pre-requisite packages for FEniCS.
RUN conda build --python 2.7 --python 3.4 --no-test petsc
RUN conda build --python 2.7 --python 3.4 --no-test petsc4py
RUN conda build --python 2.7 --python 3.4 --no-test slepc
RUN conda build --python 2.7 --python 3.4 --no-test slepc4py

# Build the FEniCS packages.
RUN conda build --python 2.7 --python 3.4 --no-test instant ufl fiat ffc
RUN conda build --python 2.7 --python 3.4 --no-test dolfin

# Meta package that combines all required packages for FEniCS.
RUN conda build --python 2.7 --python 3.4 --no-test fenics


# -------------------------------------------------------------------------
# Create test environments and install the FEniCS packages into them.
# -------------------------------------------------------------------------
RUN conda create -y -n p27 python=2.7 numpy=1.9 && conda install -n p27 --use-local ffc fiat instant ufl dolfin
RUN conda create -y -n p34 python=3.4 numpy=1.9 && conda install -n p34 --use-local ffc fiat instant ufl dolfin

# Verify that Dolfin imports without error in both Python versions.
RUN bash -c "source activate p27 && python -c 'import dolfin'"
RUN bash -c "source activate p34 && python -c 'import dolfin'"
