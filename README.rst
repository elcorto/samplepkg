samplepkg
=========

Skeleton Python package to test ``setup.py`` and the various colorful ways of
installing a Python package and its dependencies using ``pip`` +
``setuptools`` + ``setup.py`` + ``*venv*`` + ... other tools ...

Run ``installtest.sh`` to get results like the one below.

Key observations
================

* system ``pip`` installs into local site-packages
  (``~/.local/lib/pythonX.Y/site-packages``, at least on Debian)
* change ``pip`` install dir using ``PYTHONUSERBASE``
* ``pip`` copies the package (no ``.egg`` files)
* ``setup.py install`` creates ``.egg`` files
* ``pip install -e`` is the same as  ``setup.py develop``, creates
  a file ``<package>.egg-link`` which points to the source tree
* ``venv --without-pip`` uses system ``pip`` and does *not* install into venv
* dev install (``pip install -e``) doesn't apply to dependencies (see
  ``requirements.txt``)
* ``pipenv`` is a package manager for your dependencies, not an installer for
  your project, use ``pipenv install && pipenv run pip install .``


1000 ways to create a venv
--------------------------
*Never* use ``venv --without-pip`` since this will use system ``pip`` and
make the venv ineffective! However, ``venv --system-site-packages`` is OK for
access to system site package (duh..), but no packages will be installed there.

The recommended way to set up a venv is thus

.. code-block:: sh

    $ cd /path/to/project

    # pure python
    $ python3 -m venv --symlinks [--system-site-packages] awesome_venv
    $ . ./awesome_venv/bin/activate
    (awesome_venv)$ pip install dependency1 dependency2 ...
    (awesome_venv)$ pip install [-e] .

    # virtualenvwrapper (--symlinks is default)
    $ mkvirtualenv [--system-site-packages] -p /usr/bin/python3 awesome_venv
    (awesome_venv)$ pip install dependency1 dependency2 ...
    (awesome_venv)$ pip install [-e] .

    # you like living on the funky edge
    $ pipenv install
    # then either
    $ pipenv shell
    (project-08xy15foo)$ pip install .
    # or
    $ pipenv run pip install .

pipenv
------

Note that ``pipenv`` installs venvs by default to ``~/.virtualenvs`` (e.g.
``~/.virtualenvs/project-08xy15foo``, where ``08xy15foo`` is the hash of
``/path/to/project``, of course). Since ``virtualenvwrapper`` uses the same
dir, you can remove venvs with ``rmvirtualenv`` as well. Too keep things
interesting, the command for leaving ``pipenv``'s venv is ``exit``
instead of ``deactivate``. While the latter also works, it may leave funny env
vars such as ``PIPENV_ACTIVE`` behind.

Usage
=====

Adapt ``$version`` in the script to your Python version. The script will install
and uninstall the package using various methods and show where files are copied
to. No ``sudo`` is used, so everything is happening in ``$HOME``.

The script writes a log file ``installtest.log`` with detailed command output.

We assume that we have a naming scheme for the package "samplepkg" according to
the `pypa sampleproject  <https://github.com/pypa/sampleproject>`_

::

    /path/to/samplepkg
    /path/to/samplepkg/setup.py
    /path/to/samplepkg/src/samplepkg/__init__.py
    /path/to/samplepkg/src/samplepkg/foo.py

If not, then change ``$pkgname`` in the script.

You can also use ``installtest.sh`` on other projects.

.. code-block:: sh

    $ cd /path/to/myproject
    $ /path/to/samplepkg/installtest.sh

Results from a run of ``installtest.sh``, started from
``/home/elcorto/soft/git/samplepkg/``::


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
