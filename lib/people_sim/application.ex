defmodule PeopleSim.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PeopleSimWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:people_sim, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PeopleSim.PubSub},
      # Start a worker by calling: PeopleSim.Worker.start_link(arg)
      # {PeopleSim.Worker, arg},
      # Start to serve requests, typically the last entry
      PeopleSimWeb.Endpoint,
      PeopleSim.SimulationSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PeopleSim.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PeopleSimWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
