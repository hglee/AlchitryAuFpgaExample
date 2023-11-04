#!/usr/bin/env python3

s = b"uart example\n\r"

f = open("uart_text.txt", "w")

for x in s:
    f.write("{:02x} ".format(x))

f.close()
