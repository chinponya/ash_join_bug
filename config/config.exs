import Config

config :ash_join_bug,
    ash_domains: [AshJoinBug],
    ecto_repos: [AshJoinBug.PostgresRepo, AshJoinBug.MysqlRepo]

config :ash_join_bug, AshJoinBug.PostgresRepo,
    database: "ash_join_bug",
    socket_dir: ".state/postgres"

config :ash_join_bug, AshJoinBug.MysqlRepo,
    database: "ash_join_bug",
    socket: ".state/mariadb/mysql.sock"
