defmodule AshJoinBug.Resources.Resource1Mysql do
  use Ash.Resource,
    domain: AshJoinBug,
    data_layer: AshMysql.DataLayer

  mysql do
    repo AshJoinBug.MysqlRepo
    table "resource1mysql"
  end

  code_interface do
    domain AshJoinBug
    define :read
    define :destroy
    define :create
    define :update
    define :read_with_relationship, action: :with_relationship
    define :read_with_external_relationship, action: :with_external_relationship
    define :read_with_filtered_relationship, action: :with_filtered_relationship
    define :read_with_filtered_external_relationship, action: :with_filtered_external_relationship
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :with_relationship do
      prepare build(load: [:resource2mysql_belongs])
    end

    read :with_external_relationship do
      prepare build(load: [:resource2pg_belongs])
    end

    read :with_filtered_relationship do
      prepare build(load: [:resource2mysql_belongs])
      filter expr(resource2mysql_belongs.value == "other-value-0")
    end

    read :with_filtered_external_relationship do
      prepare build(load: [:resource2pg_belongs])
      filter expr(resource2pg_belongs.value == "other-value-0")
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :resource2_id, :uuid
    attribute :value, :string
  end

  relationships do
    belongs_to :resource2pg_belongs, AshJoinBug.Resources.Resource2PG do
      source_attribute :resource2_id
    end

    has_one :resource2pg_has, AshJoinBug.Resources.Resource2PG do
      destination_attribute :resource1_id
    end

    belongs_to :resource2mysql_belongs, AshJoinBug.Resources.Resource2Mysql do
      source_attribute :resource2_id
    end

    has_one :resource2mysql_has, AshJoinBug.Resources.Resource2Mysql do
      destination_attribute :resource1_id
    end
  end
end
