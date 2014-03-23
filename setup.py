#! /usr/bin/env python

import os
import sys

import mp3_scripts

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

if sys.argv[-1] == 'publish':
    os.system('python setup.py sdist upload')
    sys.exit()

packages = [
    'mp3_scripts',
]

requires = [
    open('requirements.txt').read()
]

if sys.version_info < (2, 7):
    requires += ['argparse']

setup(
    name='mp3_scripts',
    version=mp3_scripts.__version__,
    description='Tools for MP3 tags & playlists',
    long_description=open('README.rst').read(),
    author='Matt Black',
    author_email='dev@mafro.net',
    url='http://github.com/mafrosis/mp3-scripts',
    packages=packages,
    package_data={'': ['LICENSE']},
    package_dir={'': '.'},
    include_package_data=True,
    install_requires=requires,
    scripts=['scripts/tagtool'],
    license=open('LICENSE').read(),
    classifiers=(
        'Development Status :: 3 - Alpha',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'License :: OSI Approved :: BSD License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
    ),
)
