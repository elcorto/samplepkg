samplepkg
=========

Skeleton python package to test ``setup.py`` and various ways to install a package
using ``pip`` + ``setuptools`` + ``setup.py``.

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

venv take-home message
----------------------
*Never* use ``venv --without-pip`` since this will use system ``pip`` and
make the venv ineffective! However, ``venv --system-site-packages`` is OK for
access to system site package (duh..), but no packages will be installed there.

The recommended way to set up a venv is thus

.. code-block:: shell

    # pure puthon
    python3 -m venv --symlinks --system-site-packages awesome_venv

    # virtualenvwrapper (--symlinks is default)
    mkvirtualenv --system-site-packages -p /usr/bin/python3 awesome_venv

Usage
=====

Adapt ``$version`` in the script to your system first. The script will install
and uninstall the package using various methods and show where files are copied
to. No ``sudo`` is used, so everything is happening in ``$HOME``.

The script writes a log file ``installtest.log`` with detailed command output.

We assume that we have a naming scheme for the package "samplepkg" such that::

    /path/to/samplepkg
    /path/to/samplepkg/setup.py
    /path/to/samplepkg/samplepkg/<all *.py files>

If not, then change ``$pkgname`` in the script.

You can also use ``installtest.sh`` on other projects::

    $ cd /path/to/myproject
    $ /path/to/samplepkg/installtest.sh

Results from a run of ``installtest.sh``, started from
``/home/elcorto/soft/git/samplepkg/``::

    pip3 install .
                                                                which pip3 : /usr/bin/pip3
                         /home/elcorto/.local/lib/python3.7/site-packages/ : samplepkg/ samplepkg-1.2.3.dist-info/
                                                                 pip3 list : samplepkg 1.2.3

    PYTHONUSERBASE=/home/elcorto/soft pip3 install .
                                                                which pip3 : /usr/bin/pip3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : samplepkg/ samplepkg-1.2.3.dist-info/
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : samplepkg 1.2.3

    PYTHONPATH=/home/elcorto/soft/lib/python3.7/site-packages/ python3 setup.py install --prefix=/home/elcorto/soft
                                                                which pip3 : /usr/bin/pip3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : samplepkg-1.2.3-py3.7.egg
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : ./samplepkg-1.2.3-py3.7.egg
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : samplepkg 1.2.3

    pip3 install -e .
                                                                which pip3 : /usr/bin/pip3
                         /home/elcorto/.local/lib/python3.7/site-packages/ : samplepkg.egg-link
         /home/elcorto/.local/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/
       /home/elcorto/.local/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/
                                                                 pip3 list : samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg

    PYTHONUSERBASE=/home/elcorto/soft pip3 install -e .
                                                                which pip3 : /usr/bin/pip3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : samplepkg.egg-link
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/
         /home/elcorto/soft/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg

    PYTHONPATH=/home/elcorto/soft/lib/python3.7/site-packages/ python3 setup.py develop --prefix=/home/elcorto/soft
                                                                which pip3 : /usr/bin/pip3
                           /home/elcorto/soft/lib/python3.7/site-packages/ : samplepkg.egg-link
           /home/elcorto/soft/lib/python3.7/site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg/
         /home/elcorto/soft/lib/python3.7/site-packages/samplepkg.egg-link : /home/elcorto/soft/git/samplepkg/
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg

    python3.7 -m venv --without-pip --symlinks /home/elcorto/__test_venv__/; . /home/elcorto/__test_venv__/bin/activate; pip3 install .
                                                                which pip3 : /usr/bin/pip3
                         /home/elcorto/.local/lib/python3.7/site-packages/ : samplepkg/ samplepkg-1.2.3.dist-info/
                                                                 pip3 list : samplepkg 1.2.3

    python3.7 -m venv --symlinks /home/elcorto/__test_venv__/; . /home/elcorto/__test_venv__/bin/activate; pip3 install .
                                                                which pip3 : /home/elcorto/__test_venv__/bin/pip3
                  /home/elcorto/__test_venv__/lib/python3.7/site-packages/ : samplepkg/ samplepkg-1.2.3.egg-info/
                                                                 pip3 list : samplepkg 1.2.3
                               PYTHONUSERBASE=/home/elcorto/soft pip3 list : samplepkg 1.2.3
