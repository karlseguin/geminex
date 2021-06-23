defmodule Geminex.MixProject do
	use Mix.Project

	def project do
		[
			app: :geminex,
			deps: deps(),
			version: "0.1.0",
			elixir: "~> 1.12",
			elixirc_paths: paths(Mix.env),
			start_permanent: Mix.env() == :prod,
		]
	end

	defp paths(:test), do: paths(:prod) ++ ["test/support", "test/fake"]
	defp paths(_), do: ["lib"]

	def application do
		[
			extra_applications: [:logger, :ssl]
		]
	end

	defp deps do
		[
			{:telemetry, "~> 0.4.3"}
		]
	end
end
