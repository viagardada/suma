#!/usr/bin/env python3

import sys
import socket
import json
import math
import websocket
import time
import threading


# Environment variable queried for a path to params file,
# unless already found.
PARAMS_FALLBACK_ENVVAR = 'SUMA_PARAMS_FILE'
daaDispSocket = None
gbDaaDispMsgReady = False
gsDaaDispMsg = ''

def to180deg(pHdg):
    while pHdg <= -180.0:
        pHdg += 360.0
    while pHdg > 180.0:
        pHdg -= 360.0
    return pHdg

def on_open(ws):
    global gbDaaDispMsgReady
    global gsDaaDispMsg
    print("opened")
    lastTS = 0
    while True:
        time.sleep(0.01)
        curTS = time.time()
        #print('TimeStamp: {} Delta: {}'.format(curTS, curTS - lastTS))
        if (curTS - lastTS) > 5.0:
            ws.send('{}')
            lastTS = curTS
        if gbDaaDispMsgReady:
            ws.send(gsDaaDispMsg)
            lastTS = time.time()
            #print('Send msg to Daa Dispaly: !')
            gbDaaDispMsgReady = False
            gsDaaDispMsg = ''

def on_message(ws, message):
    print(message)

def on_close(ws):
    print("closed connection")

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


class sxu():
    def __init__(self):
        from julia_stm import JuliaSTM
        from julia_trm import JuliaTRM
        from juliainterpreter import JuliaInterpreter, JuliaInterpreterProcess
        from os.path import dirname, abspath, join

        instance_id = "{}_{}".format(type(self).__name__, id(self))
        self._coordination_reach_back_seconds = 0.0
        self._input_cache = []
        self._stm_output_cache = None
        self._last_output_time = float('NaN')

        self._julia_script_path = ""
        self._coordination_received = False

        use_trm = True
        table_caching_enabled = False

        self._is_runtime_persistent = False
        self._runtime = JuliaInterpreter(instance_id, history=[])
        try:
            self._runtime.use_module('ACAS_sXu', join(
                dirname(abspath(__file__)), 'ACAS_sXu'))
            stm_params_file = './LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt'
            self._stm = JuliaSTM(self._runtime, stm_params_file)
            trm_params_file = './LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt'
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
                self._persistent_runtime = None
            raise

    # Path to embedded params file (including paths to embedded lookup tables).
    embedded_params_file_path = _find_params()

    _persistent_runtime = None
    _ownData = None
    _sumaLastTS = 0.0
    _sxuLastTick = 0

    def _save_julia_commands_into_a_file(self, file_path):
        with open(file_path, 'w') as out_file:
            for line in self._runtime.history:
                out_file.write(line)
                out_file.write("\n")

    def _report_runtime_history(self, warning=False):
        from logging import DEBUG, WARNING

        if (self._julia_script_path):
            self._save_julia_commands_into_a_file(self._julia_script_path)

    def Execute(self, inputData):
        from CASCARA import InputEvent, OutputEvent
        from DiscreteSimulation import SynchronizationEvent, StoppedEvent
        from math import isnan


