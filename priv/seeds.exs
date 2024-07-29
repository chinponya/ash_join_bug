alias AshJoinBug.{PostgresRepo, MysqlRepo, Resources}

resources1 =
  for i <- 0..3 do
    %{
      id: Ash.UUID.generate(),
      resource2_id: Ash.UUID.generate(),
      value: "value-#{rem(i, 2)}"
    }
  end
  |> IO.inspect(label: :resources1)

resources2 =
  for resource <- resources1 do
    %{
      id: resource[:resource2_id],
      resource1_id: resource[:id],
      value: "other-#{resource[:value]}"
    }
  end
  |> IO.inspect(label: :resources2)

PostgresRepo.transaction(fn ->
  PostgresRepo.insert_all(Resources.Resource1PG, resources1)
  PostgresRepo.insert_all(Resources.Resource2PG, resources2)
end)

MysqlRepo.transaction(fn ->
  MysqlRepo.insert_all(Resources.Resource1Mysql, resources1)
  MysqlRepo.insert_all(Resources.Resource2Mysql, resources2)
end)
