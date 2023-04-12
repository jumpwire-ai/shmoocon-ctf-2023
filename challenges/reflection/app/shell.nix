with import <nixpkgs> {};
mkShell {
  buildInputs = [
    postgresql_15
    elixir_1_13
    nodejs-18_x
  ];

  PGDATA = "${toString ./.}/.pgdata";

  # Post Shell Hook
  shellHook = ''
    echo "Using ${postgresql_15.name}."

    # Setup: other env variables
    export PGHOST="$PGDATA"

    # Setup: DB
    if [ ! -d $PGDATA ]; then
       echo -n postgres > pgpass
       pg_ctl initdb -o "-U postgres --pwfile=pgpass -A md5"
       rm pgpass
    fi

    function cleanup() {
             echo 'Stopping hasura...'
             docker rm -f reflection-hasura

             echo 'Stopping postgres...'
             pg_ctl stop
    }
    # Start postgres and stop it when exiting the shell.
    pg_ctl -o "-k $PGDATA" start && trap cleanup EXIT

    alias pg="psql postgresql://postgres:postgres@localhost:5432/reflection_dev"

    docker run -d --name reflection-hasura -p 8080:8080 -e HASURA_GRAPHQL_DATABASE_URL=postgres://postgres:postgres@host.docker.internal:5432/reflection_dev -e HASURA_GRAPHQL_ENABLE_CONSOLE=true -e HASURA_GRAPHQL_ADMIN_SECRET=secret hasura/graphql-engine
  '';
}
