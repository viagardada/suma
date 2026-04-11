*These notes are based on their [ADDA](https://aeegitlab.honeywell.com/TCAS-Evolution/ADDA/-/blob/master/doc/Notes.md) and [UMA](https://aeegitlab.honeywell.com/TCAS-Evolution/UMA/-/blob/master/doc/Notes.md) counterparts.*

# Julia code structure
Julia code is split to directories based on ADD chapters and added code. Added code consists of:
* `Aliases.jl` – Type aliases based on chapter *1.6.1 Data Types*.
* `DataTableFormatSpecification/LoadDataTables.jl` – Data tables loading.
* `ParameterFileSpecification/LoadParams.jl` – Params loading, using `JSON` Julia package.
* `DataStructures/paramsfile_type.jl` – Params types declarations.
* `ACAS_sXu.jl` – Module unifying all code under `ACAS_sXu` module and providing `STM` and `TRM` types for storage of STM and TRM (global) states.

# Changes to ADD-extracted Julia code
* Typographical (probably introduced by the typesetting SW):
    * *`’` was replaced by `'` for matrix translations.*
    * *`-` characters were removed from parameter field identifiers.*
* Links to pages `(p. XXX)` with algorithms ware removed.
* STM and TRM global contexts were established (see `ACAS_sXu.jl`):
    * *All algorithms that require access to any non-constant global data (including `params()`) receive `this` as first parameter. `this` is of `STM` or `TRM` type based on in what module(s) is the algorithm used.*
        * `global <variable>` statements were completely removed.
        * This is to allow execution of several ACAS X instances in one process and higher flexibility.
        * Context has to be constructed and properly passed by the calling code and non-const global access needs to be done through the context (e.g. `own` replaced with `this.own`). Statements that haven't been updated and will typically result in a crash when evaluated.
    * *All `params()` calls were replaced by `this.params` and dot syntax was replaced by subscript (indexing) syntax (e.g. `params().actions.num_actions` was replaced by `this.params["actions"]["num_actions"]`).*
        * This is to allow easy params file load and use with [JSON.jl](https://github.com/JuliaIO/JSON.jl).
        * Indexing syntax needs to be used for params queries. Params need to be provided as a string-indexable structure. Params queries that don't follow the new syntax will result in a crash when evaluated.
* *Additional analysis outputs were added (logging):*
    * This is to allow capture of internal ACAS X data for analysis.
* *All code has been placed to `ACAS_sXu` module (namespace):*
    * This is to avoid potential name clashes with other ACAS X implementations.
    * Any fully-qualified type names must be updated with the `ACAS_sXu.` prefix. Type references used within the module are unaffected by this change, except for the cases where a full names are used (e.g. `GetTrackID`).

## Annotation
All changes/additions are marked with `# HON:` comments. Whole added files are marked with `# Whole file by HON.`.
