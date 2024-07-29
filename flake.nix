{
  inputs = { nixpkgs.url = "nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      beam = pkgs.beam.packages.erlang_27;
      elixir = beam.elixir_1_17;
      elixir-ls = (beam.elixir-ls.override { inherit elixir; });
      mariadb = pkgs.mariadb;
      postgresql = pkgs.postgresql;

      setup-mariadb = pkgs.writeShellScriptBin "startmariadb" ''
        ${mariadb}/bin/mysql_install_db --datadir=$MYSQL_DATADIR --basedir=${mariadb} --pid-file=$MYSQL_PID_FILE
        ${mariadb}/bin/mysqld --datadir=$MYSQL_DATADIR --pid-file=$MYSQL_PID_FILE --socket=$MYSQL_UNIX_PORT &

        finish()
        {
          echo "Shutting down the database..."
          ${mariadb}/bin/mysqladmin --socket=$MYSQL_UNIX_PORT -ppassword shutdown
          kill $MYSQL_PID
          wait $MYSQL_PID
        }

        trap finish SIGINT SIGTERM EXIT
      '';

      setup-postgresql = pkgs.writeShellScriptBin "startpostgresql" ''
        if [ ! -d "$PGHOST" ]; then
          mkdir -p $PGHOST
        fi

        if [ ! -d "$PGDATA" ]; then
          echo 'Initializing postgresql database cluster...'
          ${postgresql}/bin/initdb "$PGDATA" --auth=trust --no-locale --encoding=UTF8
        fi

        ${postgresql}/bin/postgres -k "$PGHOST"
      '';
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ elixir elixir-ls setup-mariadb setup-postgresql ];
        shellHook = ''
          mkdir -p .state/mix .state/hex
          export MIX_HOME=$PWD/.state/mix
          export HEX_HOME=$PWD/.state/hex
          export PATH=$MIX_HOME/bin:$MIX_HOME/escripts:$HEX_HOME/bin:$PATH
          mix local.hex --if-missing --force
          export LANG=en_US.UTF-8
          export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.state\"' -kernel shell_history_file_bytes 1024000"

          export MYSQL_HOME=$PWD/.state/mariadb
          export MYSQL_DATADIR=$MYSQL_HOME/data
          export MYSQL_UNIX_PORT=$MYSQL_HOME/mysql.sock
          export MYSQL_PID_FILE=$MYSQL_HOME/mysql.pid

          export PGDATA=$PWD/.state/postgres/data
          export PGHOST=$PWD/.state/postgres
        '';
      };
    };
}
