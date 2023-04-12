#!/bin/bash

# Start elixir web server. For some reason the server doesn't start properly
# as `daemon` in the nsjail.
(&>/dev/null /web-apps/release/bin/notary start)&

# Proxy stdin/stdout to web server. Without `ignoreeof` socat immediately
# sends a FIN to the server, which will halt the TCP connection without
# an HTTP response.
socat -T2 -,ignoreeof TCP:127.0.0.1:4000,forever
