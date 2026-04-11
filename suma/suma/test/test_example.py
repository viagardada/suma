#!/usr/bin/env python3

from unittest import TestCase as _TestCase, skipIf as _skipIf
from os.path import exists as _exists


_YAML_PATH = './example/example.yml'
_PY_PATH = './example/example.py'
_KINEMATIC_YAML_PATH = './example/kinematic_example.yml'


class ExampleTest(_TestCase):
    """
    Test if example can be executed and produces similar files.

    Comparison precision may be reduced when non-trivial comparison is
    required.

    Also serves as a test whether any analytical outputs are produced.
    """

    @_skipIf(not _exists(_YAML_PATH), 'Example not available.')
    def test_cli_example(self):
        from os.path import join
        from CASCARA import RunSystemTest, GetPackageTestDataFolder

        test_dir = join(
            GetPackageTestDataFolder('test_example', __file__),
            'example')
        RunSystemTest(
            self, './example', 'example.yml',
            outputDir='output', referenceDir=test_dir)

    @_skipIf(not _exists(_PY_PATH), 'Example not available.')
    def test_embedded_example(self):
        from os.path import join
        from CASCARA import RunSystemTest, GetPackageTestDataFolder

        test_dir = join(
            GetPackageTestDataFolder('test_example', __file__),
            'example')
        RunSystemTest(
            self, './example', 'example.py',
            outputDir='output', referenceDir=test_dir)

    @_skipIf(not _exists(_KINEMATIC_YAML_PATH), 'Example not available.')
    def test_kinematic_cli_example(self):
        from os.path import join
        from CASCARA import RunSystemTest, GetPackageTestDataFolder

        test_dir = join(
            GetPackageTestDataFolder('test_example', __file__),
            'kinematic_example')
        RunSystemTest(
            self, './example', 'kinematic_example.yml',
            outputDir='output', referenceDir=test_dir)