#"OwnShip:{'Psi':0.0, 'alt_pres_ft':100, 'h':100, 'lat_deg':30, 'lon_deg':110, 'vel_ew_kts':10.0, 'vel_ns_kts':0.0, 'alt_hae_ft':50.0, 'alt_rate_hae_fps':0.0, 'nacp':1, 'nacv':1, 'vfom_m':10.0)"
#"Intruder:[{'lat': 40.0,'lon': -75.0, 'alt_pres_ft': 340.0,'alt_hae_ft': 340.0,'vel_ew': 1.4512e-15, 'vel_ns': -23.699,'nic': 7, 'nacp': 10,'nacv': 2,'vfom_m': 8.0, 'sil': 3, 'sda': 1, 'v2v_uid': 100, 'mode_s': 100}]
        try:
            inputDataStr = data.decode('ascii')
            #print(inputDataStr)
            report = json.loads(inputDataStr)
            report_time = report["report_time"]
            report_type = report["report_type"]
            report_data_type = report[report_type.lower()]["data_type"]
            report_data = report[report_type.lower()][report_data_type.lower()]
            _eventIn = None
            if report_data_type == "OWNSHIP_DISCRETES":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['v2v_uid'] = report_data['remote_id']
                    report_data['requested_opmode'] = 3 
                    report_data['effective_turn_rate_rad'] = report_data['turn_rate_limit_rad']
                    report_data['effective_vert_rate_fps'] = report_data['vert_rate_limit_fps']
                    report_data['perform_poa'] = False
                    report_data['disable_gpoa'] = False
                    report_data['equipment'] = 15
                _eventIn = InputEvent(report_time, 'ReceiveDiscretessXuV4R2', report_data)
            elif report_data_type == "HEADING_OBS":
                _eventIn = InputEvent(report_time, 'ReceiveHeadingObservationV15R2', report_data)
            elif report_data_type == "PRES_ALT_OBS":
                _eventIn = InputEvent(report_time, 'ReceivePresAltObservation', report_data)
            elif report_data_type == "HEIGHT_AGL_OBS":
                _eventIn = InputEvent(report_time, 'ReceiveHeightAglObservation', report_data)
            elif report_data_type == "WGS84_OBS":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['vfom_m'] = 8
                _eventIn = InputEvent(report_time, 'ReceiveWgs84ObservationsXuV4R0', report_data)
                self._ownData = report_data
            elif report_data_type == "AIRBORNE_POSITION_REPORT":
                _eventIn = InputEvent(report_time, 'ReceiveStateVectorPositionReportsXuV4R2', report_data)
            elif report_data_type == "AIRBORNE_VELOCITY_REPORT":
                _eventIn = InputEvent(report_time, 'ReceiveStateVectorVelocityReportsXuV4R2', report_data)
            elif report_data_type == "MODE_STATUS_REPORT":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['gva'] = 2
                _eventIn = InputEvent(report_time, 'ReceiveModeStatusReportsXuV4R2', report_data)
            elif report_data_type == "EXTERNALLY_VALIDATED_ADSB":
                _eventIn = InputEvent(report_time, 'ReceiveExternallyValidatedADSB', report_data)
            elif report_data_type == "OWN_REL_NON_COOP_TRACK":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['ornct_id'] = report_data['track_id']
                    report_data['classification'] = 1
                _eventIn = InputEvent(report_time, 'ReceiveOwnRelNonCoopTracksXuV4R2', report_data)
            elif report_data_type == "ABSOLUTE_GEODETIC_TRACK":
                _eventIn = InputEvent(report_time, 'ReceiveAbsoluteGeodeticTracksXuV4R0', report_data)
            elif report_data_type == "VEHICLE_TO_VEHICLE_REPORT":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['v2v_uid'] = report_data['remote_id']
                    report_data['mode_s'] = report_data['remote_id']
                    report_data['mode_s_non_icao'] = False
                    report_data['mode_s_valid'] = True 
                    report_data['vfom_m'] = 8
                    report_data['sil'] = 3
                    report_data['sda'] = 1
                    report_data['nic'] = 7
                    report_data['q_int'] = 1
                _eventIn = InputEvent(report_time, 'ReceiveStateVectorV2VReportsXuV4R2', report_data)
            elif report_data_type == "EXTERNALLY_VALIDATED_V2V":
                if report_type == 'Acas_sXu_V3R0':
                    report_data['v2v_uid'] = report_data['remote_id']
                _eventIn = InputEvent(report_time, 'ReceiveExternallyValidatedV2VsXuV4R0', report_data)
            else:
                return ''
            curTick = math.floor(report_time - 0.00001)
            if curTick > self._sxuLastTick : 
            #if report_data_type == "EXTERNALLY_VALIDATED_V2V":
                self._sxuLastTick = curTick
                _oEvent = OutputEvent(int(report_time + 0.99))
                #print("_oEvent: ", _oEvent)
                self._start_output_processing(_oEvent)
                #print(self._stm_output_cache)
                (_lastEvent, _output, _) = self._finish_output_processing()
                #(stmReport, trmReport, _) = _output
                daaDispMsg = self._generate_daa_display_msg(_output['STMReportsXuV4R2'], _output['sXuTRMReportsXuV4R2'])
                deltaTime = time.time() - self._sumaLastTS 
                if deltaTime < 1.0:
                    time.sleep( 1.0 - deltaTime)
                self._sumaLastTS = time.time()
                (_eventOut, _output, _) = self._process_input_event(_eventIn)
                return daaDispMsg
                #print(daaDispMsg)
                #print(_output)
            else:
                (_eventOut, _output, _) = self._process_input_event(_eventIn)
                return ''

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
        #print("_process_input_event: #1")
        input_call = None
        #print("_process_input_event: event.Type:", event.Type)
        try:
            input_call = getattr(self._stm, event.Type)
            #print("_process_input_event: input_call:", input_call)
        except AttributeError:
            raise RuntimeError(
                "Unsupported input event type \"{}\".".format(
                    event.Type)) from None
        return (event, input_call(event.Data, event.Time), None)
        #yield (event, input_call(event.Data, event.Time), None)

    def _start_output_processing(self, event):
        output = {}

        output.update(self._stm.GenerateStmReport(event.Time))

        self._stm_output_cache = (event, output)

        self._last_output_time = event.Time
        return
        #yield from ()

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
            return (event, output, None)
            #yield (event, output, None)
    def _generate_daa_display_msg(self, STMReport, TRMReport):
        dispMsg = {}
        #dispMsg.update({"controls_state":{"log_enabled": False,"radar_enabled": False}})
        if len(STMReport['trm_input']['intruder']) == 0:
            return "{}"
        dispMsg.update({"time":STMReport['trm_input']['intruder'][0]['stm_display']['toa']})
        dispMsg.update(self._gen_daa_display_msg_own())
        dispMsg.update(self._gen_daa_display_msg_intruder(STMReport['trm_input']['intruder'], TRMReport['display_vert']['intruder'], TRMReport['display_horiz']['intruder']))
        dispMsg.update(self._gen_daa_display_msg_env(TRMReport['display_vert'], TRMReport['display_horiz']))
        # envMsg = {
        #     "environment":{
        #         "ring": {
        #             "regain": False,
        #             "no_hazard":[{"from": -180,"to": 180}],
        #         },
        #         "altitude_tape": {
        #             "regain": False,
        #             "no_hazard":[{"from": 0,"to": 12000}],
        #         },
        #         "vertical_speed_tape": {
        #             "regain": False,
        #             "no_hazard":[{"from": -6300,"to": 6300}],
        #         }}}
        # dispMsg.update(envMsg)
        navMsg = {
            "navigation":{}
        }
        #dispMsg.update(navMsg)

        return (json.dumps(dispMsg))
        #DAADisplayMsg.update(_daa_display_msg_own(STMReport['trm_input']['own']))
        #print(DAADisplayMsg)
    def _gen_daa_display_msg_own(self):
        """
        Per Brno_interface_requirements_v2_8.doc
            "ownship":
            {
            "longitude": 17.45678,
            "latitude": 49.036948,
            "altitude": 461.155,
            "heading": 24.59,
            "speed": 101.94,
            "vertical_speed": 0
            }
        """
        wgs84_obs = self._ownData
        if wgs84_obs == None:
            print('Error!  No Own Data received during the cycle...')
            return
        heading = 0.5 * math.pi - math.atan2(wgs84_obs['vel_ns_kts'],wgs84_obs['vel_ew_kts'])
        heading = heading * 180.0 / math.pi
        speed = math.sqrt(wgs84_obs['vel_ns_kts'] * wgs84_obs['vel_ns_kts'] + wgs84_obs['vel_ew_kts'] * wgs84_obs['vel_ew_kts'])
        daaMsgOwn = {
            'ownship':
            {
            "longitude": wgs84_obs['lon_deg'],
            "latitude": wgs84_obs['lat_deg'],
            "altitude": wgs84_obs['alt_hae_ft'],
            "heading": heading,
            "speed": speed,
            "vertical_speed": wgs84_obs['alt_rate_hae_fps'],
            }
        }
        return daaMsgOwn
    def _gen_daa_display_msg_intruder(self, intruderRpts, intrTRMVD, intrTRMHD):
        """
        Per Brno_interface_requirements_v2_8.doc
            "traffic":
            [
                {
                "icao": "4BAA0A",
                "bearing ": -2.4,
                "rel_range": 15.742,
                "rel_altitude": 303.015,
                "geo_altitude": 873.555,
                "ground_speed": 93.82,
                "vertical_speed": -23,
                "heading": 299.9,
                "trend": "level",
                "category": "LIGHT",
                "status": "PDT",
                "adsb": {
                    "bearing": -2.4,
                    "rel_range": 15.744
                    },
                "tcas": {
                    "bearing": -2.45,
                    "rel_range": 15.753

                    },
                "radar": {
                    "bearing": -2.3,
                    "rel_range": 15.728
                    }
                }
                {
                    …
                }
            ]
        """
        daaMsgIntr = {'traffic':[]}
        for intr in intruderRpts:
            bearing = intr['stm_display']['bearing_rel_rad'] * 180.0 / math.pi
            rel_range = intr['stm_display']['r_ground_ft']/ 6076.115
            dx = intr['stm_display']['dx_rel_fps']
            dy = intr['stm_display']['dy_rel_fps']
            heading = 0.5 * math.pi - math.atan2(dy, dx)
            heading = heading * 180.0 / math.pi
            dx = dx * 0.5924838486434177 #convert fps to kts
            dy = dy * 0.5924838486434177 #convert fps to kts
            speed = math.sqrt(dx * dx + dy * dy)
            #encoding Intruder "trend"
            trend = 'level'
            if intr['stm_display']['arrow'] == -1:
                trend = "descent"
            elif intr['stm_display']['arrow'] == 1:
                trend = "climb"
            #encoding Intruder "status" NORMAL or RA depends on cc code
            intrStatus = "BDT"
            intruderId = intr['id']
            for intrVD in intrTRMVD:
                if intrVD['id'] == intruderId:
                    if intrVD['code'] > 3:
                        intrStatus = "DAT"
                        break
            for intrHD in intrTRMHD:
                if intrHD['id'] == intruderId:
                    if intrHD['code'] > 3:
                        intrStatus = "DAT"
                        break
            daaMsgIntr['traffic'].append(
                {
                "icao": str(intr['stm_display']['id_directory']['icao24']['value']),
                "bearing": round(bearing,2),
                "rel_range": rel_range,
                "rel_altitude": intr['stm_display']['z_rel_ft'],
                "geo_altitude": None,
                "ground_speed": speed,
                "vertical_speed": intr['stm_display']['dz_rel_fps'],
                "heading": heading,
                "trend": trend,
                "category": None,
                "status": intrStatus
                #"bearing":-14.782217025756836,
                # "bearing": 14,
                # "category":None,
                # "geo_altitude":None,
                # "ground_speed":131.60179281817628,
                # "heading":166.76786804199219,
                # "icao":str(95),
                # "rel_altitude":634.39466362032181,
                # "rel_range":8.5351284439147665,
                # "status":"BDT",
                # "trend":"level",
                # "vertical_speed":318.89340188787236
                })
        return daaMsgIntr
    def _gen_daa_display_msg_env(self, disp_vert, disp_horiz):
        daaMsgEnv = {
            "environment":{
                "ring": {
                    "regain": disp_horiz['cc'] > 1
                },
                "altitude_tape": {
                    "regain": False,
                    "no_hazard":[{"from": 0,"to": 12000}]
                },
                "vertical_speed_tape": {
                    "regain": disp_vert['cc'] > 1
                }}}
        wgs84_obs = self._ownData
        if wgs84_obs == None:
            print('Error!  No Own Data received during the cycle...')
            return
        ownHdg = 0.5 * math.pi - math.atan2(wgs84_obs['vel_ns_kts'],wgs84_obs['vel_ew_kts'])
        ownHdg = ownHdg * 180.0 / math.pi
        greenDeg = 15
        rel_angle = disp_horiz['target_angle'] - ownHdg
        tgtHdg = to180deg(rel_angle)
        if disp_horiz['cc'] < 2:
            daaMsgEnv['environment']['ring'].update({'no_hazard':[]})
            daaMsgEnv['environment']['ring']['no_hazard'].append({"from": -180.0,"to": 180.0})
        elif disp_horiz['cc'] == 2: # turn right
            daaMsgEnv['environment']['ring']['no_hazard'] = []
            daaMsgEnv['environment']['ring']['no_hazard'].append({"from": tgtHdg,"to": tgtHdg + greenDeg})
            daaMsgEnv['environment']['ring']['warning'] = []
            daaMsgEnv['environment']['ring']['warning'].append({"from": -180,"to": tgtHdg})
        elif disp_horiz['cc'] == 3: # turn left
            daaMsgEnv['environment']['ring']['no_hazard'] = []
            daaMsgEnv['environment']['ring']['no_hazard'].append({"from": tgtHdg - greenDeg,"to": tgtHdg})
            daaMsgEnv['environment']['ring']['warning'] = []
            daaMsgEnv['environment']['ring']['warning'].append({"from": tgtHdg,"to": 180.0})
        elif disp_horiz['cc'] == 4: # Straight/No turn
            daaMsgEnv['environment']['ring']['no_hazard'] = []
            daaMsgEnv['environment']['ring']['no_hazard'].append({"from": -10,"to": 10})
            daaMsgEnv['environment']['ring']['warning'] = []
            daaMsgEnv['environment']['ring']['warning'].append({"from": -180,"to": -10.0})
            daaMsgEnv['environment']['ring']['warning'].append({"from": 10,"to": 180.0})
        greenRate = 500
        minmaxVST = 6300
        target_rate = disp_vert['target_rate'] * 60 # fps -> fpm
        if disp_vert['cc'] < 2:
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": -minmaxVST,"to": minmaxVST})
        elif disp_vert['ua'] ==  disp_vert['da']: # Multi-threat Level Off
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": -250,"to": 250})
            daaMsgEnv['environment']['vertical_speed_tape']['warning'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": -minmaxVST,"to": -250})
            daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": 250,"to": minmaxVST})
        elif disp_vert['ua']== 2:
            if disp_vert['cc'] == 4: # Do Not Descend or Weakening of positive climb RA
                daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
                daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": target_rate,"to": target_rate + greenRate})
                daaMsgEnv['environment']['vertical_speed_tape']['warning'] = []
                daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": -minmaxVST,"to": target_rate})
            else:
                daaMsgEnv['environment']['vertical_speed_tape']['warning'] = [] #No green band for cc = 6 : Weakening maintain or monitor 
                daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": -minmaxVST,"to": 0})
        elif disp_vert['da'] == 2:
            if disp_vert['cc'] == 5: # // Do Not Climb or Weakening of positive descend RA
                daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
                daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": target_rate - greenRate,"to": target_rate})
                daaMsgEnv['environment']['vertical_speed_tape']['warning'] = []
                daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": target_rate,"to": minmaxVST})
            else:
                daaMsgEnv['environment']['vertical_speed_tape']['warning'] = [] #No green band for cc = 6 : Weakening maintain or monitor 
                daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": 0,"to": minmaxVST})
        elif disp_vert['cc'] == 4: #climb commands:  vc=0-4 dependent on target rate
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": target_rate ,"to": target_rate + greenRate})
            daaMsgEnv['environment']['vertical_speed_tape']['warning'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": -minmaxVST,"to": target_rate})
        elif disp_vert['cc'] == 5: #decend commands:  vc=0-4 dependent on target rate
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['no_hazard'].append({"from": target_rate - greenRate ,"to": target_rate})
            daaMsgEnv['environment']['vertical_speed_tape']['warning'] = []
            daaMsgEnv['environment']['vertical_speed_tape']['warning'].append({"from": target_rate,"to": minmaxVST})
        return(daaMsgEnv)

if __name__ == "__main__":
    num_args = len(sys.argv)
    if num_args != 2:
        print("Usage:\r\n")
        print("       sumago.py [Server IP]\r\n")
        print("\r\n")
        exit(0)

    #binFilePath = sys.argv[1]
    #csvFilePath = sys.argv[2]

    #DAADisplayServer_IP = '127.0.0.1'
    DAADisplayServer_IP = sys.argv[1]
    DAADisplayServer_PORT = 52275

    ws = websocket.WebSocketApp("ws://{}:{}".format(DAADisplayServer_IP, DAADisplayServer_PORT), 
                                on_open=on_open, 
                                on_message=on_message,
                                on_close=on_close) 

    wst = threading.Thread(target=lambda: ws.run_forever())
    wst.daemon = True
    wst.start()

# your code continues here ...
#  

    sxuObj = sxu()

    TCP_IP = '127.0.0.1'
    TCP_PORT = 6031
    BUFFER_SIZE = 1024  # Normally 1024, but we want fast response
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((TCP_IP, TCP_PORT))
    s.listen(1)

    print('Ready to get data:')
    conn, addr = s.accept()
    print('Connection address:', addr)
    while 1:
        data = conn.recv(BUFFER_SIZE)
        if not data: break
        dispJson = sxuObj.Execute(data)
        print('len(dispJson): ', len(dispJson))
        if len(dispJson) > 10:
                gsDaaDispMsg = dispJson
                gbDaaDispMsgReady = True
        conn.send(b"Well received with many thanks!")  # echo
    conn.close()
    daaDispSocket.close()
