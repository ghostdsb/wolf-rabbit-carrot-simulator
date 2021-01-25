defmodule WolfRabbitCarrot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WolfRabbitCarrotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WolfRabbitCarrot.PubSub},
      # Start the Endpoint (http/https)
      WolfRabbitCarrotWeb.Endpoint,
      # Start a worker by calling: WolfRabbitCarrot.Worker.start_link(arg)
      # {WolfRabbitCarrot.Worker, arg}
      {DynamicSupervisor, strategy: :one_for_one, name: WolfRabbitCarrot.WolfSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: WolfRabbitCarrot.RabbitSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: WolfRabbitCarrot.CarrotSupervisor},
      {WolfRabbitCarrot.WorldServer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WolfRabbitCarrot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WolfRabbitCarrotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
