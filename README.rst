samplepkg
=========

Skeleton python package. Test setup.py. We have at least 5 ways to install a
package using pip + setuptools + setup.py, oh boy! 

Run ``installtest.sh`` to get results like the one below. Adapt ``$version`` in
the script to your system first. The script will install and uninstall the
package using various methods and show where files are copied to.

The script writes a log file ``installtest.log`` with detailed command output.

We assume that we have a naming scheme for the package "samplepkg" such that::

    /path/to/samplepkg
    /path/to/samplepkg/setup.py
    /path/to/samplepkg/samplepkg/<all *.py files>

If not, then change ``$name`` in the script.

You can also use ``installtest.sh`` on other projects::

    $ cd /path/to/myproject
    $ /path/to/samplepkg/installtest.sh

::

    #cmd: pip3 install -e .
    #pip list                             : samplepkg 1.2.3 /home/elcorto/soft/git/samplepkg
    #user site-packages                   :
    #user site-packages/easy-install.pth  :
    #local site-packages                  : samplepkg.egg-link
    #local site-packages/easy-install.pth : /home/elcorto/soft/git/samplepkg

    #cmd: PYTHONUSERBASE=/home/elcorto/soft pip3 install -e .
    #pip list                             :
    #user site-packages                   : samplepkg.egg-link
    #user site-packages/easy-install.pth  : /home/elcorto/soft/git/samplepkg
    #local site-packages                  :
    #local site-packages/easy-install.pth :

    #cmd: PYTHONPATH=/home/elcorto/soft/lib/python3.6/site-packages python3 setup.py develop --prefix=/home/elcorto/soft
    #pip list                             :
    #user site-packages                   : samplepkg.egg-link
    #user site-packages/easy-install.pth  : /home/elcorto/soft/git/samplepkg
    #local site-packages                  :
    #local site-packages/easy-install.pth :

    #cmd: pip3 install .
    #pip list                             : samplepkg 1.2.3
    #user site-packages                   :
    #user site-packages/easy-install.pth  :
    #local site-packages                  : samplepkg samplepkg-1.2.3.egg-info
    #local site-packages/easy-install.pth :

    #cmd: PYTHONPATH=/home/elcorto/soft/lib/python3.6/site-packages python3 setup.py install --prefix=/home/elcorto/soft
    #pip list                             :
    #user site-packages                   : samplepkg-1.2.3-py3.6.egg
    #user site-packages/easy-install.pth  : ./samplepkg-1.2.3-py3.6.egg
    #local site-packages                  :
    #local site-packages/easy-install.pth :
