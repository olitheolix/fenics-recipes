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

# We build our own Eigen3 and SWIG packages because, currently, the
# default SWIG in Anaconda is too old and Eigen3 is only available via
# other channels.
RUN conda build --python 2.7 --python 3.4 --no-test eigen3 swig

# Build pre-requisite packages for FEniCS.
RUN conda build --python 2.7 --python 3.4 --no-test petsc
RUN conda build --python 2.7 --python 3.4 --no-test petsc4py
RUN conda build --python 2.7 --python 3.4 --no-test slepc
RUN conda build --python 2.7 --python 3.4 --no-test slepc4py

# Build the FEniCS packages.
RUN conda build --python 2.7 --python 3.4 --no-test instant ufl fiat ffc
RUN conda build --python 2.7 --python 3.4 --no-test dolfin

# Meta package that combines all required packages for FEniCS. This
# will also run the Poisson demo as a test to ensure the FEniCS
# tool chain works.
RUN conda build --python 2.7 --python 3.4 fenics


# -------------------------------------------------------------------------
# Print Anaconda.org upload instructions when logging into the container.
# -------------------------------------------------------------------------
CMD echo "To upload packages to Anaconda.org:" && \
    echo "  >> cd /opt/conda/conda-bld/linux-64" && \
    echo "  >> anaconda login" && \
    echo "  >> anaconda upload -i eigen3* swig* petsc* slepc* instant* ufl* fiat* ffc* dolfin* fenics*" && \
    bash
