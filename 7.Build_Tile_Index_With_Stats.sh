#!/bin/bash

set -euo pipefail

cd lasinfo

## Process the PDAL info .json files into a CSV table
python3 ../pdal_info_to_csv.py vdelivery > a.csv 2> a.err

## See the output:
# ogrinfo -oo GEOM_POSSIBLE_NAMES=boundary a.csv a
# less a.err

## Convert the CSV table into a GeoPackage
ogr2ogr -f GPKG MN-3DEP-Index-With-Tile-Stats.gpkg -oo GEOM_POSSIBLE_NAMES=boundary -a_srs EPSG:4326 -nln tindex a.csv a
ogrinfo MN-3DEP-Index-With-Tile-Stats.gpkg -sql 'alter table tindex drop column boundary; vacuum;'

## See the output:
# ogrinfo MN-3DEP-Index-With-Tile-Stats.gpkg -sql "alter table tindex drop column boundary"
