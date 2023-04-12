# not gonna cry

(The name is a reference to the WannaCry ransomware).

The packet capture is a bunch of junk from apt and curl, combined with a sample IRC/Skype pcap for extra noise.

The important request is a TCP connection where the client sends `xn--yp9h` on port 1024. That's punycode for the 🤖 emoji :-D.

The server's response is gzipped. In wireshark, follow the TCP stream, set show data to "raw" and just the server's response. Save that to a file and it can be gunzipped.

Gunzipping the data shows a base64 encoded value, which in turn is a JSON document. The JSON doc has  two important fields: `addr` is an ethereum address (eth addresses start with 0x) and `net` has a value of `goerli`, which is a clue to look on the goerli test network. All the other values are extraneous.

One way to explore the ethereum address is with etherscan. First glance makes it seem like there are no transactions, but switching to the Goerli network shows several. One of those has data attached (indicated with an asterick on the Method field):

https://goerli.etherscan.io/tx/0x53c485f2ef5014884ef19b2f72d110e76ef57d848f71967b345083ca3f874064

The data is hex-encoded and can be decoded right in etherscan to UTF-8, which will show the flag.

## eth wallet

The wallet 0x05b2599e79053caa0c7d1d069d401ccb24f376b6 is seeded by the passphrase:

```
load
advice
drive
cactus
supreme
gadget
spoon
artwork
goose
grid
salute
couple
```

(There is just fake testnet eth in there)
