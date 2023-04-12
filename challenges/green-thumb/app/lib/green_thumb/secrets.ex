defmodule GreenThumb.Secrets do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Update the state with a new user's secret. Do nothing if that user already has a secret stored.
  """
  def put_new(key, secret) do
    Agent.get_and_update(__MODULE__, fn state ->
      id = map_size(state) + 1
      data = {id, secret}
      {state, Map.put_new(state, key, data)}
    end)
  end

  def fetch(key) do
    Agent.get(__MODULE__, fn state ->
      Map.fetch(state, key)
    end)
  end

  def get_id(key) do
    Agent.get(__MODULE__, fn state ->
      case Map.fetch(state, key) do
        {:ok, {id, _}} -> {:ok, id}
        _ -> :error
      end
    end)
  end
end
