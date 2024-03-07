About
=====

This is a skeleton Python package to test `setup.py` and various ways
of installing a Python package from a source tree and its dependencies (see
`requirements.txt`) using `pip` + `setuptools` + `setup.py` + `venv`/`pipenv`.
We don't (yet) cover `pyproject.toml` or package managers other than
`pip`, such as `conda`.

This repo is not a replacement for the [pypa sampleproject][sampleproject].
Rather, we use `installtest.sh` to install/uninstall the package in various
ways and analyze where files have been placed in order to understand how
different install methods affect the system. This is useful for situations
where using `docker` or cheaper install env separation tech such as venvs is
not used and one still needs to separate manually installed packages from those
installed by a system package manager such as `apt` on Debian. Also, this
knowledge helps to debug situations such as "Hey, I installed the `foo` package
using `$some_method` but my Python says `No module named 'foo'`. What's
up?".

Key observations
================

* system `pip` installs into local site-packages
  (`~/.local/lib/pythonX.Y/site-packages`, at least on Debian)
* change `pip` install dir using `PYTHONUSERBASE`
* `pip` copies the package (no `.egg` files)
* `setup.py install` creates `.egg` files
* `pip install -e` is the same as `setup.py develop`, creates a file
  `<package>.egg-link` which points to the source tree
* `venv --without-pip` uses system `pip` and does *not* install into
  venv
* dev install (`pip install -e`) doesn\'t apply to dependencies (see
  `requirements.txt`)
* `pipenv` is a package manager for your dependencies, not an
  installer for your project, use
  `pipenv install && pipenv run pip install .`

Many ways to create a venv
--------------------------

*Never* use `venv --without-pip` since this will use system `pip` and make the
venv ineffective! However, `venv --system-site-packages` is OK for access to
system site package, but no packages will be installed there.

The recommended way to set up a venv is thus

```sh
$ cd /path/to/project

# pure python
$ python3 -m venv --symlinks [--system-site-packages] awesome_venv
$ . ./awesome_venv/bin/activate
(awesome_venv)$ pip install -r requirements.txt  # or pip install dep1 dep2 ...
(awesome_venv)$ pip install [-e] .

# virtualenvwrapper (--symlinks is default)
$ mkvirtualenv [--system-site-packages] -p /usr/bin/python3 awesome_venv
(awesome_venv)$ pip install -r requirements.txt
(awesome_venv)$ pip install [-e] .

# pipenv
$ pipenv install
# then either
$ pipenv shell
(project-08xy15foo)$ pip install .
# or
$ pipenv run pip install .
```

pipenv
------

Note that `pipenv` installs venvs by default to `~/.virtualenvs` (e.g.
`~/.virtualenvs/project-08xy15foo`, where `08xy15foo` is the hash of
`/path/to/project`). Since `virtualenvwrapper` uses the same dir, you can
remove venvs with `rmvirtualenv` as well. However, the command for leaving
`pipenv`'s venv is `exit` instead of `deactivate`. While the latter also works,
it may leave env vars such as `PIPENV_ACTIVE` behind.

Usage
=====

Adapt `$version` in `installtest.sh` to your Python version. The script will
install and uninstall the package using various methods and show where files
are copied to. No `sudo` is used, so everything is happening in `$HOME`.

The script writes a log file `installtest.log` with detailed command
output.

We assume that we have a naming scheme for the package "samplepkg"
according to the [pypa sampleproject][sampleproject]

    /path/to/samplepkg
    /path/to/samplepkg/setup.py
    /path/to/samplepkg/src/samplepkg/__init__.py
    /path/to/samplepkg/src/samplepkg/foo.py

If not, then change `$pkgname` in the script.

You can also use `installtest.sh` on other projects.

```sh
$ cd /path/to/myproject
$ /path/to/samplepkg/installtest.sh
```

