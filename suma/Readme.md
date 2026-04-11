# sUMA
Julia ACAS sXu code extracted from *Algorithm Design Description of the Airborne Collision Avoidance System sXu* with a [CASCARA](https://aeegitlab.honeywell.com/TCAS-Evolution/CASCARA) model.

sUMA is UMA's slimmer younger sister and most of the design is shared. Visit UMA for more info or useful scripts.

Additional project files can be found at: <https://honeywellprod.sharepoint.com/teams/ATE-SAD-ACAS-Xu/Shared Documents>

## Download and installation
Python distribution can be installed or upgraded [using pip](https://docs.python.org/3/installing/index.html). Before download, pip must be configured with APIS as well as a private repository [sadpip-pypi-stable-local](https://artifactory-na.honeywell.com/artifactory/webapp/#/artifacts/browse/simple/General/sadpip-pypi-stable-local). Contact the project owners/maintainers for access, then set up your machine (see [here](https://aeegitlab.honeywell.com/APIS/APIS/blob/release/Readme.md#how-to-download-packages-from-apis) and [here](https://aeegitlab.honeywell.com/APIS/APIS/blob/release/Readme.md#how-to-download-packages-from-private-repositories)).

Installing the distribution and tests (can be omitted):
```shell
pip install --upgrade acas-sxu-suma acas-sxu-suma-test
```

*Only 64-bit Python is officially supported.*

Interpretation of Julia expressions is provided by [juliainterpreter](https://aeegitlab.honeywell.com/TCAS-Evolution/JuliaInterpreter) package. The package is automatically installed with sUMA, but Julia needs to be installed separately.

64-bit Julia 1.0 (1.0.3) with JSON package is required by sUMA. Check the JuliaInterpreter Readme for details.

Julia-only packages, including convenient code, data and Julia runtime "bundles", can be found at <https://artifactory-na.honeywell.com/artifactory/list/sad-generic-stable-local/suma/julia/>.

## Usage
By default ACAS sXu lookup tables and params file are expected to be present in `suma/LookupTables` folder. The files are not contained in this repo, *nor the installed distribution* due to their size. Download the appropriate `sUMA_*.tar.gz` archive from <https://artifactory-na.honeywell.com/artifactory/list/sad-generic-stable-local/suma/data/>.

You can either unpack directly to the `suma/` package directory or somewhere else and set the `SUMA_PARAMS_FILE` environment variable to the path of the params file container within the directory. Alternatively you can also set the `stmParamsFile` and `trmParamsFile` Model parameters or set the `suma.Model.embedded_params_file_path` global variable (not recommended).

Params file path setting example:
```shell
export SUMA_PARAMS_FILE='./LookupTables/paramsfile_acasxu.txt'
```

Once sUMA is installed, you can execute the examples with:
```shell
cd example
python -m CASCARA example.yml --log-file output/log.txt
python example.py
```

Unittests can be executed with:
```shell
python -m unittest -v suma.test
```

See the unittests for further usage examples.

See [Verification Notes](doc/VerificationNotes.md) for more info on verification using the official Test Suite and caveats.

## Dependencies
Distribution requirements (in addition to Julia environment described above) are listed in [`install_requires.txt`](./install_requires.txt) and other requirement files. Use [`requirements.txt`](./requirements.txt) to set up a development environment (includes both the distribution requirements and additional development tools):
```shell
pip install -r requirements.txt
```

Test Suite files are not stored directly in this repo due to their size. For the development purposes, download the appropriate `sUMA-Test_*.tar.gz` archive from <https://artifactory-na.honeywell.com/artifactory/list/sad-generic-stable-local/suma/data/> and unpack the Suite as the `suma/test/TestData/test_testsuite` folder.

## Packaging
Distributions can be packaged using `setuptools` based setup scripts:
```shell
python setup_acas_sxu_suma.py bdist_wheel
python setup_acas_sxu_suma_test.py bdist_wheel
```

Update the [Changelog](Changelog.md) before a release.

## Versioning
Version number is composed of corresponding ADD version and a version number incremented during local development. For example, for ADD V4R1, second version the number is `4.1.1`. Repo tags are used to mark a commit with a version number.

## CI
Continuous integration creates wheels and executes tests. For tags in the version number format a version number is injected from the tag into the package's code and deployment to PyPI and generic repositories is automatically executed. Therefore to make a release only the changelog needs to be updated and an appropriate git tag needs to be created — CI handles the rest automatically.

Local runner caches are used to avoid repeated large data downloads (see `cache*.*` scripts). Create new variants of the downloaded files and update the scripts (increase the version number and update the links) when any change is required. Run a pipeline with `CI_INVALIDATE_CACHES` variable set to `true` to force the data re-download when necessary.

Specific platform, tools and additional data may be required to execute the CI/CD script. See [.gitlab-ci.yml](.gitlab-ci.yml) for details.

## See also
Based on [APIS template](https://aeegitlab.honeywell.com/APIS/Template/tree/release/).
