#!/usr/bin/env python3

"""
A setuptools based setup module for acas-sxu-suma-test distribution.

Template based on:
https://aeegitlab.honeywell.com/APIS/Template/blob/release/
https://github.com/pypa/sampleproject

For more info see:
https://aeegitlab.honeywell.com/APIS/APIS/blob/release/Readme.md
https://packaging.python.org/en/latest/distributing.html
"""


from setuptools import setup
from apis import load_install_requires, list_package_data
from suma.test import __version__


setup(
    name='acas-sxu-suma-test',
    version=__version__,
    packages=['suma.test'],
    install_requires=(
        load_install_requires(path='./install_requires_test.txt') + [
            'acas-sxu-suma==' + __version__
            ]),
    package_data={
        'suma.test': (
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup10', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup20', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup30', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup40', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup50', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup60', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup70', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup80', 'suma/test') +
            list_package_data(
                'suma/test/TestData/test_testsuite/TestGroup99', 'suma/test') + [
            'TestData/test_example/example/*.json',
            'TestData/test_example/example/*.ndjson',
            'TestData/test_example/kinematic_example/*.kml',
            'TestData/test_example/kinematic_example/*.ndjson',
            ]),
        },
    license='Honeywell Proprietary',
    url='https://aeegitlab.honeywell.com/TCAS-Evolution/suma',
    )
