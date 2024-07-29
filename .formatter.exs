# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,priv}/**/*.{ex,exs}"],
  import_deps: [:ecto, :ecto_sql, :ash, :ash_postgres, :ash_mysql],
]
