defmodule GreenThumb.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = Application.get_env(:green_thumb, :tcp)

    children = [
      GreenThumb.Random,
      GreenThumb.Secrets,
      {Task, &GreenThumb.startup/0},
      {GreenThumb.Server, opts},
    ]

    opts = [strategy: :one_for_one, name: GreenThumb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
