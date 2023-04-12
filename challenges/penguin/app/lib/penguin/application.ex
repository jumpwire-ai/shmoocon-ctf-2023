defmodule Penguin.Application do
  use Application

  @impl true
  def start(_type, _args) do
    opts = Application.get_env(:penguin, :tcp)

    children = [
      {Penguin.Listener, opts},
    ]

    opts = [strategy: :one_for_one, name: Penguin.Application]
    Supervisor.start_link(children, opts)
  end
end
