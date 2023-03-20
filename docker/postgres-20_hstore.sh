#!/bin/bash
set -eu

echo "Loading hstore extension into ${POSTGRES_DB}"
psql --command "CREATE EXTENSION IF NOT EXISTS hstore;" --dbname "${POSTGRES_DB}"
