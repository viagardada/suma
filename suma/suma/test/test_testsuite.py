#!/usr/bin/env python3

from unittest import TestCase as _TestCase


# Incorrect stm_report.trm_input.own.trm_velmode
INCORRECT_VELMODE_ENCOUNTERS = [
    'Encounter8420801Aircraft1',
    ]


# Incorrect stm_report.trm_input.intruder[0].classification
INCORRECT_CLASSIFICATION_ENCOUNTERS = [
    'Encounter8421001Aircraft1',
    'Encounter8421002Aircraft1',
    'Encounter8421003Aircraft1',
    ]


class TestSuiteTest(_TestCase):
    """
    Tests based on official (ASIM) Test Suite.

    All STM, TRM and TRM Costs are compared. Values are compared to the
    same number of significant figures as in the reference files,
    unless special processing is used. See VerificationNotes for details
    on relaxations.

    Test methods are generated on module import by scanning the folder
    structure.
    """

    # Maximum number of compared significant figures.
    # The chosen value allows some error accumulation on top of the
    # Double Precision's 15-17 significant figures.
    # TODO: process the issue #326
    max_significant_figures = 13

    # Absolute comparison precision of horizontal intruder beliefs.
    # TODO: process the issue #326
    horizontal_belief_precision = 1e-7

    # Absolute comparison precision of intruder bearing reported by STM
    # to display.
    # TODO: process the issue #326
    bearing_precision = 1e-11

    # Absolute comparison precision of horizontal speed reported by STM
    # to display.
    # TODO: process the issue #326
    speed_precision = 1e-9

    # Absolute comparison precision of horizontal speed reported by STM
    # to display.
    # TODO: process the issue #326
    ground_range_precision = 1e-7

    # Maximum number of compared significant figures for TRM costs.
    # Also used for TDS comparison since the cost of CoC is included in
    # its value.
    # The Half Precision used for cost tables provides 3-4 significant
    # figures. This value was increased, since the reported precision
    # seems to be generally higher.
    # TODO: process the issue #326
    costs_max_significant_figures = 7

    # Absolute value threshold below which TRM costs are considered
    # to be equal to zero.
    # The Half Precision used for cost tables minimum is approx. 6.1E-5.
    # TODO: process the issue #326
    considered_zero_cost_threshold = 1e-10

    def _compare_stm_output(self, test_name, reference, test):
        """
        Compare Test Case STM Output file contents.
        """

        from CASCARA import AssertStructSigFigsEqual, SerializeBackTrace

        is_incorrect_velmode_encounter = (
            any(test in test_name for test in INCORRECT_VELMODE_ENCOUNTERS))
        is_incorrect_classification_encounter = (
            any(test in test_name for test in INCORRECT_CLASSIFICATION_ENCOUNTERS))

        (test_data, reference_data) = (
            test['acasx_reports'], reference['acasx_reports'])

        # All reference outputs must be compared but having one more
        # test output is fine.
        self.assertTrue(0 <= len(test_data) - len(reference_data) <= 1)

        for report_idx, (test_report, reference_report) in enumerate(
                zip(test_data, reference_data)):
            back_trace = []
            try:
                # This is where any "special cases" are handled by
                # modifying the reference and/or tested report(s).
                # E.g. reducing compared sig. figures, re-ordering...
                test_report_entry = test_report['acas_sxu_do396']['stm_report']
                reference_report_entry = reference_report['acas_sxu_do396']['stm_report']

                # Sorting both lists by "id", ignoring prioritization order.
                self.sort_by_id(test_report_entry['trm_input']['intruder'])
                self.sort_by_id(test_report_entry['display'])
                self.sort_by_id(reference_report_entry['trm_input']['intruder'])
                self.sort_by_id(reference_report_entry['display'])

                # Special handling for horizontal intruder beliefs and
                # some display entries (bearings and horizontal speeds).
                self._compare_intruder_belief_horiz(
                    test_report_entry,
                    reference_report_entry,
                    self.horizontal_belief_precision)
                self._compare_relaxed_stm_display_entries(
                    test_report_entry, reference_report_entry,
                    self.speed_precision,
                    self.bearing_precision)

                if is_incorrect_velmode_encounter:
                    self._remove_own_velmode(test_report_entry)
                    self._remove_own_velmode(reference_report_entry)

                if is_incorrect_classification_encounter:
                    self._remove_intruder_classification(test_report_entry)
                    self._remove_intruder_classification(reference_report_entry)

                AssertStructSigFigsEqual(
                    self, test_report, reference_report,
                    backTrace=back_trace)
            except AssertionError as ex:
                back_trace.insert(0, "acasx_reports[{}]".format(report_idx))
                raise AssertionError("{} ({})".format(
                    str(ex), SerializeBackTrace(back_trace))) from ex

    def _compare_trm_output(self, test_name, reference, test):
        """
        Compare Test Case TRM Output file contents.
        """

        from CASCARA import AssertStructSigFigsEqual, SerializeBackTrace

        is_incorrect_velmode_encounter = (
            any(test in test_name for test in INCORRECT_VELMODE_ENCOUNTERS))
        is_incorrect_classification_encounter = (
            any(test in test_name for test in INCORRECT_CLASSIFICATION_ENCOUNTERS))

        if is_incorrect_velmode_encounter:
            tds_significant_figures = 1
        else:
            tds_significant_figures = self.costs_max_significant_figures

        (test_data, reference_data) = (
            test['acasx_reports'], reference['acasx_reports'])

        # All reference outputs must be compared but having one more
        # test output is fine.
        self.assertTrue(0 <= len(test_data) - len(reference_data) <= 1)

        for report_idx, (test_report, reference_report) in enumerate(
                zip(test_data, reference_data)):
            back_trace = []
            try:
                # This is where any "special cases" are handled by
                # modifying the reference and/or tested report(s).
                # E.g. reducing compared sig. digits, re-ordering...
                test_report_entry = test_report['acas_sxu_do396']['trm_report']
                reference_report_entry = reference_report['acas_sxu_do396']['trm_report']

                # Sorting both lists by "id", ignoring prioritization order.
                self.sort_by_id(test_report_entry['display_vert']['intruder'])
                self.sort_by_id(test_report_entry['display_horiz']['intruder'])
                self.sort_by_id(test_report_entry['coordination'])
                self.sort_by_id(reference_report_entry['display_vert']['intruder'])
                self.sort_by_id(reference_report_entry['display_horiz']['intruder'])
                self.sort_by_id(reference_report_entry['coordination'])

                # Maximum number of compared significant figures for TDS
                # is different than the rest of entires in the TRM report
                self._reduce_tds_precision(reference_report_entry, tds_significant_figures)

                if is_incorrect_velmode_encounter:
                    self._remove_trm_velmode(test_report_entry)
                    self._remove_trm_velmode(reference_report_entry)

                if is_incorrect_classification_encounter:
                    self._remove_coordination(test_report_entry)
                    self._remove_coordination(reference_report_entry)

                AssertStructSigFigsEqual(
                    self, test_report, reference_report,
                    backTrace=back_trace)
            except AssertionError as ex:
                back_trace.insert(0, "acasx_reports[{}]".format(report_idx))
                raise AssertionError("{} ({})".format(
                    str(ex), SerializeBackTrace(back_trace))) from ex

    def _compare_trm_costs(self, test_name, reference, test):
        """
        Compare Test Case TRM Costs Output file contents.
        """

        from CASCARA import AssertStructSigFigsEqual, SerializeBackTrace

        del test_name  # Unused.

        (test_data, reference_data) = (
            test['CostInfo'][0]['Encounter'], reference['CostInfo'][0]['Encounter'])

        # All reference outputs must be compared but having one more
        # test output is fine.
        self.assertTrue(0 <= len(test_data) - len(reference_data) <= 1)

        for report_idx, (test_costs, reference_costs) in enumerate(
                zip(test_data, reference_data)):
            back_trace = []
            try:
                # This is where any "special cases" are handled by
                # modifying the reference and/or tested costs.
                # E.g. reducing compared sig. figures, re-ordering...

                # Sort both tested and reference costs by ID.
                # The order used in costs files is undefined.
                self.sort_individual_costs_by_id(test_costs)
                self.sort_individual_costs_by_id(reference_costs)
                self.sort_horizontal_costs_by_id(test_costs)
                self.sort_horizontal_costs_by_id(reference_costs)

                self.round_near_zeroes_costs(test_costs)
                self.round_near_zeroes_costs(reference_costs)

                self.remove_empty_horizontal_costs_parts(test_costs)
                self.remove_empty_horizontal_costs_parts(reference_costs)

                AssertStructSigFigsEqual(
                    self, test_costs, reference_costs,
                    backTrace=back_trace)
            except AssertionError as ex:
                back_trace.insert(
                    0, "CostInfo[0]Encounter[{}]".format(report_idx))
                raise AssertionError("{} ({})".format(
                    str(ex), SerializeBackTrace(back_trace))) from ex

    def _test_json_test_case(
            self, test_name, stm_input_path, stm_reference_path,
            trm_reference_path, costs_reference_path, test_output_dir,
            model_parameters):
        from CASCARA import (
            ChangeCWD,
            GetPackageParentFolder,
            AssureFolderExists,
            LoadTestCaseWithSigFigures,
            )
        from os.path import join
        from json import load

        with ChangeCWD(GetPackageParentFolder(__file__)):
            AssureFolderExists(test_output_dir)

            stm_report_file_path = join(
                test_output_dir, "{}STMReport.json".format(test_name))
            trm_report_file_path = join(
                test_output_dir, "{}TRMReport.json".format(test_name))
            trm_costs_file_path = join(
                test_output_dir, "{}CostOutput.json".format(test_name))

            if (model_parameters is not None):
                model_parameters = model_parameters.copy()
            else:
                model_parameters = {}

            # Whether coordination reachback is applied can be found
            # in the test input file description.
            coordination_reach_back_seconds = 0.0
            if (any((
                    scenario in test_name
                    for scenario
                    in [
                        'Encounter2200003Aircraft1',
                        ]
                    ))):
                coordination_reach_back_seconds = 0.6
            model_parameters['coordination_reach_back_seconds'] = coordination_reach_back_seconds
            model_parameters['enable_table_caching'] = True

            # Debug: Enable to capture the equivalent Julia script.
            # model_parameters['julia_script_path'] = f"{test_name}.jl"

            self.simulate(
                test_name, stm_input_path, stm_report_file_path,
                trm_report_file_path, trm_costs_file_path, model_parameters)

            with open(stm_reference_path) as reference_file, \
                 open(stm_report_file_path) as test_file:
                self._compare_stm_output(
                    test_name,
                    LoadTestCaseWithSigFigures(
                        reference_file,
                        self.max_significant_figures),
                    load(test_file))

            with open(trm_reference_path) as reference_file, \
                 open(trm_report_file_path) as test_file:
                self._compare_trm_output(
                    test_name,
                    LoadTestCaseWithSigFigures(
                        reference_file,
                        self.max_significant_figures),
                    load(test_file))

            # TODO: Uncomment the following lines when Cost implementation is ready
