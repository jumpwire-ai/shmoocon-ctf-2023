defmodule GreenThumb.MixProject do
  use Mix.Project

  def project do
    [
      app: :green_thumb,
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
      mod: {GreenThumb.Application, []}
    ]
  end

  defp deps do
    [
      {:eqrcode, "~> 0.1.10"},
      {:nimble_totp, "~> 0.2.0"},
      {:ranch, "~> 2.1"},
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
