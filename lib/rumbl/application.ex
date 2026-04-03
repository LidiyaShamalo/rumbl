defmodule Rumbl.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RumblWeb.Telemetry,
      Rumbl.Repo,
      {DNSCluster, query: Application.get_env(:rumbl, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Rumbl.PubSub},
      {InfoSys.Supervisor, name: InfoSys.Supervisor},
      RumblWeb.Presence,
      RumblWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    RumblWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
