defmodule GreenThumb.Random do
  use Bitwise
  use GenServer
  require Logger

  @bits 64
  @max 1 <<< @bits

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    splitmask_seed = System.os_time(:second)
    Logger.info("Using #{splitmask_seed} for PRNG seed")

    {seeds, _} = Enum.reduce(1..4, {[], splitmask_seed}, fn _, {seeds, state} ->
      {val, state} = next(:splitmix64, state)
      {seeds ++ [val], state}
    end)

    {:ok, seeds}
  end

  def handle_call(:next, _from, state) do
    {val, state} = next(:xoshiro256starstar, state)
    {:reply, val, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def next(), do: GenServer.call(__MODULE__, :next)
  def state(), do: GenServer.call(__MODULE__, :state)

  def secret() do
    <<(next())::64, (next())::64, (next())::64>>
  end

  @doc """
  splitmix64: https://prng.di.unimi.it/splitmix64.c

  xoshiro256starstar: https://prng.di.unimi.it/xoshiro256starstar.c
  """
  def next(algorithmn, state)

  def next(:splitmix64, state) do
    bits = 64
    z = state = mask(state + 0x9e3779b97f4a7c15, bits)
    z = mask(bxor(z, z >>> 30) * 0xbf58476d1ce4e5b9, bits)
    z = mask(bxor(z, z >>> 27) * 0x94d049bb133111eb, bits)
    result = mask(bxor(z, z >>> 31), bits)
    {result, state}
  end

  def next(:xoshiro256starstar, [s0, s1 , s2, s3]) do
    result = mask(rotl(mask(s1 * 5), 7) * 9)
    t = mask(s1 <<< 17)

    s2 = bxor(s2, s0)
    s3 = bxor(s3, s1)
    s1 = bxor(s1, s2)
    s0 = bxor(s0, s3)

    s2 = bxor(s2, t)
    s3 = rotl(s3, 45) |> mask()

    state = [s0, s1, s2, s3]
    {result, state}
  end

  def rotl(x, k) do
    mask(x <<< k) ||| (x >>> (@bits - k))
  end

  def mask(x), do: x &&& (@max - 1)
  def mask(x, bits), do: x &&& ((1 <<< bits) - 1)
end
