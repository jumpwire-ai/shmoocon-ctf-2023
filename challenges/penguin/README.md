# penguin

This challenge involves bruteforcing AES-ECB. This is easy to do since AES-ECB does not use a salt or IV and encrypts each block independently. The same 16-bytes of input data will always generate the same ciphertext.

Connecting to the server allows you to provide text that is prepended to the flag before encrypting. The attacker can use this to pad out the data to create known blocks of data, then iterate on each byte and look for matches.

The plaintext that gets encrypted is "Here is the #{localized}: #{flag}", where `localized` is set by the attacker. The characters before that take up 12 bytes, so the first 4 bytes of the user string will fill up that block. Another 16 bytes gives us a controlled block - we know the plaintext going in and will see the ciphertext coming out.

Using a pad of `4444`  for the first block and `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa` (32 bytes) for the next two blocks produces `81c84e13c4aa75c3c64e5f118d23b4adbd131929faef63b15267e175ca34e09bbd131929faef63b15267e175ca34e09b1ef9801a7b015fce457e88036d0abf8378eee700bea1fe7c3f8ca477558434d741d74c11e5ad42c1021d54f23def34f8`. (There's nothing special about the input used, it just need to be known to us). Breaking this down by block:

```
81c84e13c4aa75c3c64e5f118d23b4ad
bd131929faef63b15267e175ca34e09b  # block 2 - 16 `a`s
bd131929faef63b15267e175ca34e09b  # block 3 - same as 2
1ef9801a7b015fce457e88036d0abf83  # block 4 - start of flag
78eee700bea1fe7c3f8ca477558434d7
41d74c11e5ad42c1021d54f23def34f8
```

Removing one byte will shift the text after our input so that the first character ends our block. Since we control the previous block's plaintext, we can try ASCII characters in that until the blocks match. We can discover the first unknown character by cycling through inputs of `4444aaaaaaaaaaaaaaa?aaaaaaaaaaaaaaa`, where the `?` is replaced on each iteration until block 2 and 3 match. Eventually we get a `:` as the value:


```
4444aaaaaaaaaaaaaaa:aaaaaaaaaaaaaaa
# showing the result split into blocks
81c84e13c4aa75c3c64e5f118d23b4ad
5d3d4b77a7d24a09692af8ce368682f2  # block 2 - aaaaaaaaaaaaaaa:
5d3d4b77a7d24a09692af8ce368682f2  # block 3 - start of the flag, same as block 2
a0bb417c3867136ddcae174d2be0b1bf
3ebf9d7b150448d8070679f94a851d1f
43be114d144e3e84dac11b77dea4b9cb
```

Again we take away one byte and guess the next character - now our input looks like `4444aaaaaaaaaaaaaa?:aaaaaaaaaaaaaa`. Eventually we can deduce the full flag this way.

A solution using Python/pwntools can be found at `solver.py`.
