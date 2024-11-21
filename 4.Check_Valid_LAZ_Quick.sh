#!/bin/bash

# Check files valid (quick)
for i in `find vdelivery/Datasets/Staged/Elevation/LPC/Projects -name 0_file_download_links.txt` ; do
	dir=${i/0_file_download_links.txt/LAZ}
	echo "Checking $dir"
	(
		set -eu
		cd $dir
		mkdir -p bad
		for j in *laz ; do
			pdal info --metadata $j > /dev/null 2>&1 || mv -v $j bad
		done
		rmdir --ignore-fail-on-non-empty bad
	)
done