Results from a run of `installtest.sh`, started from
`/home/elcorto/soft/git/samplepkg/`:

    pip3 install .
                                                                which pip3 : /usr/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                         /home/elcorto/.local/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.dist-info/

    PYTHONUSERBASE=/home/elcorto/soft pip3 install .
                                                                which pip3 : /usr/bin/pip3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.dist-info/

    PYTHONPATH=/home/elcorto/soft/lib/python3.7/site-packages/ python3 setup.py install --prefix=/home/elcorto/soft
                                                                which pip3 : /usr/bin/pip3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : dummy_test-0.1.3-py3.7.egg/ samplepkg-1.2.3-py3.7.egg
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : ./samplepkg-1.2.3-py3.7.egg ./dummy_test-0.1.3-py3.7.egg

    pip3 install -e .
                                                                which pip3 : /usr/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                         /home/elcorto/.local/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg.egg-link
       /home/elcorto/.local/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
         /home/elcorto/.local/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/

    PYTHONUSERBASE=/home/elcorto/soft pip3 install -e .
                                                                which pip3 : /usr/bin/pip3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                           /home/elcorto/soft/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg.egg-link
         /home/elcorto/soft/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/

    PYTHONPATH=/home/elcorto/soft/lib/python3.7/site-packages/ python3 setup.py develop --prefix=/home/elcorto/soft
                                                                which pip3 : /usr/bin/pip3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                           /home/elcorto/soft/lib/python3.7/site-packages/ : dummy_test-0.1.3-py3.7.egg/ samplepkg.egg-link
         /home/elcorto/soft/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/ ./dummy_test-0.1.3-py3.7.egg

    python3.7 -m venv --without-pip --symlinks /home/elcorto/__test_venv__/; . /home/elcorto/__test_venv__/bin/activate; pip3 install .
                                                                which pip3 : /usr/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                         /home/elcorto/.local/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.dist-info/

    python3.7 -m venv --symlinks /home/elcorto/__test_venv__/; . /home/elcorto/__test_venv__/bin/activate; pip3 install .
                                                                which pip3 : /home/elcorto/__test_venv__/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                  /home/elcorto/__test_venv__/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.egg-info/

    PIPENV_VENV_IN_PROJECT=1 pipenv install . >> installtest.log 2>&1; . ./.venv/bin/activate
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/

    PIPENV_VENV_IN_PROJECT=1 pipenv install -e . >> installtest.log 2>&1; . ./.venv/bin/activate
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg.egg-link
                    ./.venv/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
                      ./.venv/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/

    PIPENV_VENV_IN_PROJECT=1 pipenv install >> installtest.log 2>&1; . ./.venv/bin/activate; pip3 install .
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.dist-info/

    PIPENV_VENV_IN_PROJECT=1 pipenv install >> installtest.log 2>&1; . ./.venv/bin/activate; pip3 install -e .
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg.egg-link
                    ./.venv/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
                      ./.venv/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/

    (PIPENV_VENV_IN_PROJECT=1 pipenv install && pipenv run pip install .) >> installtest.log 2>&1; . ./.venv/bin/activate
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg/ samplepkg-1.2.3.dist-info/

    (PIPENV_VENV_IN_PROJECT=1 pipenv install && pipenv run pip install -e .) >> installtest.log 2>&1; . ./.venv/bin/activate
                                                                which pip3 : /home/elcorto/soft/git/samplepkg/.venv/bin/pip3
                                                                 pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : dummy-test 0.1.3  samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg/src
                                      ./.venv/lib/python3.7/site-packages/ : dummy_test/ dummy_test-0.1.3.dist-info/ samplepkg.egg-link
                    ./.venv/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/src/
                      ./.venv/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/src/

Upload a package to pypi
========================

See

* <https://packaging.python.org/tutorials/packaging-projects/>
* <https://packaging.python.org/guides/using-testpypi/>

Install pypa's upload tool `twine`.

```sh
# Debian-ish system
$ sudo apt install twine
# Any system
$ pip install twine
```

Build package data for upload to pypi.

With `setup.py`:

```sh
$ rm -rf build dist $(find . -name "*.egg-info")
$ python3 setup.py sdist bdist_wheel
```

With `pyproject.toml`:

Install the `build` tool first.

```sh
# Debian-ish system
$ sudo apt install python3-build
# Any system
$ pip install build
```

Build

```sh
$ rm -rf dist
$ python3 -m build
```

Test

```sh
$ twine upload --repository testpypi dist/*

$ mkvirtualenv foo

# this may fail
(foo) $ pip search --index https://test.pypi.org/simple mypackage

# this usually works
(foo) $ pip install --index-url https://test.pypi.org/simple [--no-deps] mypackage
(foo) $ deactivate
$ rmvirtualenv foo
```

Real upload

```sh
$ twine upload dist/*
```

or use this when using a pypi API token:

```sh
$ TWINE_USERNAME=__token__ TWINE_PASSWORD=pypi-xxxsupersecretyyy twine upload dist/*
```

[sampleproject]: https://github.com/pypa/sampleproject
