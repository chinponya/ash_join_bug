defmodule AshJoinBug do
  use Ash.Domain

  resources do
    resource AshJoinBug.Resources.Resource1PG
    resource AshJoinBug.Resources.Resource2PG
    resource AshJoinBug.Resources.Resource1Mysql
    resource AshJoinBug.Resources.Resource2Mysql
  end
end
