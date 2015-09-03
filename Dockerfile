# Second of two Dockerfile to build Anaconda packages for FEniCS.
#
# Build with:
#   >> docker build -t fenics27 -f Dockerfile_fenics .
# 
# Author: Oliver Nagy <olitheolix@gmail.com>
FROM fenics_base:latest
MAINTAINER Oliver Nagy <olitheolix@gmail.com>

# Additional build dependencies; BLAS/LAPACK for PETSc and libptscotch/gfortran for Dolfin.
RUN apt-get install -y libblas-dev liblapack-dev libptscotch-dev gfortran

WORKDIR /tmp/fenics-recipes

# Build auxiliary packages. These are not FEniCS specific but Anaconda
# has either no default (Eigen3) or it is too old (SWIG). Therfore, we
# build our own from the just added set of recipes.
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

# Create test environments and install the FEniCS packages into them.
RUN conda create -y -n f27 python=2.7 numpy=1.9 && conda install -n f27 --use-local ffc fiat instant ufl dolfin
RUN conda create -y -n f34 python=3.4 numpy=1.9 && conda install -n f34 --use-local ffc fiat instant ufl dolfin
RUN bash -c "source activate f27 && python -c 'import dolfin'"
RUN bash -c "source activate f34 && python -c 'import dolfin'"
