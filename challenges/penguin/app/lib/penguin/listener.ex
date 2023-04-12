defmodule Penguin.Listener do
  require Logger

  @behaviour :ranch_protocol

  def child_spec(opts) do
    Logger.info("Listening on port #{opts[:port]}")
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, __MODULE__, %{})
  end

  @impl :ranch_protocol
  def start_link(ref, transport, opts) do
    Logger.debug("New connection")
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [ref, transport, opts])}
  end

  def init(ref, transport, _opts) do
    {:ok, socket} = :ranch.handshake(ref)
    timeout = Application.fetch_env!(:penguin, :timeout)
    loop(socket, transport, timeout)
  end

  def loop(socket, transport, timeout) do
    case transport.recv(socket, 0, timeout) do
      {:ok, data} ->
        encrypted = data |> String.trim() |> Penguin.encrypt()
        transport.send(socket, encrypted <> "\n")
        loop(socket, transport, timeout)

      _ ->
        Logger.debug("Connection closed")
        :ok = transport.close(socket)
    end
  end
end