#             with open(costs_reference_path) as reference_file, \
#                  open(trm_costs_file_path) as test_file:
#                 self._compare_trm_costs(
#                     test_name,
#                     LoadTestCaseWithSigFigures(
#                         reference_file,
#                         self.costs_max_significant_figures),
#                     load(test_file))

    def _assert_within_tolerance(
            self, test, reference, tolerance,
            msg=None):
        """
        Assert the difference between tesed and reference value is below
        the specified threshold.
        reference -- Reference value, potentially with embedded
            significant digits.
        """

        if (not isinstance(reference, str)):
            if (isinstance(reference, tuple)):
                reference = reference[0]
            msg = f"{msg} ({test} != {reference})"
            self.assertLess(abs(test - reference), tolerance, msg=msg)
        else:
            self.assertEqual(test, reference, msg=msg)

    def _compare_intruder_belief_horiz(self, test_report, reference_report, precision):
        """
        Compare the belief_horiz contents of all intruders in
        trm_input.intruder. Uses the given absolute precision.

        Removes the entries from futher comparison.
        """

        self.assertEqual(
            len(test_report['trm_input']['intruder']),
            len(reference_report['trm_input']['intruder']),
            msg='STM TRM input intruder lists are not the same size.')

        for test_intruder, reference_intruder in zip(
                test_report['trm_input']['intruder'],
                reference_report['trm_input']['intruder']):
            self.assertEqual(
                len(test_intruder['belief_horiz']),
                len(reference_intruder['belief_horiz']),
                msg="STM intruder {} horizontal belief lists are not the same size.".format(
                    test_intruder['id']))

            for test_belief, reference_belief in zip(
                    test_intruder['belief_horiz'],
                    reference_intruder['belief_horiz']):
                self._assert_within_tolerance(
                    test_belief['dx_rel'], reference_belief['dx_rel'],
                    precision,
                    msg="TRM input intruder horizontal dX belief outside allowed tolerance")
                del test_belief['dx_rel']
                del reference_belief['dx_rel']
                self._assert_within_tolerance(
                    test_belief['dy_rel'], reference_belief['dy_rel'],
                    precision,
                    msg='TRM input intruder horizontal dY belief outside allowed tolerance')
                del test_belief['dy_rel']
                del reference_belief['dy_rel']
                self._assert_within_tolerance(
                    test_belief['x_rel'], reference_belief['x_rel'],
                    precision,
                    msg='TRM input intruder horizontal X belief outside allowed tolerance')
                del test_belief['x_rel']
                del reference_belief['x_rel']
                self._assert_within_tolerance(
                    test_belief['y_rel'], reference_belief['y_rel'],
                    precision,
                    msg='TRM input intruder horizontal Y belief outside allowed tolerance')
                del test_belief['y_rel']
                del reference_belief['y_rel']

    def _compare_single_relaxed_stm_display_entries(
            self, test_display, reference_display,
            horizontal_speed_precision, bearing_precision):
        self._assert_within_tolerance(
            test_display['dx_rel_fps'],
            reference_display['dx_rel_fps'],
            horizontal_speed_precision,
            msg='Intruder STM display X speed outside allowed tolerance')
        del test_display['dx_rel_fps']
        del reference_display['dx_rel_fps']
        self._assert_within_tolerance(
            test_display['dy_rel_fps'],
            reference_display['dy_rel_fps'],
            horizontal_speed_precision,
            msg='Intruder STM display Y speed outside allowed tolerance')
        del test_display['dy_rel_fps']
        del reference_display['dy_rel_fps']
        self._assert_within_tolerance(
            test_display['bearing_rel_rad'],
            reference_display['bearing_rel_rad'],
            bearing_precision,
            msg='Intruder STM display bearing outside allowed tolerance')
        del test_display['bearing_rel_rad']
        del reference_display['bearing_rel_rad']
        self._assert_within_tolerance(
            test_display['r_ground_ft'],
            reference_display['r_ground_ft'],
            self.ground_range_precision,
            msg='Intruder STM display ground range outside allowed tolerance')
        del test_display['r_ground_ft']
        del reference_display['r_ground_ft']

    def _compare_relaxed_stm_display_entries(
            self, test_report, reference_report,
            horizontal_speed_precision, bearing_precision):
        """
        Compare the bearing and horizontal speeds of each display
        struct in the display list and stm_display of each intruder in
        trm_input.intruder. Uses the given absolute precision.

        Removes the entries from futher comparison.
        """

        self.assertEqual(
            len(test_report['trm_input']['intruder']),
            len(reference_report['trm_input']['intruder']),
            msg='STM TRM input intruder lists are not the same size.')
        self.assertEqual(
            len(test_report['display']),
            len(reference_report['display']),
            msg='STM display lists are not the same size.')

        for test_intruder, reference_intruder in zip(
                test_report['trm_input']['intruder'],
                reference_report['trm_input']['intruder']):
            self._compare_single_relaxed_stm_display_entries(
                test_intruder['stm_display'],
                reference_intruder['stm_display'],
                horizontal_speed_precision, bearing_precision)
        for test_display, reference_display in zip(
                test_report['display'],
                reference_report['display']):
            self._compare_single_relaxed_stm_display_entries(
                test_display, reference_display,
                horizontal_speed_precision, bearing_precision)

    def _reduce_tds_precision(self, report, significant_figures):
        """
        Reduce the number of compared significant figures for the
        tds fields
        """
        for intruder in report['display_vert']['intruder']:
            intruder['tds'] = (
                intruder['tds'][0],
                min(significant_figures, intruder['tds'][1]))
        for intruder in report['display_horiz']['intruder']:
            intruder['tds'] = (
                intruder['tds'][0],
                min(significant_figures, intruder['tds'][1]))

    @staticmethod
    def _remove_own_velmode(report_entry):
        del report_entry['trm_input']['own']['trm_velmode']

    @staticmethod
    def _remove_trm_velmode(report_entry):
        del report_entry['display_horiz']['trm_velmode']
        del report_entry['display_horiz']['wind_relative']

    @staticmethod
    def _remove_intruder_classification(report_entry):
        for intruder in report_entry['trm_input']['intruder']:
            del intruder['classification']

    @staticmethod
    def _remove_coordination(report_entry):
        del report_entry['display_vert']
        del report_entry['display_horiz']['cc']
        del report_entry['display_horiz']['target_angle']
        del report_entry['coordination']
        del report_entry['broadcast_msg']
        del report_entry['alerting_data']
        for intruder in report_entry['display_horiz']['intruder']:
            del intruder['tds']
            del intruder['classification']
            del intruder['code']

    @staticmethod
    def simulate(
            test_name, stm_input_path, stm_report_file_path,
            trm_report_file_path, trm_costs_file_path, model_parameters):
        from CASCARA import (
            AutoOutputParameters,
            JSONTestCaseSTMInputSourceParameters,
            JSONTestCaseSTMOutputHandlerParameters,
            JSONTestCaseTRMCostsHandlerParameters,
            JSONTestCaseTRMOutputHandlerParameters,
            ModeCCachingAdapterParameters,
            ModelParameters,
            SanityCheckingAdapterParameters,
            Simulation,
            )

        Simulation().Run(
            [
                ModelParameters(
                    'suma',
                    parameters=model_parameters,
                    adapters=[
                        ModeCCachingAdapterParameters(),
                        ]),
            ],
            [
                JSONTestCaseSTMInputSourceParameters(stm_input_path),
                AutoOutputParameters(
                    # Tests typically start at 0.0 s, first reference output
                    # comes at 1.0 s.
                    offset_Seconds=1.0),
            ],
            [
                JSONTestCaseSTMOutputHandlerParameters(
                    stm_report_file_path),
                JSONTestCaseTRMOutputHandlerParameters(trm_report_file_path),
                JSONTestCaseTRMCostsHandlerParameters(trm_costs_file_path),
            ],
            adapters=[
                SanityCheckingAdapterParameters(),
                ],
            # Out of order input message in following encounter
            # to hit a branch in the code
            allowUnorderedTime=('Encounter7000020Aircraft1' in test_name))

    @staticmethod
    def sort_by_id(intruders):
        """
        Sort an intruder list by id. For comparison, where
        prioritization should be ignored.
        """

        intruders.sort(key=lambda intruder: intruder['id'])

    @staticmethod
    def sort_individual_costs_by_id(encounter_costs):
        if ('Individual' in encounter_costs['data']):
            encounter_costs['data']['Individual'].sort(
                key=lambda individual_costs: individual_costs['int_id'])

    @staticmethod
    def sort_horizontal_costs_by_id(encounter_costs):
        if ('PrioritizeAndFilterIntruders' in encounter_costs['data_horiz']):
            encounter_costs['data_horiz']['PrioritizeAndFilterIntruders'].sort(
                key=lambda filter_intruder: filter_intruder['id'])

        if ('SelectHorizontalAdvisory' in encounter_costs['data_horiz']):
            for advisory in encounter_costs['data_horiz']['SelectHorizontalAdvisory']:
                advisory['HorizontalCostFusion']['Individual'].sort(
                        key=lambda intruder: intruder['id'])

    @staticmethod
    def round_near_zero(item, zero_threshold):
        if (isinstance(item, tuple)):
            (value, sig_figures) = item
            if (abs(value) < zero_threshold):
                value = 0.0
            return (value, sig_figures)
        if (isinstance(item, (int, float, complex)) and
                abs(item) < zero_threshold):
            item = 0.0
        return item

    def round_near_zeroes_action(self, action_costs):
        for cost_name in action_costs.keys():
            if cost_name == 'Online Itemized':
                self.round_near_zeroes_dict(action_costs[cost_name])
            else:
                action_costs[cost_name] = self.round_near_zero(
                    action_costs[cost_name],
                    self.considered_zero_cost_threshold)

    def round_near_zeroes_dict(self, dict_costs):
        for cost_name in dict_costs.keys():
            dict_costs[cost_name] = self.round_near_zero(
                dict_costs[cost_name],
                self.considered_zero_cost_threshold)

    def round_near_zeroes_costs(self, encounter_costs):
        if ('Individual' in encounter_costs['data']):
            for individual in encounter_costs['data']['Individual']:
                for action in individual['values'].values():
                    self.round_near_zeroes_action(action)

        if ('Combined' in encounter_costs['data']):
            for combined in encounter_costs['data']['Combined']:
                if ('UnequippedCostFusion' in combined):
                    combined['UnequippedCostFusion']['COC'] = self.round_near_zero(
                        combined['UnequippedCostFusion']['COC'],
                        self.considered_zero_cost_threshold)

        if ('PrioritizeAndFilterIntruders' in encounter_costs['data_horiz']):
            for intruder in encounter_costs['data_horiz']['PrioritizeAndFilterIntruders']:
                if ('offline_costs' in intruder):
                    self.round_near_zeroes_dict(intruder['offline_costs'])

        if ('SelectHorizontalAdvisory' in encounter_costs['data_horiz']):
            for advisory in encounter_costs['data_horiz']['SelectHorizontalAdvisory']:
                if ('Combined' in advisory):
                    self.round_near_zeroes_dict(advisory['Combined'])
                if ('Combined' in advisory['HorizontalCostFusion']):
                    self.round_near_zeroes_dict(advisory['HorizontalCostFusion']['Combined'])
                for intruder in advisory['HorizontalCostFusion']['Individual']:
                    if ('offline_costs' in intruder):
                        self.round_near_zeroes_dict(intruder['offline_costs'])
                if ('ApplyHorizontalOnlineCosts' in advisory):
                    self.round_near_zeroes_dict(advisory['ApplyHorizontalOnlineCosts'])
                    for action_name in advisory['ApplyHorizontalOnlineCosts'].keys():
                        self.round_near_zeroes_dict(
                            advisory['ApplyHorizontalOnlineCosts'][action_name])

    @staticmethod
    def remove_empty_horizontal_costs_parts(encounter_costs):
        if ('PrioritizeAndFilterIntruders' in encounter_costs['data_horiz'] and
                len(encounter_costs['data_horiz']['PrioritizeAndFilterIntruders']) < 1):
            del encounter_costs['data_horiz']['PrioritizeAndFilterIntruders']

        if ('SelectHorizontalAdvisory' in encounter_costs['data_horiz'] and
                len(encounter_costs['data_horiz']['SelectHorizontalAdvisory']) < 1):
            del encounter_costs['data_horiz']['SelectHorizontalAdvisory']

    @staticmethod
    def _generate_test(
            test_name, stm_input_path, stm_reference_path,
            trm_reference_path, costs_reference_path, test_output_dir,
            model_parameters=None, allowed_to_fail=False):
        def _test(self):
            try:
                # pylint: disable=protected-access
                self._test_json_test_case(
                    test_name, stm_input_path, stm_reference_path,
                    trm_reference_path, costs_reference_path,
                    test_output_dir, model_parameters)
            except AssertionError as ex:
                if (allowed_to_fail):
                    self.skipTest("Allowed to fail: {}".format(ex))
                raise
        return _test

    @staticmethod
    def list_input_files(test_data_dir):
        from os.path import join
        from os import walk

        test_case_folders = [
            join(test_data_dir, 'TestGroup10'),
            join(test_data_dir, 'TestGroup20'),
            join(test_data_dir, 'TestGroup30'),
            join(test_data_dir, 'TestGroup40'),
            join(test_data_dir, 'TestGroup50'),
            join(test_data_dir, 'TestGroup60'),
            join(test_data_dir, 'TestGroup70'),
            join(test_data_dir, 'TestGroup80'),
            join(test_data_dir, 'TestGroup99'),
            ]

        return [
            join(root, name)
            for folder in test_case_folders
            for root, _, files in walk(folder)
            for name in files
            if (name.endswith('Input.json'))
            ]

    @staticmethod
    def get_test_name_from_input_path(test_case_path, test_data_dir):
        from os.path import relpath
        from re import sub

        return "test_{}".format(
            sub(r'[/\\]', '_', relpath(test_case_path, test_data_dir)).replace('Input.json', ''))

    @staticmethod
    def generate_tests():
        """
        Generate tests from individual Test Suite cases.
        """

        from CASCARA import GetPackageTestDataFolder
        from os.path import join
        from re import sub

        test_data_dir = GetPackageTestDataFolder(
            'test_testsuite', __file__)
        test_output_dir = join(test_data_dir, 'TestOutputs')

        for test_case_path in TestSuiteTest.list_input_files(
                test_data_dir):
            test_name = TestSuiteTest.get_test_name_from_input_path(
                test_case_path, test_data_dir)

            stm_reference_path = sub(
                r'Input\.json$',
                'StmReport.json',
                test_case_path)
            trm_reference_path = sub(
                r'Input\.json$',
                'TrmReport.json',
                test_case_path)
            costs_reference_path = sub(
                r'Input\.json$',
                'CostFile.json',
                test_case_path)

            setattr(
                TestSuiteTest,
                test_name,
                TestSuiteTest._generate_test(
                    test_name,
                    test_case_path,
                    stm_reference_path,
                    trm_reference_path,
                    costs_reference_path,
                    test_output_dir))


TestSuiteTest.generate_tests()
