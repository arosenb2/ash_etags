defmodule Etags.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Automatically provide seed data.
    # Normally this is done outside of the application life, but since we are using
    # ETS, it needs to happen at application start.
    IO.puts("Seeding in-memory database...")

    1..10
    |> Enum.map(fn num -> Etags.Example.Foo.create!(%{title: "Example - #{num}"}) end)

    IO.puts("Initial data is seeded.")

    children = [
      # Start the Telemetry supervisor
      EtagsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Etags.PubSub},
      # Start the Endpoint (http/https)
      EtagsWeb.Endpoint
      # Start a worker by calling: Etags.Worker.start_link(arg)
      # {Etags.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Etags.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EtagsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
