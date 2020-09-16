import os
from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.rst')) as fd:
    long_description = fd.read()


setup(
    name='samplepkg',
    version='1.2.3',
    description='',
    long_description=long_description,
    url='https://git.focker.com/samplepkg',
    author='Gaylord Focker',
    author_email='git@focker.com',
    license='BSD 3-Clause',
    keywords='k3y w0rd',
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    install_requires=open('requirements.txt').read().splitlines(),
    python_requires='>=3',
)
