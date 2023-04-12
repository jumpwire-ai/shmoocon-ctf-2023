#!/usr/bin/env elixir

# little script to generate flag values for new challenges

val = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)

IO.puts "flag{#{val}}"
