FROM postgres:10

COPY docker/db/docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/
COPY db/example_seed.sql /docker-entrypoint-initdb.d/
