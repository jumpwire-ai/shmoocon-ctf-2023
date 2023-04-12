from pwn import *
import time
from numpy.random import Generator
from randomgen import Xoshiro256
from base64 import b32encode
import pyotp

def secret_for_seed(seed, user_id=1):
    # setting legacy causes splitmax64 to be used to initialize the xoshiro seed
    rng = Generator(Xoshiro256(seed, mode="legacy"))

    for _ in range(0, user_id - 1):
        for _ in range(0, 3):
            rng.bit_generator.random_raw()

    bytes = b''
    for i in range(0, 3):
        val = rng.bit_generator.random_raw()
        bytes += val.to_bytes(8, byteorder='big')

    return b32encode(bytes).decode('utf8').rstrip("=")


def find_seed(user_secret, user_id):
    # iterate all seeds starting one week ago, adjust as needed
    now = int(time.time())
    start = now - (60 * 60 * 24 * 7)
    for seed in range(start, now):
        secret = secret_for_seed(seed, user_id)
        if secret == user_secret:
            print('Seed: ', seed)
            return seed

# change these values
secret = 'DHF4WP3LT5ZUTZY5P6WGKW5EVFFVC6SFXOR3LOY'
user_id = 2

seed = find_seed(secret, user_id)

root_secret = secret_for_seed(seed, 1)
print('Root secret: ', root_secret)

r = remote("green-thumb.ctf.jumpwire.ai", 1337)
r.recvuntil('Enter your username')
r.sendline('root')
r.recvuntil('Enter the OTP')
code = pyotp.TOTP(root_secret).now()
r.sendline(code)
print(r.recvallS())
