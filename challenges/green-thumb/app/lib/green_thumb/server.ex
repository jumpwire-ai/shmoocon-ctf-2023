defmodule GreenThumb.Server do
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
    timeout = Application.fetch_env!(:green_thumb, :timeout)
    transport.send(socket, "Enter your username: ")
    username = nil
    loop(username, socket, transport, timeout)
  end

  def loop(state, socket, transport, timeout) do
    case transport.recv(socket, 0, timeout) do
      {:ok, data} ->
        data = String.trim(data)

        case state do
          nil ->
            next = check_username(data)
            transport.send(socket, next)
            loop(data, socket, transport, timeout)

          username ->
            check_code(username, data, transport, socket)

            transport.send(socket, "Enter your username: ")
            loop(nil, socket, transport, timeout)
        end

      _ ->
        Logger.debug("Connection closed")
        :ok = transport.close(socket)
    end
  end

  defp check_username(username) do
    case GreenThumb.Secrets.get_id(username) do
      {:ok, id} ->
        "Enter the OTP for #{username} (#{id}): "

      _ ->
        # Delay the response to limit account creating
        :timer.sleep(:timer.seconds(1))
        qr = GreenThumb.qr_code(username)
        ["Hello #{username}! Here is your OTP code - do not lose it!\n", qr, "\n\nEnter an OTP code for validation: "]
    end
  end

  defp check_code(username, code, transport, socket) do
    if GreenThumb.valid?(username, code) do
      transport.send(socket, "Correct!\n")
      if username == "root" do
        flag = Application.get_env(:green_thumb, :flag)
        transport.send(socket, flag <> "\n")
        :ok = transport.close(socket)
      end

    else
      transport.send(socket, "WRONG!\n")
    end
  end
end
