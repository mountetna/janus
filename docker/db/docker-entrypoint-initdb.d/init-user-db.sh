#!/bin/bash
set -e


# Add any other roles / databases here
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE janus_test;
  CREATE DATABASE janus_development;
  GRANT ALL PRIVILEGES ON DATABASE janus_test TO $POSTGRES_USER;
  GRANT ALL PRIVILEGES ON DATABASE janus_development TO $POSTGRES_USER;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/example_seed.sql
