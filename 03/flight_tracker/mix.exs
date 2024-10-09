defmodule FlightTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :flight_tracker,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FlightTracker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cloudevents, "~> 0.6.1"},
      {:gen_stage, "~> 1.2"},
      {:uuid, "~> 1.1"}
    ]
  end
end
