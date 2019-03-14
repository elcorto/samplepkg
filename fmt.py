#!/usr/bin/python3

# Why this? B/c string processing in the shell is not fun.

import sys

for line in sys.stdin.readlines():
    left, right = line.split(":")
    left = left.strip().replace('//','/')
    right = right.strip().replace('//','/')
    if len(right) > 0:
        print(f'{left:>{70}} : {right}')
