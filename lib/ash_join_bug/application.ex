defmodule AshJoinBug.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshJoinBug.PostgresRepo,
      AshJoinBug.MysqlRepo
    ]

    opts = [strategy: :one_for_one, name: AshJoinBug.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
