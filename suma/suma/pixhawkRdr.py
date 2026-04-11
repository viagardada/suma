#!/usr/bin/env python3

import sys
import socket
import json
import math
import time
from dronekit import connect, VehicleMode

# Set the connection string to your Pixhawk's serial port or network address
connection_string = '/dev/ttyUSB1'  # Example for serial connection
BUFFER_SIZE = 1024
s = None
# Connect to the Pixhawk
vehicle = connect(connection_string, wait_ready=True)
vehicle.remote_id = 111

# Function to retrieve the "WGS84_OBS" dataset
#"wgs84_obs": {"toa": 0.997, "lat_deg": 53.5323, "lon_deg": 8.1069, "vel_ew_kts": 2.1768e-15, "vel_ns_kts": -35.549, "alt_hae_ft": 200, "alt_rate_hae_fps": 3, "nacp": 10, "nacv": 3}
def get_wgs84_obs():
    wgs84_obs = {
        "toa": time.time(),
        "lat_deg": vehicle.location.global_frame.lat,
        "lon_deg": vehicle.location.global_frame.lon,
        "vel_ew_kts": vehicle.velocity[0],  # East-West velocity
        "vel_ns_kts": vehicle.velocity[1],  # North-South velocity
        "alt_hae_ft": vehicle.location.global_frame.alt,
        "alt_rate_hae_fps": vehicle.velocity[2],  # Vertical velocity
        "nacp": 10,  # Fixed value as per your requirement
        "nacv": 3   # Fixed value as per your requirement
    }
    return wgs84_obs
# Function to retrieve the "HEADING_OBS" dataset
#"heading_obs": {"toa": 0.994, "psi_rad": 3.1416, "heading_degraded": false}
def get_heading_obs():
    heading_obs = {
        "toa": time.time(),
        "psi_rad": math.radians( vehicle.heading), 
        "heading_degraded": False
    }
    return heading_obs

# Function to retrieve the "PRES_ALT_OBS" dataset
#"pres_alt_obs": {"toa": 0.995, "alt_pres_ft": 200},
def get_pres_alt_obs():
    pres_alt_obs = {
        "toa": time.time(),
        "alt_pres_ft": vehicle.location.global_frame.alt
    }
    return pres_alt_obs

# Function to retrieve the "HEIGHT_AGL_OBS" dataset
#"height_agl_obs": {"toa": 0.996, "h_ft": 200},
def get_height_agl_obs():
    height_agl_obs = {
        "toa": time.time(),
        "h_ft": vehicle.location.global_frame.alt
    }
    return height_agl_obs

# Function to retrieve the "OWNSHIP_DISCRETES" dataset
#"ownship_discretes": {"toa": 0.993, "remote_id": 111, "opflg": true, "surv_only_disp_on": false, "turn_rate_limit_rad": 0.053, "vert_rate_limit_fps": 16.667, "prefer_wind_relative": false, "perform_poa_and_gpoa": false}
def get_ownship_discretes():
    ownship_discretes = {
        "toa": time.time(),
        "remote_id": vehicle.remote_id,
        "opflg": vehicle.armed,
        "surv_only_disp_on": False,  # You can set this based on your requirements
        "turn_rate_limit_rad": 0.053, # TBD, should be a preconfigurable value
        "vert_rate_limit_fps": 16.667, # TBD, should be a preconfigurable value
        "prefer_wind_relative": False,
        "perform_poa_and_gpoa": False
    }
    return ownship_discretes

# Function to retrieve the "VEHICLE_TO_VEHICLE_REPORT" dataset
#"vehicle_to_vehicle_report": {"toa": 0.999, "remote_id": 222, "lat_deg": 53.52682, "lon_deg": 8.1069, "vel_ns_kts": 0, "vel_ew_kts": 0, "alt_pres_ft": 400, "alt_hae_ft": 400, "nacp": 10, "nacv": 2, "gva": 1, "classification": 3}
def get_vehicle_to_vehicle_report():
    vehicle_to_vehicle_report = {
        "toa": time.time(),
        "remote_id": vehicle.remote_id,
        "lat_deg": vehicle.location.global_frame.lat,
        "lon_deg": vehicle.location.global_frame.lon,
        "vel_ew_kts": vehicle.velocity[0],  # East-West velocity
        "vel_ns_kts": vehicle.velocity[1],  # North-South velocity
        "alt_hae_ft": vehicle.location.global_frame.alt,
        "alt_pres_ft": vehicle.location.global_frame.alt,
        "nacp": 10,  # TBD, should be a preconfigurable value
        "nacv": 2,  # TBD, should be a preconfigurable value
        "gva": 1,  # TBD, should be a preconfigurable value
        "classification": 3  # TBD, should be a preconfigurable value
    }
    return vehicle_to_vehicle_report

