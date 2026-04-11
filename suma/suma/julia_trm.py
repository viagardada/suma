#!/usr/bin/env python3


from enum import IntEnum


class JuliaTRM:
    ID_GROUND = 4294967295

    # Cost Data Place
    class CDP(IntEnum):
        NONE = 0
        ICAO24 = 1
        ANON24 = 2
        V2V_UID = 3
        ORNCT_ID = 4
        AGT_IDS = 5
        PO_ID = 6

    def __init__(
            self, runtime, params_file, stm_context_expression,
            table_caching_enabled=False):
        from juliainterpreter import to_bool_literal

        self._runtime = runtime
        self._runtime.evaluate(
            "ACAS_sXu.SetsXuTableCacheEnabled({})"
            .format(to_bool_literal(table_caching_enabled)))

        self._trm_name = runtime.create_julia_symbol(
            'trm',
            # Normalize (back)slashes to avoid interpretation as escape
            # sequences.
            "ACAS_sXu.TRM(\"{}\", {})".format(
                params_file.replace("\\", '/'),
                stm_context_expression))

        self._sxutrm_state_name = runtime.create_julia_symbol(
            'st_xutrm',
            'ACAS_sXu.sXuTRMState()')
        self._trm_report_name = runtime.create_julia_symbol('trmReport')

    @property
    def trm_report_variable_name(self):
        return self._trm_report_name

    def _transform_variable_id_directory(self, intruder):
        if (intruder['id_directory']['icao24']['valid']):
            intruder['icao24'] = intruder['id_directory']['icao24']['value']
        if (intruder['id_directory']['anon24']['valid']):
            intruder['anon24'] = intruder['id_directory']['anon24']['value']
        if (intruder['id_directory']['v2v_uid']['valid']):
            intruder['v2v_uid'] = intruder['id_directory']['v2v_uid']['value']
        if (intruder['id_directory']['ornct_id']['valid']):
            intruder['ornct_id'] = intruder['id_directory']['ornct_id']['value']
        if (0 < len(intruder['id_directory']['agt_ids'])):
            intruder['agt_ids'] = intruder['id_directory']['agt_ids']
        if (intruder['id_directory']['po_id']['valid']):
            intruder['po_id'] = intruder['id_directory']['po_id']['value']
        del intruder['id_directory']

    def _find_cost_data_place(self, id_directory):
        if (0 < len(id_directory['agt_ids'])):
            return self.CDP.AGT_IDS
        if (id_directory['po_id']['valid']):
            return self.CDP.PO_ID
        if (id_directory['ornct_id']['valid']):
            return self.CDP.ORNCT_ID
        if (id_directory['anon24']['valid']):
            return self.CDP.ANON24
        if (id_directory['icao24']['valid']):
            return self.CDP.ICAO24
        if (id_directory['v2v_uid']['valid']):
            return self.CDP.V2V_UID
        raise ValueError('Cost Data Place was not found.')

    def _transform_variable_intruder_parts(self, intruders):
        """
        Splits an intruder into several entries, for each of its valid
        id_directory identifiers is created an intruder with an id and
        an indentifier value.
        An intruder cost data are inserted into the last of the
        intruders just created.
        """
        if intruders is None:
            return
        for intruder in intruders:
            if (intruder['offline_costs'] is None):
                del intruder['offline_costs']
            if (intruder['stateDependentOnlineCosts'] is None):
                del intruder['stateDependentOnlineCosts']

        new_intruders = []
        for intruder in intruders:
            cdp = self._find_cost_data_place(intruder['id_directory'])
            if (intruder['id_directory']['v2v_uid']['valid']):
                if (cdp == self.CDP.V2V_UID):
                    intruder['v2v_uid'] = intruder['id_directory']['v2v_uid']['value']
                else:
                    new_intruders.append({
                        'v2v_uid': intruder['id_directory']['v2v_uid']['value'],
                        'id': intruder['id']})
            if (intruder['id_directory']['icao24']['valid']):
                if (cdp == self.CDP.ICAO24):
                    intruder['icao24'] = intruder['id_directory']['icao24']['value']
                else:
                    new_intruders.append({
                        'icao24': intruder['id_directory']['icao24']['value'],
                        'id': intruder['id']})
            if (intruder['id_directory']['anon24']['valid']):
                if (cdp == self.CDP.ANON24):
                    intruder['anon24'] = intruder['id_directory']['anon24']['value']
                else:
                    new_intruders.append({
                        'anon24': intruder['id_directory']['anon24']['value'],
                        'id': intruder['id']})
            if (intruder['id_directory']['ornct_id']['valid']):
                if (cdp == self.CDP.ORNCT_ID):
                    intruder['ornct_id'] = intruder['id_directory']['ornct_id']['value']
                else:
                    new_intruders.append({
                        'ornct_id': intruder['id_directory']['ornct_id']['value'],
                        'id': intruder['id']})
            if (intruder['id_directory']['po_id']['valid']):
                if (cdp == self.CDP.PO_ID):
                    intruder['po_id'] = intruder['id_directory']['po_id']['value']
                else:
                    new_intruders.append({
                        'po_id': intruder['id_directory']['po_id']['value'],
                        'id': intruder['id']})
            if (0 < len(intruder['id_directory']['agt_ids'])):
                intruder['agt_ids'] = intruder['id_directory']['agt_ids']
            del intruder['id_directory']
            new_intruders.append(intruder)
        return new_intruders

    def _remove_point_obstacle_oi_costs(self, online_itemized):
        if online_itemized['is_point_obs']:
            del online_itemized['coord_ra_deferral']
            del online_itemized['max_reversal']
            del online_itemized['prevent_early_weakening']
            del online_itemized['SA01']
            del online_itemized['restrict_coc_due_to_reversal']
            del online_itemized['safe_crossing_ra_deferral']
            del online_itemized['time_based_non_compliance']
            del online_itemized['critical_interval_protection']
            del online_itemized['advisory_restart']
            del online_itemized['altitude_dependent_coc']
            del online_itemized['compatibility']
            del online_itemized['coord_delay']
            del online_itemized['initialization']
            del online_itemized['prevent_early_coc']
            del online_itemized['crossing_no_alert']
        del online_itemized['is_point_obs']

    def _transform_variable_vertical_cost_parts(self, logged_costs):
        """
        Remove empty part and create a ground_id if necessary.
        """
        if (logged_costs['unequippedCostFusion'] is None):
            del logged_costs['unequippedCostFusion']
        for intruder in logged_costs['individual']:
            self._transform_variable_id_directory(intruder)
            self._remove_point_obstacle_oi_costs(intruder['online_itemized'])
            if ('id' in intruder and
                    intruder['id'] == self.ID_GROUND):
                intruder['ground_id'] = intruder['id']
            if (intruder['multithreat'] is None):
                del intruder['multithreat']
            elif (intruder['multithreat']['sandwich_prevention'] is None):
                del intruder['multithreat']['sandwich_prevention']

    def _transform_variable_horizontal_cost_parts(self, logged_costs):
        logged_costs['prioritizeAndFilterIntruders'] = (
            self._transform_variable_intruder_parts(
                logged_costs['prioritizeAndFilterIntruders']))

        if logged_costs['selectHorizontalAdvisory'] is not None:
            for advisory in logged_costs['selectHorizontalAdvisory']:
                advisory['horizontalCostFusion']['individual'] = (
                    self._transform_variable_intruder_parts(
                        advisory['horizontalCostFusion']['individual']))
        return logged_costs

    def _transform_variable_cost_parts(self, logged_costs):
        self._transform_variable_vertical_cost_parts(logged_costs)
        logged_costs = self._transform_variable_horizontal_cost_parts(logged_costs)
        return logged_costs

    def sXuTRMUpdate(self, trm_input_expression):
        xutrm_report = self._runtime.evaluate_expr(
            "{} = ACAS_sXu.sXuTRMUpdate({}, {}, {})".format(
                self._trm_report_name,
                self._trm_name,
                self._sxutrm_state_name,
                trm_input_expression))

        logged_costs = self._runtime.evaluate_expr(
            "{}.loggedCosts".format(
                self._trm_name))
        logged_costs = self._transform_variable_cost_parts(logged_costs)
        return {
            'sXuTRMReportsXuV4R2': xutrm_report,
            'TRMIntruderCostssXuV4R2': logged_costs,
        }
