# fenics-recipes

This repository is a fork of https://github.com/Juanlu001/fenics-recipes.

The aim is to build packages for Python 2 & 3, and move the entire build
process into a Docker container. Unfortunately, the Python 3 requirement meant
dropping VTK because it is incompatible.

The main differences are:

* Added SLEPc4py
* VTK is disabled
* Builds with latest FEniCS v1.7.dev
* No MKL dependency (system BLAS only)
* Latest version of PETSc and SLEPc (v3.6)
* All packages build for Python 2.7 & 3.4 with the same recipes

This repository (and the associated Anaconda packages) are
experimental - you have been warned :)


## Installation from Anaconda.org (Linux 64bit)

The Anaconda packages require a few system libraries that I could not figure
out how to distribute via Anaconda. These are BLAS/LAPACK, Scotch, and a
Fortran compiler. On Ubuntu 14.04 you can install everything with:

.. code-block:: bash

   apt-get install -y liblapack-dev libptscotch-dev gfortran pkg-config
   conda install -c https://conda.anaconda.org/olitheolix fenics


## Building the Packages

There are two ways to rebuild all the packages yourself. The first one copies
your local repository into the Docker container and then builds it, the second
one clones the recipes from GitHub (ie this very repository).

The first option is useful if you want to alter and test your recipes. The
second option is a self contained Dockerfile that you can build on eg AWS.

Either way, afterwards you can log into the container and try out the
packages. You may also upload them to your own Anaconda.org channel
(instructions are displayed when you log in).

Note: both options build the same packages; Option 1 is simply more convenient
when you want to tune recipes and build the locally first.


### Option 1: Local Recipes

Clone this repository, modify the recipes (if you want), and then build the two
containers with these commands:

.. code-block:: bash
   git clone https://github.com/olitheolix/fenics-recipes.git
   docker build -t fenics_base -f Dockerfile_base .
   docker build -t fenics .

Note: the `-f` option is only supported in newer versions of Docker. You may
need to upgrade first, or rename `Dockerfile_base` to `Dockerfile` and build
without the `-f` option.


### Option 2: Recipes from GitHub
Copy the `docker/Dockerfile` somewhere and run:

.. code-block:: bash
   docker build -t fenics .
