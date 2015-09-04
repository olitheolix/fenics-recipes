echo -n 'Testing with ' && `python --version`

python $PREFIX/share/dolfin/demo/documented/poisson/python/demo_poisson.py

# It is important to delete this directory after the test because
# Instant will cache _something_ in there it specific to the used
# Python version. This, in turn, messes with the above test when
# executed for multiple Python versions. Therefore, delete it.
rm -rf $HOME/.instant
