defmodule AshJoinBug.Resources.Resource2PG do
  use Ash.Resource,
    domain: AshJoinBug,
    data_layer: AshPostgres.DataLayer

  postgres do
    repo AshJoinBug.PostgresRepo
    table "resource2pg"
  end

  code_interface do
    domain AshJoinBug
    define :read
    define :destroy
    define :create
    define :update
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :resource1_id, :uuid
    attribute :value, :string
  end

  relationships do
    belongs_to :resource1pg_belongs, AshJoinBug.Resources.Resource1PG do
      source_attribute :resource1_id
    end

    has_one :resource1pg_has, AshJoinBug.Resources.Resource1PG do
      destination_attribute :resource2_id
    end

    belongs_to :resource1mysql_belongs, AshJoinBug.Resources.Resource1Mysql do
      source_attribute :resource1_id
    end

    has_one :resource1mysql_has, AshJoinBug.Resources.Resource1Mysql do
      destination_attribute :resource2_id
    end
  end
end
