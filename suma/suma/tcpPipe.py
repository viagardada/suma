#!/usr/bin/env python3

import sys

if __name__ == "__main__":
    data = sys.stdin.buffer.read()
    while(data != None):
        print(data)
        data = sys.stdin.buffer.read()