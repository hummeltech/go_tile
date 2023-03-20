#!/bin/bash
set -eu

# From https://github.com/openstreetmap/chef/blob/2170e9c9897b544b7188cf3fd4cea8498121ff7f/roles/tile.rb#LL39-L53C51
OSM_OPTIONS=(
'autovacuum_analyze_scale_factor = "0.02"'
'autovacuum_vacuum_scale_factor = "0.05"'
'commit_delay = "10000"'
'jit = "off"'
'max_connections = "250"'
'max_parallel_workers_per_gather = "0"'
'max_wal_senders = "0"'
'max_wal_size = "2880MB"'
'random_page_cost = "1.1"'
'temp_buffers = "32MB"'
'track_activity_query_size = "16384"'
'wal_buffers = "1024kB"'
'wal_level = "minimal"'
'wal_writer_delay = "500ms"'
'work_mem = "128MB"'
)

ADDITIONAL_OPTIONS=(
'autovacuum_work_mem = "1GB"'
'checkpoint_completion_target = "0.9"'
'checkpoint_timeout = "60min"'
'maintenance_work_mem = "1GB"'
'shared_buffers = "2GB"'
)

UNSAFE_OPTIONS=(
'fsync = "off"'
'full_page_writes = "off"'
'synchronous_commit = "off"'
)

echo "Tuning OSM PostgreSQL server configuration options"
for OSM_OPTION in "${OSM_OPTIONS[@]}"
do
    psql --command "ALTER SYSTEM SET ${OSM_OPTION};"
done

echo "Tuning additional PostgreSQL server configuration options"
for ADDITIONAL_OPTION in "${ADDITIONAL_OPTIONS[@]}"
do
    psql --command "ALTER SYSTEM SET ${ADDITIONAL_OPTION};"
done

echo "Tuning unsafe PostgreSQL server configuration options"
for UNSAFE_OPTION in "${UNSAFE_OPTIONS[@]}"
do
    psql --command "ALTER SYSTEM SET ${UNSAFE_OPTION};"
done