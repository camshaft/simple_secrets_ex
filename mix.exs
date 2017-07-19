defmodule SimpleSecretsEx.Mixfile do
  use Mix.Project

  def project do
    [app: :simple_secrets,
     description: "A simple, opinionated library for encrypting small packets of data securely.",
     version: "1.0.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [ {:msgpax, "~> 1.0.0"},
      {:pkcs7, "~> 1.0.2"} ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/camshaft/simple_secrets_ex"}]
  end
end
