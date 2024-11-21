#!/bin/bash
set -euo pipefail

pipeline="$1"
dir="$2"
j="$3"
outdir="$4"

outjson="$outdir"/"$dir/$(basename $j).json"
tmplas="$outdir"/"$dir/$(basename $j).las"
pdal pipeline --readers.las.filename="$j" --writers.las.filename="$tmplas" "$pipeline"
pdal info --all --enumerate Classification "$tmplas" > "$outjson"
rm "$tmplas"
