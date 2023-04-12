defmodule Notary.MixProject do
  use Mix.Project

  def project do
    [
      app: :notary,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      default_release: "chal",
      default_task: "phx.server",
    ]
  end

  def application do
    [
      mod: {Notary.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.6.15"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:joken, "~> 2.5"},
      {:guardian, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end

  defp releases() do
    [
      chal: [
         include_executables_for: [:unix],
      ]
    ]
  end
end
