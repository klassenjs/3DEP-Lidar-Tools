#!/bin/bash

# Check files valid (full) and generate metadata JSONs for 7.Build_Tile_Index_With_Stats.sh
for i in `find vdelivery/Datasets/Staged/Elevation/LPC/Projects/$1 -name 0_file_download_links.txt` ; do
   here="$(pwd)"
   dir=${i/0_file_download_links.txt/LAZ}
   outdir="$(pwd)/lasinfo"
   echo "Checking $dir"
   (
     set -eu
     cd $dir
     mkdir -p "$outdir"/"$dir" bad
     for j in *.laz ; do
        outjson="$outdir"/"$dir/$(basename $j).json"
        if [ ! -e "$outjson" ] ; then
            # What it normally should be:
            #  sem -j+0 pdal info --all --enumerate Classification $j ">" "$outjson" "2>&1" "||" echo mv -v $j bad
            #
            # Need this because some LAZ files have malformed CRS and causes PDAL to not emit the EPSG:4326 BBOX:
            # Note: this does slightly change the metadata output structure.
            #
            sem -j+0 pdal pipeline "$here"/fix_projection.json --readers.las.filename="$j" --metadata /dev/stdout ">" "$outjson" "2>&1" "||" mv -v $j bad
        fi
     done
     rmdir --ignore-fail-on-non-empty bad
   )
done
sem --wait

# Remove invalid JSONs
for i in $(find lasinfo/vdelivery/Datasets/Staged/Elevation/LPC/Projects/$1 -name '*.json') ; do jq . $i > /dev/null || rm -v $i ; done
