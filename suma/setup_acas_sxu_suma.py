#!/usr/bin/env python3

"""
A setuptools based setup module for acas-sxu-suma distribution.

Template based on:
https://aeegitlab.honeywell.com/APIS/Template/blob/release/
https://github.com/pypa/sampleproject

For more info see:
https://aeegitlab.honeywell.com/APIS/APIS/blob/release/Readme.md
https://packaging.python.org/en/latest/distributing.html
"""


from setuptools import setup
from apis import load_install_requires, list_package_data
from suma import __version__


setup(
    # A more specific name is used to avoid accidentally installing
    # the wrong distribution ("suma" name is too generic).
    name='acas-sxu-suma',
    version=__version__,
    packages=['suma'],
    install_requires=load_install_requires(),
    package_data={
        'suma': (
            list_package_data('suma/ACAS_sXu', 'suma')),
        },
    license='Honeywell Proprietary',
    url='https://aeegitlab.honeywell.com/TCAS-Evolution/suma',
    )
