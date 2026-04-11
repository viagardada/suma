#!/usr/bin/env python3

import sys
import socket
import json

if __name__ == "__main__":
    num_args = len(sys.argv)
    if num_args != 3:
        print("Usage:\r\n")
        print("       terrPrsr.py [terr bin file.bin] [output csv file.csv]\r\n")
        print("\r\n")
        exit(0)

    inFilePath = sys.argv[1]
    outFilePath = sys.argv[2]

    with open(inFilePath, 'rt') as readfile:
        jsonTxt = readfile.readlines()
    jsonStr = ""
    for line in jsonTxt:
        jsonStr += line
    jo = json.loads(jsonStr)
    num_report = len(jo["acasx_reports"])
    #setup socket
    TCP_IP = '192.168.98.129'
    TCP_PORT = 6031
    BUFFER_SIZE = 1024
    MESSAGE = "Hello, World!"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))

    #go through input file and send data out via socket
    for ss in range(0, num_report) :
        report = jo["acasx_reports"][ss]
        #report_time = report["report_time"]
        #report_type = report["report_type"]
        #report_data_type = report["acas_sxu_do396"]["data_type"]
        #report_data = report["acas_sxu_do396"][report_data_type.lower()]
        #report_data = report["acas_sxu_do396"]
        msg = json.dumps(report)
        print(msg)
        s.send(str(msg).encode())
        data = s.recv(BUFFER_SIZE)
        print("received data:", data.decode('ascii'))
        if data == "EOC":
            break
    s.close()