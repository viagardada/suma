#!/usr/bin/env python3


def convert_to_z(value):
    from juliainterpreter import convert_to
    return convert_to(value, 'ACAS_sXu.Z')

def convert_to(value, julia_type):
    return "convert({}, {:d})".format(julia_type, value)

# TODO: to be moved to juliainterpreter
def convert_to_v1_uint128(value):
    """convert_to_uint128 variant for 0.5+"""
    return convert_to(value, 'UInt128')

class JuliaSTM:
    def __init__(self, runtime, params_file):
        self._runtime = runtime
        self._stm_name = runtime.create_julia_symbol(
            'stm',
            # Normalize (back)slashes to avoid interpretation as escape
            # sequences.
            "ACAS_sXu.STM(\"{}\")".format(params_file.replace("\\", '/')))
        self._stm_report_name = runtime.create_julia_symbol('stmReport')

    @staticmethod
    def _TryDeserializeSpecialFloats(jsonValue):
        """
        Try to convert JSON value containing format-specific special
        float values. Returns None if the value was not converted.
        """

        from math import nan, inf

        if (jsonValue == '_NaN_'):
            return nan
        if (jsonValue in ['_Inf_', '+_Inf_']):
            return inf
        if (jsonValue == '-_Inf_'):
            return -inf
        return None

    @staticmethod
    def _DeserializeFloat(jsonValue):
        """
        Convert JSON value to float, with format-specific special float values support.
        """

        specialFloatValue = JuliaSTM._TryDeserializeSpecialFloats(jsonValue)
        if (specialFloatValue is None):
            return float(jsonValue)
        return specialFloatValue

    @staticmethod
    def _DeserializeStructureSpecialFloats(structure):
        """
        Convert all format-specific special float JSON (string) values
        among the dictionary or list based structure into floats.
        Works in situ.
        """

        assert(isinstance(structure, (dict, list)))

        keys = (
            list(structure.keys())
            if (isinstance(structure, dict)) else
            range(len(structure)))

        for key in keys:
            if (isinstance(structure[key], (dict, list))):
                JuliaSTM._DeserializeStructureSpecialFloats(
                    structure[key])
            else:
                specialFloatValue = JuliaSTM._TryDeserializeSpecialFloats(
                    structure[key])
                if (specialFloatValue is not None):
                    structure[key] = specialFloatValue

    @property
    def stm_context_variable_name(self):
        return self._stm_name

    def ReceiveStateVectorPositionReportsXuV4R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveStateVectorPositionReport({}, {}, {}, {}, {}, {}, {}, {}, {}, {})"
            .format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['lat_deg'])),
                to_float64_literal(self._DeserializeFloat(data['lon_deg'])),
                to_float64_literal(self._DeserializeFloat(data['alt_ft'])),
                to_bool_literal(data['is_alt_geo_hae']),
                convert_to_v1_uint32(data['mode_s']),
                convert_to_v1_uint32(data['nic']),
                convert_to_v1_uint32(data['q_int_ft']),
                to_bool_literal(data['non_icao']),
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceiveStateVectorVelocityReportsXuV4R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveStateVectorVelocityReport({}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['vel_ew_kts'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ns_kts'])),
                convert_to_v1_uint32(data['mode_s']),
                convert_to_v1_uint32(data['nic']),
                to_bool_literal(data['non_icao']),
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceiveStateVectorUatReportXuV4R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveStateVectorUatReport({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})"
            .format(
                self._stm_name,
                to_float64_literal(data['lat']),
                to_float64_literal(data['lon']),
                to_float64_literal(data['alt']),
                to_bool_literal(data['is_alt_geo_hae']),
                to_float64_literal(data['vel_ew']),
                to_float64_literal(data['vel_ns']),
                convert_to_v1_uint32(data['mode_s']),
                convert_to_v1_uint32(data['nic']),
                convert_to_v1_uint32(data['q_int']),
                to_bool_literal(data['non_icao']),
                to_float64_literal(data['toa'])))
        return {}

    def ReceiveModeStatusReportsXuV4R2(self, data, time):
        from juliainterpreter import (
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveModeStatusReport({}, {}, {}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint32(data['adsb_version']),
                convert_to_v1_uint32(data['nacp']),
                convert_to_v1_uint32(data['nacv']),
                convert_to_v1_uint32(data['gva']),
                convert_to_v1_uint32(data['sil']),
                convert_to_v1_uint32(data['sda']),
                convert_to_v1_uint32(data['mode_s']),
                to_bool_literal(data['is_uat']),
                to_bool_literal(data['non_icao'])))
        return {}

    def ReceiveExternallyValidatedADSB(self, data, time):
        from juliainterpreter import (
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveExternallyValidatedADSB({}, {}, {}, {})".format(
                self._stm_name,
                to_bool_literal(data['externally_validated']),
                convert_to_v1_uint32(data['mode_s']),
                to_bool_literal(data['non_icao'])))
        return {}

    def ReceiveStateVectorV2VReportsXuV4R2(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            convert_to_v1_uint8,
            to_bool_literal,
            to_float64_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveStateVectorV2VReport({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, "
            "{}, {}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['lat_deg'])),
                to_float64_literal(self._DeserializeFloat(data['lon_deg'])),
                to_float64_literal(self._DeserializeFloat(data['alt_pres_ft'])),
                to_float64_literal(self._DeserializeFloat(data['alt_hae_ft'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ew_kts'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ns_kts'])),
                convert_to_v1_uint32(data['nic']),
                convert_to_v1_uint32(data['nacp']),
                convert_to_v1_uint32(data['nacv']),
                to_float64_literal(self._DeserializeFloat(data['vfom_m'])),
                convert_to_v1_uint32(data['sil']),
                convert_to_v1_uint32(data['sda']),
                convert_to_v1_uint128(int(data['v2v_uid'])),
                convert_to_v1_uint32(data['mode_s']),
                to_bool_literal(data['mode_s_non_icao']),
                to_bool_literal(data['mode_s_valid']),
                convert_to_v1_uint8(data['classification']),
                convert_to_v1_uint32(data['q_int']),
                to_float64_literal(data['toa'])))
        return {}

    def ReceiveExternallyValidatedV2VsXuV4R0(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveExternallyValidatedV2V({}, {}, {})".format(
                self._stm_name,
                to_bool_literal(data['externally_validated']),
                convert_to_v1_uint128(int(data['v2v_uid']))))
        return {}

    def ReceiveOwnRelNonCoopTracksXuV4R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            convert_to_v1_uint32,
            convert_to_v1_uint8)
        del time  # Not used.

        xgrgr_mat = self.GetMatrix(data['rel_xgrgr_Sigma'], 4)
        zdz_mat = self.GetMatrix(data['rel_zdz_Sigma'], 2)
        self._runtime.evaluate(
            "ACAS_sXu.ReceiveOwnRelNonCoopTrack({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})"
            .format(
                self._stm_name,
                convert_to_v1_uint32(data['ornct_id']),
                convert_to_v1_uint8(data['track_status']),
                convert_to_v1_uint8(data['classification']),
                to_float64_literal(self._DeserializeFloat(data['toa'])),
                to_float64_literal(self._DeserializeFloat(data['range_ft'])),
                to_float64_literal(self._DeserializeFloat(data['azimuth_rad'])),
                to_float64_literal(self._DeserializeFloat(data['dgr_fps'])),
                to_float64_literal(self._DeserializeFloat(data['dxgr_fps'])),
                xgrgr_mat,
                to_float64_literal(data['rel_z_ft']),
                to_float64_literal(data['rel_dz_fps']),
                zdz_mat))
        return {}

    def ReceiveAbsoluteGeodeticTracksXuV4R0(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            convert_to_v1_uint8,
            convert_to_v1_uint16,
            to_float64_literal,
            to_bool_literal)
        del time  # Not used.

        covariance_horiz_mat = self.GetMatrix([self._DeserializeFloat(sigma)
                            for sigma
                            in data['covariance_horiz_ft_fps']], 4)
        covariance_pres_mat = self.GetMatrix([
                            self._DeserializeFloat(sigma)
                            for sigma
                            in data['covariance_pres_ft_fps']
                            ], 2)
        covariance_hae_mat = self.GetMatrix([
                            self._DeserializeFloat(sigma)
                            for sigma
                            in data['covariance_hae_ft_fps']], 2)
        self._runtime.evaluate(
            "ACAS_sXu.ReceiveAbsoluteGeodeticTrack({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, "
            "{}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint32(data['agt_id']),
                convert_to_v1_uint32(data['mode_s']),
                convert_to_v1_uint128(int(data['v2v_uid'])),
                convert_to_v1_uint16(data['track_status']),
                to_bool_literal(data['externally_validated']),
                convert_to_v1_uint8(data['classification']),
                to_float64_literal(self._DeserializeFloat(data['lat_deg'])),
                to_float64_literal(self._DeserializeFloat(data['lon_deg'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ew_kts'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ns_kts'])),
                covariance_horiz_mat,
                to_float64_literal(self._DeserializeFloat(data['alt_pres_ft'])),
                to_float64_literal(self._DeserializeFloat(data['alt_rate_pres_fps'])),
                covariance_pres_mat,
                to_float64_literal(self._DeserializeFloat(data['alt_hae_ft'])),
                to_float64_literal(self._DeserializeFloat(data['alt_rate_hae_fps'])),
                covariance_hae_mat,
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceivePointObstacleReportsXuV4R0(self, data, time):
        from juliainterpreter import (
            convert_to_v1_uint32,
            to_float64_literal,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceivePointObstacleReport({}, {}, {}, {}, {}, {})"
            .format(
                self._stm_name,
                convert_to_v1_uint32(data['po_id']),
                to_float64_literal(data['lat_deg']),
                to_float64_literal(data['lon_deg']),
                to_float64_literal(data['alt_hae_ft']),
                to_bool_literal(data['to_be_deleted'])))
        return {}

    def ReceiveDiscretessXuV4R2(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            convert_to_v1_uint8,
            to_bool_literal,
            to_float64_literal)
        del time  # Not used.
        self._runtime.evaluate(
            "ACAS_sXu.ReceiveDiscretes({}, {}, {}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint128(int(data['v2v_uid'])),
                to_bool_literal(data['opflg']),
                convert_to_v1_uint8(data['requested_opmode']),
                to_float64_literal(self._DeserializeFloat(data['effective_turn_rate_rad'])),
                to_float64_literal(self._DeserializeFloat(data['effective_vert_rate_fps'])),
                to_bool_literal(data['prefer_wind_relative']),
                to_bool_literal(data['perform_poa']),
                to_bool_literal(data['disable_gpoa']),
                convert_to_v1_uint8(data['equipment'])))
        return {}

    def ReceivePresAltObservation(self, data, time):
        from juliainterpreter import (
            to_float64_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceivePresAltObservation({}, {}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['alt_pres_ft'])),
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceiveHeightAglObservation(self, data, time):
        from juliainterpreter import (
            to_float64_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveHeightAglObservation({}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['h_ft']))))
        return {}

    def ReceiveTrueAirspeedObservationsXuV4R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveTrueAirspeedObservation({}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['hor_true_airspeed_kts']))))
        return {}

    def ReceiveHeadingObservationV15R2(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveHeadingObservation({}, {}, {}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['psi_rad'])),
                to_float64_literal(self._DeserializeFloat(data['toa'])),
                to_bool_literal(data['heading_degraded'])))
        return {}

    def ReceiveWgs84ObservationsXuV4R0(self, data, time):
        from juliainterpreter import (
            to_float64_literal,
            convert_to_v1_uint32)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveWgs84Observation({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                to_float64_literal(self._DeserializeFloat(data['lat_deg'])),
                to_float64_literal(self._DeserializeFloat(data['lon_deg'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ew_kts'])),
                to_float64_literal(self._DeserializeFloat(data['vel_ns_kts'])),
                to_float64_literal(self._DeserializeFloat(data['alt_hae_ft'])),
                to_float64_literal(self._DeserializeFloat(data['alt_rate_hae_fps'])),
                convert_to_v1_uint32(data['nacp']),
                convert_to_v1_uint32(data['nacv']),
                to_float64_literal(self._DeserializeFloat(data['vfom_m'])),
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceiveV2VCoordinationsXuV4R0(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            to_float64_literal,
            convert_to_v1_uint32)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveV2VCoordination({}, {}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint128(int(data['v2v_uid'])),
                convert_to_v1_uint32(data['cvc']),
                convert_to_v1_uint32(data['vrc']),
                convert_to_v1_uint32(data['vsb']),
                convert_to_v1_uint32(data['chc']),
                convert_to_v1_uint32(data['hrc']),
                convert_to_v1_uint32(data['hsb']),
                to_float64_literal(self._DeserializeFloat(data['toa']))))
        return {}

    def ReceiveV2VOperationalStatusMessagesXuV4R2(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            convert_to_v1_uint16,
            convert_to_v1_uint8)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveV2VOperationalStatusMessage({}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint8(data['ca_status']),
                convert_to_v1_uint8(data['sense']),
                convert_to_v1_uint8(data['type_capability']),
                convert_to_v1_uint8(data['priority']),
                convert_to_v1_uint8(data['equipment']),
                convert_to_v1_uint8(data['pilot_or_passengers']),
                convert_to_v1_uint128(int(data['v2v_uid']))))
        return {}

    def ReceiveADSBOperationalStatusMessage(self, data, time):
        from juliainterpreter import (
            convert_to_v1_uint32,
            convert_to_v1_uint8,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveADSBOperationalStatusMessage({}, {}, {}, {}, {}, {}, {}, {})".format(
                self._stm_name,
                convert_to_v1_uint8(data['ca_operational']),
                convert_to_v1_uint8(data['sense']),
                convert_to_v1_uint8(data['type_capability']),
                convert_to_v1_uint8(data['priority']),
                convert_to_v1_uint8(data['daa']),
                convert_to_v1_uint32(data['mode_s']),
                to_bool_literal(data['non_icao'])))
        return {}

    def ReceiveDescentInhibitThresholds(self, data, time):
        from juliainterpreter import (
            to_float64_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveDescentInhibitThresholds({}, {}, {})".format(
                self._stm_name,
                to_float64_literal(data['h_lo_ft']),
                to_float64_literal(data['h_hi_ft'])))
        return {}

    def ReceiveTargetDesignationsXuV4R0(self, data, time):
        from juliainterpreter import (
            # TODO convert_to_v1_uint128,
            convert_to_v1_uint32,
            to_bool_literal)
        del time  # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.ReceiveTargetDesignation({}, {}, {}, {}, {}, {})".format(
                convert_to_v1_uint32(data['mode_s']),
                to_bool_literal(data['mode_s_non_icao']),
                to_bool_literal(data['mode_s_valid']),
                convert_to_v1_uint128(int(data['v2v_uid'])),
                to_bool_literal(data['v2v_uid_valid']),
                convert_to_v1_uint32(data['designation'])))
        return {}

    @staticmethod
    def GetMatrix(subdata, dim):
        from juliainterpreter import to_float64_literal
        assert (len(subdata) % dim == 0)
        mat = '['
        arr = '['
        count = 0
        for i in subdata:
            count += 1
            arr += str(to_float64_literal(i)) + ','
            if count == dim:
                mat += arr[:-1] + '] '
                count = 0
                arr = '['
        return mat + ']'

    @property
    def stm_report_variable_name(self):
        return self._stm_report_name

    # TODO: original version from Xu, update if needed
    def SetOwnshipData(self, time):
        """
        Unofficial extension, allowing invocation of SetOwnshipData
        algorithm. Allows retrieval of TRMOwnInput without invoking
        GenerateStmReport and without affecting the STM state.
        OwnWgs84Timeout and reset based on invalid vertical tracker are
        also emulated.

        The opmode and h_opmode fields are not properly updated and
        are removed.

        returns -- TRMOwnInput, including degradation flags and
            the fields being potentially being invalidated.
        """

        from math import nan
        from juliainterpreter import to_float64_literal

        self._runtime.evaluate(
            ("{report_name} = ACAS_sXu.StmReport()\n"
             "ACAS_sXu.SetOwnshipData({stm_name}, {report_name}, {time})").format(
                report_name=self._stm_report_name,
                stm_name=self._stm_name,
                time=to_float64_literal(time)))
        trm_own_input = self._runtime.evaluate_expr(
            "{}.trm_input.own".format(self._stm_report_name))

        wgs84_is_invalid = self._runtime.evaluate_expr(
            ("({stm_name}.own.wgs84_state == ACAS_sXu.OWN_WGS84_VALID) && "
             "({time} - {stm_name}.own.wgs84_toa > {stm_name}.params["
             "\"surveillance\"][\"ownship_wgs84\"][\"timeout\"])").format(
                stm_name=self._stm_name,
                time=to_float64_literal(time)))
        if (wgs84_is_invalid):
            trm_own_input['degraded_own_surveillance'] &= self._runtime.evaluate_expr(
                '~ACAS_sXu.DEGRADED_OWN_WGS84_COAST')
            trm_own_input['degraded_own_surveillance'] += self._runtime.evaluate_expr(
                'ACAS_sXu.DEGRADED_OWN_WGS84_INVALID')
            trm_own_input['track_angle'] = nan
            trm_own_input['ground_speed'] = nan

        vertical_tracker_is_invalid = self._runtime.evaluate_expr(
            "isnan({stm_name}.own.toa_h)".format(stm_name=self._stm_name))
        if (vertical_tracker_is_invalid):
            trm_own_input['belief_vert'] = []

        del trm_own_input['opmode']
        del trm_own_input['h_opmode']

        return trm_own_input

    def GenerateStmReport(self, time):
        from juliainterpreter import to_float64_literal
        #print("GenerateStmReport -> self._stm_report_name: ", self._stm_report_name)
        #print("GenerateStmReport -> self._stm_name: ", self._stm_name)
        report = self._runtime.evaluate_expr(
            "{} = ACAS_sXu.GenerateStmReport({}, {})".format(
                self._stm_report_name,
                self._stm_name,
                to_float64_literal(time)))
        return {
            'STMReportsXuV4R2': report,
            }

    def StmHousekeeping(self, trmReportExpression, time):
        del time # Not used.

        self._runtime.evaluate(
            "ACAS_sXu.StmHousekeeping({}, {})".format(
                self._stm_name,
                trmReportExpression))
        return {}
