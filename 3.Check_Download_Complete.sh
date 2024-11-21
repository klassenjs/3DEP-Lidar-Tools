#!/bin/bash

# Check download complete
for i in `find -name 0_file_download_links.txt | sort` ; do
	shortname="${i%%/0_file_download_links.txt}"
	shortname="${shortname##./vdelivery/Datasets/Staged/Elevation/}"
	echo \
		$(cat $i | wc -l) \
		$(find ${i/0_file_download_links.txt/LAZ} -maxdepth 1 -type f 2>/dev/null | wc -l) \
		${shortname}
done
