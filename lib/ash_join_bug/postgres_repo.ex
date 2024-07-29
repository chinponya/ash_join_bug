defmodule AshJoinBug.PostgresRepo do
  use AshPostgres.Repo, otp_app: :ash_join_bug

  def installed_extensions do
    ["ash-functions"]
  end
end
