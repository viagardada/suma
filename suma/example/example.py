#!/usr/bin/env python3

"""
Python-native equivalent of "example.yml" scenario.
"""


def main():
    import CASCARA
    from os.path import join

    output_dir_path = './output'
    CASCARA.AssureFolderExists(output_dir_path)

    CASCARA.Simulation().Run(
        [
            CASCARA.ModelParameters(
                'suma',
                {
                    # 'use_trm': True,
                    # 'stm_params_file': ...,
                    # 'trm_params_file': ...,
                    # 'coordination_reach_back_seconds': 0.0,
                    # 'enable_table_caching': False,
                    # 'process_isolation': False,
                    # 'process_environment': None,
                    # 'julia_script_path': '',
                },
                adapters=[
                    # Sanity Checking verifies structure of Model inputs
                    # and outputs. Useful for testing and debugging, but
                    # may be slow for large data processing.
                    CASCARA.SanityCheckingAdapterParameters(),
                    # Verify the simulation time is ascending.
                    CASCARA.TimeCheckingModelAdapterParameters(),
                ]),
        ],
        [
            # Automatically produce outputs.
            # Allows to modify start time offset and step, if needed.
            CASCARA.JSONTestCaseSTMInputSourceParameters(
                './Encounter4110010Aircraft1Input.json'),
            # First reference STM report should start 1 s after start
            # time.
            CASCARA.AutoOutputParameters(
                offset_Seconds=1.0),
        ],
        [
            # Display progress.
            CASCARA.ProgressBarHandlerParameters(),
            # ASIM STM output JSON format.
            CASCARA.JSONTestCaseSTMOutputHandlerParameters(
                join(output_dir_path, 'stm_output.json')),
            # ASIM TRM output JSON format.
            CASCARA.JSONTestCaseTRMOutputHandlerParameters(
                join(output_dir_path, 'trm_output.json')),
            # ASIM TRM costs JSON format.
            # Currently not supported by sUMA (always empty).
            CASCARA.JSONTestCaseTRMCostsHandlerParameters(
                join(output_dir_path, 'trm_costs.json')),
            # Generic Newline Delimited JSON log of all model outputs.
            CASCARA.NDJSONFileHandlerParameters(
                join(output_dir_path, 'all_output.ndjson')),
            # Generic Newline Delimited JSON log of all model inputs.
            # Can be useful e.g. when the inputs are generated and/or
            # modified on the fly.
            CASCARA.NDJSONFileInputHandlerParameters(
                join(output_dir_path, 'all_input.ndjson')),
        ])


if (__name__ == '__main__'):
    main()
