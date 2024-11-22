#!/bin/bash
RED='\033[1;31m'
NOR='\033[0m'

# Check download complete
for i in `find -name 0_file_download_links.txt | sort` ; do
	shortname="${i%%/0_file_download_links.txt}"
	shortname="${shortname##./vdelivery/Datasets/Staged/Elevation/}"
	foldername=LAZ
	if [[ $shortname = OPR* ]] ; then
		foldername=TIFF
	fi
	expected=$(cat $i | wc -l)
	found=$(find ${i/0_file_download_links.txt/$foldername} -maxdepth 1 -type f 2>/dev/null | wc -l)
	col="${NOR}"
	if [[ $expected != $found ]] ; then
		col="${RED}"
	fi
	echo -e \
		${col} \
		${expected} \
		${found} \
		${shortname} \
		${NOR}
done