# Function to retrieve the "EXTERNALLY_VALIDATED_V2V" dataset
#"externally_validated_v2v": {"toa": 1, "externally_validated": true, "remote_id": 222}
def get_externally_validated_v2v():
    externally_validated_v2v = {
        "toa": time.time(),
        "externally_validated": True,
        "remote_id": vehicle.remote_id,
    }
    return externally_validated_v2v
# Function to retrieve the "V2V_CAPABILITY_REPORT" dataset
#"v2v_capability_report": {"toa": 1.031, "ri": 3, "ca_operational": 1, "sense": 0, "type_capability": 1, "priority": 0, "daa": 0, "remote_id": 222}
def get_v2v_capability_report():
    v2v_capability_report = {
        "toa": time.time(),
        "ri": 3, # TBD, should be a preconfigurable value
        "ca_operational": 1, # TBD, should be a preconfigurable value
        "sense": 0, # TBD, should be a preconfigurable value
        "type_capability": 1, # TBD, should be a preconfigurable value
        "priority": 0, # TBD, should be a preconfigurable value
        "daa": 0, # TBD, should be a preconfigurable value
        "remote_id": vehicle.remote_id
    }
    return v2v_capability_report

def get_acasx_report(data_set_name, data_set):
    acasx_report = {
        "report_time": time.time(),
        "report_type": "Acas_sXu_V3R0", 
        "acas_sxu_v3r0": {
            "data_type": data_set_name.upper(), 
            data_set_name: data_set
            }
    }
    return acasx_report

def ss_send(msg):
    global s
    global BUFFER_SIZE
    s.send(msg)
    data = s.recv(BUFFER_SIZE)
    print("received data:", data.decode('ascii'))
    if data == "EOC":
        return False
    return True


if __name__ == "__main__":
    num_args = len(sys.argv)
    if num_args != 3:
        print("Usage:\r\n")
        print("       pixhawkRdr.py [sumago IP] [sumago port]\r\n")
        print("\r\n")
        exit(0)

    TCP_IP = sys.argv[1]
    TCP_PORT = int(sys.argv[2])

    #setup socket
    #TCP_IP = '192.168.98.129'
    #TCP_PORT = 6031
    MESSAGE = "Hello, World!"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))

    # Main loop to read and package data
    last_ts = 0
    try:
        while True:
            if time.time() - last_ts < 0.99:
                continue
            last_ts = time.time()
            ownship_discretes_data = get_ownship_discretes()
            ownship_discretes_report = json.dumps(get_acasx_report("ownship_discretes", ownship_discretes_data), indent = 4)
            ss_send(str(ownship_discretes_report).encode())
            heading_obs_data = get_heading_obs()
            heading_obs_report = json.dumps(get_acasx_report("heading_obs", heading_obs_data), indent = 4)
            ss_send(str(heading_obs_report).encode())
            pres_alt_obs_data = get_pres_alt_obs()
            pres_alt_obs_report = json.dumps(get_acasx_report("pres_alt_obs", pres_alt_obs_data), indent = 4)
            ss_send(str(pres_alt_obs_report).encode())
            height_agl_obs_data = get_height_agl_obs()
            height_agl_obs_report = json.dumps(get_acasx_report("height_agl_obs", height_agl_obs_data), indent = 4)
            ss_send(str(height_agl_obs_report).encode())
            wgs84_obs_data = get_wgs84_obs()
            wgs84_obs_report = json.dumps(get_acasx_report("wgs84_obs", wgs84_obs_data), indent = 4)
            ss_send(str(wgs84_obs_report).encode())
            vehicle_to_vehicle_report_data = get_vehicle_to_vehicle_report()
            vehicle_to_vehicle_report_report = json.dumps(get_acasx_report("vehicle_to_vehicle_report", vehicle_to_vehicle_report_data), indent = 4)
            #ss_send(str(vehicle_to_vehicle_report_report).encode())
            externally_validated_v2v_data = get_externally_validated_v2v()
            externally_validated_v2v_report = json.dumps(get_acasx_report("externally_validated_v2v", externally_validated_v2v_data), indent = 4)
            #ss_send(str(externally_validated_v2v_report).encode())
            v2v_capability_report_data = get_v2v_capability_report()
            v2v_capability_report_report = json.dumps(get_acasx_report("v2v_capability_report", v2v_capability_report_data), indent = 4)
            #ss_send(str(v2v_capability_report_report).encode())
            # Here, you can send the JSON message to a communication channel (e.g., MQTT, socket, etc.)
            
    except KeyboardInterrupt:
        print("Program terminated by user.")
    finally:
        vehicle.close()
        s.close()