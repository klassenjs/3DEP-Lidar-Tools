#!/bin/bash
RED='\033[1;31m'
NOR='\033[0m'

# Check files valid (full) and generate metadata JSONs for 7.Build_Tile_Index_With_Stats.sh
for i in `find vdelivery/Datasets/Staged/Elevation/LPC/Projects/"$1" -name 0_file_download_links.txt` ; do
   here="$(pwd)"
   dir="${i/0_file_download_links.txt/LAZ}"
   outdir="$(pwd)/lasinfo"
   echo "Checking $dir"

   # MN_RedRiver_3_D23 and MN_RedRiver_4_D23 have correct UTM15 EPSG codes and CRS names, but the values
   # for longitude, etc. in the WKT are for UTM14.  PDAL prioritizes the contents of the WKT over the names.
   # This forces the projection to be correct for these two collects.
   fix_projection="$here/fix_projection.json"
   if [ $dir == "vdelivery/Datasets/Staged/Elevation/LPC/Projects/MN_RedRiver_D23/MN_RedRiver_3_D23/LAZ" ] ; then
     echo "Forcing projection to UTM15"
     fix_projection="$here/fix_projection2.json"
   fi
   if [ $dir == "vdelivery/Datasets/Staged/Elevation/LPC/Projects/MN_RedRiver_D23/MN_RedRiver_4_D23/LAZ" ] ; then
     echo "Forcing projection to UTM15"
     fix_projection="$here/fix_projection2.json"
   fi
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
            sem -j+0 pdal pipeline "$fix_projection" --readers.las.filename="$j" --metadata /dev/stdout ">" "$outjson" "2>&1" "||" mv -v "$j" bad
        fi
     done
     rmdir --ignore-fail-on-non-empty bad
   )
done
sem --wait

# Remove invalid JSONs
echo "Searching and removing corrupt JSON files."
echo "If this list is not empty, run this script again:"
echo -en "${RED}"
for i in $(find lasinfo/vdelivery/Datasets/Staged/Elevation/LPC/Projects/"$1" -name '*.json') ; do
  # File is not "blank", and is readable as JSON (by jq), otherwise delete it.
  grep -qF '"stages":' "$i" && \
    jq .stages "$i" > /dev/null || rm -v "$i"
done

echo -en "${NOR}"
echo "Done."
