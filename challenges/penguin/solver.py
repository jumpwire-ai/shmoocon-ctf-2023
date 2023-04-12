#!/usr/bin/env python

from pwn import *
import string

r = remote("penguin.ctf.jumpwire.ai", 1337)

def blocks(x):
    element = []
    for i in range(0, len(x), 32):
        element.append(x[i:i + 32])
    return element

def check_cookie(packet):
    r.sendline(bytes(packet, 'ascii'))
    data = r.recvline().strip()
    cookie = data[32:-1]
    return blocks(cookie)

flag = ""
for pos in range(64):
    for char in string.printable:
        brute = '4444' + 'a' * (63-len(flag)) + flag + char + 'a' * (63-len(flag))
        data = check_cookie(brute)
        if data[3] == data[7]:
            flag += char
            print(flag, "\n")
            break
r.close()
