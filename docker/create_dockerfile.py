"""
Create a standalone Dockerfile that pulls the recipes from Github.

This script concatenates Dockerfile_base and Dockerfile_fenics and replaces the
ADD command with a 'git clone'. Furthermore, it updates the environment
variables that specify which version of FEniCS to build.

This script requires Python 3.

Usage examples:
  >> python create_dockerfile.py --branch master
  >> python create_dockerfile.py --branch 1.6.0

This will create a Dockerfile. Build it with:
  > docker build -t fenics Dockerfile .

"""
import argparse
import os
import re
import sys


def parseCommandLine():
    """
    Parse program arguments.
    """
    # Create the parser.
    parser = argparse.ArgumentParser(
        description=('Create standalone Dockerfiles for '
                     'individual FEniCS versions'),
        formatter_class=argparse.RawTextHelpFormatter)

    # Shorthand.
    padd = parser.add_argument

    # Add the command line options.
    padd('--branch', metavar='tag/branch', type=str, default='master',
         help='Tag/branch of FEniCS repository to use (default=master)')
    padd('--test', action='store_true', default=False,
         help='Run the tests during build (default=off)')

    # Run the parser.
    param = parser.parse_args()

    # Determine the Git branch/tag and the corresponding version tag assigned
    # to the Anaconda packages that will be created.
    if param.branch == 'master':
        pkg_version = '1.7.0dev'
    elif param.branch == '1.6.0':
        pkg_version = param.branch
    else:
        print('Unsupported branch <{}>'.format(param.branch))
        sys.exit(1)

    param.pkg_version = pkg_version
    return param


def stripHeader(lines: list):
    # Verify that exactly one line starts with 'MAINTAINER'.
    tmp = [idx for idx, line in enumerate(lines)
           if line.startswith('MAINTAINER')]
    assert len(tmp) == 1
    idx = tmp[0]

    # Drop all lines prior to the MAINTAINER line.
    return lines[idx + 1:]


def main():
    # Parse command line for package version information.
    param = parseCommandLine()

    # Define the names of the input/output Dockerfile.
    fname_base = '../Dockerfile_base'
    fname_fenics = '../Dockerfile'
    fname_out = 'Dockerfile_{}'.format(param.branch)

    # Read the Docker files.
    docker_base = open(fname_base, 'r').readlines()
    docker_fenics = open(fname_fenics, 'r').readlines()

    # Strip the file headers.
    docker_base = stripHeader(docker_base)
    docker_fenics = stripHeader(docker_fenics)

    # Define the header for the new Dockerfile.
    header = [
        'FROM continuumio/anaconda:latest\n'
        'MAINTAINER Oliver Nagy <olitheolix@gmail.com>\n'
    ]

    # Concatenate the header and the two old Docker files.
    dockerfile = header + docker_base + docker_fenics
    dockerfile = ''.join(dockerfile)

    # Replace the ADD command with the correct clone command.
    dockerfile = re.sub(
        r'^ADD .*',
        'RUN git clone https://github.com/olitheolix/fenics-recipes.git',
        dockerfile,
        flags=re.MULTILINE
    )

    # Set the correct value for FENICS_BRANCH.
    dockerfile = re.sub(
        r'^ENV FENICS_BRANCH .*',
        'ENV FENICS_BRANCH "{branch}"'.format(branch=param.branch),
        dockerfile,
        flags=re.MULTILINE
    )

    # Set the correct value for FENICS_ANACONDA_PACKAGE_VERSION.
    version = '\'"{}"\''.format(param.pkg_version)
    dockerfile = re.sub(
        r'^ENV FENICS_ANACONDA_PACKAGE_VERSION .*',
        'ENV FENICS_ANACONDA_PACKAGE_VERSION {ver}'.format(ver=version),
        dockerfile,
        flags=re.MULTILINE
    )

    # Deactivate the tests. By default, the build commands in the Dockerfile
    # use the '--no-test' flag. If the user wants to run the tests during build
    # then we need to delete it.
    if param.test is True:
        dockerfile = dockerfile.replace(' --no-test', '')

    # Write the Dockerfile and print basic build instructions.
    open(fname_out, 'w').write(dockerfile)
    print('Wrote build instructions to <{}>'.format(fname_out))
    print('Build with eg: >> docker build -t fenics:{} -f {} .'
          .format(param.branch, fname_out))


if __name__ == '__main__':
    main()
