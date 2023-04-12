defmodule Penguin.MixProject do
  use Mix.Project

  def project do
    [
      app: :penguin,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      default_release: "chal",
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Penguin.Application, []}
    ]
  end

  defp deps do
    [
      {:ranch, "~> 2.1.0"},
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
