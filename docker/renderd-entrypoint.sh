#!/usr/bin/env sh
set -eux

if [ ! -d /data/tiles/default ]; then
  mkdir --parents /data/tiles/default
  chown --recursive renderd:renderd /data
  chmod --recursive 775 /data
fi

if [ ! -f /data/extracts/region.osm.pbf ]; then
  mkdir --parents /data/extracts
  curl --location --progress-bar "${DOWNLOAD_PBF:-https://download.geofabrik.de/europe/germany/hamburg-latest.osm.pbf}" > /data/extracts/region.osm.pbf
  curl --location --progress-bar "${DOWNLOAD_POLY:-https://download.geofabrik.de/europe/germany/hamburg.poly}" > /data/extracts/region.poly
fi

if [ ! -f /data/renderd.conf ]; then
  cp /etc/renderd.conf /data/renderd.conf
  printf '\n[default]\nMAXZOOM=20\nTILEDIR=/data/tiles\nTILESIZE=256\nXML=/usr/share/openstreetmap-carto/mapnik.xml\n' >> /data/renderd.conf
  sed --in-place \
    --expression "s#font_dir=.*#font_dir=/usr/share/openstreetmap-carto/fonts#g" \
    --expression "s#socketname=.*#iphostname=0.0.0.0\nipport=7654#g" \
    --expression "s#tile_dir=.*#tile_dir=/data/tiles#g" \
    /data/renderd.conf
fi

if [ ! -f /data/planet-import-complete ]; then
  cd /usr/share/openstreetmap-carto

  osm2pgsql \
    --create \
    --hstore \
    --multi-geometry \
    --number-processes "$(nproc)" \
    --slim \
    --style openstreetmap-carto.style  \
    --tag-transform-script openstreetmap-carto.lua \
    /data/extracts/region.osm.pbf

  scripts/get-external-data.py \
    --cache \
    --no-update

  psql --file indexes.sql

  touch /data/planet-import-complete
fi

su --command "renderd --config /data/renderd.conf --foreground" --shell /usr/bin/sh renderd
