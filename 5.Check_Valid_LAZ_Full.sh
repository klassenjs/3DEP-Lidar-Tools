#!/bin/bash

# Check files valid (full)
for i in `find vdelivery/Datasets/Staged/Elevation/LPC/Projects -name 0_file_download_links.txt` ; do
   dir=${i/0_file_download_links.txt/LAZ}
   outdir="$(pwd)/lasinfo"
   echo "Checking $dir"
   (
     set -eu
     cd $dir
     mkdir -p /scratch/lasinfo/"$dir" bad
     for j in *.laz ; do
        outjson="$outdir"/"$dir/$(basename $j).json"
        tmplas="$outdir"/"$dir/$(basename $j).las"
        if [ ! -e "$outjson" ] ; then
            sem -j+0 pdal info --all --enumerate Classification $j ">" /scratch/lasinfo/"$dir/$(basename $j).json" "2>&1" "||" echo mv -v $j bad
        fi
     done
     rmdir --ignore-fail-on-non-empty bad
   )
done
sem --wait


# Check files valid (and fix malformed projections causing EPSG:4326 metadata to not be generated)
for i in `find vdelivery/Datasets/Staged/Elevation/LPC/Projects -name 0_file_download_links.txt` ; do
   dir=${i/0_file_download_links.txt/LAZ}
   here="$(pwd)"
   outdir="$(pwd)/lasinfo"
   pipeline="$(pwd)/fix_projection.json"
   echo "Checking $dir"
   (
     set -eu
     cd $dir
     for j in *.laz ; do
        outjson="$outdir"/"$dir/$(basename $j).json"
        tmplas="$outdir"/"$dir/$(basename $j).las"
        if [ ! -e "$outjson" ] ; then
            echo $j
            sem -j8 "$here"/fix_projection.sh "$pipeline" "$dir" "$j" "$outdir"
        fi
     done
   )
done
sem --wait

# Remove invalid JSONs
for i in $(find lasinfo -name '*.json') ; do jq . $i > /dev/null || rm -v $i ; done
