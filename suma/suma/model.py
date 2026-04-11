#!/usr/bin/env python3

from CASCARA import AsyncModel as _AsyncModel


# Environment variable queried for a path to params file,
# unless already found.
PARAMS_FALLBACK_ENVVAR = 'SUMA_PARAMS_FILE'


def _find_params():
    """
    Find params file embedded in the Python package.
    """

    from os import getenv
    from os.path import abspath, dirname, join, exists

    package_folder = dirname(abspath(__file__))
    params_path = join(
        package_folder, 'LookupTables',
        'DO-396_paramsfile_acassxu_origami_20220908.txt')
    if (exists(params_path)):
        return params_path
    params_path = getenv(PARAMS_FALLBACK_ENVVAR)
    if (params_path is not None and
            exists(params_path)):
        return params_path
    return None


class Model(_AsyncModel):
    """
    CASCARA model based on Julia ACAS sXu code extracted from ADD.

    Features:
    * STM-only operation
    * Coordination reachback
    * Lookup table caching to avoid re-initialization overhead
    * Julia runtime isolation into a separate process
    * Execution exception recovery is not possible

    Potential Modifications status
    ("original" means original ADD implementation is used):
    * Descent Inhibit Thresholds – implemented (original),
      (ReceiveDescentInhibitThresholds) none are used.
    * Target Designation – implemented (original) and input is supported
      by the model (ReceiveTargetDesignation), but doesn't do anything.
      Housekeeping is implemented (original), but not used.

    Used CASCARA I/O:
    * Inputs (from InputEvent.Type):
        * ReceiveAbsoluteGeodeticTracksXuV4R0
        * ReceiveADSBOperationalStatusMessage
        * ReceiveDescentInhibitThresholds
        * ReceiveDiscretessXuV4R2
        * ReceiveExternallyValidatedADSB
        * ReceiveExternallyValidatedV2VsXuV4R0
        * ReceiveHeadingObservationV15R2
        * ReceiveHeightAglObservation
        * ReceiveModeStatusReportsXuV4R2
        * ReceiveOwnRelNonCoopTracksXuV4R2
        * ReceivePointObstacleReportsXuV4R0
        * ReceivePresAltObservation
        * ReceiveStateVectorUatReportXuV4R2
        * ReceiveStateVectorPositionReportsXuV4R2
        * ReceiveStateVectorVelocityReportsXuV4R2
        * ReceiveStateVectorV2VReportsXuV4R2
        * ReceiveTargetDesignationsXuV4R0
        * ReceiveTrueAirspeedObservationsXuV4R2
        * ReceiveV2VCoordinationsXuV4R0
        * ReceiveV2VOperationalStatusMessagesXuV4R2
        * ReceiveWgs84ObservationsXuV4R0
    * Outputs (on OutputEvent):
        * STMReportsXuV4R2
        * sXuTRMReportsXuV4R2
    """

    def __init__(self, parameters):
        """
        parameters -- Dictionary with:
            [optional] use_trm -- Instantiate TRM. Only STM is used if
                False. Default is True.
            [optional] stm_params_file -- Custom STM params JSON file
                path. Embedded is used by default. If not found,
                SUMA_PARAMS_FILE envvar is queried.
            [optional] trm_params_file -- Custom TRM params JSON file
                path. Embedded is used by default. If not found,
                SUMA_PARAMS_FILE envvar is queried.
            [optional] coordination_reach_back_seconds -- Postpone
                processing so that coordination messages
                (ReceiveV2VCoordinationsXuV4R0) up to this time into the new
                cycle (i.e. after OutputEvent) are processed before TRM
                is executed. The value needs to be lower than the length
                of the output creation interval. Default is 0.0.
            [optional] enable_table_caching -- Keep the lookup tables
                cached or reuse already cached lookup tables. Note this
                doesn't check for stm/trm_params_file path changes.
                Default is False.
            [optional] process_isolation -- Use process isolation for
                the Julia runtime. Slower, but allows multiple different
                interpreters being used by the same simulation. Default
                is False.
            [optional] process_environment -- A dict of environment
                variables of the Julia process. Controls the selected
                Julia runtime and environment. See JuliaInterpreter
                usage for more info. Only applicable when
                process_isolation is used. Parent process envvars are
                used by default.
            [optional] julia_script_path -- Log the invoked Julia
                commands to this file. Creates a standalone script that
                can be invoked directly by the Julia interpreter. When
                disabled, the script is dumped into a log instead.
                Disabled by default.
        """

        from .julia_stm import JuliaSTM
        from .julia_trm import JuliaTRM
        from juliainterpreter import JuliaInterpreter, JuliaInterpreterProcess
        from CASCARA import GetModelLogger
        from os.path import dirname, abspath, join

        super().__init__(parameters)

        self._logger = GetModelLogger(type(self).__name__)
        instance_id = "{}_{}".format(type(self).__name__, id(self))
        self._coordination_reach_back_seconds = parameters.get(
            'coordination_reach_back_seconds', 0.0)
        self._input_cache = []
        self._stm_output_cache = None
        self._last_output_time = float('NaN')

        self._julia_script_path = parameters.get('julia_script_path', "")
        self._coordination_received = False

        use_trm = parameters.get('useTRM', True)
        table_caching_enabled = parameters.get('enable_table_caching', False)

        self._is_runtime_persistent = False
        if (parameters.get('process_isolation', False)):
            if (table_caching_enabled and
                    Model._persistent_runtime is not None):
                self._runtime = Model._persistent_runtime
                self._is_runtime_persistent = True
                self._runtime.reset_context(instance_id)
            else:
                self._runtime = JuliaInterpreterProcess(
                    instance_id,
                    collect_history=True,
                    env=parameters.get('process_environment'),
                    # Need to daemonize, since there's not reliable way
                    # to determine when the process is no longer needed.
                    daemon=True if (table_caching_enabled) else None).__enter__()
                if (table_caching_enabled):
                    Model._persistent_runtime = self._runtime
                    self._is_runtime_persistent = True
        else:
            self._runtime = JuliaInterpreter(instance_id, history=[])
        try:
            self._runtime.use_module('ACAS_sXu', join(
                dirname(abspath(__file__)), 'ACAS_sXu'))
            stm_params_file = parameters.get(
                'stm_params_file', self.embedded_params_file_path)
            if (stm_params_file is None):
                raise AttributeError(
                    'No STM params file found. Set the "stm_params_file" model parameter.')
            self._stm = JuliaSTM(self._runtime, stm_params_file)
            trm_params_file = parameters.get(
                'trm_params_file', self.embedded_params_file_path)
            if (trm_params_file is None):
                raise AttributeError(
                    'No TRM params file found. Set the "trm_params_file" model parameter.')
            self._trm = None
            if (use_trm):
                self._trm = (
                    JuliaTRM(
                        self._runtime,
                        trm_params_file,
                        self._stm.stm_context_variable_name,
                        table_caching_enabled=table_caching_enabled))
        except Exception:
            self._report_runtime_history(warning=True)
            self._runtime.__exit__(None, None, None)
            self._runtime = None
            if (self._is_runtime_persistent):
                Model._persistent_runtime = None
            raise

    # Path to embedded params file (including paths to embedded lookup tables).
    embedded_params_file_path = _find_params()

    _persistent_runtime = None

    def _save_julia_commands_into_a_file(self, file_path):
        with open(file_path, 'w') as out_file:
            for line in self._runtime.history:
                out_file.write(line)
                out_file.write("\n")

    def _report_runtime_history(self, warning=False):
        from logging import DEBUG, WARNING

        if (self._julia_script_path):
            self._save_julia_commands_into_a_file(self._julia_script_path)
        else:
            self._logger.log(
                WARNING if (warning) else DEBUG,
                "\n# Command history BEGIN.\n%s\n# Command history END.",
                '\n'.join(self._runtime.history))

    def Execute(self, event):
        from CASCARA import InputEvent, OutputEvent
        from DiscreteSimulation import SynchronizationEvent, StoppedEvent
        from math import isnan

        try:
            if (isinstance(event, SynchronizationEvent)):
                # Finished, but there are cached events.
                # Process anything cached:
                #   Output, cached inputs and Mode C replies.
                if (self._stm_output_cache is None and
                        len(self._input_cache) == 0):
                    yield (
                        event,
                        None,
                        RuntimeError(
                            'More outputs expected, but there are no events left to process.'))
                    return

                for model_output in self._finish_output_processing():
                    yield model_output

                while (len(self._input_cache) > 0):
                    cached_event = self._input_cache.pop(0)
                    for model_output in self._process_input_event(cached_event):
                        yield model_output
            elif (isinstance(event, StoppedEvent)):
                self._report_runtime_history()
                if (not self._is_runtime_persistent):
                    self._runtime.__exit__(None, None, None)
                self._runtime = None
                yield (event, {}, None)
            elif (isnan(self._last_output_time)):
                # Just started or the delayed output was already
                # produced in this cycle.
                # Process any event "normally", typically immediately.
                if (isinstance(event, OutputEvent)):
                    for model_output in self._start_output_processing(event):
                        yield model_output
                    if (self._coordination_reach_back_seconds == 0.0):
                        # Special case: Skip all asynchronicity if no
                        # coordination reachback is set.
                        for model_output in self._finish_output_processing():
                            yield model_output
                else:
                    for model_output in self._process_input_event(event):
                        yield model_output
            elif (event.Time > self._last_output_time + self._coordination_reach_back_seconds):
                # Coordination reachback interval has been reached.
                # Delayed output can be produced and cached outputs can
                # be all processed. The current event is also processed.
                for model_output in self._finish_output_processing(self._coordination_received):
                    yield model_output

                self._coordination_received = False
                while (len(self._input_cache) > 0):
                    cached_event = self._input_cache.pop(0)
                    for model_output in self._process_input_event(cached_event):
                        yield model_output

                if (isinstance(event, OutputEvent)):
                    for model_output in self._start_output_processing(event):
                        yield model_output
                else:
                    for model_output in self._process_input_event(event):
                        yield model_output
            else:
                # Within coordination reachback interval. Any
                # non-coordination inputs are cached to be processed
                # later. Coordination messages are processed immediately.
                if (isinstance(event, OutputEvent)):
                    yield (
                        event,
                        None,
                        RuntimeError(
                            'Another OutputEvent received within coordination reachback interval.'))
                elif (isinstance(event, InputEvent) and
                      event.Type == 'ReceiveV2VCoordinationsXuV4R0'):
                    self._coordination_received = True
                    for model_output in self._process_input_event(event):
                        yield model_output
                else:
                    self._input_cache.append(event)
                    # Processing delayed.
        except Exception:
            if (self._runtime is not None):
                self._report_runtime_history(warning=True)
                self._runtime.__exit__(None, None, None)
                if (self._is_runtime_persistent):
                    Model._persistent_runtime = None
                self._runtime = None
            raise

    def _process_input_event(self, event):
        """
        Process InputEvent.
        """

        from CASCARA import InputEvent

        if (isinstance(event, InputEvent)):
            input_call = None
            try:
                input_call = getattr(self._stm, event.Type)
            except AttributeError:
                raise RuntimeError(
                    "Unsupported input event type \"{}\".".format(
                        event.Type)) from None
            yield (event, input_call(event.Data, event.Time), None)
        else:
            self._logger.debug(
                "Ignored \"%s\" event.",
                type(event).__name__)
            yield (event, {}, None)

    def _start_output_processing(self, event):
        output = {}

        output.update(self._stm.GenerateStmReport(event.Time))

        self._stm_output_cache = (event, output)

        self._last_output_time = event.Time
        yield from ()

    def _finish_output_processing(self, reachback_set=False):
        # Optimization: Assuming output.update calls only add entries.
        #               No conflict resolution needed.
        if (self._stm_output_cache is not None):
            (event, output) = self._stm_output_cache
            self._stm_output_cache = None
            self._last_output_time = float('NaN')

            if (self._trm is not None):
                output.update(self._trm.sXuTRMUpdate(
                    "{}.trm_input".format(
                        self._stm.stm_report_variable_name)))
                output.update(self._stm.StmHousekeeping(
                    self._trm.trm_report_variable_name,
                    event.Time))
                # TODO: to be removed, only for matching with reference results
                #       STM report is captured after TRM is invoked because
                #       TRM modifies content of the STM report
                if (not reachback_set):
                    output['STMReportsXuV4R2'] = self._stm._runtime.evaluate_expr(
                        self._stm.stm_report_variable_name)
            yield (event, output, None)
